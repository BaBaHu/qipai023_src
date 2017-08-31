-- 辅助函数，主要是相关逻辑的具体算法

local _M = {}

local function getPaiByIndex(id)
    -- body
    local t = 
    {
        [0x01] = 1,
        [0x02] = 2,
        [0x03] = 3,
        [0x04] = 4,
        [0x05] = 5,
        [0x06] = 6,
        [0x07] = 7,
        [0x08] = 8,
        [0x09] = 9,
        [0x0A] = 10,
        [0x0B] = 11,
        [0x0C] = 12,
        [0x0D] = 13,
        [0x11] = 14,
        [0x12] = 15,
        [0x13] = 16,
        [0x14] = 17,
        [0x15] = 18,
        [0x16] = 19,
        [0x17] = 20,
        [0x18] = 21,
        [0x19] = 22,
        [0x1A] = 23,
        [0x1B] = 24,
        [0x1C] = 25,
        [0x1D] = 26,
        [0x21] = 27,
        [0x22] = 28,
        [0x23] = 29,
        [0x24] = 30,
        [0x25] = 31,
        [0x26] = 32,
        [0x27] = 33,
        [0x28] = 34,
        [0x29] = 35,
        [0x2A] = 36,
        [0x2B] = 37,
        [0x2C] = 38,
        [0x2D] = 39,
        [0x31] = 40,
        [0x32] = 41,
        [0x33] = 42,
        [0x34] = 43,
        [0x35] = 44,
        [0x36] = 45,
        [0x37] = 46,
        [0x38] = 47,
        [0x39] = 48,
        [0x3A] = 49,
        [0x3B] = 50,
        [0x3C] = 51,
        [0x3D] = 52,
    }
    return t[id]
end

local function getIndexByPai(id)
    -- body
    local t = 
    {
        [1] = 0x01,
        [2] = 0x02,
        [3] = 0x03,
        [4] = 0x04,
        [5] = 0x05,
        [6] = 0x06,
        [7] = 0x07,
        [8] = 0x08,
        [9] = 0x09,
        [10] = 0x0A,
        [11] = 0x0B,
        [12] = 0x0C,
        [13] = 0x0D,
        [14] = 0x11,
        [15] = 0x12,
        [16] = 0x13,
        [17] = 0x14,
        [18] = 0x15,
        [19] = 0x16,
        [20] = 0x17,
        [21] = 0x18,
        [22] = 0x19,
        [23] = 0x1A,
        [24] = 0x1B,
        [25] = 0x1C,
        [26] = 0x1D,
        [27] = 0x21,
        [28] = 0x22,
        [29] = 0x23,
        [30] = 0x24,
        [31] = 0x25,
        [32] = 0x26,
        [33] = 0x27,
        [34] = 0x28,
        [35] = 0x29,
        [36] = 0x2A,
        [37] = 0x2B,
        [38] = 0x2C,
        [39] = 0x2D,
        [40] = 0x31,
        [41] = 0x32,
        [42] = 0x33,
        [43] = 0x34,
        [44] = 0x35,
        [45] = 0x36,
        [46] = 0x37,
        [47] = 0x38,
        [48] = 0x39,
        [49] = 0x3A,
        [50] = 0x3B,
        [51] = 0x3C,
        [52] = 0x3D,
    }
    return t[id]
end

local function getJetonByIndex(id)
    -- body
    local t = 
    {
        [1] = 100,
        [2] = 1000,
        [3] = 10000,
        [4] = 100000,
        [5] = 1000000,
        [6] = 5000000,
        [7] = 10000000,
    }
    return t[id]
end

local function getAreaByClientIndex(id)
    -- body
    local t = 
    {
        [1] = 6,
        [2] = 0,
        [3] = 1,
        [4] = 2,
        [5] = 7,
    }
    return t[id]
end

local function getAreaByServerIndex(id)
    -- body
    if id == 6 then
        return 1
    elseif id == 0 then
        return 2
    elseif id == 1 then
        return 3
    elseif id == 2 then
        return 4 
    elseif id == 7 then
        return 5
    end
    return -1
end

_M.getPaiByIndex                = getPaiByIndex             --根据索引获取牌
_M.getIndexByPai                = getIndexByPai             --根据牌获取索引
_M.getJetonByIndex              = getJetonByIndex           --根据索引获取筹码
_M.getAreaByClientIndex         = getAreaByClientIndex      --根据索引获取下注区域
_M.getAreaByServerIndex         = getAreaByServerIndex      --根据索引获取下注区域

return _M
