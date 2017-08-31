GameLogicManager = {}

require "app.config.init"
require "app.utils.init"

function GameLogicManager:setup()
    print("GameLogicManager:setup() !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    if self._isValid == nil or not self._isValid then
        self._isValid = true --是否有效
        self:init()
    end
end

function GameLogicManager:init()
    -- body
    NetWorkManager:setup()
    NoticeMessageListener:setup()

    self.login_ = cc.LogonUI:create(NET_IP_ADDRESS, NET_PORT)
    self.login_:retain()

    self.pay_ = cc.PayUI:create(NET_IP_ADDRESS, NET_PORT)
    self.pay_:retain()
    
    self.imageDownloader_ = cc.MEImageDownloader:create(device.writablePath.."images"..device.directorySeparator) 
    self.imageDownloader_:retain()
    print("device.writablePath", device.writablePath)

    self:setUpdateResPathConfig()
end

function GameLogicManager:setUpdateResPathConfig()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    local tblResPath = {}
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        tblResPath =
        {
            "../Library/setup/res/",
            "../Library/setup/src/",
            "../Library/setup/",
        }
    else
        tblResPath =
        {  
            "setup/res/",
            "setup/src/",
            "setup/",
        }
    end
    for i = 1, #tblResPath  do
        cc.FileUtils:getInstance():addSearchPath(tblResPath[i], true)
    end
end

function GameLogicManager:logout()
    -- body
    self.login_:logout()
end

function GameLogicManager:regist(str_account, str_pwd)
    -- body
    self.login_:regist(str_account, str_pwd)
end

function GameLogicManager:loginByType(nLoginType)
    -- body
    self.login_:loginByType(nLoginType)
end

function GameLogicManager:reqLogin(str_account, str_pwd)
    -- body
    local params = {}
    params["zorder"] = 1024
    app:openDialog("LoadLayer", params)

    if str_account == nil or str_pwd == nil then
        str_account = cc.UserDefault:getInstance():getStringForKey("account", "")
        str_pwd = cc.UserDefault:getInstance():getStringForKey("password", "")
    end
    print("account ==================", str_account, str_pwd)
    
    if string.len(str_account) < 6 or string.len(str_pwd) < 6 then
        math.randomseed(os.clock()*10000)
        local accountId = math.floor(100000 + math.random() * 899999)
        local account = DEFAULT_ACCOUNT..accountId
        self.login_:regist(account, DEFAULT_PWD)
        return
    end
    self.login_:login(str_account, str_pwd)
end

function GameLogicManager:getBaseEnsureTake()
    -- body
    self.login_:getBaseEnsureTake()
end

function GameLogicManager:payIpa(proId)
    -- body
    self.pay_:payIpa(proId)
end

function GameLogicManager:payCard(card, pwd)
    -- body
    self.pay_:payCard(card, pwd)
end

function GameLogicManager:share()
    -- body
    self.pay_:share()
end

function GameLogicManager:captureScreen( callback )
    -- body
    local fileName = "CaptureScreenTest.png"
    local function afterCaptured(succeed, outputFile)
        if succeed then
            fileName = outputFile
            callback(outputFile)
        else
            print("Capture screen failed.")
        end
    end
    cc.Director:getInstance():getTextureCache():removeTextureForKey(fileName)
    cc.utils:captureScreen(afterCaptured, fileName)
end

function GameLogicManager:WeiXinShareScreen()
    -- body
    self:captureScreen( function ( filename )
        -- body
        cc.MEWeiXinHelper:shareImageWX(filename, 0)
    end)
end

function GameLogicManager:WeiXinShareUrl(strTitle, strDesc, shareType)
    -- body
    cc.MEWeiXinHelper:shareUrlWX(SHARE_MAIN_URL, strTitle, strDesc, shareType)
end

function GameLogicManager:payByApplay(buyType, subject, body, price, count, callback)
    local xhr = cc.XMLHttpRequest:new() -- http请求  
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING   -- 响应类型 

    local url = "http://www.yibo98.com/api/AlipayOrder.aspx?userID=" .. cc.MENetUtil:getUserID() .. "&subject=" .. string.url_encode(subject) .."&body=" ..  string.url_encode(body) .."&total_fee=" .. price .."&count=" .. count.."&buytype=" .. buyType
    xhr:open("GET", url)  
    print("url = ", url)
    
  
    local function onReadyStateChange()  
         
        local statusString = "Http Status Code:"..xhr.statusText 
        print(statusString)   
        print(xhr.response)
        if xhr.response ~= nil and xhr.response ~= "" then 
            if callback then
                callback(xhr.response)
            end
        else
            print("支付宝充值参数错误！！！！！！！！！！！！！！！")
        end
        xhr:unregisterScriptHandler()
    end  
  
    xhr:registerScriptHandler(onReadyStateChange)  
    xhr:send() 
    print("waiting...")  
end  

function GameLogicManager:payByWx(buyType, body, price, count, callback)
    local xhr = cc.XMLHttpRequest:new() -- http请求  
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING   -- 响应类型 
  
    local url = "http://www.yibo98.com/api/WXpayOrder.aspx?userID=" .. cc.MENetUtil:getUserID() .."&body=" ..  string.url_encode(body) .."&total_fee=" .. price .."&count=" .. count.."&buytype=" .. buyType
    xhr:open("GET", url)  
    print("url = ", url)
    
    
    local function onReadyStateChange()  
          
        local statusString = "Http Status Code:"..xhr.statusText 
        print(statusString)   
        print(xhr.response)
        if xhr.response ~= nil and xhr.response ~= "" then 
            if callback then
                callback(xhr.response)
            end
        else
            print("微信充值参数错误！！！！！！！！！！！！！！！")
        end
        xhr:unregisterScriptHandler()
    end  
      
    xhr:registerScriptHandler(onReadyStateChange)  
    xhr:send()   
    print("waiting...")  
end

function GameLogicManager:getRank(kindID, callback)
    local xhr = cc.XMLHttpRequest:new() -- http请求  
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING   -- 响应类型 
    
    local url = "http://www.yibo98.com/ApiServer/GameRankForMobile.aspx?KindID=" .. kindID
    xhr:open("GET", url)  
    print("url = ", url)
    
     
    local function onReadyStateChange()  
        
        local statusString = "Http Status Code:"..xhr.statusText 
        local output = {}
        if xhr.response ~= "" then
            output = json.decode(xhr.response,1)
            print("output = ", output)
            if callback then
                callback(output)
            end
        end
        xhr:unregisterScriptHandler()
    end
 
    xhr:registerScriptHandler(onReadyStateChange)  
    xhr:send() 
    print("waiting...")  
end

-- 下载头像
function GameLogicManager:downAvatar(url, errorCallBack, succCallBack)
    if not url or #url == 0 then
        print("downAvatar failure, url can not be nil!")
        if errorCallBack then
            errorCallBack()
        end
        return
    end

    print("len = ", string.len(url))
    local customid = Helper:md5sum(url)
    local filename = Helper:getFileNameByUrl(url, customid)
    print("down player[%s]'s avatar, customid:%s url:%s filename:%s", customid, url, filename)

    local function OnImageDownloaderSuccess(url, customid, filepath)
        -- body
        print("OnImageDownloaderSuccess .........................", url, customid, filepath)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("Down" .. customid .. "Succ")
        me.FileUtils:addSearchPath(filepath)

        local filename = Helper:getFileNameByUrl(url, customid)
        if succCallBack then
            succCallBack(filename)
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("Down" .. customid .. "Succ", OnImageDownloaderSuccess)
    self.imageDownloader_:downImage(url, filename, customid)
end

function GameLogicManager:dispose()
    -- body
    self._isValid = false
    NetWorkManager:dispose()
    NoticeMessageListener:dispose()
    self.imageDownloader_:release()
    self.login_:release()
    self.pay_:release()
    print("GameLogicManager:dispose() !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
end


return GameLogicManager
