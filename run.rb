# 実行ファイル
start_time = Time.now

#デバッグログ用ライブラリ読み込み
require "./my_library/debug_log.rb"

# 標準ライブラリ読み込み
require "yaml"
require "securerandom"
debug "標準ライブラリ読み込み完了。", type: :success

# gem読み込み
require "discordrb"
debug "Gemライブラリ読み込み完了。", type: :success

# 自作ライブラリ読み込み
require "./my_library/emoji_bar.rb"
require "./my_library/othello.rb"
require "./my_library/savedata_v2.rb"
debug "自作ライブラリ読み込み完了。", type: :success


# Botトークン取得処理。
tokens = YAML.load_file("./config/tokens.yml")

if tokens["using"]
    token_key = tokens["using"]
    debug "トークン「#{token_key}」を使用します。"
else
    raise "The token to be used has not been specified.  使用するトークンが指定されていません。"
end

token = nil
if tokens[token_key]
    token = tokens[token_key]
else
    raise "The token name \"#{token_key}\" does not exist in config / tokens.yml.トークン名 「#{token_key}」 は config/tokens.yml に存在しません。"
end

#デバッグようprefixを決める
if DEBUG_LOG_FLAG
    bot_prefix = (0...5).map{ (65 + rand(26)).chr }.join + "!"
else
    bot_prefix = SecureRandom.hex(30)
end

Bot = Discordrb::Commands::CommandBot.new(token: token,prefix: bot_prefix)
debug "Botオブジェクト初期化。"

# コマンド読み込み
Dir[File.expand_path('../events/commands', __FILE__) << '/*.rb'].each do |file|
  require file
  debug "コマンドを読み込みました。 (#{file})"
end

#その他イベント処理　読み込み
Dir[File.expand_path('../events/others others', __FILE__) << '/*.rb'].each do |file|
  require file
  debug "ファイルを読み込みました。 (#{file})"
end

first_startup = true

# 起動
Bot.ready() {|event|
    if first_startup
        debug "スタートアップ完了。\n所要時間: #{(Time.now - start_time)}秒。\nデバッグ用コマンドプレフィックスは \e[1m#{bot_prefix}\e[0m です。", type: :success
    else
        debug "再接続しました。"
    end
}

debug "Discord APIサーバーへ接続中..."
Bot.run