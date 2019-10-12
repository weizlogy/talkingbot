print("textextractor.R Loaded.")

get_my_tweets_terms <- function(max = 1000) {
  return(normalize_tweet(get_timeline('twilightalpaca', n = as.numeric(max))))
}

search_tweets_by_query <- function(query) {
  return(normalize_tweet(search_tweets(q = query, n = 50, include_rts = F, lang = "ja")))
}

normalize_tweet <- function(raw) {
  raw_filtered <- dplyr::filter(
    raw, is.na(retweet_status_id) & !str_detect(source, "Talking with Alpaca"))

  # URLと@だけ消す。ほかの不要文字は後で調整
  filtered_modifier <-
    dplyr::mutate(raw_filtered, text = purrr::map(text, ~ {
      str_replace_all(.x, "(https?://t.co/[[:alnum:]]+)|@.+? ", "")
    }))
  
  # text抽出(list) からの改行分割してデータフレームに戻す
  text <- filtered_modifier$text %>% str_split(pattern = "\n") %>% unlist %>% paste("BOS", .) %>% enframe(name = "name", value = "text")
  
  ngram3 <- docDF(text, type = 1, N = 3, nDF = 1, column = "text", Genkei = 1)

  print(head(text))

  ngram3_modifier <- dplyr::select(ngram3, N2, N3)

  return(ngram3_modifier)
}

after_adjusting_text <- function(text) {
  newtext <- gsub(",", " ", text, fixed = T)
  newtext <- gsub('"', "", newtext, fixed = T)
  newtext <- gsub("#", "♯", newtext, fixed = T)
  newtext <- gsub("[.+?]", "", newtext, fixed = F)
  return(newtext)
}

proofreading <- function(text) {
  a3rt_pf_ep <- paste(a3rt_pf_ep, '&sentence=', text, sep="") %>% URLencode
  a3rt_body <- GET(a3rt_pf_ep) %>% content('text') %>% fromJSON(flatten = T)

  sentence <- a3rt_body['inputSentence']$inputSentence

  print(sentence)

  if (a3rt_body['status']$status == 1) {
    f <- function(x) {
      # filterでデータ行が全部消えると落ちるので(こんなデータになる)
      # [1] alerts.pos         alerts.word        alerts.score       alerts.suggestions
      # <0 rows> (or 0-length row.names)
      if (x[1] == F || x$alerts.word == "♯") {
        return()
      }
      str_sub(sentence, start = x$alerts.pos + 1, end = x$alerts.pos + 1) <- x$alerts.suggestions[1]
      sentence <<- sentence
    }
    a3rt_body['alerts'] %>% as.data.frame %>%
      dplyr::filter(alerts.score > 0.9) %>% dplyr::arrange(alerts.score) %>% apply(1, f)

    print(sentence)
  }
  return(sentence)
}
