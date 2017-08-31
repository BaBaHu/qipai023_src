
local FourCustomResultLayer = class("FourCustomResultLayer", cc.load("mvc").DialogBase)
FourCustomResultLayer.RESOURCE_FILENAME = "game_fourmj/four_custom_result_layer.csb"

local tCreaterPos = {
    [1] = cc.p(350, 725),
    [2] = cc.p(810, 725),
    [3] = cc.p(1265, 725),
    [4] = cc.p(1725, 725),
}

local tBigWinPos = {
    [1] = cc.p(99, 744),
    [2] = cc.p(560, 744),
    [3] = cc.p(1020, 744),
    [4] = cc.p(1478, 744),
}

local tBestDPPos = {
    [1] = cc.p(405, 220),
    [2] = cc.p(867, 220),
    [3] = cc.p(1323, 220),
    [4] = cc.p(1783, 220),
}

function FourCustomResultLayer:onCreate(data) 
    print("FourCustomResultLayer:onCreate(data).............", data)

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

    local nMaxDPCount = 0
    local nMaxDPInx = 0
    for i=1,4 do
        if data.dwUserID[i] == data.wTableOwner then
            local imgBg = display.newSprite("#creater_room.png")
            self._children["panel"]:addChild(imgBg)
            imgBg:setPosition(tCreaterPos[i])
        end

        self._children["labScore" .. i]:setString(data.lUserScore[i])
        self._children["labName" .. i]:setString(data.szNick[i])

        self._children["labZM" .. i]:setString(data.dwDataCount[i].dwZMCount)
        self._children["labJP" .. i]:setString(data.dwDataCount[i].dwJPCount)
        self._children["labDP" .. i]:setString(data.dwDataCount[i].dwDPCount)
        self._children["labAG" .. i]:setString(data.dwDataCount[i].dwAGCount)
        self._children["labMG" .. i]:setString(data.dwDataCount[i].dwMGCount)
        self._children["labCDJ" .. i]:setString(data.dwDataCount[i].dwCJCount)

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
            local user = data.users[i]
            if user.type == 0 or user.url == "" then
                local faceId = data.dwUserFace[i]%20 + 1
                head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
            else
                --下载头像
                print("url = ", user.url)
                GameLogicManager:downAvatar(user.url, 
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

        if data.dwDataCount[i].dwDPCount >= nMaxDPCount then
            nMaxDPCount = data.dwDataCount[i].dwDPCount
            nMaxDPInx = i
        end
    end
    print("nMaxInx, nMaxDPInx", nMaxInx, nMaxDPInx)
    local imgBg = display.newSprite("#big_winer.png")
    self._children["panel"]:addChild(imgBg)
    imgBg:setPosition(tBigWinPos[nMaxInx])

    local imgBg = display.newSprite("#zuijiapaoshou.png")
    self._children["panel"]:addChild(imgBg)
    imgBg:setPosition(tBestDPPos[nMaxDPInx])

    self._children["btn_share"]:addClickEventListener(function() 
        GameLogicManager:WeiXinShareScreen()
    end)

    self._children["btn_back"]:addClickEventListener(function()
        app:backDialog()
        EventDispatcher:dispatchEvent(EventMsgDefine.GotoMainScene)
    end)
end

return FourCustomResultLayer
