bot = Bot
# エイリアス追加コマンド
bot.command(:alias) do |event, *args|
    event.extend PotatoUtil
    arg      = args.join(" ")
    old_name = nil
    new_name = nil
    #引数の解析
    if arg.match(/(delete|del|remove|rem|rm) (.+)/)
        old_name = $~[2]
        debug "del alias"
    elsif arg.match(/\"(.+)\"(=| | = | =|= )\"(.*)\"/)
        old_name = $~[1]
        new_name = $~[3]
        debug "alias 1"
    elsif arg.match(/(.+)(=| | = | =|= )(.+)/)
        old_name = $~[1]
        new_name = $~[3]
        debug "alias 2"
    elsif arg.match(/list/)
        old_name = "list"
    end
    data = Users[event.user.id] # load user data
    if old_name == "list"
        r = "```ruby\n# alias list\n"
        data[:aliases].each{|k,v|
            r += "\"#{k}\" = \"#{v}\"\n"
        }
        r += "```"
        event.easy_embed("エイリアス一覧", {"List" => r})
    elsif old_name && new_name
        if data[:aliases][old_name]
            event.send_error("エイリアス「`#{old_name}`」は既に登録されています。")
        else
            
            
            data[:aliases][old_name] = new_name
            Users[event.user.id] = data
            event.send_success("「`#{old_name}`」を「`#{new_name}`」に置き換えるように登録しました。")
        end
    elsif old_name
        if data[:aliases][old_name]
            data[:aliases].delete(old_name)
            event.send_success("エイリアス「`#{old_name}`」を削除しました。")
        else
            event.send_error("「`#{old_name}`」のエイリアスは登録されていません。")
        end
        Users[event.user.id] = data
    else
        event.send_error(
            "引数が不正です。",
            {
                "使い方" => [
                    "`alias s status`: 「s」 コマンドでstatusを呼び出せるように設定。",
                    "`alias s=status` `alias \"s\" = \"status\"` などでも使用できます。",
                    "`alias list`: エイリアスの一覧を表示します。",
                    "`プレフィックスに`!`を一つ付け足すと、エイリアスの置き換え処理を無視して実行できます。`",
                    "`alias remove <エイリアス名>`: エイリアスを削除します。"
                ].join("\n")
            }
        )
    end
end