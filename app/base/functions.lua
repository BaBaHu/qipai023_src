--模块相关接口

function instanceOf(cls)
    if cls and type(cls) == 'table' and cls.__cname then
        return cls.__cname
    end
    return "None_Clas"
end

--[[--
    将对象序列化
]]
function serialize(t)
    local mark={}
    local assign={}

    local function tb(len)
        local ret = ''
        while len > 1 do
            ret = ret .. '       '
            len = len - 1
        end
        if len >= 1 then
            ret = ret .. '├┄┄'
        end
        return ret
    end

    local function table2str(t, parent, deep)
        deep = deep or 0
        mark[t] = parent
        local ret = {}
        table.foreach(t, function(f, v)
            local k = type(f)=="number" and "["..f.."]" or tostring(f)
            local dotkey = parent..(type(f)=="number" and k or "."..k)
            local t = type(v)
            if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
                table.insert(ret, string.format("%s=%q", k, tostring(v)))
            elseif t == "table" then
                if mark[v] then
                    table.insert(assign, dotkey.."="..mark[v])
                else
                    table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey, deep + 1)))
                end
            elseif t == "string" then
                table.insert(ret, string.format("%s=%q", k, v))
            elseif t == "number" then
                if v == math.huge then
                    table.insert(ret, string.format("%s=%s", k, "math.huge"))
                elseif v == -math.huge then
                    table.insert(ret, string.format("%s=%s", k, "-math.huge"))
                else
                    table.insert(ret, string.format("%s=%s", k, tostring(v)))
                end
            else
                table.insert(ret, string.format("%s=%s", k, tostring(v)))
            end
        end)
        return "{\n" .. tb(deep + 1) .. table.concat(ret,",\n" .. tb(deep + 1)) .. '\n' .. tb(deep) .."}"
    end

    if type(t) == "table" then
        if t.__tostring then 
            return tostring(t)
        end
        local str = string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))
        return "<<table>>" .. str
    else
        return tostring(t)
    end
end

--格式化table为string
function table2string(obj)  
    local lua = ""
    print(obj)  
    local t = type(obj)
    print(t)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
        for k, v in pairs(obj) do  
            lua = lua .. "[" .. table2string(k) .. "]=" .. table2string(v) .. ",\n"  
        end  
        local metatable = getmetatable(obj)  
            if metatable ~= nil and type(metatable.__index) == "table" then  
            for k, v in pairs(metatable.__index) do  
                lua = lua .. "[" .. table2string(k) .. "]=" .. table2string(v) .. ",\n"  
            end  
        end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not table2string a " .. t .. " type.")  
    end  
    return lua  
end  

--格式化string为table 
function string2table(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end

function getFileDir(szPath)
    local szPrePath = ''
    if string.lower(szPath['-4']) == '.lua' then
        szPrePath = szPath[':-5']
    else
        szPrePath = szPath
    end
    local nLen = #szPrePath
    while nLen > 0 do
        if szPrePath[nLen] == '.' then
            szPrePath = szPrePath[{1, nLen}]
            break
        end
        nLen = nLen - 1
    end
    return szPrePath
end


function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
    return math.round(tonum(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end


--[[--
    根据指定类型打印日志, 有效日志将会保存在输出文件夹的log目录中
    @param kType: 日志类型:MELOG_ERROR(错误日志), MELOG_INFO(记录日志), MELOG_WARNING(警告日志)
    @param fmt: 格式控制
    @param ...: 输出数据
    @return nil
]]
function MELOG(kType, fmt, ...)
    local str = string.format(fmt, ...)
    if kType == MELOG_ERROR then
        MELOGERROR(str)
    elseif kType == MELOG_INFO then 
        MELOGINFO(str)
    elseif kType == MELOG_WARNING then 
        MELOGWARNING(str)
    else
        print(str)
    end
end


function MELOG2(szMsg, kType)
    kType = kType or MELOG_INFO
    if kType == MELOG_ERROR then
        MELOGERROR(szMsg)
    elseif kType == MELOG_INFO then 
        MELOGINFO(szMsg)
    elseif kType == MELOG_WARNING then 
        MELOGWARNING(szMsg)
    end
end

-- cclog
cclog = function(...)
    print(string.format(...))
end

--格式化打印
if DEBUG >= 1 then
    --MELogUtil:sharedLogManager():setLogPath("/sdcard/KOLOG/log")
    MELogUtil:sharedLogManager():setCanWriteInfo(true)
    MELogUtil:sharedLogManager():setCanWriteError(true)
    print_ = print
    function print(...)
        local arg = {...}
        local ret = ''
        for k, v in pairs(arg) do
            local str = serialize(v)
            ret = ret .. '   ' .. str
        end
        print_(ret)
        MELOG2(ret, MELOG_INFO)
    end
else
    print = function() end
end