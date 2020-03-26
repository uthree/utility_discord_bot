bot = Bot

bot.command :freecategory do |event,act|
    GlobalData["freecategory"] ||= {}
    gdata = GlobalData["freecategory"]
    event.extend PotatoUtil
    if act == "setup"
        if gdata[event.server.id]
            event.send_error("既にフリーカテゴリーを設定されています。")
        else
            #TODO: 登録処理
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
                channel_score: {},
                
                delete_day: 5, # 最終発言から何日後に消すか
                max_channels: 30 # チャンネル数上限
            }
        end
    elsif act == "teardown"
        if gdata[event.server.id]
            event.easy_embed("フリーカテゴリーを削除します...")
            gdata.delete(event.server.id)

            event.send_success("削除処理が正常に完了しました。", "チャンネル及びカテゴリーは手動で削除してください。")
        else
            event.send_error("このサーバーはフリーカテゴリーを使用していません。")
        end
    end
    GlobalData["freecategory"] = gdata
end

bot.require_command_permission(:freecategory, [:administrator])


#チャンネル作成処理

bot.message do |event|
    GlobalData["freecategory"] ||= {}
    gdata = GlobalData["freecategory"]
    sdata = gdata[event.server.id]
    event.extend PotatoUtil
    if sdata
        if event.channel.id == sdata[:create_channel]
            name = event.message.content
            if name.length > 30
                event.send_error("名前が長すぎます。")
            else
                ch = event.server.create_channel(name,type=)
            end
        end
        gdata[event.server.id] = sdata
        GlobalData["freecategory"] = gdata
    end
end
