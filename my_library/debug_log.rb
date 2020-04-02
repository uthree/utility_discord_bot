require "yaml"
DEBUG_LOG_FLAG = YAML.load_file("./config/debug.yml")["debug_log"]
def debug(message, type: :normal) # type: :normal | :warn | :error | :success
    message = message.to_s unless message.class == String
    if DEBUG_LOG_FLAG
        time = Time.now
        pref = ""
        case type
        when :normal
            pref = "\e[36m"
        when :warn
            pref = "\e[33m"
        when :error
            pref = "\e[31m"
        when :success
            pref = "\e[32m"
        end
        pref += "[#{time.hour}:#{time.min}:#{time.sec}.#{(time.usec/1000).round}]"
        until pref.length > 18
            pref += " "
        end
        message.split("\n").each_with_index{|msg,idx|
            if idx == 0
                puts pref + "\e[37m" + msg
            else
                puts " |" + ("-" * (pref.length-8)) + " \e[37m" + msg
            end
        }
        puts "" if message.index("\n")
    end
end

debug "デバッグログを表示する設定です。\n変更する場合は config/debug.yml の debug_log を false にしてください。"