module CUIEditor
    @@user_max_size = 100000
    class Editor #エディタ本体
        attr_accessor :users
        def initialize()

        end
    end
    class Document # ドキュメント
        attr_reader :author
        attr_accessor :content, :syntax

    end
    class User # ユーザー

    end
    class Folder # フォルダ

    end
end