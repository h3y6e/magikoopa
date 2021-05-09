"""
    searchtweets(query::String,
        start_time::DateTime,
        bearer_token::String
        [, next_token=""]
    ) -> HTTP.Response

Get tweets from `start_time` that match `query` using Twitter API v2.
"""
function searchtweets(query::String, start_time::DateTime, bearer_token::String, next_token = "")
    # use Twitter API v2
    base = "https://api.twitter.com/2/tweets/search/recent"
    url = base *
        "?query=$(HTTP.escapeuri(query))&" *
        "max_results=100&" *
        "tweet.fields=source&" *
        "start_time=$(start_time)Z" *
        "$(next_token == "" ? "" : "&next_token=$next_token")"
    headers = ["Authorization" => "Bearer $bearer_token"]
    r = HTTP.get(url, headers)
    return r
end

"""
    gather(username::String, start_time::DateTime) -> Vector{Any}

tweets of @`username` from `start_time` (excluding RTs).
"""
function gather(username::String, start_time::DateTime)
    query = "from:$username -is:retweet"
    next_token = ""
    data = Vector{Any}()
    while true
        r = searchtweets(query, start_time, ENV["BEARER_TOKEN"], next_token)
        body = JSON.parse(String(r.body))
        append!(data, body["data"])
        if haskey(body["meta"], "next_token")
            next_token = body["meta"]["next_token"]
        else
            break
        end
    end

    return data

end

"""
    exporttweet(start_time::DateTime) -> String

Export gathered tweets since `start_time`.
"""
function exporttweet(start_time::DateTime)
    newtweets = Dict{String,String}()
    for tweet in gather(ENV["USERNAME"], start_time)
        if (tweet["source"] != "magikoopa") && (tweet["source"] != "へいほぅ単位取得率bot")
            text = tweet["text"]
            println(text)
            push!(newtweets, tweet["id"] => text)
        end
    end
    # save to data/tweets/[n].json and remove duplicates
    tweetfile = readdir("data/tweets", join = true)[end]
    open(tweetfile, "r+") do io
        read(io, String) == "" && write(io, "{}")
        seekstart(io)
        tweets = JSON.parse(io)
        merge!(tweets, newtweets)
        seekstart(io)
        JSON.print(io, tweets, 0)
    end
    return tweetfile
end