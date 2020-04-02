# PotatoUtil: Discordrb::Eventにextendして使うモジュール。
module PotatoUtil
    def emoji_bar(value,max,size: 12,type: nil)
        empty_left  = "<:el:675202829186498560>"
        empty_mid   = "<:em:675202813453795348>"
        empty_right = "<:er:675202820689100800>"
        
        full_left  = ""
        full_mid   = ""
        full_right = ""
        
        case type
        when :green
            full_left  = "<:gl:675198323489243176>"
            full_mid   = "<:gm:675198332083109897>"
            full_right = "<:gr:675198370297544732>"
        when :blue
            full_left  = "<:bl:675326358066561064>"
            full_mid   = "<:bm:675326304593117186>"
            full_right = "<:br:675326329251561472>"
        end
        
        #準備となる計算
        
        bar = ""
        bar_count = 0
        
        bar_count = (value.to_f/max.to_f)*size.round
        p bar_count
        
        if value != 0 && bar_count == 0 #バーカウント、数値が0以上なら１にする ( HPの矛盾回避とか )
            bar_count = 1
        end
        
        #バーを生成する
        
        if bar_count > 0 # LEFT
            bar += full_left
        else
            bar += empty_left
        end
        
        if size >= 2 # MID
            (size-2).times do |t|
                if bar_count >= t+2
                    bar += full_mid
                else
                    bar += empty_mid
                end
            end
        end
        
        if bar_count == size  # RIGHT
            bar += full_right
        else
            bar += empty_right
        end
        p bar
        return bar
    end
end