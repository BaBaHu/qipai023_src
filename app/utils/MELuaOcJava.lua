MELuaOcJava = {}

SCREEN_ORIENTATION_LANDSCAPE = 0

SCREEN_ORIENTATION_PORTRAIT  = 1

local targetPlatform = me.Application:getTargetPlatform()

function MELuaOcJava.checkResult(ok,ret)
    -- body
    if ok then return ret end
    return nil
end

local function checkArguments(args, sig)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end

    sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")V"

    return args, table.concat(sig)
end

function MELuaOcJava.callStaticMethod(className, methodName, args,sig) 
    if cc.PLATFORM_OS_ANDROID == targetPlatform then
        print("this is android platform ...............................")
        local luaj = require "cocos.cocos2d.luaj"
        local args, sig = checkArguments(args, sig)
        print("==JAVA=>MELuaOcJava.callStaticMethod(\"%s\",\n\t\"%s\",\n\targs,\n\t\"%s\"", className, methodName, sig)
        local ok,ret = luaj.callStaticMethod(className, methodName, args, sig)
        if not ok then
            print("luaj error:", ret)
            local msg = string.format("==OC=>MELuaOcJava.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                    className, methodName, tostring(args), tostring(ret))
            if ret == -1 then
                print(msg .. "INVALID PARAMETERS")
            elseif ret == -2 then
                print(msg .. "CLASS NOT FOUND")
            elseif ret == -3 then
                print(msg .. "METHOD NOT FOUND")
            elseif ret == -4 then
                print(msg .. "EXCEPTION OCCURRED")
            elseif ret == -5 then
                print(msg .. "INVALID METHOD SIGNATURE")
            elseif ret == -7 then
                print(msg .. "PLATFORM NOT SUPPORT")
            else
                print(msg .. "UNKNOWN")
            end
        else
            print("The ret is:", ret)
        end
        return ok, ret
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        print("this is ios platform ...............................")
        local luaoc = require "cocos.cocos2d.luaoc"
        local ok,ret = luaoc.callStaticMethod(className, methodName, args)
        if not ok then
            print("luaj error:", ret)
            local msg = string.format("==OC=>MELuaOcJava.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                    className, methodName, tostring(args), tostring(ret))
            if ret == -1 then
                print(msg .. "INVALID PARAMETERS")
            elseif ret == -2 then
                print(msg .. "CLASS NOT FOUND")
            elseif ret == -3 then
                print(msg .. "METHOD NOT FOUND")
            elseif ret == -4 then
                print(msg .. "EXCEPTION OCCURRED")
            elseif ret == -5 then
                print(msg .. "INVALID METHOD SIGNATURE")
            elseif ret == -7 then
                print(msg .. "PLATFORM NOT SUPPORT")
            else
                print(msg .. "UNKNOWN")
            end
        else
            print("The ret is:", ret)
        end
        return ok, ret
    else
        print("this platform not Support..................................")
        return
    end
end

return MELuaOcJava