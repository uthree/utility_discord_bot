bot = Bot
#送信したEmbedを全て削除
bot.command(:clear) do |event|
    event.extend PotatoUtil
    debug "送信したembedを削除。"
    event.clear_embeds()
end