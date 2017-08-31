
local BaiJiaLeLuDanLayer = class("BaiJiaLeLuDanLayer", cc.load("mvc").DialogBase)
BaiJiaLeLuDanLayer.RESOURCE_FILENAME = "game_bjl/bjl_ludan_layer.csb"

--区域索引
local AREA_XIAN         = 0      --闲家索引
local AREA_PING         = 1      --平家索引
local AREA_ZHUANG       = 2      --庄家索引
local AREA_XIAN_TIAN    = 3      --闲天王
local AREA_ZHUANG_TIAN  = 4      --庄天王
local AREA_TONG_DUI     = 5      --同点平
local AREA_XIAN_DUI     = 6      --闲对子
local AREA_ZHUANG_DUI   = 7      --庄对子
local AREA_MAX          = 8      --最大区域

function BaiJiaLeLuDanLayer:onCreate(data) 
    print("BaiJiaLeLuDanLayer:onCreate(data).............", data)
    self:setInOutEffectEnable(true)

    self._children["panel"]:addTouchEventListener(function ( ... )
        -- body
        app:backDialog()
    end)
    self.longCounts_ = 0
    self.heCounts_ = 0
    self.fengCounts_ = 0
    self.longDuiCounts_ = 0
    self.fengDuiCounts_ = 0
    
    local tRecord = {}
    for k,v in pairs(data) do
        if v.cbPlayerCount > v.cbBankerCount then
            self.fengCounts_ = self.fengCounts_ + 1
            tRecord[#tRecord + 1] = 2
        elseif v.cbPlayerCount < v.cbBankerCount then
            self.longCounts_ = self.longCounts_ + 1
            tRecord[#tRecord + 1] = 1
        else
            self.heCounts_ =  self.heCounts_ + 1
            tRecord[#tRecord + 1] = 3
        end

        if v.bBankerTwoPair then
            self.longDuiCounts_ = self.longDuiCounts_ + 1
        end

        if v.bPlayerTwoPair then
            self.fengDuiCounts_ = self.fengDuiCounts_ + 1
        end
    end
    print("tRecord ======================", tRecord)
    local nPos = cc.p(self._children["recordPanel"]:getPosition() )
    local s = self._children["recordPanel"]:getContentSize()
    local x
    local y 
    for k,v in pairs(tRecord) do
        local imgRecord
        if v == 1 then
            imgRecord = display.newSprite("#b_long1.png")
        elseif v == 2 then
            imgRecord = display.newSprite("#b_feng1.png")
        elseif v == 3 then
            imgRecord = display.newSprite("#b_he1.png")
        end
        local s1 = imgRecord:getContentSize()
        
        if x == nil then
            x = s1.width/2 + 5
        end
        if y == nil then
            y = s.height - 5 - s1.height/2
        else
            y = y - s1.height - 10
        end
        imgRecord:setPosition(cc.p(x, y))
        self._children["recordPanel"]:addChild(imgRecord)
       
        if k % 8 == 0 then
            y = nil
            x = x + s1.width + 10
        end 
    end
    --------------------------------------------------------------------
    --绘画路径
    local nPos = cc.p(self._children["pointPanel"]:getPosition() )
    local s = self._children["pointPanel"]:getContentSize()
    local nPosX = 15
    local nPosY = s.height - 20
    local nGridWidth = 35
    local nGridHeight = 35
    local nVerCount = 0
    local nHorCount = 0
    local cbPreWinSide = 0
    local cbCurWinSide = 0
    local m_bFillTrace = {}
    for i=1,6 do
        m_bFillTrace[i] = {}
        for j=1,25 do
            m_bFillTrace[i][j] = false
        end
    end
    print("m_bFillTrace = ", m_bFillTrace)
    for k,v in pairs(data) do
        if v.cbPlayerCount > v.cbBankerCount then
            cbCurWinSide = AREA_XIAN + 1
        elseif v.cbPlayerCount < v.cbBankerCount then
            cbCurWinSide = AREA_ZHUANG + 1
        else
            cbCurWinSide = AREA_PING + 1
        end

        --递增数目
        if (cbPreWinSide ~= 0 and cbPreWinSide == cbCurWinSide) or (cbCurWinSide == AREA_PING + 1) then
            nVerCount = nVerCount + 1
            print("nVerCount, nHorCount", nVerCount, nHorCount)
            if nVerCount == 6 or m_bFillTrace[nVerCount+1][nHorCount+1] then
                nVerCount = nVerCount - 1
                nHorCount = nHorCount + 1
            end
        else
            nVerCount = 0
            --第一次
            if cbPreWinSide ~= 0 then
                for i=1,25 do
                    if not m_bFillTrace[1][i] then
                        nHorCount = i-1
                        break
                    end
                end               
            end
            cbPreWinSide = cbCurWinSide
        end

        --设置标识
        m_bFillTrace[nVerCount+1][nHorCount+1] = true

        --清零判断
        if nHorCount == 25 then
            break
        end
        print(k, nHorCount, nVerCount)
        local imgRecord
        if cbCurWinSide == AREA_ZHUANG + 1 then
            imgRecord = display.newSprite("#bjl_point_long.png")
        elseif cbCurWinSide == AREA_XIAN + 1 then
            imgRecord = display.newSprite("#bjl_point_feng.png")
        else
            imgRecord = display.newSprite("#bjl_point_he.png")
        end
        imgRecord:setPosition(cc.p(nPosX + nHorCount * nGridWidth, nPosY - nVerCount * nGridHeight) )
        self._children["pointPanel"]:addChild(imgRecord)
        
    end

    self._children["lab_feng"]:setString(self.fengCounts_)
    self._children["lab_he"]:setString(self.heCounts_)
    self._children["lab_long"]:setString(self.longCounts_)
    self._children["lab_fengdui"]:setString(self.fengDuiCounts_)
    self._children["lab_longdui"]:setString(self.longDuiCounts_)
end

return BaiJiaLeLuDanLayer
