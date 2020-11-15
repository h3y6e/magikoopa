module Magikoopa

using DataFrames
using CSV
using DotEnv
using Twitter
using ProgressMeter
using Statistics
using StatsPlots

export get_followers_df, save_csv

DotEnv.config()
twitterauth(
  ENV["API_KEY"],
  ENV["API_SECRET_KEY"],
  ENV["ACCESS_TOKEN"],
  ENV["ACCESS_TOKEN_SECRET"],
)

function get_all_followers_ids(screen_name)
  cursor = -1
  followers_ids = []
  while true
    followers = get_followers_ids(screen_name = screen_name, cursor = cursor)
    append!(followers_ids, followers["ids"])
    if followers["next_cursor"] == 0
      break
    else
      cursor = followers["next_cursor"]
    end
  end
  return followers_ids
end

function get_followers_df(target_followers_ids)
  target_followers_count = length(target_followers_ids)
  df = DataFrame(
    ScreenName = [],
    FollowersCount = [],
    FriendsCount = [],
    Ratio = [],
    Influence = [],
  )
  for idx = 1:target_followers_count÷100+min(target_followers_count % 100, 1)
    user_ids_str = join(
      target_followers_ids[100*(idx-1)+1:min(
        100 * idx,
        target_followers_count,
      )],
      ",",
    )
    users_lookup = get_users_lookup(user_id = user_ids_str)
    users_lookup_count = length(users_lookup)
    screen_name = [users_lookup[i].screen_name for i = 1:users_lookup_count]
    followers_count =
      [users_lookup[i].followers_count for i = 1:users_lookup_count]
    friends_count = [users_lookup[i].friends_count for i = 1:users_lookup_count]
    append!(df.ScreenName, screen_name)
    append!(df.FollowersCount, followers_count)
    append!(df.FriendsCount, friends_count)
    append!(df.Ratio, followers_count ./ friends_count)
    append!(df.Influence, followers_count .^ 2 ./ friends_count)
    sleep(1)
  end
  sort!(df, [:Influence], rev = true)
  return df
end

function save_csv(target_screen_name)
  df = get_followers_df(target_screen_name)
  CSV.write("$target_screen_name.csv", df)
end



end

function get_engagement(target_screen_name; count = 200, coef = 2)
  target_timeline = get_user_timeline(
    screen_name = target_screen_name,
    count = count,
    trim_user = true,
    exclude_replies = true,
    include_rts = false,
  )
  return mean([
    coef * target_timeline[i].retweet_count + target_timeline[i].favorite_count
    for i = 1:length(target_timeline)
  ])
end

get_engagement("5ebec")
