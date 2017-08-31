-- 辅助函数，主要是相关逻辑的具体算法

local _M = {}

local function getPaiByIndex(id)
    -- body
    if id >= 1 and id <= 9 then
        return id
    elseif id == 0x11 then
        return 10
    elseif id == 0x19 then
        return 11
    elseif id == 0x21 then
        return 12
    elseif id == 0x29 then
        return 13
    elseif id == 0x31 then
        return 14
    elseif id == 0x32 then
        return 15
    elseif id == 0x33 then
        return 16
    elseif id == 0x34 then
        return 17
    elseif id == 0x35 then
        return 20
    elseif id == 0x36 then
        return 19
    elseif id == 0x37 then
        return 18
    else
        return id
    end
end

local function getIndexByPai(id)
    -- body
    if id >= 1 and id <= 9 then
        return id
    elseif id == 10 then
        return 0x11

    elseif id == 11 then
        return 0x19
    
    elseif id == 12 then
        return 0x21
    
    elseif id == 13 then
        return 0x29
    
    elseif id == 14 then
        return 0x31
    
    elseif id == 15 then
        return 0x32
    
    elseif id == 16 then
        return 0x33
    
    elseif id == 17 then
        return 0x34
    
    elseif id == 18 then
        return 0x37
    
    elseif id == 19 then
        return 0x36
    
    elseif id == 20 then
        return 0x35
    else
        return id
    end
end

