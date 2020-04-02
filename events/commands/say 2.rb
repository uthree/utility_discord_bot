bot = Bot
bot.command(:say) do |event,*args|
    event.respond(args.join(" "))
end