bot = Bot

def fss_get_rank(level) #TODO: Write it.

end

def fss_get_next_exp(level)
    return ((level * 334) + (level ** 1.05)).round
end

# ユーザーの情報を表示するコマンド
bot.command(:status) do |event|
    event.extend PotatoUtil
    udata = Users[event.user.id]
    next_exp = fss_get_next_exp(udata[:level])
    bar = event.emoji_bar(udata[:exp],next_exp)
    event.easy_embed(
        "#{event.user.name}",
        {
            "メッセージ数" => "#{udata[:message_count]}",
            "レベル" => "#{udata[:level]}",
            "経験値" => "#{udata[:exp]} / #{next_exp} #{bar}",
        }
    )
end