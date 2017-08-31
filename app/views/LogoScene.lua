local LogoScene = class("LogoScene", cc.load("mvc").SceneBase)
LogoScene.RESOURCE_FILENAME = "logo_scene.csb"

local support  = true
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) 
    or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) 
    or (cc.PLATFORM_OS_MAC  == targetPlatform) then
    support = true
end
local support_updator = support and true
local updator_has_updated = updator_has_updated  or (not support_updator)

function LogoScene:onCreate()
	self:init()
end

function LogoScene:init()
    -- body
    local function OnProgressBackListener(percent)
        -- body
        print("OnProgressBackListener.......................", percent)
	    self._children["LoadingBar"]:setPercent(percent)
	    self._children["labelText"]:setString("正在更新游戏资源：".. percent .. "%")
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onProgress", OnProgressBackListener)
    
    local function OnSuccessBackListener()
        -- body
        print("OnSuccessBackListener.......................")
    	self._children["labelText"]:setString("更新成功！")
	    if self.assetsManager:isDownpackage() and (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	        deleteDownloadDir(self.pathToSave)
	        --安装更新包
	        local apkPath =self.assetsManager:getDownPackageStoragePath()
	        print("apkPath = ", apkPath)
	        MEDeviceInfo.autoInstallApk(apkPath)
	        --终止当前应用
	        MEDeviceInfo.terminateApp()
	    end

	    self:runAction(cc.Sequence:create(
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(function() 
	            self._children["labelText"]:setString("正在初始化资源，请稍候...")
	        end),
	        cc.DelayTime:create(3),
	        cc.CallFunc:create(function() 
	            self:reloadModule()
	        end)
    	))
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onSuccess", OnSuccessBackListener)
    
    local function OnErrorBackListener(errorCode)
        -- body
        print("OnErrorBackListener.......................", errorCode)
        local strText
	    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
	        print("no new version")
	        self:reloadModule()
	        return
	    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
	        print("network error")
	        strText = "更新失败，请检测网络环境！"
	    elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
	        print("create file error")
	        strText = "创建下载资源错误，更新失败！"
	    elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
	        print("unzip download file error")
	        strText = "解压资源异常，更新失败！"
	    elseif errorCode == 4 then
	    	print("ios update error")
	        strText = "游戏已更新，请到app store下载更新，否则无法正常游戏！"
	    end

	    local function doOk()
	    	self:runAction(cc.Sequence:create(
		        cc.DelayTime:create(1),
		        cc.CallFunc:create(function() 
		            self:check()
		        end)
    		))
        end
        local function doCancel()

        end
	    self:showTips(strText, doOk, doCancel)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onError", OnErrorBackListener)
    
   	self.versionUrl 	= "http://hotup.yibo98.com:8080/?action=ver&prj=app1"
	self.versionBaseUrl = "http://hotup.yibo98.com:8080/?action=basever&prj=app1"
	self.updateZipUrl 	= "http://hotup.yibo98.com:8080/?action=update.zip&prj=app1&ver="

    self.pathToSave = ""
    self.pathToSave = createDownloadDir()

    local versionName = MEDeviceInfo.getCurAppVersionName() or "1.0.0"
	local versionCode = MEDeviceInfo.getCurAppVersionCode() or 1
	print("versionName, versionCode = ", versionName, versionCode)

    --assetsManager cc.MEUpdateEngine 的一个类
    self.assetsManager = cc.MEUpdateEngine:new(self.updateZipUrl, self.versionUrl, self.pathToSave)
    local ver = self.assetsManager:getVersion() -- 从GetStringKey 获取Version
    if ver == "" then
        ver = versionName
        if ver == "" then
            ver = "1.0.0"
        end
        self.assetsManager:setVersion(ver)
    end
    local baseVer = self.assetsManager:getBaseVersion() -- c++ 中从 getStringForKey
    if baseVer == "" then
     	baseVer = versionName
        if baseVer == "" then
           baseVer = "1.0.0"
        end
        self.assetsManager:setBaseVersion(baseVer)
    end
    self.updateZipUrl = self.updateZipUrl .. ver .. "&basever=" ..baseVer
    print("self.updateZipUrl = ", self.updateZipUrl)

    self.assetsManager:setPackageUrl(self.updateZipUrl)
    self.assetsManager:setBaseVersionFileUrl(self.versionBaseUrl)
    self.assetsManager:retain()
    self.assetsManager:setConnectionTimeout(3)
end

function LogoScene:update()
    self.assetsManager:update()
end

function LogoScene:reloadModule()
    updator_has_updated = true
    require "app.utils.GameLogicManager"
    GameLogicManager:setup()           -- 设置好一些路径
  	app:enterScene("LoginScene")        -- 进入LoginScene
end

function LogoScene:check()
    -- body
    if not updator_has_updated then
        self:update()
    else
        self:reloadModule()
    end
end

function LogoScene:onEnterTransitionFinish()        -- 界面加载完成后，来到这里
    print("LogoScene:onEnterTransitionFinish() ...................................")
    self:initUI()
end

function LogoScene:initUI()
	if me.ENABLE_AUTOUPDATE then
		self:runAction(cc.Sequence:create(
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(function() 
	            self:check()
	        end)
    	))
	else
		self:runAction(cc.Sequence:create(
	        cc.DelayTime:create(3),
	        cc.CallFunc:create(function() 
	            self:reloadModule()
	        end)
    	))
    end
end

function LogoScene:onEnter()
    print("LogoScene:onEnter() ..........................................")
end

function LogoScene:onClear()
    print("LogoScene:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onProgress")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onSuccess")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onError")

    self.assetsManager:release()
end

return LogoScene