--判断是否胡牌
local function isHuPai(curlist,isPoing,data_pong)
    --抽出红中
    local count = 0
    local list = {}
    for i,v in ipairs(curlist) do
        list[i] = v
    end
    local isPong_alear = false
    if isPoing then
        isPong_alear = true
        local wanZi = 0
        local tongZi = 0
        local suZi = 0
        local daZi = 0
        
        for i=1,#curlist do
            if curlist[i] > 0 and curlist[i] <10 then
                --todo
                wanZi = 1
            end
            if curlist[i] >= 10 and curlist[i] <12 then
                --todo
                tongZi = 1
            end
            if curlist[i] >= 12 and curlist[i] <14 then
                --todo
                suZi = 1
            end
            if curlist[i] > 13 and curlist[i] <20 then
                --todo
                daZi = 1
            end

        end
        for i=1,#data_pong do
            if data_pong[i] > 0 and data_pong[i] <10 then
                --todo
                wanZi = 1
            end
            if data_pong[i]>= 10 and data_pong[i] <12 then
                --todo
                tongZi = 1
            end
            if data_pong[i] >= 12 and data_pong[i] <14 then
                --todo
                suZi = 1
            end
            if data_pong[i] > 13 and data_pong[i] <20 then
                --todo
                daZi = 1
            end
        end

        local typeCount = wanZi + tongZi + suZi + daZi
        --print("碰的牌型检测",typeCount)
        if typeCount == 1 then
            isPoing = false
        end
    end

    table.sort(list,function(a,b) return a<b end)
    for i,v in ipairs(list) do
        if v == 20 then 
            count = count + 1
            list[i] = 0
        end
    end


    local function _isHuPai(_list,count,isPong)--count 红中个数 isPong 是否有碰牌
        local list_pai = {}
        for i,v in ipairs(_list) do
            list_pai[i] = v
        end
        --print("是否碰牌了",isPong)
        -- dump(list_pai,"去眼后牌型")
        
        --先找出123  111这种结对
        local isBreak_j = false
        for i,v in ipairs(list_pai) do
            for j,w in ipairs(list_pai) do
                for k,x in ipairs(list_pai) do
                    if i ~= j and j ~= k and i~=k  then
                        if  v < 10 and w < 10 and x < 10 and v > 0 and w > 0 and x > 0 then
                            if (v == w + 1 and w == x + 1 and not isPong) or (v == w and w == x) then
                                list_pai[i] = 0
                                list_pai[j] = 0
                                list_pai[k] = 0
                                isBreak_j = true
                                break
                            end

                        elseif v > 0 and w > 0 and x > 0 then
                            if (v == w and w == x) then
                                list_pai[i] = 0
                                list_pai[j] = 0
                                list_pai[k] = 0
                                isBreak_j = true
                                break
                            end
                        end
                    end
                end
                if isBreak_j then
                    isBreak_j = false
                    break
                end
            end

        end

        --dump(list_pai,"去除123 111这种结对")

        --利用红中判断是否能消除这些结对  12 13  11这种类型 
        --print(count,"中的个数")
        local tem_count = count
        if tem_count > 0 then
            for i,v in ipairs(list_pai) do
                for j,w in ipairs(list_pai) do
                    if i ~= j then
                        if  v < 10 and w < 10  and v > 0 and w > 0 then
                            --print(tem_count,"中的个数")
                            if (v == w + 1 or v == w + 2) and tem_count > 0 and not isPong then
                                list_pai[i] = 0
                                list_pai[j] = 0
                                tem_count = tem_count - 1
                                --print(tem_count,"中的个数")
                                break
                            end
                            if v == w and tem_count > 0 then
                                list_pai[i] = 0
                                list_pai[j] = 0
                                tem_count = tem_count - 1
                                --print(tem_count,"中的个数")
                                break
                            end
                        elseif v > 0 and w > 0 then
                            if v == w and tem_count > 0 then
                                list_pai[i] = 0
                                list_pai[j] = 0
                                tem_count = tem_count - 1
                                --print(tem_count,"中的个数")
                                break
                            end
                        end
                    end
                end
            end

        end
        -- dump(list_pai,"红中去除12 11这种结对")

        local isHu = true
        local countPai = 0
        for i,v in ipairs(list_pai) do
            if v > 0 then
                countPai = countPai + 1
            end
        end
        if countPai == 1 and tem_count == 2  then
            --todo
            --print("test 1")
        elseif countPai == 2 and tem_count == 4  then
            --print("test 2")
            --todo
        elseif countPai > 0 then
            --print("test 3")
            isHu = false
        end
        --print("是否胡牌",isHu,isPong)
        if isHu == false and not isPong_alear then
            isHu = true
            --七小对判断 消除11牌型 共六对
            local list_qi = {}
            for i,v in ipairs(_list) do
                list_qi[i] = v
            end
            -- dump(list_qi,"七小原牌")
            --消除11类型
            for i=1,#list_qi do
                if i < #list_qi and list_qi[i] > 0 and list_qi[i] == list_qi[i+1] then
                    --print("i",i)
                    list_qi[i] = 0
                    list_qi[i+1] = 0
                end
            end
            -- dump(list_qi,"七小对去对")
            --利用红中消除单只
            local tem_count = count
            for i,v in ipairs(list_qi) do
                if v > 0 and tem_count > 0 then
                    list_qi[i] = 0 
                    tem_count = tem_count - 1
                end
            end
            for i,v in ipairs(list_qi) do
                if v > 0 then
                    isHu = false
                    break
                end
            end
            
            -- dump(list_qi,"七小对")
        end
        return isHu
    end


    --先取眼位 普通遍历 不带红中
    -- dump(list,"开始牌型")
    for i,v in ipairs(list) do
        if v > 0 then
            if i < #list then
                if list[i] == list[i+1] then
                    --print("当前眼",v)
                    local tem_list = {}
                    for _,v in ipairs(list) do
                        tem_list[_] = v
                    end
                    tem_list[i] = 0
                    tem_list[i+1] = 0
                    local huPai =  _isHuPai(tem_list,count,isPoing)
                    if huPai == true then
                        --print("可以胡牌了 眼不带红中")
                        return true
                    end
                end
            end
        end
    end
    --先取眼位 普通遍历 带红中
    for i,v in ipairs(list) do
        if v > 0 then
            local tem_list = {}
            for _,v in ipairs(list) do
                tem_list[_] = v
            end
            tem_list[i] = 0
            local huPai =  _isHuPai(tem_list,count - 1,isPoing)
            if huPai == true then
                --print("可以胡牌了 眼带一红中")
                return true
            end
        end
    end
    --两个中当眼
    if count >= 2  then
        local tem_list = {}
        for _,v in ipairs(list) do
            tem_list[_] = v
        end
        local huPai =  _isHuPai(tem_list,count - 2,isPoing)
        if huPai == true then
            --print("可以胡牌了 眼带二红中")
            return true
        end
    end

    
    -- dump(list,"结束牌型")

    --十三幺牌
    local isHu = false

    if not isPoing then
        local pai_13 = {1,9,10,11,12,13,14,15,16,17,18,19,20}
        local tem_list = {}
        for _,v in ipairs(list) do
            tem_list[_] = v
        end
        for i,v in ipairs(pai_13) do
            for j,w in ipairs(tem_list) do
                if w == v then
                    tem_list[j] = 0
                    break
                end
            end
        end
        for i=#tem_list,1,-1 do
            if tem_list[i] == 0 then
                table.remove(tem_list,i)
            end
        end

        -- dump(tem_list,"十三幺牌")
        if #tem_list == 1 then
            for i,v in ipairs(pai_13) do
                if v == tem_list[1] then
                    return true
                end
            end

        end
    end
    return isHu
