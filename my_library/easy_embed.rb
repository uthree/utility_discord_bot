module PotatoUtil
    @@embeds = {}
    def easy_embed(title,content = {},color = nil)
        @@embeds[self.user.id] ||= []
        if content.class == Hash
            @@embeds[self.user.id] << channel.send_embed() do |embed|
                embed.title =  title
                content.each{|k,v|
                    embed.add_field(name: k,value:v)
                }
                embed.color = self.user.color || 0x4283f4
                embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: user.name, icon_url: user.avatar_url)
            end
        elsif content.class == Array
            @@embeds[self.user.id] << channel.send_embed() do |embed|
                embed.title =  title
                embed.add_field(name: "--DIALOG--", value: "#{content.join("\n")}") 
                embed.color = self.user.color  || 0x4283f4
                embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: user.name, icon_url: user.avatar_url)
            end
        else
            @@embeds[self.user.id] << channel.send_embed() do |embed|
                embed.title =  title
                embed.add_field(name: "--DIALOG--", value: "#{content}") unless content == ""
                embed.color = self.user.color || 0x4283f4
                embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: user.name, icon_url: user.avatar_url)
            end
        end 
    end
    def send_error(title,content={})
        title = ":x: #{title}"
        easy_embed(title,content)
    end
    def send_success(title,content={})
        title = ":white_check_mark: #{title}"
        easy_embed(title,content)
    end
    def clear_embeds
        if @@embeds[self.user.id].size > 30 # 多すぎる場合は最新の30件のみに絞る。
            @@embeds[self.user.id] = @@embeds[self.user.id][-30..-1]
        end
        @@embeds[self.user.id].each{|em| em.delete()}
        @@embeds[self.user.id] = []
    end
end