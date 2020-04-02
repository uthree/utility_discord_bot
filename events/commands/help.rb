bot = Bot
# ヘルプコマンド
# ヘルプコマンドの資料を読み込む。
COMMAND_HELP_DATA = YAML.load_file("./help.yml")
bot.command(:help) do |event,*args|
    event.extend PotatoUtil
    keywords = []
    search_result = []
    help_data = COMMAND_HELP_DATA
    if args.length > 0 # 引数があった場合はそれで検索を行う。
        keywords = args
    else
        keywords = ["general"] # 引数がない場合、generalカテゴリでの検索を行う。
    end
    
    keywords.each do |kw| 
        # カテゴリ検索。
        if help_data[kw]
            search_result += help_data[kw].values
        end
        
        # コマンド別で検索
        help_data.values.each do |hd|
            debug hd
            search_result += hd.values.select do |cmd|
                debug cmd
                cmd["name"] == kw || cmd["description"].index(kw)
            end
        end

    end
    
    search_result.uniq! # 重複するものを削除。
    #検索結果を送信。
    debug "SEARCH RESULT"
    debug search_result
    
    if search_result.length > 0
        #ヘルプメッセージ生成
        pref = Servers[event.server.id][:prefixes].first

        s = "```md\n"
        search_result.each do|cmd|
            s += [
                "==========",
                "# #{cmd["name"]}",
                "#{cmd["description"]}",
                "",
                "使用方法:\n"
            ].join("\n")
            cmd["usage"].each do |uk,uv|
                s += "# #{pref}#{uk} \n #{uv}\n\n"
            end
            s += [
                ""
            ].join("\n")
        end
        s += "\n```"
        
        #ヘルプ送信
        event.easy_embed("ヘルプ", s)
    else
        event.send_error("一致するコマンドが見つかりませんでした。","`#{keywords.join(" ")}` にスペルミスがないかなど、もう一度確認してみてください。")
    end
end