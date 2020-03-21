# セーブデータ用ライブラリ

require 'yaml'

module SaveData
    class SaveData
        def initialize(dir, delete_count = 60, view_log = false)
            @dir = dir #保存先のディレクトリ
            @buf = {} #一時的にデータを置いておくためのhash
            @delete_count = delete_count #保存するまでの待機時間(秒単位)
            @view_log = view_log #ログを表示するかどうか
            @count = {}
            
            #ディレクトリ名の指定をちょっと補正する
            if @dir[-1] != "/"
                @dir += "/"
            end
            #ディレクトリ自動生成
            Dir.mkdir(@dir) unless Dir.exist?(@dir)
            
            @delete_thread = Thread.start { #自動削除スレッド
                loop do
                    @buf.keys.each{|key|
                        @count[key] ||= 0
                        @count[key] += 1 #カウントをふやす。
                        if @count[key] > @delete_count
                            save(key,@buf[key]) #セーブ処理
                            @buf.delete(key) #データをメモリから削除
                            @count.delete(key) #カウントも削除。
                        end
                    }
                    sleep 1
                end
            }
        end
        def []=(name,val) #新しいものを定義する、上書き
            if @buf[name]
                @count[name] = 0
            else
                @count[name] = @delete_count
            end
            @buf[name] = val
            return val
        end
        def [](name) #値を取得する。
            @count[name] = 0
            unless @buf.has_key?(name) #バッファに存在しなかった場合は読み込む。
                @buf[name] = load(name)
            end
            return @buf[name]
        end
        def keys()
            #TODO: このままだとファイルの状態になったものしか列挙できない(しかもpath)ため、それを解決する。
            Dir.glob(@dir + "*")
        end
        private
        def save(name, val) #ファルへの書き込み
            File.open("#{@dir}#{name}.txt", "w") do |f| 
                f.puts(YAML.dump(val))
            end
            puts "#{name}を書き込みました。" if @view_log
            return val
        end
        def load(name) #ファイルから読み込み
            r = nil
            return nil unless File.exist?("#{@dir}#{name}.txt")
            File.open("#{@dir}#{name}.txt", "r") do |f| 
                r = YAML.load(f.read())
            end
            puts "#{name}を読み込みました。" if @view_log
            return r
        end
        def save_all() #バッファにあるデータを全てセーブする
            @buf.keys.each{|key|
                save(key,@buf[key])
            }
        end
        
    end
end