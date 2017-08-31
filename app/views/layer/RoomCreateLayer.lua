
local RoomCreateLayer = class("RoomCreateLayer", cc.load("mvc").DialogBase)

RoomCreateLayer.RESOURCE_FILENAME = "room_create_layer.csb"

function RoomCreateLayer:onCreate(params) 
    self:setInOutEffectEnable(true)
    self.params = params
    local function  removeSelf()
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    local function  OnCreateRoom()
        app:backDialog()
        self:createRoom()
    end
    self._children["btn_create_room"]:addClickEventListener(OnCreateRoom)

    self.nSelType = 1
    self.nSelFourMJJuShu = 2
    self.nSelFourMJFan = 3
    self.nSelFourMJWF1 = 2
    self.nSelFourMJWF2 = 1
    self.nSelFourMJWF3 = {true, true, true, true}

    self.nSelFour2MJJuShu = 2
    self.nSelFour2MJFan = 3
    self.nSelFour2MJWF1 = 2
    self.nSelFour2MJWF2 = 1
    self.nSelFour2MJWF3 = {true, true, true, true}

    self.nSelHZBMJJuShu = 1
    self.nSelFourHZBMJJuShu = 1

    for i=1,2 do
        self._children["Panel".. i]:setVisible(false)
    end
    for i=1,4 do
        self._children["ImgBtn" .. i]:addTouchEventListener(function ( ... )
            --body
            self:onSelType(i)
        end)
    end
    self:onSelType(self.nSelType)
end

