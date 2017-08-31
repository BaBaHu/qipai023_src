
local MainScene = class("MainScene", cc.load("mvc").SceneBase)
MainScene.RESOURCE_FILENAME = "main_scene.csb"

function MainScene:onCreate(params)
    print("MainScene:onCreate(params).................", params)
    self:init(params)
    self:addEventListener(EventMsgDefine.ShowNoticeMsg,self.ShowNoticeMsg,self)
end

function MainScene:init(params)
    -- body
    self.isExpandFinish = true
    self.params = params
    self.gameList = {}
    self.serverList = {}

    --注册GameKind监听回调
    local function OnGameKindBackListener(kindID, kindName)
        -- body
        print("OnGameKindBackListener.......................", kindID, kindName)
        if GameListConfig[kindID] ~= nil then 
            self.gameList[#self.gameList + 1] = {
                idx    = GameListConfig[kindID].idx,
                kindID = kindID, 
                kindName = kindName
            }
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameKindBack", OnGameKindBackListener)
    
    
    --注册ServerList监听回调
    local function OnServerListBackListener(idx, kindID, serverID, serverName, limit)
        -- body
        print("OnServerListBackListener.......................", idx, kindID, serverID, serverName, limit)
        self.serverList[#self.serverList + 1] = 
        {
            idx = idx,
            kindID = kindID,
            serverID = serverID,
            serverName = serverName,
            limit = limit,
        }
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onServerListBack", OnServerListBackListener)

     --注册ServerListFinsih监听回调
    local function OnServerListFinsihBackListener()
        -- body
        print("OnServerListFinsihBackListener.......................")
        app:closeDialog("LoadLayer")
        dump(self.serverList)
        table.sort(self.serverList,function(v1,v2) return v1.limit<v2.limit end )
        local params = {}
        params["serverList"] = self.serverList
        params["enterRoomCallBack"] = function ( kindID, serverID )
            -- body
            self.serverList_:enterServerRoom(kindID, serverID)
        end
        app:openDialog("SelectRoomLayer", params)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onServerListFinishBack", OnServerListFinsihBackListener)

    self.serverList_ = cc.ServerListUI:create(NET_IP_ADDRESS, NET_PORT)     -- 
    self.serverList_:retain()

    self.customRoomUI_ = cc.CustonRoomUI:create(NET_IP_ADDRESS, NET_PORT)
    self.customRoomUI_:retain()
end

function MainScene:initEvent()
    -- body
    --注册loginGame监听回调
    local function OnLoginGameBackListener(kindID, serverID)
        -- body
        print("OnLoginGameBackListener.......................", kindID, serverID)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onLoginGameBack")
        app:closeDialog("LoadingLayer")
        if kindID == 122 then
            --检测玩家是否还在游戏中
            if cc.MENetUtil:isGamePlaying() then
                self:preLoadRes(GameListConfig[kindID].scene, function ( ... )
                    -- body
                    app:enterScene(GameListConfig[kindID].scene)
                end)
            else
                cc.MENetUtil:autoJoin()
            end
        else 
            local params = {}
            params["kindID"] = kindID
            params["serverID"] = serverID
            app:enterScene("TableScene", params)
        end
    end                                                                 -- ServerListUI:create 中有 onLoginGameBack  的调用
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onLoginGameBack", OnLoginGameBackListener)
    
    --注册loginGameError监听回调
    local function OnLoginGameErrorBackListener(strDesc)
        -- body
        print("OnLoginGameErrorBackListener.....................................", strDesc)
        app:closeDialog("LoadingLayer")
        self:showTips(strDesc)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onLoginGameErrorBack", OnLoginGameErrorBackListener)
    
    --注册SitDownSuccess监听回调
    local function OnSitDownSuccessBackListener(kindID)
        -- body
        print("OnSitDownSuccessBackListener.....................................")
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownErrorBack")
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownSuccessBack")
        
        self:preLoadRes(GameListConfig[kindID].scene, function ( ... )
            -- body
            app:enterScene(GameListConfig[kindID].scene)
        end)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onSitDownSuccessBack", OnSitDownSuccessBackListener)
    
    --注册SitDownError监听回调
    local function OnSitDownErrorBackListener(strDesc)
        -- body
        print("OnSitDownErrorBackListener...............................", strDesc)
        app:closeDialog("LoadingLayer")
        self:showTips(strDesc)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onSitDownErrorBack", OnSitDownErrorBackListener)

    --注册CreateCustomRoomError监听回调
    local function OnCreateCustomRoomErrorBackListener(errorCode)
        -- body
        print("OnCreateCustomRoomErrorBackListener...............................", errorCode)
        app:closeDialog("LoadingLayer")
        local idx
        if errorCode == 2 then
            idx = 28
        elseif errorCode == 3 then
            idx = 30
        elseif errorCode == 1 then
            idx = 29
        else
            idx = 27
        end
        self:showTips(GameTipsConfig[idx])
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onCreateCustomRoomErrorBack", OnCreateCustomRoomErrorBackListener)

    --注册EnterCustomRoomError监听回调
    local function OnEnterCustomRoomErrorBackListener(errorCode)
        -- body
        print("OnCreateCustomRoomErrorBackListener...............................", errorCode)
        app:closeDialog("LoadingLayer")
        self:showTips(GameTipsConfig[errorCode])
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onEnterCustomRoomErrorBack", OnEnterCustomRoomErrorBackListener)

    --注册EnterCustomRoom监听回调
    local function OnEnterCustomRoomBackListener(dwRoomID, kindID, serverName)
        -- body
        print("OnEnterCustomRoomBackListener...............................",dwRoomID, kindID, serverName)
        --app:closeDialog("LoadingLayer")
        cc.MENetUtil:init(kindID, GameListConfig[kindID].player, PLATFORM_VERSION, serverName)
        self.customRoomUI_:enterCustomRoom(dwRoomID)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onEnterCustomRoomBack", OnEnterCustomRoomBackListener)

    --注册BaseEnsure监听回调
    local function OnBaseEnsureBackListener(bSucc, strDesc)
        -- body
        print("OnBaseEnsureBackListener...............................", bSucc, strDesc)
        if bSucc then
            EventDispatcher:dispatchEvent(EventMsgDefine.UpdateBankData)
        end
        self:showTips(strDesc)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onBaseEnsureBack", OnBaseEnsureBackListener)

end

function MainScene:preLoadRes(sceneName, callback )
    -- body
    local t 
    if sceneName == "MaJiangScene" then
        t = {
            [1] = "res/effect/MJTime/MJTime.ExportJson",
            [2] = "res/effect/MJHu/MJHu.ExportJson",
            [3] = "res/effect/MJPeng/MJPeng.ExportJson",
            [4] = "res/effect/MJGang/MJGang.ExportJson",
            [5] = "res/effect/MJMan/MJMan.ExportJson",
            [6] = "res/effect/MJWoman/MJWoman.ExportJson",
            [7] = "res/effect/MJVoice/MJVoice.ExportJson",
        }
    elseif sceneName == "FourMaJiangScene" or sceneName == "FourMJScene" or sceneName == "FourHzbScene" then
        t = {
            [1] = "res/effect/MjCardArrow/MjCardArrow.ExportJson",
            [2] = "res/effect/MjDianPao/MjDianPao.ExportJson",
            [3] = "res/effect/MJPeng2/MJPeng.ExportJson",
            [4] = "res/effect/MJGang2/MJGang.ExportJson",
            [5] = "res/effect/MJZiMo/MJZiMo.ExportJson",
            [6] = "res/effect/MJHu2/MJHu2.ExportJson",
            [7] = "res/effect/MJVoice/MJVoice.ExportJson",
        }
        if sceneName == "FourMaJiangScene" or sceneName == "FourMJScene" then
            t[8] = "res/effect/MJGuanFeng/MJGuanFeng.ExportJson"
            t[9] = "res/effect/MJXiaYu/MJXiaYu.ExportJson"
        end
        if sceneName == "FourHzbScene" then
            t[8] = "res/effect/MJHu/MJHu.ExportJson"
        end
    elseif sceneName == "BaiJiaLeScene" then
        t = {
            [1] = "res/effect/BJLEffect1/BJLEffect1.ExportJson",
            [2] = "res/effect/MJVoice/MJVoice.ExportJson",
        }
    end

    local progress = 0
    local function dataLoaded()
        -- body
        progress = progress + 1
        if progress == #t then
            callback()
        end
    end
    for k,v in pairs(t) do
        ResLoadControl:instance():loadArmatureModelResAsync(v, dataLoaded, true)
    end
end

function MainScene:onEnterTransitionFinish()
    print("MainScene:onEnterTransitionFinish() ...................................")
    self:initEvent()        -- 房间加载完毕后，注册事件。
    self:initUI()
    self:registerDialogMessageListener()
    
    if not audio.isMusicPlaying() then
        audio.playMusic("music/plaza_bg_music.mp3",true)
    end

    local function OnLoad( ... )
        -- body
    end
    ResLoadControl:instance():loadArmatureModelResAsync("res/effect/MJLoad/MJLoad.ExportJson", OnLoad, true)
    
    if self.params ~= nil and self.params.isShowGoBack ~= nil and self.params.isShowGoBack then
        --不拉了
    else
        self.customRoomUI_:checkAutoEnterCustomGame()
    end

    display.loadImage("res/dating/room.png", function ( ... )
        -- body
    end)
    display.loadImage("res/dating/join_room.png", function ( ... )
        -- body
    end)
    display.loadImage("res/dating/create_room.png", function ( ... )
        -- body
    end)

end

function MainScene:ShowNoticeMsg( msg )
    -- body
    print("MainScene:ShowNoticeMsg( msg )", msg)
    local tmp = string.find(msg,"欢迎您进入")
    if tmp ~= nil then
        return
    end

    self._children["ImgNoticeBg"]:setVisible(true)
    self._children["msgPanel"]:removeAllChildren()
    
    local s = self._children["msgPanel"]:getContentSize()
    local labelTips = cc.Label:createWithTTF(msg, "res/fonts/fzzyjt.ttf", 45) 
    labelTips:setColor(cc.c3b(255, 255, 255))
    local s1 = labelTips:getContentSize()
    labelTips:setPosition(cc.p(s.width + s1.width, s.height/2))
    self._children["msgPanel"]:addChild(labelTips)
     
    local seq = cc.Sequence:create(
        cc.MoveTo:create(12, cc.p(-s.width - s1.width, s.height/2) ),
        cc.CallFunc:create(function()
            labelTips:removeFromParent()
            self._children["ImgNoticeBg"]:setVisible(false)
        end)
    )       
    labelTips:runAction(seq)
end

function MainScene:onEnter()
    print("MainScene:onEnter() ..........................................")
end

function MainScene:onClear()
    print("MainScene:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onLoginGameErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onLoginGameBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onServerListFinishBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onServerListBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameKindBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onCreateCustomRoomErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onEnterCustomRoomErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBaseEnsureBack")

    self.serverList_:release()
    self.customRoomUI_:release()
end

function MainScene:setExpandEffect()
    -- body
    if not self.isExpandFinish then
        return
    end
    self.isExpandFinish = false
    local moveTo1 = transition.newEasing(cc.MoveTo:create(0.4, cc.p(self.nOrgPos.x, self.nOrgPos.y - 100) ), "BOUNCEOUT")
    local moveTo2 = transition.newEasing(cc.MoveTo:create(0.4, cc.p(self.nOrgPos.x, self.nOrgPos.y) ), "BOUNCEOUT")

    local action = cc.Sequence:create(
        moveTo1,
        cc.DelayTime:create(0.5),
        moveTo2,
        cc.CallFunc:create(function() 
            self.isExpandFinish = true
        end)
    )
    self._children["btn_jiuji"]:runAction(action)
end

function MainScene:initUI()
    self._children["ImgNoticeBg"]:setVisible(false)

    local layer = require("app.views.layer.UserInfoLayer"):new()
    layer:setPosition(cc.p(0,0))
    self._children["panel"]:addChild(layer)

    self.nOrgPos = cc.p(self._children["btn_jiuji"]:getPosition() )
    self._children["btn_jiuji"]:setLocalZOrder(1000)

    local function getjiuji()
        self:setExpandEffect()
        GameLogicManager:getBaseEnsureTake()
    end
    self._children["btn_jiuji"]:addClickEventListener(getjiuji)
    
	self.pv_main = self._children["pv_games"]
	self.lab_sys_msg = self._children["lab_sys_msg"]

    local function showBack()
        local params = {}
        params["zorder"] = 2048
        app:openDialog("ExitGameLayer", params)
    end
    self._children["btn_back"]:addClickEventListener(showBack)

    self:registerKeyboardListener(function ( ... )
        -- body
        showBack()
    end)

    local function createRoom(pSender)
        if cc.MENetUtil:getUserType() ~= 2 then
            self:showTips("创建房卡游戏，需要微信登录！")
            return
        end
        local tag = pSender:getTag()
        print("tag ==============================", tag)
        if tag == 1 then 
            local params = {}
            params["createCustomRoomCallBack"] = function (iKind, iRound, iWF)
                -- body
                self.customRoomUI_:createRoom(iKind, iRound, iWF)
            end
            app:openDialog("RoomCreateLayer", params)
        else
            local params = {}
            params["zorder"] = 1024
            app:openDialog("LoadingLayer", params)
            self.customRoomUI_:checkAutoEnterCustomGame()
        end
    end

    self._children["btn_create_room"]:addClickEventListener(createRoom)
    self._children["btn_create_room"]:setTag(1)

    if self.params ~= nil and self.params.isShowGoBack ~= nil and self.params.isShowGoBack then
        self._children["btn_create_room"]:loadTextures("room_back.png","room_back2.png","", ccui.TextureResType.plistType)
        self._children["btn_create_room"]:setTag(2)
    end

    local function joinRoom()
        if cc.MENetUtil:getUserType() ~= 2 then
            self:showTips("加入房卡游戏，需要微信登录！")
            return
        end
        local params = {}
        params["enterCustomRoomCallBack"] = function (iRoomID)
            -- body
            self.customRoomUI_:enterRoom(iRoomID)
        end
        app:openDialog("RoomJoinLayer", params)
    end
    self._children["btn_join_room"]:addClickEventListener(joinRoom)

    -- 创建子游戏，按钮
    self:initView()
end

function MainScene:initView()
	-- body
    self.listView = self._children["listView"]
    local item = self.listView:getChildByName("item")
    item:setVisible(false)
    self.listView:setItemModel(item)
    self.listView:setLocalZOrder(100)
    self.listView:removeAllChildren()

    table.sort(self.gameList, function (a,b) return a.idx < b.idx end)
    for i=1, #self.gameList do
        self.listView:pushBackDefaultItem()
    end

    dump(self.gameList)     -- 创建 四个游戏按钮
    for i = 1, #self.gameList do
        local item = self.listView:getItem(i - 1)
        item:setVisible(true)

        local btnGame = item:getChildByName("btnGame")
        btnGame:setTag(self.gameList[i].kindID)
        btnGame:loadTextures(GameListConfig[self.gameList[i].kindID].normal, GameListConfig[self.gameList[i].kindID].press,"", ccui.TextureResType.plistType)

        local time1 = cc.DelayTime:create(i*4)
        local sc1 = cc.ScaleTo:create(0.6,1.1)
        local sc2 = cc.ScaleTo:create(0.4,1)
        local time2 = cc.DelayTime:create(i*5)
        local seq = cc.Sequence:create(time1,sc1,sc2,time2)

        btnGame:runAction(cc.RepeatForever:create(seq))

        local function onClicked(sender)
            local tag = sender:getTag()
            print("tag ==============================", tag)
           -- MEAudioUtils.playSoundEffect("sound/btnClick.mp3")
            local params = {}
            params["zorder"] = 1024
            app:openDialog("LoadLayer", params)     -- 加载loading界面

            -- 登陆小游戏
            self.serverList = {}
            self.serverList_:getServerLists(tag)        -- 调用 C++ 的 getServerLists() 
        end
        btnGame:addClickEventListener(onClicked)
    end
end

return MainScene
