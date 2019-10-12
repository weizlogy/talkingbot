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

  text <-
    paste(markovchainSequence(n = as.numeric(n), markovchain=fit$estimate, include.t0 = F, t0 = "BOS"), collapse = "") %>%
    after_adjusting_text %>%
    proofreading

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

  text <-
    paste(markovchainSequence(n = as.numeric(n), markovchain=fit$estimate, include.t0 = T), collapse = "") %>%
    after_adjusting_text %>%
    proofreading

  if (as.logical(p)) {
    post_tweet(status = str_interp("@tos ${t} >> ${text}"))
  }

  paste0(text)
}
