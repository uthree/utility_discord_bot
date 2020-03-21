# バグ修正版, Discord向けカスタマイズ。
# Author: uuu
module Othello
    class Board
        def initialize
            #2次元配列に nil :white, black がはいる事になる
            @board = Array.new(8).map{Array.new(8, nil)}
            @board[3][3] = :white
            @board[4][4] = :white
            @board[3][4] = :black
            @board[4][3] = :black
        end
        def get_board(color=nil) #ボード表示
            white = ":white_circle: "
            black = ":black_circle: "
            no_stone = ":green_square: "
            canput_no_stone = ":yellow_square: "
            r = ":negative_squared_cross_mark: :regional_indicator_a: :regional_indicator_b: :regional_indicator_c: :regional_indicator_d: :regional_indicator_e: :regional_indicator_f: :regional_indicator_g: :regional_indicator_h:\n"
            nums = [":one:", ":two:", ":three:", ":four:", ":five:", ":six:", ":seven:", ":eight:"]
            @board.each_with_index{|y,yi|
                str = "#{nums[yi]} "
                str += y.map.with_index{|x,xi|
                    case x
                    when nil
                        if color
                            if can_put?(color,xi,yi)
                                canput_no_stone
                            else
                                no_stone
                            end
                        else
                            no_stone
                        end
                    when :white
                        white
                    when :black
                        black
                    end
                }.join("")
                r += str + "\n"
            }
            return ".\n" + r
        end
        def can_put?(color,x,y) #設置可能であるかを取得 取得できた場合は方向[[x,y],[x,y],[x,y]...]が帰ってくる
            return false unless get_color(x,y) == nil
            directions = [[1,0],[1,1],[0,1],[1,-1],[0,-1],[-1,0],[-1,1],[-1,-1]] #チェックする８方向
            anothor_color_find = directions.select{|d| #自分と違う色のマスがある方向を検索する
                get_color(x+d[0],y+d[1]) != nil && get_color(x+d[0],y+d[1]) != color
            }
            return false unless anothor_color_find.size > 0 #どこに自分と違う色のますがなければこの時点でfalse
            can_put_direction = anothor_color_find.select {|d| #設置可能な方向の一覧を取得する
                (1..7).to_a.find{|t|#調べるべき方向に7回分試行する
                    c = get_color(x+(d[0]*t),y+(d[1]*t))
                    if c!= nil
                        c == color
                    else
                        break false
                    end
                }
            }
            if can_put_direction.size > 0
                return can_put_direction
            else
                return false
            end
        end
        def winner #勝利者の色を出力する。 :white :black 　勝利者がいなければ nil 引き分けなら :draw
            if can_put_any?(:black) || can_put_any?(:white) #どちらも設置可能
                return nil
            else #誰も置けない
                if count(:black) > count(:white)
                    return :black
                end
                if count(:black) < count(:white)
                    return :white
                end
                return :draw
            end
        end
        def count(color)
            @board.flatten.count(color)
        end
        def can_put_any?(color) #指定の色が、どれかのマスに配置できるか
            (0..7).to_a.map{|y|
                (0..7).to_a.map{|x|
                    can_put?(color,x,y) != false
                }.any?
            }.any?
        end
        def get_color(x,y) #指定座標の色を取得
            return nil if x > 7 || x < 0
            return nil if y > 7 || y < 0
            @board[y][x]
        end
        def get_color_by_id(id) #指定番号の色を取得。idは0~63のInteger
            @board.flatten()[id]
        end
        def id_to_pos(id) #idから座標を取得する。 戻り値は [x,y]
            arr = []
            (0..7).to_a.each{|y|
                (0..7).to_a.each{|x|
                    arr << [x,y]
                }
            }
            return arr[id]
        end
        def set_color(x,y,color) #色を上書き
            @board[y][x] = color
        end
        def put(color,x,y) #設置する 設置不可能なら例外発生。
            directions = can_put?(color,x,y)
            raise CanNotPutError if directions == false
            set_color(x,y,color)
            directions.each{|d|
                col = nil
                count = 1
                until col == color
                    col = get_color(x+d[0]*count,y+d[1]*count)
                    set_color(x+d[0]*count,y+d[1]*count,color)
                    count += 1
                end
            }
        end
    end
    class OthelloError < Exception;end
    class CanNotPutError < OthelloError;end
end

#テスト用
#b = Othello::Board.new()
#puts b.get_board(color=:white)
#p b.can_put?(:white,2,4)
#b.put(:white,2,4)
#puts b.get_board(color=:white)