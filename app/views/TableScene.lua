local TableScene = class("TableScene", cc.load("mvc").SceneBase)
TableScene.RESOURCE_FILENAME = "table_scene.csb"

function TableScene:onCreate(params)
    self:init(params)
end

function TableScene:init(params)
    -- body
    self.params = params
    self.tChairIcon = {}

    self.tablePanel = self._children["tablePanel"]
    local s = self.tablePanel:getContentSize()
    self.table_ = cc.TableUI:create(s.width, s.height, 0, 0)
    self.table_:retain()
    self.tablePanel:addChild(self.table_)
end

function TableScene:initEvent()
    -- body
    --注册BackToServerList监听回调
    local function OnBackToServerListBackListener(bShowTips)
        -- body
        print("OnBackToServerListBackListener........................", bShowTips)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBackToServerListBack")
        if not bShowTips then
            app:enterScene("MainScene")
            Helper:scheduleOnce(1, function()
                cc.MENetUtil:exitGameRoom()
            end)
        else
            local function okCallBack()
                -- body
                app:enterScene("MainScene")
                
            end
            self:showTips(GameTipsConfig[14], okCallBack)
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onBackToServerListBack", OnBackToServerListBackListener)
    
    --注册SitDownClick监听回调
    local function OnSitDownClickBackListener(nTable, nChair)
        -- body
        print("OnSitDownClickBackListener.....................................", nTable, nChair)
        --MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownClickBack")
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onUserIconBack")
        if cc.MENetUtil:getUserType() ~= 0 then
            --下载头像
            local url = cc.MENetUtil:getUserIconUrl()
            print("url = ", url)
            if url == nil or url == "" then
                self.table_:setChairIcon(nTable, nChair, "")
            else
                local customid = Helper:md5sum(url)
                local filename = Helper:getFileNameByUrl(url, customid)
                print(filename)
                self.table_:setChairIcon(nTable, nChair, filename)
            end
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onSitDownClickBack", OnSitDownClickBackListener)
    
    --注册SitDownSuccess监听回调
    local function OnSitDownSuccessBackListener()
        -- body
        print("OnSitDownSuccessBackListener.....................................")
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownSuccessBack")
        self:preLoadRes(GameListConfig[self.params.kindID].scene, function ( ... )
            -- body
            app:enterScene(GameListConfig[self.params.kindID].scene, self.params)
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

    --注册UserIcon监听回调
    local function OnUserIconBackListener(nTable, nChair, url)
        -- body
        print("OnUserIconBackListener.....................................", nTable, nChair, url)
        Helper:scheduleOnce(0.2, function()
            GameLogicManager:downAvatar(url, 
            function ( ... )
                -- body
            end,
            function (filename)
                -- body
                print(filename)
                self.table_:setChairIcon(nTable, nChair, filename)
            end)
        end)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onUserIconBack", OnUserIconBackListener)
end

function TableScene:onEnterTransitionFinish()
    print("TableScene:onEnterTransitionFinish() ...................................")
    self:initEvent()
    self:initUI()
    self:registerDialogMessageListener()
    
    if not audio.isMusicPlaying() then
        audio.playMusic("music/plaza_bg_music.mp3",true)
    end
    --检测玩家是否还在游戏中
    if cc.MENetUtil:isGamePlaying() then
        self:preLoadRes(GameListConfig[self.params.kindID].scene, function ( ... )
            -- body
            app:enterScene(GameListConfig[self.params.kindID].scene, self.params)
        end)
    end
end

function TableScene:onEnter()
    print("TableScene:onEnter() ..........................................")
end

function TableScene:onClear()
    print("TableScene:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownSuccessBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSitDownClickBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBackToServerListBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onUserIconBack")
    self.table_:release()
end

function TableScene:preLoadRes(sceneName, callback )
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

function TableScene:initUI()
    -- body?
        local function OnGoBack() 
        -- body
        self.table_:backToServerListScene()
    end
    self._children["btn_back"]:addClickEventListener(OnGoBack)

    self:registerKeyboardListener(function ( ... )
        -- body
        OnGoBack()
    end)

    local function OnAutoJoin()
        cc.MENetUtil:autoJoin()
    end
    self._children["btn_auto_join"]:addClickEventListener(OnAutoJoin)

    local layer = require("app.views.layer.UserInfoLayer"):new()
    self._children["panel"]:addChild(layer)

    local nTableGold = cc.MENetUtil:getTableGold(self.params.kindID, self.params.serverID)
    print("nTableGold = ", nTableGold)
    self._children["ImgGold"]:loadTexture(nTableGold..".png", ccui.TextureResType.plistType)

end

return TableScene
