-- 辅助函数，主要是相关逻辑的具体算法

local _M = {}

local function getPaiByIndex(id)
    -- body
    if id >= 1 and id <= 9 then
        return id
    elseif id == 0x11 then
        return 10
    elseif id == 0x12 then
        return 11
    elseif id == 0x13 then
        return 12
    elseif id == 0x14 then
        return 13
    elseif id == 0x15 then
        return 14
    elseif id == 0x16 then
        return 15
    elseif id == 0x17 then
        return 16
    elseif id == 0x18 then
        return 17
    elseif id == 0x19 then
        return 18
    elseif id == 0x21 then
        return 19
    elseif id == 0x22 then
        return 20
    elseif id == 0x23 then
        return 21
    elseif id == 0x24 then
        return 22
    elseif id == 0x25 then
        return 23
    elseif id == 0x26 then
        return 24
    elseif id == 0x27 then
        return 25
    elseif id == 0x28 then
        return 26
    elseif id == 0x29 then
        return 27
    elseif id == 0x31 then
        return 28
    elseif id == 0x32 then
        return 29
    elseif id == 0x33 then
        return 30
    elseif id == 0x34 then
        return 31
    elseif id == 0x35 then
        return 32
    elseif id == 0x36 then
        return 33
    elseif id == 0x37 then
        return 34
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
        return 0x12

    elseif id == 12 then
        return 0x13

    elseif id == 13 then
        return 0x14

    elseif id == 14 then
        return 0x15

    elseif id == 15 then
        return 0x16
    
    elseif id == 16 then
        return 0x17
    
    elseif id == 17 then
        return 0x18
    
    elseif id == 18 then
        return 0x19
    
    elseif id == 19 then
        return 0x21
    
    elseif id == 20 then
        return 0x22
    
    elseif id == 21 then
        return 0x23
    
    elseif id == 22 then
        return 0x24
    
    elseif id == 23 then
        return 0x25
    
    elseif id == 24 then
        return 0x26
    
    elseif id == 25 then
        return 0x27
    
    elseif id == 26 then
        return 0x28
    
    elseif id == 27 then
        return 0x29

    elseif id == 28 then
        return 0x31

    elseif id == 29 then
        return 0x32

    elseif id == 30 then
        return 0x33

    elseif id == 31 then
        return 0x34

    elseif id == 32 then
        return 0x35

    elseif id == 33 then
        return 0x36

    elseif id == 34 then
        return 0x37
    else
        return id
    end
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
_M.getShaiZiCount               = getShaiZiCount    --获取骰子点数
_M.getHuPaiType                 = getHuPaiType      --获取胡牌类型
_M.getHuPaiName                 = getHuPaiName      --获取胡牌名称
_M.getHuPaiFanShu               = getHuPaiFanShu    --获取胡牌番数
_M.getHuPaiSound                = getHuPaiSound     --获取胡牌音效
return _M
