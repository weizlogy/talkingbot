#* 
#* @param n number of chains
#* @param r random chains
#* @param p post tweet
#* @post /predict
function(n = 5, r = F, p = F) {
  terms <- get_my_tweets_terms()

  fit <- markovchainFit(data = terms)

  if (as.logical(r)) {
    n <- sample(3:n, 1)
  }

  text <- paste(predict(object = fit$estimate, newdata = terms, n.ahead = as.numeric(n)), collapse = "")
  text <- paste(text, str_interp("(AUTO-PREDIC-${n})"))

  if (as.logical(p)) {
    post_tweet(status = text)
  }

  paste0(text)
}

#* 
#* @param n number of chains
#* @param r random chains
#* @param p post tweet
#* @post /mcmc
function(n = 5, r = F, p = F) {
  terms <- get_my_tweets_terms()

  fit <- markovchainFit(data = terms)

  if (as.logical(r)) {
    n <- sample(3:n, 1)
  }

  text <- paste(markovchainSequence(n = as.numeric(n), markovchain=fit$estimate, include.t0 = T), collapse = "")
  text <- paste(text, str_interp("(AUTO-MARKOV-${n})"))

  if (as.logical(p)) {
    post_tweet(status = text)
  }

  paste0(text)
}

get_my_tweets_terms <- function() {
  tweets1 <- get_timeline('twilightalpaca', n = 1000)

  tweets <- dplyr::filter(
    tweets1, is.na(retweet_status_id) & is.na(reply_to_status_id) & !str_detect(text, "AUTO-[PREDIC|MARKOV-]"))

  # tweetのテキスト抽出 > 要らない文字を消す > tibble形式 > dataframe形式 > めかぶ
  # 正規表現で除外
  #   半角カナ, パンクチュエーション, 全角記号, あるぱか, URL, ハッシュタグ
  test <- tweets$text %>%
    str_replace_all("[ｦ-ﾟ]|[[:punct:]]|[︰-＠]|[ξ.+?Ҙ]|(https?://t.co/[[:alnum:]]+)|(#.+? )", "") %>%
    enframe(name = NULL, value = "text") %>%
    as.data.frame %>% RMeCabDF %>% unlist %>% data.frame(., names(.))

  colnames(test) <- c("Morph", "POS")

  test <- dplyr::filter(test, POS != "記号")

  terms <- c(t(test["Morph"]))

  return(terms)
}

