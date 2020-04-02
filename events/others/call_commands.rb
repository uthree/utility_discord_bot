# コマンド実行
bot = Bot

def execute_command(command_chain, event) #コマンド実行処理
    debug "コマンド実行開始\nソース: #{command_chain}"
    multiline_command = false
    read_raw = false
    if command_chain[0] == "!" # !コマンド で テキストを「そのまま」実行。  記号とかをあまり気にしない方針でいく
        command_chain = command_chain[1..-1]
        debug "RAWモード"
        read_raw = true
    end
    
    unless read_raw
        if command_chain[0] == ";" #複数コマンド同時実行 (; を先頭に置き、その後 ; で区切って複数のコマンドを実行する。)
            command_chain = command_chain[1..-1]
            debug "MULTILINEモード"
            multiline_command = true
        end
    end
    
    
    #実行するコマンドを配列にする。
    commands = []
    if multiline_command
        commands = command_chain.split(/\n|\;/)
    else
        commands = [command_chain] #複数行コマンドじゃない場合はひとつだけいれる。
    end
    debug "実行内容:\n" + commands.join("\n")
    debug "合計 #{commands.length} 件のコマンド"
    
    long_command = commands.length >= 5 # 5件以上のコマンドを実行する際、プログレスバーを表示する。
    if long_command
        bar = event.respond(event.emoji_bar(0,commands.length,type: :green) + "** 0 / #{commands.length}**") #プログレスバー
    end
    
    commands.each_with_index do |cmd,idx|
        words = []
        words = cmd.split(" ")
        #エイリアスの読み込み
        aliases = Users[event.user.id][:aliases]
        
        words.each_with_index do |w,i|
            #コマンド名エイリアス
            if aliases[w] && (not words[0] == "alias") #alias コマンドは例外的に置き換えを行わない。
                debug "エイリアス置き換え「#{w}」"
                words.delete_at(i)
                words.insert(i,aliases[w.to_s].to_s.split(" "))
            end
        end
        words.flatten!
        debug words
        
        if long_command #長いコマンドのときのプログレスバーの処理
            bar.edit(event.emoji_bar(idx+1,commands.length,type: :green) + "** #{idx+1} / #{commands.length}**\n`#{cmd}`")
            sleep 1 #APIに負荷をかけないよう、スリープを挟む。
            if idx+1 == commands.length # 実行が終わったとき、プログレスバーを片付ける。
                bar.delete
                event.send_success("#{commands.length}件のコマンドの処理が完了しました。")
            end
        end
        
        
        command_name = words[0].downcase.to_sym
        args = []
        
        
        if words.size > 1
            if read_raw 
                args = words[1..-1]
            elsif (not command_name == "alias") #alias コマンドは例外的に置き換えを行わない。
                args = words[1..-1] #TODO: 複雑なパースを実装。ユーザセレクタとか。いろいろ。
                
                
                # #引数エイリアス 処理
                # aliases.each{|k,v|
                #     args.each_with_index{|a,i|
                #         if a == k
                #             args[i] = v
                #         end
                #     }
                # }
            end
        end
        
        
        command_event = Discordrb::Commands::CommandEvent.new(event.message,Bot)
        begin
            if Bot.can_use?(command_name,event.user)
                debug "#{command_name} を実行しています..."
                Bot.execute_command(command_name,command_event,args)
                debug "#{command_name} 処理完了", type: :success
            else
                event.send_error("権限がありません。")
            end
        rescue => error
            if error.class == Discordrb::Errors::NoPermission
                event.send_error("Botに必要な権限が不足しています。")
            else
                event.send_error("内部エラーが発生しました。開発者にお問い合わせください。")
                debug error.message, type: :error
                debug error.to_s + error.backtrace.join("\n"), type: :error
            end
        end
    end
end

running = []

bot.message do |event|
    event.extend PotatoUtil
    
    #同じユーザーが同時実行するのを阻止する
    next if running.index(event.user.id)
    running << event.user.id
    
    #コマンドであるか判定する。
    server_id = event.server.id
    prefixes = (Servers[server_id] || {prefixes: ["sz!"]})[:prefixes]
    
    
    message = event.message.content
    prefixes.each do |pref|
        if message[0..(pref.length-1)] == pref
            command_chain = message[(pref.length)..-1]
            execute_command(command_chain,event)
            break
        end
    end
    
    running.delete(event.user.id)
end