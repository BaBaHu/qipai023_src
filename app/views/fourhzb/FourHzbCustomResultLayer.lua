
local FourHzbCustomResultLayer = class("FourHzbCustomResultLayer", cc.load("mvc").DialogBase)
FourHzbCustomResultLayer.RESOURCE_FILENAME = "game_erhzb/hzb_custom_result_layer.csb"

local tCreaterPos = {
    [1] = cc.p(480, 570),
    [2] = cc.p(810, 570),
    [3] = cc.p(1120, 570),
    [4] = cc.p(1440, 570),
}
local tBigWinPos = {
    [1] = cc.p(590, 510),
    [2] = cc.p(910, 510),
    [3] = cc.p(1230, 510),
    [4] = cc.p(1550, 510),
}

function FourHzbCustomResultLayer:onCreate(data) 
    print("FourHzbCustomResultLayer:onCreate(data).............", data)

    local nPos = cc.p(self._children["panel"]:getPosition())
    local s = self._children["panel"]:getContentSize()
    self._children["panel"]:setPosition(cc.p(nPos.x, display.height + s.height))
    local seq = cc.Sequence:create(
        cc.MoveTo:create(0.5, nPos),
        cc.CallFunc:create(function()
            
        end)
    )
    self._children["panel"]:runAction(seq) 

    self._children["labelMessage"]:setString(data.szMessage)

    local nMaxScore = 0
    local nMaxInx = 0
    for i=1,4 do
        if data.dwUserID[i] == data.wTableOwner then
            local imgBg = display.newSprite("#creater_room.png")
            self._children["panel"]:addChild(imgBg)
            imgBg:setPosition(tCreaterPos[i])
        end

        self._children["labScore" .. i]:setString(data.lUserScore[i])
        self._children["labName" .. i]:setString(data.szNick[i])

        local head = self._children["ImgHead" .. i]
        if cc.MENetUtil:getChairID() == i-1 then
            local url = cc.MENetUtil:getUserIconUrl()
            if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
                local faceId = cc.MENetUtil:getFaceID()%20 + 1
                head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
            else
                --下载头像
                print("url = ", url)
                local customid = Helper:md5sum(url)
                local filename = Helper:getFileNameByUrl(url, customid)
                print(filename)
                head:loadTexture(filename)
            end
        else
            if data.targetType == 0 or data.targetUrl == "" then
                local faceId = data.dwUserFace[i]%20 + 1
                head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
            else
                --下载头像
                print("url = ", data.targetUrl)
                GameLogicManager:downAvatar(data.targetUrl, 
                function ( ... )
                    -- body
                end,
                function (filename)
                    -- body
                    print(filename)
                    head:loadTexture(filename)
                end)
            end
        end
        
        if data.lUserScore[i] >= nMaxScore then
            nMaxScore = data.lUserScore[i]
            nMaxInx = i
        end
    end
    local imgBg = display.newSprite("#big_winer.png")
    self._children["panel"]:addChild(imgBg)
    imgBg:setPosition(tBigWinPos[nMaxInx])

    self._children["btn_share"]:addClickEventListener(function() 
        GameLogicManager:WeiXinShareScreen()
    end)

    self._children["btn_back"]:addClickEventListener(function()
        app:backDialog()
        EventDispatcher:dispatchEvent(EventMsgDefine.GotoMainScene)
    end)
end

return FourHzbCustomResultLayer