end

local function getShaiZiCount(count)
    -- body
    local dian1 = 1
    local dian2 = 1
    if count == 1542 then
        dian1 = 6
        dian2 = 6
    elseif count == 1541 then
        dian1 = 6
        dian2 = 5
    elseif count == 1540 then
        dian1 = 6
        dian2 = 4
    elseif count == 1539 then
        dian1 = 6
        dian2 = 3
    elseif count == 1538 then
        dian1 = 6
        dian2 = 2
    elseif count == 1537 then
        dian1 = 6
        dian2 = 1
    elseif count == 1286 then
        dian1 = 5
        dian2 = 6
    elseif count == 1285 then
        dian1 = 5
        dian2 = 5
    elseif count == 1284 then
        dian1 = 5
        dian2 = 4
    elseif count == 1283 then
        dian1 = 5
        dian2 = 3
    elseif count == 1282 then
        dian1 = 5
        dian2 = 2
    elseif count == 1281 then
        dian1 = 5
        dian2 = 1
     elseif count == 1030 then
        dian1 = 4
        dian2 = 6
    elseif count == 1029 then
        dian1 = 4
        dian2 = 5
    elseif count == 1028 then
        dian1 = 4
        dian2 = 4
    elseif count == 1027 then
        dian1 = 4
        dian2 = 3
    elseif count == 1026 then
        dian1 = 4
        dian2 = 2
    elseif count == 1025 then
        dian1 = 4
        dian2 = 1
    elseif count == 774 then
        dian1 = 3
        dian2 = 6
    elseif count == 773 then
        dian1 = 3
        dian2 = 5
    elseif count == 772 then
        dian1 = 3
        dian2 = 4
    elseif count == 771 then
        dian1 = 3
        dian2 = 3
    elseif count == 770 then
        dian1 = 3
        dian2 = 2
    elseif count == 769 then
        dian1 = 3
        dian2 = 1
    elseif count == 518 then
        dian1 = 2
        dian2 = 6
    elseif count == 517 then
        dian1 = 2
        dian2 = 5
    elseif count == 516 then
        dian1 = 2
        dian2 = 4
    elseif count == 515 then
        dian1 = 2
        dian2 = 3
    elseif count == 514 then
        dian1 = 2
        dian2 = 2
    elseif count == 513 then
        dian1 = 2
        dian2 = 1
    elseif count == 262 then
        dian1 = 1
        dian2 = 6
    elseif count == 261 then
        dian1 = 1
        dian2 = 5
    elseif count == 260 then
        dian1 = 1
        dian2 = 4
    elseif count == 259 then
        dian1 = 1
        dian2 = 3
    elseif count == 258 then
        dian1 = 1
        dian2 = 2
    elseif count == 257 then
        dian1 = 1
        dian2 = 1
    else
       print("点数错误",count)
       dian1 = 1
       dian2 = 1
    end
    return dian1, dian2
end

