# アルパカとお話できるやつ

## 基本

Twitterの投稿を形態素解析し、マルコフ連鎖モンテカルロ法にて文章を生成し、投稿します。

## 環境

- R(>= 3.5.0)で動きます。
- MeCab, openssl, curlのインストールが必要です。

## 実行

nohup Rscript main.R &

## エンドポイントへのアクセス

### 単純文章生成

curl -X POST -d "r=T" -d "p=T" -d "n=10" -d "m=100" http://localhost:8000/mcmc

- r
連鎖回数をランダムにするか？(T=する, F=しない)

- p
結果をTwitterに投稿するか？(T=する, F=しない)

- n
連鎖回数の指定(数値)

- m
Twitterの投稿抽出数の指定(数値)

### 返信文章生成

curl -X POST -d "r=T" -d "p=T" -d "n=10" -d t="こんにちは" http://localhost:8000/reply

r, p, n は同上です。

- t
返信元となる文章
