
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.newrandomseed()
    self.isEnterBackground = false
end

function MyApp:applicationDidEnterBackground()
    if self.isEnterBackground then
        return
    end
    self.isEnterBackground = true
    print("app enter background!")
    EventDispatcher:dispatchEvent(EventMsgDefine.APP_ENTERBACKGROUND)
end

function MyApp:applicationWillEnterForeground()
    if not self.isEnterBackground then
        return
    end
    self.isEnterBackground = false
    print("app enter foreground!")
    EventDispatcher:dispatchEvent(EventMsgDefine.APP_ENTERFOREGROUND)
end

function MyApp:gotologin()
    GameLogicManager:logout()
    app:enterScene("LoginScene")
end

function MyApp:onExit()
    GameLogicManager:dispose()
end

return MyApp
