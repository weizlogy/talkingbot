#* 
#* @param n number of chains
#* @param r random chains
#* @param p post tweet
#* @param m max tweet samples
#* @post /mcmc
function(n = 5, r = F, p = F, m = 1000) {
  terms <- get_my_tweets_terms(m)

  fit <- markovchainFit(data = terms)

  if (as.logical(r)) {
    n <- sample(3:n, 1)
  }

  text <- paste(markovchainSequence(n = as.numeric(n), markovchain=fit$estimate, include.t0 = T), collapse = "")

  text <- after_adjusting_text(text)

  if (as.logical(p)) {
    post_tweet(status = text)
  }

  paste0(text)
}

#* 
#* @param n number of chains
#* @param r random chains
#* @param p post tweet
#* @param t text
#* @post /reply
function(n = 10, r = F, p = F, t = "") {
  terms <- search_tweets_by_query(t)

  fit <- markovchainFit(data = terms)

  if (as.logical(r)) {
    n <- sample(5:n, 1)
  }

  text <- paste(markovchainSequence(n = as.numeric(n), markovchain=fit$estimate, include.t0 = T), collapse = "")

  text <- after_adjusting_text(text)

  if (as.logical(p)) {
    post_tweet(status = str_interp("@tos ${t} >> ${text}"))
  }

  paste0(text)
}

get_my_tweets_terms <- function(max = 1000) {
  return(normalize_tweet(get_timeline('twilightalpaca', n = as.numeric(max))))
}

search_tweets_by_query <- function(query) {
  return(normalize_tweet(search_tweets(q = query, n = 100, include_rts = F, lang = "ja")))
}

normalize_tweet <- function(raw) {
  raw_filtered <- dplyr::filter(
    raw, is.na(retweet_status_id) & is.na(reply_to_status_id) & !str_detect(source, "Talking with Alpaca"))

  # URLと@だけ消す。ほかの不要文字は後で調整
  filtered_modifier <- dplyr::mutate(raw_filtered, text = purrr::map(
    text, ~ { str_replace_all(.x, "(https?://t.co/[[:alnum:]]+)|@", "") }))
  
  # text抽出(list) からの改行分割してデータフレームに戻す
  text <- filtered_modifier$text %>% str_split(pattern = "\n") %>% unlist %>% enframe(name = "name", value = "text")

  ngram3 <- docDF(text, type = 1, N = 3, nDF = 1, column = "text")

  ngram3_modifier <- dplyr::select(ngram3, starts_with("N"))

  return(ngram3_modifier)
}

after_adjusting_text <- function(text) {
  newtext <- gsub(",", " ", text, fixed = T)
  newtext <- gsub('"', "", newtext, fixed = T)
  newtext <- gsub("#", "♯", newtext, fixed = T)
  return(newtext)
}