function RoomCreateLayer:onSelType(selType)
    -- body
    print("RoomCreateLayer:onSelType()", selType)
    if selType == nil then
        return
    end
    self.nSelType = selType
    if self.nSelType == 1 then
        self._children["ImgBtn1"]:loadTexture("xuez2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("fxzyj.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("4hongz.png", ccui.TextureResType.plistType)
        self._children["ImgBtn4"]:loadTexture("2hongz.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 2 then
        self._children["ImgBtn1"]:loadTexture("xuez.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("fxzmj2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("4hongz.png", ccui.TextureResType.plistType)
        self._children["ImgBtn4"]:loadTexture("2hongz.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 3 then
        self._children["ImgBtn1"]:loadTexture("xuez.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("fxzyj.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("4hongz2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn4"]:loadTexture("2hongz.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 4 then
        self._children["ImgBtn1"]:loadTexture("xuez.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("fxzyj.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("4hongz.png", ccui.TextureResType.plistType)
        self._children["ImgBtn4"]:loadTexture("2hongz2.png", ccui.TextureResType.plistType)
    end
    self:initView()
end

function RoomCreateLayer:initView()
    -- body
    if self.nSelType == 1 then
        self._children["Panel1"]:setVisible(true)
        self._children["Panel2"]:setVisible(false)

        local panel = self._children["Panel1"] 
        panel:loadTexture("res/dating/create_xz.png") 
        for i=1,2 do
            --局数
            local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
            local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFourMJJuShu then
                ImgSelFlag:setVisible(true)
            end

            imgJuShu:addTouchEventListener(function ( ... )
                --body
                self:onSelFourMJJuShuType(i)
            end)

            --自摸玩法
            local ImgWanFa1 = panel:getChildByName("ImgWanFa1" .. i)
            local ImgSelFlag = ImgWanFa1:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFourMJWF1 then
                ImgSelFlag:setVisible(true)
            end

            ImgWanFa1:addTouchEventListener(function ( ... )
                --body
                self:onSelFourMJWF1Type(i)
            end)

            --点杠花玩法
            local ImgWanFa2 = panel:getChildByName("ImgWanFa2" .. i)
            local ImgSelFlag = ImgWanFa2:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFourMJWF2 then
                ImgSelFlag:setVisible(true)
            end

            ImgWanFa2:addTouchEventListener(function ( ... )
                --body
                self:onSelFourMJWF2Type(i)
            end)
        end

        for i=1,3 do
            --番数
            local ImgFan = panel:getChildByName("ImgFan" .. i)
            local ImgSelFlag = ImgFan:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFourMJFan then
                ImgSelFlag:setVisible(true)
            end

            ImgFan:addTouchEventListener(function ( ... )
                --body
                self:onSelFourMJFanType(i)
            end)
        end

        for i=1,4 do
            --其他玩法
            local ImgWanFa3 = panel:getChildByName("ImgWanFa3" .. i)
            local ImgSelFlag = ImgWanFa3:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if self.nSelFourMJWF3[i] ~= nil and self.nSelFourMJWF3[i] then
                ImgSelFlag:setVisible(true)
            end

            ImgWanFa3:addTouchEventListener(function (sender,eventType )
                --body
                if eventType == ccui.TouchEventType.ended then
                    self:onSelFourMJWF3Type(i)
                end
            end)
        end
    elseif self.nSelType == 2 then
        self._children["Panel1"]:setVisible(true)
        self._children["Panel2"]:setVisible(false)

        local panel = self._children["Panel1"]
        panel:loadTexture("res/dating/create_yaoji.png")   
        for i=1,2 do
            --局数
            local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
            local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFour2MJJuShu then
                ImgSelFlag:setVisible(true)
            end

            imgJuShu:addTouchEventListener(function ( ... )
                --body
                self:onSelFour2MJJuShuType(i)
            end)

            --自摸玩法
            local ImgWanFa1 = panel:getChildByName("ImgWanFa1" .. i)
            local ImgSelFlag = ImgWanFa1:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFour2MJWF1 then
                ImgSelFlag:setVisible(true)
            end

            ImgWanFa1:addTouchEventListener(function ( ... )
                --body
                self:onSelFour2MJWF1Type(i)
            end)

            --点杠花玩法
            local ImgWanFa2 = panel:getChildByName("ImgWanFa2" .. i)
            local ImgSelFlag = ImgWanFa2:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFour2MJWF2 then
                ImgSelFlag:setVisible(true)
            end

            ImgWanFa2:addTouchEventListener(function ( ... )
                --body
                self:onSelFour2MJWF2Type(i)
            end)
        end

        for i=1,3 do
            --番数
            local ImgFan = panel:getChildByName("ImgFan" .. i)
            local ImgSelFlag = ImgFan:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFour2MJFan then
                ImgSelFlag:setVisible(true)
            end

            ImgFan:addTouchEventListener(function ( ... )
                --body
                self:onSelFour2MJFanType(i)
            end)
        end

        for i=1,4 do
            --其他玩法
            local ImgWanFa3 = panel:getChildByName("ImgWanFa3" .. i)
            local ImgSelFlag = ImgWanFa3:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if self.nSelFour2MJWF3[i] ~= nil and self.nSelFour2MJWF3[i] then
                ImgSelFlag:setVisible(true)
            end

            ImgWanFa3:addTouchEventListener(function (sender,eventType )
                --body
                if eventType == ccui.TouchEventType.ended then
                    self:onSelFour2MJWF3Type(i)
                end
            end)
        end
    elseif self.nSelType == 3 then
        self._children["Panel1"]:setVisible(false)
        self._children["Panel2"]:setVisible(true)

        local panel = self._children["Panel2"]  
        for i=1,2 do
            --局数
            local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
            local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelFourHZBMJJuShu then
                ImgSelFlag:setVisible(true)
            end

            imgJuShu:addTouchEventListener(function ( ... )
                --body
                self:onSelFourHZBMJJuShuType(i)
            end)  
        end
    elseif self.nSelType == 4 then
        self._children["Panel1"]:setVisible(false)
        self._children["Panel2"]:setVisible(true)

        local panel = self._children["Panel2"]  
        for i=1,2 do
            --局数
            local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
            local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelHZBMJJuShu then
                ImgSelFlag:setVisible(true)
            end

            imgJuShu:addTouchEventListener(function ( ... )
                --body
                self:onSelHZBMJJuShuType(i)
            end)  
        end
    end
end

function RoomCreateLayer:onSelFourMJJuShuType(nSelType)
    -- body
    self.nSelFourMJJuShu = nSelType
    local panel = self._children["Panel1"]
    for i=1,2 do
        --局数
        local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
        local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFourMJJuShu then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFour2MJJuShuType(nSelType)
    -- body
    self.nSelFour2MJJuShu = nSelType
    local panel = self._children["Panel1"]
    for i=1,2 do
        --局数
        local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
        local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFour2MJJuShu then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelHZBMJJuShuType(nSelType)
    -- body
    self.nSelHZBMJJuShu = nSelType
    local panel = self._children["Panel2"]
    for i=1,2 do
        --局数
        local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
        local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelHZBMJJuShu then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFourHZBMJJuShuType(nSelType)
    -- body
    self.nSelFourHZBMJJuShu = nSelType
    local panel = self._children["Panel2"]
    for i=1,2 do
        --局数
        local imgJuShu = panel:getChildByName("ImgJuShu" .. i)
        local ImgSelFlag = imgJuShu:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFourHZBMJJuShu then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFourMJFanType(nSelType)
    -- body
    self.nSelFourMJFan = nSelType
    local panel = self._children["Panel1"]
    for i=1,3 do
        --番数
        local ImgFan = panel:getChildByName("ImgFan" .. i)
        local ImgSelFlag = ImgFan:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFourMJFan then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFour2MJFanType(nSelType)
    -- body
    self.nSelFour2MJFan = nSelType
    local panel = self._children["Panel1"]
    for i=1,3 do
        --番数
        local ImgFan = panel:getChildByName("ImgFan" .. i)
        local ImgSelFlag = ImgFan:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFour2MJFan then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFourMJWF1Type(nSelType)
    -- body
    self.nSelFourMJWF1 = nSelType
    local panel = self._children["Panel1"]
    for i=1,2 do
        --自摸玩法
        local ImgWanFa1 = panel:getChildByName("ImgWanFa1" .. i)
        local ImgSelFlag = ImgWanFa1:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFourMJWF1 then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFour2MJWF1Type(nSelType)
    -- body
    self.nSelFour2MJWF1 = nSelType
    local panel = self._children["Panel1"]
    for i=1,2 do
        --自摸玩法
        local ImgWanFa1 = panel:getChildByName("ImgWanFa1" .. i)
        local ImgSelFlag = ImgWanFa1:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFour2MJWF1 then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFourMJWF2Type(nSelType)
    -- body
    self.nSelFourMJWF2 = nSelType
    local panel = self._children["Panel1"]
    for i=1,2 do
        --点杠花玩法
        local ImgWanFa2 = panel:getChildByName("ImgWanFa2" .. i)
        local ImgSelFlag = ImgWanFa2:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFourMJWF2 then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFour2MJWF2Type(nSelType)
    -- body
    self.nSelFour2MJWF2 = nSelType
    local panel = self._children["Panel1"]
    for i=1,2 do
        --点杠花玩法
        local ImgWanFa2 = panel:getChildByName("ImgWanFa2" .. i)
        local ImgSelFlag = ImgWanFa2:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelFour2MJWF2 then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RoomCreateLayer:onSelFourMJWF3Type(nSelType)
    -- body
    if not self.nSelFourMJWF3[nSelType] then
        self.nSelFourMJWF3[nSelType] = true 
    else
        self.nSelFourMJWF3[nSelType] = false 
    end
    local panel = self._children["Panel1"]
    local ImgWanFa3 = panel:getChildByName("ImgWanFa3" .. nSelType)
    local ImgSelFlag = ImgWanFa3:getChildByName("ImgSelFlag")
    ImgSelFlag:setVisible(self.nSelFourMJWF3[nSelType])
end

function RoomCreateLayer:onSelFour2MJWF3Type(nSelType)
    -- body
    if not self.nSelFourMJWF3[nSelType] then
        self.nSelFour2MJWF3[nSelType] = true 
    else
        self.nSelFour2MJWF3[nSelType] = false 
    end
    local panel = self._children["Panel1"]
    local ImgWanFa3 = panel:getChildByName("ImgWanFa3" .. nSelType)
    local ImgSelFlag = ImgWanFa3:getChildByName("ImgSelFlag")
    ImgSelFlag:setVisible(self.nSelFour2MJWF3[nSelType])
end

function RoomCreateLayer:createRoom()
    -- body
    local params = {}
    params["zorder"] = 1024
    app:openDialog("LoadingLayer", params)
    
    local iKind = 0
    local iRound = 0
    local iWF = 0
    if self.nSelType == 1 then
        iKind = 302
        --局数
        if self.nSelFourMJJuShu == 1 then
            iRound = 4
        elseif self.nSelFourMJJuShu == 2 then
            iRound = 8
        end

        --番数
        if self.nSelFourMJFan == 1 then
            iWF = cc.MEFvMask:Add(iWF, RULE_3_1_1)
        elseif self.nSelFourMJFan == 2 then
            iWF = cc.MEFvMask:Add(iWF, RULE_3_1_2)
        elseif self.nSelFourMJFan == 3 then
            iWF = cc.MEFvMask:Add(iWF, RULE_3_1_3)
        end

        --自摸玩法
        if self.nSelFourMJWF1 == 1 then -- true
            iWF = cc.MEFvMask:Add(iWF, RULE_2_1)
        elseif self.nSelFourMJWF1 == 2 then --false
            --iWF = cc.MEFvMask:Add(iWF, RULE_2_1)
        end

        --点杠玩法
        if self.nSelFourMJWF2 == 1 then
            iWF = cc.MEFvMask:Add(iWF, RULE_2_2)
        elseif self.nSelFourMJWF2 == 2 then
            --iWF = cc.MEFvMask:Add(iWF, RULE_2_2)
        end

        --其他多选玩法
        local tWF = {RULE_4_1_1, RULE_4_1_2, RULE_4_1_3, RULE_4_1_4}
        for k,v in pairs(self.nSelFourMJWF3) do
            if v then
                iWF = cc.MEFvMask:Add(iWF, tWF[k])
            end
        end
    elseif self.nSelType == 2 then
        iKind = 301
        --局数
        if self.nSelFour2MJJuShu == 1 then
            iRound = 4
        elseif self.nSelFour2MJJuShu == 2 then
            iRound = 8
        end

        --番数
        if self.nSelFour2MJFan == 1 then
            iWF = cc.MEFvMask:Add(iWF, RULE_3_1_1)
        elseif self.nSelFour2MJFan == 2 then
            iWF = cc.MEFvMask:Add(iWF, RULE_3_1_2)
        elseif self.nSelFour2MJFan == 3 then
            iWF = cc.MEFvMask:Add(iWF, RULE_3_1_3)
        end

        --自摸玩法
        if self.nSelFour2MJWF1 == 1 then -- true
            iWF = cc.MEFvMask:Add(iWF, RULE_2_1)
        elseif self.nSelFour2MJWF1 == 2 then --false
            --iWF = cc.MEFvMask:Add(iWF, RULE_2_1)
        end

        --点杠玩法
        if self.nSelFour2MJWF2 == 1 then
            iWF = cc.MEFvMask:Add(iWF, RULE_2_2)
        elseif self.nSelFour2MJWF2 == 2 then
            --iWF = cc.MEFvMask:Add(iWF, RULE_2_2)
        end

        --其他多选玩法
        local tWF = {RULE_4_1_1, RULE_4_1_2, RULE_4_1_3, RULE_4_1_4}
        for k,v in pairs(self.nSelFour2MJWF3) do
            if v then
                iWF = cc.MEFvMask:Add(iWF, tWF[k])
            end
        end
    elseif self.nSelType == 3 then
        iKind = 350
        --局数
        if self.nSelFourHZBMJJuShu == 1 then
            iRound = 4
        elseif self.nSelFourHZBMJJuShu == 2 then
            iRound = 8
        end
    elseif self.nSelType == 4 then
        iKind = 351
        --局数
        if self.nSelHZBMJJuShu == 1 then
            iRound = 4
        elseif self.nSelHZBMJJuShu == 2 then
            iRound = 8
        end
    end
    print("iKind, iRound, iWF", iKind, iRound, iWF )
    self.params.createCustomRoomCallBack(iKind, iRound, iWF)
end

return RoomCreateLayer