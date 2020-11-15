count = 100 # <= 100

followers = get_followers_list(count = count)
userids = [followers["users"][i]["id_str"] for i = 1:count]

lookups = get_friendships_lookup(user_id = join(userids, ","))

for idx = 1:count
    if lookups[idx]["connections"] == ["followed_by"]
        name = lookups[idx]["name"]
        println("not following $name")
    end
end


"""
フォロー，フォロリク，ミュート，ブロックしていないフォロワー
(`Any["followed_by"]`) を以下のいずれかの条件を満たした場合フォローする．
 - 人間である
 - リプライを送られる
"""

"""
人間か否かを判断する
 - FF比0.2以上
 - 名前やbioに"相互", "専門店", "月収"という単語が含まれていない
 - 名前やbioに絵文字が多く含まれていない
 - bioにハッシュタグが多く含まれていない
 - 最新ツイートが15日以内
"""
function ishuman(ids)
    lookup = get_users_lookup(user_id = join(ids, ","))
    taboowords = ["相互", "専門店", "月収"]
    for i = 1:length(ids)
        ff = lookup[i].friends_count / lookup[i].followers_countfin
        sentence = lookup[i].name * lookup[i].description
        if ff <= 0.2
            for word in taboowords
                if occursin(word, sentence)

        end
    end
end



followerids = get_followers_ids(count = 5000)
lookup = get_users_lookup(user_id = "2976464166")
println(lookup[1].description)
get_friendships_lookup(user_id = 718762507716800512)
println(followerids["ids"])
