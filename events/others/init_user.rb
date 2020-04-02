bot = Bot
#ユーザーデータ初期化
default_user_data = {
    prefixes: [],
    command_aliases: {},
    also_known_as: [],
    aliases: {},
    money: 0,
    exp: 0,
    total_exp: 0,
    level: 1,
    message_count: 0,
}
bot.message do |event|
    id = event.user.id
    Users[id] ||= {}
    data = Users[id]
    default_user_data.each{|k,v|
        data[k] ||= v
    }
    Servers[id] = data
end