bot = Bot
#サーバーでーた初期化
default_server_data = {
    prefixes: ["sz!"], # ["prefix", "prefix"]
    aliases: {}, # {"cmdname" => "cmdname"}
    jail_role: nil, # roleid
    jailed_users: [], # [userid]
    rolesave: false, # bool
    saved_role: {}, # {userid => [role]}
}
bot.message do |event|
    id = event.server.id
    Servers[event.server.id] ||= {}
    data = Servers[event.server.id]
    default_server_data.each{|k,v|
        data[k] ||= v
    }
    Servers[event.server.id] = data
end