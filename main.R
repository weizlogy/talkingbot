# locale to ja_JP
# Sys.setlocale("LC_ALL", '.932')

# Install package if missing.
.libPaths(c(.libPaths(), "./packages"))

for (package in c('plumber', 'rtweet', 'tidytext', 'stringr', 'tibble', 'dplyr', 'markovchain')) {
  if (!require(package, character.only = T, lib = './packages')) {
    install.packages(package, lib = './packages')
    library(package, character.only = T, lib = './packages')
  }
}

if (!require("RMeCab", lib = './packages')) {
  install.packages("RMeCab", repos = "http://rmecab.jp/R", type = "source", lib = './packages')
  library("RMeCab")
}

# reading twitter access information
twitter_info <- read.csv("./twitter_info.csv", header = F, stringsAsFactors = F)

# access token method: create token and save it as an environment variable

token <- create_token(
  app = "Talking with Alpaca",
  consumer_key = twitter_info[1, 1],
  consumer_secret = twitter_info[1, 2],
  access_token = twitter_info[1, 3],
  access_secret = twitter_info[1, 4])

# Running server
#  -> https://www.rplumber.io/
r <- plumb('plumber.R')
r$run(port=8000)
