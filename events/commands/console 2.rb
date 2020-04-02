bot = Bot
console_users = []
bot.command(:console) do |event,arg|
    event.extend PotatoUtil
    if arg == "exit"
        if console_users.index(event.user.id)
            debug "CONSOLE EXIT"
            console_users.delete event.user.id
            event.easy_embed("終了中...")
            event.clear_embeds
        else
            event.send_error("コンソール を起動していないため、終了できません。")
        end
    else
        if console_users.index(event.user.id)
            event.send_error("既にコンソールを起動しています。")
        else
            console_users << event.user.id
            event.message.delete()
            event.easy_embed("コンソール を起動しました。", "`console exit` で終了できます。")
        end
    end
    p console_users
    nil
end

bot.message do |event|
    if console_users.index(event.user.id)
        event.extend PotatoUtil
        event.message.delete()
        execute_command(event.message.content,event)
    end
    nil
end