bot = Bot

# Prefix設定
bot.command(:prefix) do |event,*args|
    event.extend PotatoUtil
    sdata = Servers[event.server.id]
    if args.length > 0
        sdata[:prefixes] = args
        event.send_success("プレフィックスを設定しました: #{args.join(" ")}")
    else
        event.send_error("プレフィックスを一つ以上指定してください。")
    end
    Servers[event.server.id] = sdata
end

bot.require_command_permission(:prefix, [:administrator])