
local LoginScene = class("LoginScene", cc.load("mvc").SceneBase)
LoginScene.RESOURCE_FILENAME = "login_scene.csb"

function LoginScene:onCreate()
   self:init()
   self:initEvent()
end

function LoginScene:init()
    -- body
    local volume_music = cc.UserDefault:getInstance():getIntegerForKey("sound_music", 100)
    local volume_effect = cc.UserDefault:getInstance():getIntegerForKey("sound_effect", 100)
    audio.setMusicVolume(volume_music*0.01)
    audio.setSoundsVolume(volume_effect*0.01)
end

function LoginScene:initEvent()
    -- body
    --注册login监听回调
    local function OnLoginBackListener()        -- 在cc.onLoginBack之前，是用接收服务器的登陆结果的 分析，与操作。然后来到了这里
        -- body
        print("OnLoginBackListener.....................................")
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onLoginBack")
        app:closeDialog("LoadLayer")
        app:enterScene("MainScene")
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onLoginBack", OnLoginBackListener)  --接收 登陆消息
    
    --注册OtherLogin监听回调
    local function OnOtherLoginBackListener(nType, url)
        -- body
        print("OnOtherLoginBackListener.....................................", nType, url)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onOtherLoginBack")
        --下载头像
        GameLogicManager:downAvatar(url)         -- url debug模式下，为空
        GameLogicManager:loginByType(nType)      -- nType 为2 也没有用的。 这里就开始登陆了，有网络部分的操作  有发送操作，
    end
    --注册 onOtherLoginBack 
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onOtherLoginBack", OnOtherLoginBackListener)
    
    --注册loginError监听回调
    local function OnLoginErrorBackListener(strDesc)
        -- body
        print("OnLoginErrorBackListener...............................", strDesc)
        self:showTips(strDesc)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onLoginErrorBack", OnLoginErrorBackListener)

    --注册netError监听回调
    local function OnNetErrorBackListener(errorCode)
        -- body
        print("OnNetErrorBackListener...............................", errorCode)
        self:showTips(GameTipsConfig[13])
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onNetErrorBack", OnNetErrorBackListener)

    self:registerKeyboardListener(function ( ... )
        -- body
        local params = {}
        params["zorder"] = 2048
        app:openDialog("ExitGameLayer", params)
    end)
end

-- onEnterTransitionFinish 是场景进入并且过渡动画完成时候触发
function LoginScene:onEnterTransitionFinish()
    print("LoginScene:onEnterTransitionFinish() ...................................")
    self:initUI()
    self:registerDialogMessageListener()
    
    audio.playMusic("music/plaza_bg_music.mp3",true)
end

function LoginScene:onEnter()
    print("LoginScene:onEnter() ..........................................")
end

function LoginScene:initUI()
    -- body
    self._children["btn_qq_login"]:addClickEventListener(function ( ... )
        -- body
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)

        cc.MEWeiXinHelper:getInstance():qqlogin()
    end)

    -- 案件相应
    self._children["btn_weixin_login"]:addClickEventListener(function ( ... )
        -- body
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)
        
        cc.MEWeiXinHelper:getInstance():wxlogin()   -- 调用微信登陆 这个里面 有调用 onOtherLoginBack，在InitEvent中，在画面启动的时候，已经注册了onOtherLoginBack
    end)

    self._children["btn_account_login"]:addClickEventListener(function ( ... )
        -- body
        local params = {}
        params["loginCallBack"] = function (account, pwd)
            -- body
            GameLogicManager:reqLogin(account, pwd)
        end
        params["quickloginCallBack"] = function ()
            -- body
            GameLogicManager:reqLogin()
        end
        params["registCallBack"] = function (account, pwd)
            -- body
            local params = {}
            params["zorder"] = 1024
            app:openDialog("LoadLayer", params)

            GameLogicManager:regist(account, pwd)
        end
        app:openDialog("AccountLoginLayer", params)
    end)

    local srcPos = cc.p(self._children["login_logo"]:getPosition())
    local s = self._children["login_logo"]:getContentSize()
    self._children["login_logo"]:setPosition( cc.p(srcPos.x, srcPos.y + s.height + 200) )
    Helper:scheduleOnce(0.1, function()
        local moveTo = cc.EaseBackInOut:create( cc.MoveTo:create(0.8, srcPos) )
        self._children["login_logo"]:runAction(moveTo)
    end)
    
    local srcPos = cc.p(self._children["btn_qq_login"]:getPosition())
    self._children["btn_qq_login"]:setPosition( cc.p(srcPos.x, -200) )
    Helper:scheduleOnce(0.5, function()
        local moveTo = cc.EaseBackInOut:create( cc.MoveTo:create(1, srcPos) )
        self._children["btn_qq_login"]:runAction(moveTo)
    end)

    local srcPos = cc.p(self._children["btn_weixin_login"]:getPosition())
    self._children["btn_weixin_login"]:setPosition( cc.p(srcPos.x, -200) ) -- 重新设置 btn_weixin_login 的位置，以便有动画的方式显示
    Helper:scheduleOnce(0.5, function()     -- "btn_weixin_login" 按钮 动画 从
        local moveTo = cc.EaseBackInOut:create( cc.MoveTo:create(1, srcPos) )
        self._children["btn_weixin_login"]:runAction(moveTo)
    end)
    
    local srcPos = cc.p(self._children["btn_account_login"]:getPosition())
    self._children["btn_account_login"]:setPosition( cc.p(srcPos.x, -200) )
    Helper:scheduleOnce(0.5, function()
        local moveTo = cc.EaseBackInOut:create( cc.MoveTo:create(1, srcPos) )
        self._children["btn_account_login"]:runAction(moveTo)
    end)

    --test
    if DEBUG >= 1 then
        print(device.writablePath)
        local label2 = ccui.Text:create()
        label2:setString(device.writablePath)
        label2:setFontSize(30)
        label2:setColor(cc.c3b(255, 0, 0))
        label2:setPosition( cc.p( me.winSize.width*0.5, 100) )
        self._children["panel"]:addChild(label2)
    end
                 
end

function LoginScene:onClear()
    print("LoginScene:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onLoginErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onLoginBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onNetErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onOtherLoginBack")
end

return LoginScene