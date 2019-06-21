# locale to ja_JP
# Sys.setlocale("LC_ALL", '.932')

# Install package if missing.
.libPaths(c(.libPaths(), "./packages"))

for (package in c('plumber', 'rtweet', 'tidytext', 'stringr', 'tibble', 'dplyr', 'markovchain', 'httr', 'jsonlite')) {
  if (!require(package, character.only = T, lib = './packages', warn.conflicts = F)) {
    install.packages(package, lib = './packages')
    library(package, character.only = T, lib = './packages')
  }
}

if (!require("RMeCab", lib = './packages')) {
  install.packages("RMeCab", repos = "http://rmecab.jp/R", type = "source", lib = './packages')
  library("RMeCab")
}

# Loading self definitions.
source("./textextractor.R")

# reading twitter access information
twitter_info <- read.csv("./twitter_info.csv", header = F, stringsAsFactors = F)

# access token method: create token and save it as an environment variable
token <- create_token(
  app = "Talking with Alpaca",
  consumer_key = twitter_info[1, 1],
  consumer_secret = twitter_info[1, 2],
  access_token = twitter_info[1, 3],
  access_secret = twitter_info[1, 4])

# reading A3RT access information
a3rt_info <- read.csv("./a3rt_info.csv", header = F, stringsAsFactors = F)

# create ProfreadingAPI endpoint
a3rt_pf_ep <- paste('https://api.a3rt.recruit-tech.co.jp/proofreading/v2/typo?', 'apikey=', a3rt_info[1, 1], '&sensitivity=high', sep="")

# Running server
#  -> https://www.rplumber.io/
r <- plumb('plumber.R')
r$run(host="0.0.0.0", port=8000)
