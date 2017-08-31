
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
EventDispatcher = require("app.base.EventDispatcher").new()
require "app.base.functions"
require "app.base.BaseEventMsgDefine"

-- for CCLuaEngine traceback    
function __G__TRACKBACK__(msg)
    print("----------------error begin------------------------")
    local msg = "LUA ERROR: " .. tostring(msg) .. "/n"
    msg = msg .. debug.traceback()
    print(msg)
    MELOGERROR(msg)
    print("----------------error end------------------------")
end

function applicationDidEnterBackground()
    if app then 
        app:applicationDidEnterBackground()
    end
end

function applicationWillEnterForeground()
    if app then 
        app:applicationWillEnterForeground()
    end
end

local function main()
    --require("app.MyApp"):create():run()
    local path = cc.FileUtils:getInstance():getSearchPaths()
    dump(path, "路径")
    cc.MEResolution:setResolutionRect(1920, 1080, 1280, 720)
    require "initME"
    require "app.utils.init_base"
    app = require("app.MyApp"):create()
    app:enterScene("LogoScene")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
