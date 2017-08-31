
local SelectRoomLayer = class("SelectRoomLayer", cc.load("mvc").DialogBase)
SelectRoomLayer.RESOURCE_FILENAME = "select_room_layer.csb"

function SelectRoomLayer:onCreate(params)
    print("SelectRoomLayer:onCreate(params)", params)
    --self:setInOutEffectEnable(true)
    self.params = params
    self.nCurShowPage = 1
    self.nMaxShowPage = math.min(3, math.ceil(#self.params.serverList/3))
    print(self.nMaxShowPage)
    self.isbInit = true
    self.itemList = {}
    if not audio.isMusicPlaying() then
      audio.playMusic("music/plaza_bg_music.mp3",true)
    end

    local function removeSelf()
        self:removeFromParent()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
   
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)
    self:registerScrollEventListener()

    for i = 1, 3 do
        local ImgPage = self._children["panel"]:getChildByName("ImgPage" .. i)
        ImgPage:setVisible(false)
    end
    self:SwitchPage(self.nCurShowPage)
end

--注册滑动事件
function SelectRoomLayer:registerScrollEventListener()
    -- body
    local touchPanel = self._children["touchPanel"]

    local function onTouchBegan(touch, event)
        --获取当前触控点相对与事件监听对象的位置
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            self.touchBegin = locationInNode
            return true
        end
        return false
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local deltPos = cc.pSub(locationInNode, self.touchBegin)
        local nDir = -1
        if deltPos.x <= -80 then
            --向左
            nDir = 2
        elseif deltPos.x >= 80 then
            --向右
            nDir = 1
        end
        if nDir ~= -1 then
            self:onArrowBtnClick(nDir)
        else
            self:onArrowBtnClick2(locationInNode)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = touchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchPanel)
    self.listener = listener
end

--1上一个 2下一个
function SelectRoomLayer:onArrowBtnClick(direct)
    print("SelectRoomLayer:onArrowBtnClick = ", direct )
    if direct == 1 then
        if self.nCurShowPage <= 1 then
            return
        end
        self.nCurShowPage = self.nCurShowPage - 1
        if self.nCurShowPage <= 1 then 
            self.nCurShowPage = 1
        end    
    elseif direct == 2 then
        if self.nCurShowPage >= self.nMaxShowPage then
            return
        end
        self.nCurShowPage = self.nCurShowPage + 1
        if self.nCurShowPage >= self.nMaxShowPage then 
            self.nCurShowPage = self.nMaxShowPage
        end
    end
    self:SwitchPage(self.nCurShowPage)
end

--切换显示页
function SelectRoomLayer:SwitchPage(showIdx)
    if self.nMaxShowPage > 1 then
        for i = 1, self.nMaxShowPage do
            local ImgPage = self._children["panel"]:getChildByName("ImgPage" .. i)
            ImgPage:setVisible(true)
            if i == showIdx then
                ImgPage:loadTexture("point2.png", ccui.TextureResType.plistType)
            else
                ImgPage:loadTexture("point1.png", ccui.TextureResType.plistType)
            end
        end
    end
    --刷新视图
    self:initView(showIdx) 
end

--1上一个 2下一个
function SelectRoomLayer:onArrowBtnClick2(touch)
    print("SelectRoomLayer:onArrowBtnClick2 = ", touch )
    local nIdx = -1
    for k,v in pairs(self.itemList) do
       local s = v.item:getContentSize()
       local pos = cc.p(v.item:getPosition())
       local rect = cc.rect(pos.x - s.width/2, pos.y - s.height/2, s.width, s.height)
       print("rect", k, rect)
       if cc.rectContainsPoint(rect, touch) then
           nIdx = k
           break
       end
    end
    
    if nIdx == -1 then
       return
    end
    MEAudioUtils.playSoundEffect("sound/btnClick.mp3")
    if nIdx == 1 then
        self:starGame()
    else
        if #self.itemList == 3 then
            self:play3Effect( nIdx )
        elseif #self.itemList == 2 then
            self:play2Effect( nIdx )
        else
            self:starGame()
        end
    end
end

function SelectRoomLayer:starGame()
    local data = self.itemList[1]
    print("点击",data)
    if data.idx == -1 or data.serverID == -1 then
        self:showTips("该房间未开放！")
        return
    end
    local params = {}
    params["zorder"] = 1024
    app:openDialog("LoadingLayer", params)

    cc.MENetUtil:init(data.kindID, GameListConfig[data.kindID].player, PLATFORM_VERSION, data.serverName)
    self.params.enterRoomCallBack(data.kindID, data.serverID)
end

