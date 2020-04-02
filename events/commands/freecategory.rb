bot = Bot

frct_cmd_running = false

bot.command :freecategory do |event,act,arg|
    until frct_cmd_running == false; sleep 1; end
    frct_cmd_running = true
    GlobalData["freecategory"] ||= {}
    gdata = GlobalData["freecategory"]
    event.extend PotatoUtil
    if act == "setup"
        if gdata[event.server.id]
            event.send_error("既にフリーカテゴリーを設定されています。")
        else
            category       = event.server.create_channel("フリーカテゴリー",type= 4)
            announce       = event.server.create_channel("お知らせ",type= 0, parent: category) #お知らせ用チャンネル
            create_channel = event.server.create_channel("チャンネル作成",type= 0, parent: category) #チャンネル作成用
            
            bot.send_message(
                announce,
                [
                    "__**フリーカテゴリー**__",
                    "本サーバーはフリーカテゴリーを導入しました。",
                    "フリーカテゴリーが話題になった際、本サーバーを自動的に宣伝します。",
                    "このサーバーがプライベートのものである場合、直ちにフリーカテゴリーの登録を解除してください。",
                    "解除の方法についてはヘルプコマンドをご覧ください。",
                    "",
                    "また、定期的にこのチャンネルに、ホットなサーバーの情報などをお届けします。",
                    "このサーバーでも良いカテゴリーができたら、全サーバーに発信を行います！"
                ].join("\n")
            )
            
            gdata[event.server.id] = {
                category: category.id,
                announce: announce.id,
                create_channel: create_channel.id,
                channels: [],
                channel_score: {}, #チャンネルのアクティビティ
                
                delete_count: 7, # 1週間後に削除 (0なら削除しない)
                max_channels: 30 # チャンネル数上限
            }
            
            event.send_success("フリーカテゴリーをセットアップしました。")
        end
    elsif act == "teardown"
        if gdata[event.server.id]
            event.easy_embed("フリーカテゴリーを削除します...")
            gdata.delete(event.server.id)
            
            event.send_success("削除処理が正常に完了しました。", "チャンネル及びカテゴリーは手動で削除してください。")
        else
            event.send_error("このサーバーはフリーカテゴリーを使用していません。")
        end
    elsif act == "setlimit"
        if arg.to_i > 0
            sdata = gdata[event.server.id]
            if sdata
                sdata[:max_channels] = arg.to_i
                event.send_success("最大チャンネル数を #{arg.to_i} にしました。")
                gdata[event.server.id] = sdata
            else
                event.send_error("このサーバーはフリーカテゴリーを使用していません。")
            end
        else
            event.send_error("チャンネル数の上限を指定してください。")
        end
    elsif act == "setdelete"
        if arg.to_i > -1
            sdata = gdata[event.server.id]
            if sdata
                sdata[:delete_count] = arg.to_i
                if arg.to_i > 0
                    event.send_success("最期の発言から #{arg.to_i} 日経過後に削除する設定にしました。")
                else
                    event.send_success("自動削除を無効化しました。")
                end
                gdata[event.server.id] = sdata
            else
                event.send_error("このサーバーはフリーカテゴリーを使用していません。")
            end
        else
            event.send_error("日数を指定してください。")
        end
    elsif act == "addch"
        sdata = gdata[event.server.id]
        if sdata[:channels].index(event.channel.id)
            event.send_error("このチャンネルは既に登録されています")
        else
            ch = event.channel
            sdata[:channels] << ch.id
            sdata[:channel_score][ch.id] = 0
            event.send_success("チャンネル <##{ch.id}> をフリーカテゴリーに登録しました。")
        end
        gdata[event.server.id] = sdata
    end
    GlobalData["freecategory"] = gdata
    frct_cmd_running = false
end

bot.require_command_permission(:freecategory, [:administrator])


#チャンネル作成処理、スコア計算処理

bot.message do |event|
    until frct_cmd_running == false; sleep 1; end
    GlobalData["freecategory"] ||= {}
    gdata = GlobalData["freecategory"]
    sdata = gdata[event.server.id]
    event.extend PotatoUtil
    if sdata
        if event.channel.id == sdata[:create_channel]
            name = event.message.content
            if name.length > 30
                event.send_error("名前が長すぎます。")
            elsif event.channel.parent.children.size > sdata[:max_channels]
                event.send_error("チャンネル数が上限に達したため、作成できませんでした。")
            else
                ch = event.server.create_channel(name,type=0, parent: sdata[:category], topic: "#{event.user.name}さんによって作成されました。")
                sdata[:channels] << ch.id
                sdata[:channel_score][ch.id] = 0
                event.send_success("チャンネル #{name} を作成しました。")
            end
        elsif event.channel.id == sdata[:announce]
            event.message.delete
        else
            #スコアを計算する。　とりあえず雑にメッセージの情報量を加算する。
            message = event.message.content
            get_score = ((message.length + message.split("").uniq.length)/10).round
            sdata[:channel_score][event.channel.id] += get_score
        end
        gdata[event.server.id] = sdata
        GlobalData["freecategory"] = gdata
    end
end

#TODO: 自動削除

bot.ready do |event|
    loop do
        if Time.now.min == 0
            frct_cmd_running = true
            gdata = GlobalData["freecategory"]
            gdata.each do |sid,sdata|
                str = "__**サーバー内　アクティビティ ランキング**__\n\n"

                # スコアを9/10にする。
                gdata[sid][:channel_score].each{|id,score|
                    gdata[sid][:channel_score][id] = (score * (9.0/10.0)).round()
                }

                # ランキングを書く
                sdata[:channel_score].sort{|(ak,av),(bk,bv)| bv <=> av}.each_with_index{|a,i|
                    k,v = a
                    str += "# #{i+1}   <##{k}> Score: **#{v}**\n\n"
                    if str.length > 1000
                        bot.send_message(sdata[:announce],str)
                        str = ""
                    end
                    bot.send_message(sdata[:announce],str)
                }
            end
            GlobalData["freecategory"] = gdata
            frct_cmd_running = false
        end
        sleep 60
    end
end