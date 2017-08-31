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
    else
        return id
    end
end

local function isSelectTypePai(selType, id)
    -- body
    if selType == 0 then
        return false
    elseif selType == 1 then
        if id >= 1 and id <= 9 then
            return true
        end
    elseif selType == 17 then
        if id > 10 and id <= 18 then
            return true
        end
    elseif selType == 33 then
        if id >= 19 and id <= 27 then
            return true
        end
    end
    return false
end

local function isWanPai(id)
    -- body
    if id >= 1 and id <= 9 then
        return true
    end
    return false
end

local function isTiaoPai(id)
    -- body
    if id > 10 and id <= 18 then
        return true
    end
    return false
end

local function isTongPai(id)
    -- body
    if id >= 19 and id <= 27 then
        return true
    end
    return false
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
        0x00000002,
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
        0x00010000,
        0x00020000,
        0x00040000,
        0x00080000,
        0x00100000,
    }
    return data_type
end

local function getHuPaiName(index)
    -- body
    local data_name = {
        [1]  = "抢杠",
        [2]  = "杠上炮",
        [3]  = "杠上花",
        [4]  = "天胡",
        [5]  = "地胡",
        [6]  = "大对子",
        [7]  = "清一色",
        [8]  = "暗七对",
        [9]  = "带幺",
        [10] = "将对",
        [11] = "",--"素番",
        [12] = "清对",
        [13] = "龙七对",
        [14] = "清七对",
        [15] = "清幺九",
        [16] = "清龙七对",
        [17] = "金钩钩",
        [18] = "门清",
        [19] = "中张",
        [20] = "海底捞月",
        [21] = "点杠花",
    }
    return data_name[index]
end

local function getWFName(index)
    -- body
    local data_name = {
        [1]  = "三番封顶",
        [2]  = "四番封顶",
        [3]  = "五番封顶",
        [4]  = "自摸加底",
        [5]  = "自摸加番",
        [6]  = "点杠花(自摸)",
        [7]  = "点杠花(点炮)",
        [8]  = "换三张",
        [9]  = "幺九将对",
        [10] = "门清中张",
        [11] = "天地胡",
    }
    return data_name[index]
end

_M.getPaiByIndex                = getPaiByIndex     --根据索引获取牌
_M.getIndexByPai                = getIndexByPai     --根据牌获取索引
_M.isSelectTypePai              = isSelectTypePai   --检测是否是选择定缺类型的牌
_M.getShaiZiCount               = getShaiZiCount    --获取骰子点数
_M.getHuPaiType                 = getHuPaiType      --获取胡牌类型
_M.getHuPaiName                 = getHuPaiName      --获取胡牌名称
_M.getWFName                    = getWFName         --获取玩法名称
_M.isWanPai                     = isWanPai          --
_M.isTiaoPai                    = isTiaoPai         --
_M.isTongPai                    = isTongPai         --
return _M
