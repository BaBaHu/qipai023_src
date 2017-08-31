MEDeviceInfo = {}
MEDeviceInfo.CLASS_NAME = nil
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == targetPlatform then
    MEDeviceInfo.CLASS_NAME = "org/cocos2dx/lua/MEDeviceInfo"
elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    MEDeviceInfo.CLASS_NAME = "MEDeviceInfo"
end

function MEDeviceInfo.getCurAppName()
    local ok,ret = MELuaOcJava.callStaticMethod(MEDeviceInfo.CLASS_NAME, "getCurAppName",nil,"()Ljava/lang/String;")
    return MELuaOcJava.checkResult(ok,ret)
end

function MEDeviceInfo.getCurAppVersionName()
    local ok,ret = MELuaOcJava.callStaticMethod(MEDeviceInfo.CLASS_NAME, "getCurAppVersionName",nil,"()Ljava/lang/String;")
    return MELuaOcJava.checkResult(ok,ret)
end

function MEDeviceInfo.getCurAppVersionCode()
    local ok,ret = MELuaOcJava.callStaticMethod(MEDeviceInfo.CLASS_NAME, "getCurAppVersionCode",nil,"()I")
    return MELuaOcJava.checkResult(ok,ret)
end

function MEDeviceInfo.getPackageName()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        print("ios not support")
        return nil
    else
        local ok,ret = MELuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getCocos2dxPackageName",nil,"()Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

function MEDeviceInfo.getAppWritablePath()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        print("ios not support")
        return nil
    else
        local ok,ret = MELuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getCocos2dxWritablePath",nil,"()Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

function MEDeviceInfo.terminateApp()
    if cc.PLATFORM_OS_ANDROID == targetPlatform then
    	MELuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "terminateProcess")
    else
        print("terminateApp not support...")
    end
end

function MEDeviceInfo.autoInstallApk(apkUrl)
    if cc.PLATFORM_OS_ANDROID == targetPlatform then
        MELuaOcJava.callStaticMethod(MEDeviceInfo.CLASS_NAME,"autoInstallApk",{apkUrl})
    else
        print("autoInstallApk not support...")
    end
end

function MEDeviceInfo.getWxFilterEmojiName(name)
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        print("ios not support")
        return nil
    else
        local ok,ret = MELuaOcJava.callStaticMethod(MEDeviceInfo.CLASS_NAME,"getWxFilterEmojiName",{name},"(Ljava/lang/String;)Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

return MEDeviceInfo