function SelectRoomLayer:play3Effect( idx )
    -- body
    print("idx = ", idx)
    print("before:", self.itemList)

    local item1 = self.itemList[1].item
    local pos1 = cc.p(item1:getPosition())

    local item2 = self.itemList[2].item
    local pos2 = cc.p(item2:getPosition())

    local item3 = self.itemList[3].item
    local pos3 = cc.p(item3:getPosition())

    local function finish( ... )
        -- body
        print("after:", self.itemList)
        for k,v in pairs(self.itemList) do
            if k == 1 then
                v.item:setScale(1.0)
                v.item:setOpacity(255)
            else
                v.item:setScale(0.8)
                v.item:setOpacity(120)
            end
        end
    end

    if idx == 2 then
        --顺时针
        local head = clone(self.itemList[1])
        local tail = clone(self.itemList[3])

        local function show2()
            -- body
            local action = cc.Sequence:create(
                cc.MoveTo:create(0.25, pos2),
                cc.ScaleTo:create(0.05,0.8),
                cc.CallFunc:create(function()
                    self.itemList[2] = tail
                    finish()
                end)
            )
            item3:setOpacity(120)
            item3:runAction(action)
        end

        local function show1()
            -- body
            local action = cc.Sequence:create(
                cc.MoveTo:create(0.23, pos3),
                cc.ScaleTo:create(0.05,0.8),
                cc.CallFunc:create(function()
                    self.itemList[3] = head
                end)
              )
            item1:setOpacity(120)
            item1:runAction(action)
        end

        local function show()
            local action = cc.Sequence:create(
                cc.MoveTo:create(0.2, pos1),
                cc.ScaleTo:create(0.05,1),
                cc.CallFunc:create(function()
                    self.itemList[1] = self.itemList[2]
                end)
            )
            item2:setOpacity(255)
            item2:runAction(action)
        end
        show()
        show1()
        show2()
    elseif idx == 3 then
        --逆时针
        local head = clone(self.itemList[1])
        local tail = clone(self.itemList[2])

        local function show2()
            -- body
            local action = cc.Sequence:create(
                cc.MoveTo:create(0.25, pos3),
                cc.ScaleTo:create(0.05,0.8),
                cc.CallFunc:create(function()
                    self.itemList[3] = tail
                    finish()
                end)
            )
            item2:setOpacity(120)
            item2:runAction(action)
        end

        local function show1()
            -- body
            local action = cc.Sequence:create(
                cc.MoveTo:create(0.23, pos2),
                cc.ScaleTo:create(0.05,0.8),
                cc.CallFunc:create(function()
                    self.itemList[2] = head
                end)
              )
            item1:setOpacity(120)
            item1:runAction(action)
        end

        local function show()
            local action = cc.Sequence:create(
                cc.MoveTo:create(0.2, pos1),
                cc.ScaleTo:create(0.05,1.0),
                cc.CallFunc:create(function()
                    self.itemList[1] = self.itemList[3]
                end)
            )
            item3:setOpacity(255)
            item3:runAction(action)
        end
        show()
        show1()
        show2()
    end
end

function SelectRoomLayer:play2Effect( idx )
    -- body
    print("idx = ", idx)
    print("before:", self.itemList)

    local item1 = self.itemList[1].item
    local pos1 = cc.p(item1:getPosition())

    local item2 = self.itemList[2].item
    local pos2 = cc.p(item2:getPosition())

    local function finish( ... )
        -- body
        print("after:", self.itemList)
        for k,v in pairs(self.itemList) do
            if k == 1 then
                v.item:setScale(1.0)
                v.item:setOpacity(255)
            else
                v.item:setScale(0.8)
                v.item:setOpacity(120)
            end
        end
    end

    --顺时针
    local head = clone(self.itemList[1])
    local tail = clone(self.itemList[2])

    local function show1()
        -- body
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.23, pos2),
            cc.ScaleTo:create(0.05,0.8),
            cc.CallFunc:create(function()
                self.itemList[2] = head
            end)
            )
        item1:setOpacity(120)
        item1:runAction(action)
    end

    local function show()
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.2, pos1),
            cc.ScaleTo:create(0.05,1),
            cc.CallFunc:create(function()
                self.itemList[1] = self.itemList[2]
            end)
        )
        item2:setOpacity(255)
        item2:runAction(action)
    end
    show()
    show1()
end
function SelectRoomLayer:initView(showIdx)
    -- body
    self.itemList = {}
    local panel = self._children["panel"]
    
    local nStartIdx = (showIdx-1)*3 + 1
    local nEndIdx = nStartIdx + 3 - 1
    print("showIdx , nStartIdx , nEndIdx", showIdx, nStartIdx, nEndIdx)

    for i= nStartIdx, nEndIdx do
        local item = self._children["ImgItem" .. i]
        local data = {}
        if self.params.serverList[i] ~= nil then
            local labelName = item:getChildByName("labelName")
            labelName:setString(self.params.serverList[i].serverName)
            data["idx"]             = self.params.serverList[i].idx
            data["kindID"]          = self.params.serverList[i].kindID
            data["serverID"]        = self.params.serverList[i].serverID
            data["limit"]           = self.params.serverList[i].limit
            data["serverName"]      = self.params.serverList[i].serverName
            data["item"] = item
            if #self.itemList == 0 then
               item:setScale(1.0)
               item:setOpacity(255)
            else
               item:setScale(0.8)
               item:setOpacity(120)
            end
            self.itemList[#self.itemList + 1] = data
        else
            item:setVisible(false)
        end
    end

    if self.isbInit then
        self.isbInit = false
        if #self.itemList > 1 then
            self:playInitEffect()
        end
    end
end

function SelectRoomLayer:playInitEffect()
    -- body
    local function show2(item, pos)
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.3, pos)
        )
        item:setOpacity(120)
        item:runAction(action)
    end

    local function show(item, pos)
        -- body
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.25, pos)
        )
        item:setOpacity(255)
        item:runAction(action)
    end

    local item1 = self.itemList[1].item
    local pos1 = cc.p(item1:getPosition())

    for i=1, #self.itemList do
        local item = self.itemList[i].item
        local pos = cc.p(item:getPosition())

        if i == 1 then
            item:setPosition(cc.p(pos1.x + 50, pos1.y))
            show(item, pos)
        else
            item:setPosition(pos1)
            show2(item, pos)
        end
    end
end

return SelectRoomLayer
