bot = Bot
#チャンネルデータ初期化
default_channel_data = {
}
bot.message do |event|
    id = event.channel.id
    Channels[id] ||= {}
    data = Channels[id]
    default_channel_data.each{|k,v|
        data[k] ||= v
    }
    Channels[id] = data
end