module Magikoopa

# imports
import HTTP
import JSON

# usings
using Base64
using Dates
using MbedTLS
using PyCall
using Random

# includes
include("divide.jl")
include("generate.jl")
include("gather.jl")
include("post.jl")

"""
    updatemodel(starttime::DateTime)

Update models.
"""
function updatemodel(starttime::DateTime)
    tweetfile = exporttweet(starttime)
    corpusfile = readdir("data/corpora", join = true)[end]
    open(corpusfile, "r+") do io
        tweetjson = JSON.parsefile(tweetfile)
        tweet = join(values(tweetjson), "\n") |> preprocess |> divide
        write(io, tweet)
        modelfile = readdir("data/models", join = true)[end]
        generate(corpusfile, modelfile)
    end
    open(tweetfile, "r") do io
        if countlines(io) > 10000
            i = match(r"\d+", tweetfile).match
            index = string(parse(Int, i) + 1)
            touch(joinpath("data/tweets", index * ".json"))
            touch(joinpath("data/corpora", index * ".txt"))
            touch(joinpath("data/models", index * ".json"))
        end
    end
end

"""
    Magikoopa.run()

Add tweets from the previous day's midnight to Markov chain model and generate a sentence of 140 characters or less.
Then, tweet the generated text. Return this text.

# Examples
```julia-repl
julia> Magikoopa.run()
"TL見ながらなかなかエンジンのかからない車みたいに笑ってしまったので今月は生き延びれそう"
```
and tweet the sentence as shown in [this tweet](https://twitter.com/5ebec/status/1379450178915037186)
"""
function run()
    yesterday = DateTime(Date(now())) - Day(1)
    updatemodel(yesterday)
    return post(makesentence())
end

end # module