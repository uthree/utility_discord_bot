require "yaml"

require "discordrb"

require "./my_library/emoji_bar.rb"
require "./my_library/othello.rb"
require "./my_library/savedata_v2.rb"

#Botトークン取得処理。

tokens = YAML.load_file("./config/tokens.yml")

if tokens["using"]
    token_key = tokens["using"]
else
    raise "The token to be used has not been specified.  使用するトークンが指定されていません。"
end

token = nil
if tokens[token_key]
    token = tokens[token_key]
else
    raise "The token name \"#{token_key}\" does not exist in config / tokens.yml.トークン名 「#{token_key}」 は config/tokens.yml に存在しません。"
end