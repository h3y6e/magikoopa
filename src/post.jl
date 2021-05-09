"""
    oauthheader(url::String,
        options::Dict,
        oauth_consumer_secret::String,
        oauth_token_secret::String
    ) -> String

Build OAuth header. OAuth version is OAuth 1.0a.
"""
function oauthheader(url::String, options::Dict, oauth_consumer_secret::String, oauth_token_secret::String)
    options["oauth_nonce"] = randstring(32)
    options["oauth_signature_method"] = "HMAC-SHA1"
    options["oauth_timestamp"] = round(Int, time()) |> string
    options["oauth_version"] = "1.0"
    # Creating the signature base string
    parameterstring = join(["$key=$(HTTP.escapeuri(options[key]))" for key in sort!(collect(keys(options)))], "&")
    signaturebasestring = "POST&$(HTTP.escapeuri(url))&$(HTTP.escapeuri(parameterstring))"
    # Getting a signing key
    signingkey = "$oauth_consumer_secret&$oauth_token_secret"
    oauth_signature = digest(MD_SHA1, signaturebasestring, signingkey) |> base64encode |> HTTP.escapeuri
    return "OAuth " *
        "oauth_consumer_key=\"$(options["oauth_consumer_key"])\", " *
        "oauth_nonce=\"$(options["oauth_nonce"])\", " *
        "oauth_signature=\"$oauth_signature\", " *
        "oauth_signature_method=\"$(options["oauth_signature_method"])\", " *
        "oauth_timestamp=\"$(options["oauth_timestamp"])\", " *
        "oauth_token=\"$(options["oauth_token"])\", " *
        "oauth_version=\"$(options["oauth_version"])\""
end

"""
    post(tweet::String) -> String

Post a tweet using Twitter API v1.1.
"""
function post(tweet::String)
    # use Twitter API v1.1
    url = "https://api.twitter.com/1.1/statuses/update.json"
    options = Dict{String,String}(
        "oauth_consumer_key" => ENV["API_KEY"],
        "oauth_token" => ENV["ACCESS_TOKEN"],
        "status" => tweet
    )
    headers = [
        "Content-Type" => "application/x-www-form-urlencoded",
        "Authorization" => oauthheader(url, options, ENV["API_KEY_SECRET"], ENV["ACCESS_TOKEN_SECRET"]),
        "Accept" => "*/*"
    ]
    r = HTTP.post(url, headers, "status=$(HTTP.escapeuri(tweet))")
    return tweet
end