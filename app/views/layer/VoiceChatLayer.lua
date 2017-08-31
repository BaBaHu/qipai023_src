
local VoiceChatLayer = class("VoiceChatLayer", cc.load("mvc").DialogBase)
VoiceChatLayer.RESOURCE_FILENAME = "yuyin_layer.csb"

function VoiceChatLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:initUI()
end

function VoiceChatLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["panel"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    self.listView = self._children["ListView"]
    local item = self.listView:getChildByName("item")
    item:setVisible(false)
    self.listView:setItemModel(item)

    self:initView()
end

function VoiceChatLayer:initView()
    -- body
    self.listView:removeAllChildren()

    for i=1, #GameChatConfig do
        self.listView:pushBackDefaultItem()
    end

    local nIdx = 1
    for i = 1, #GameChatConfig do
        print(i)
        local item       = self.listView:getItem(i - 1)
        item:setVisible(true)

        local labelText   = item:getChildByName("labelText")
        item:setTag(nIdx)
        labelText:setString(GameChatConfig[nIdx])

        nIdx = nIdx + 1

        local function onClicked(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local tag = sender:getTag()
                print("tag ==============================", tag)
                self:OnChat(tag)
            end
        end
        item:addTouchEventListener(onClicked)
    end
end

function VoiceChatLayer:OnChat(nIdx)
    print("VoiceChatLayer:OnChat(nIdx)...............", nIdx)
    app:backDialog()
    cc.MENetUtil:playChat(cc.MENetUtil:getChairID(), nIdx, cc.MENetUtil:getSex() )
    local data = {}
    data["cbChatType"] = 1
    data["dwSendChairID"] = cc.MENetUtil:getChairID()
    data["idx"] = nIdx
    data["sex"] = cc.MENetUtil:getSex()
    EventDispatcher:dispatchEvent(EventMsgDefine.PlayVoiceText, data)
end

return VoiceChatLayer