local function getHuPaiType()
    -- body
     local data_type = {
         0x00000001,
         0x00000004,
         0x00000008,
         0x00000010,
         0x00000020,
         0x00000040,
         0x00000080,
         0x00000100,
         0x00000200,
         0x00000400,
         0x00000800,
         0x00001000,
         0x00002000,
         0x00004000,
         0x00008000,
         0x00040000,
         0x00080000,
         0x00100000,
         0x00200000,
         0x00400000,
         0x00800000,
         0x01000000,
    }
    return data_type
end

local function getHuPaiName(index)
    -- body
    local data_name = {
        [1]  = "鸡胡",
        [2]  = "碰碰胡",
        [3]  = "",
        [4]  = "七小对",
        [5]  = "豪华",
        [6]  = "超豪华",
        [7]  = "超超豪华",
        [8]  = "地胡",
        [9]  = "天胡",
        [10] = "清一色",
        [11] = "抢杠",
        [12] = "海底捞月",
        [13] = "全风头",
        [14] = "风幺九",
        [15] = "全幺九",
        [16] = "十八罗汉",
        [17] = "十三幺",
        [18] = "坎坎胡",
        [19] = "门清",
        [20] = "混一色",
        [21] = "杠爆",
        [22] = "无宝牌",
    }
    return data_name[index]
end

local function getHuPaiFanShu(name)
    -- body
    local data_name = {}
    data_name["鸡胡"]       = 0
    data_name["碰碰胡"]     = 4
    data_name["自摸"]       = 0
    data_name["七小对"]     = 8
    data_name["豪华"]       = 12
    data_name["超豪华"]     = 24
    data_name["超超豪华"]   = 36
    data_name["地胡"]       = 0
    data_name["天胡"]       = 20
    data_name["清一色"]     = 8
    data_name["抢杠"]       = 0
    data_name["海底捞月"]   = 0
    data_name["全风头"]     = 20
    data_name["风幺九"]     = 10
    data_name["全幺九"]     = 20
    data_name["十八罗汉"]   = 0
    data_name["十三幺"]     = 22
    data_name["坎坎胡"]     = 12
    data_name["门清"]       = 0
    data_name["混一色"]     = 4
    data_name["杠爆"]       = 0
    data_name["无宝牌"]     = 0
    return data_name[name]
end

local function getHuPaiSound(name)
    -- body
    local data_name = {}
    data_name["鸡胡"]        = nil
    data_name["碰碰胡"]      = "PPH.mp3"
    data_name["自摸"]        = "CHI_HU.mp3"
    data_name["七小对"]      = "QD.mp3"
    data_name["豪华"]        = "HH.mp3"
    data_name["超豪华"]      = "CHH.mp3"
    data_name["超超豪华"]    = "CCHH.mp3"
    data_name["地胡"]        = "DH.mp3"
    data_name["天胡"]        = "TH.mp3"
    data_name["清一色"]      = "QYS.mp3"
    data_name["抢杠"]        = nil
    data_name["海底捞月"]    = "HDLY.mp3"
    data_name["全风头"]      = "QFT.mp3"
    data_name["风幺九"]      = "FYJ.mp3"
    data_name["全幺九"]      = "QYJ.mp3"
    data_name["十八罗汉"]    = "LH.mp3"
    data_name["十三幺"]      = "SSY.mp3"
    data_name["坎坎胡"]      = "KKH.mp3"
    data_name["门清"]        = "MQ.mp3"
    data_name["混一色"]      = "HYS.mp3"
    data_name["杠爆"]        = "GSKH.mp3"
    data_name["无宝牌"]      = nil
    return data_name[name]
end

_M.getPaiByIndex                = getPaiByIndex     --根据索引获取牌
_M.getIndexByPai                = getIndexByPai     --根据牌获取索引
_M.isHuPai                      = isHuPai           --是否胡牌
_M.getShaiZiCount               = getShaiZiCount    --获取骰子点数
_M.getHuPaiType                 = getHuPaiType      --获取胡牌类型
_M.getHuPaiName                 = getHuPaiName      --获取胡牌名称
_M.getHuPaiFanShu               = getHuPaiFanShu    --获取胡牌番数
_M.getHuPaiSound                = getHuPaiSound     --获取胡牌音效
return _M
