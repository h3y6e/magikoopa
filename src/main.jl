using DotEnv
DotEnv.config()

using Twitter

twitterauth(ENV["API_KEY"], ENV["API_SECRET_KEY"], ENV["ACCESS_TOKEN"], ENV["ACCESS_TOKEN_SECRET"])
