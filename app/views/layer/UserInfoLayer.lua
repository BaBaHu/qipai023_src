
local UserInfoLayer = class("UserInfoLayer", cc.load("mvc").ViewBase)

UserInfoLayer.RESOURCE_FILENAME = "userinfo_layer.csb"

function UserInfoLayer:onCreate()

    self._children["lab_gold"]:setString(cc.MENetUtil:getUserGold() )
    self._children["lab_gameId"]:setString("ID:" .. cc.MENetUtil:getGameID() )
    self._children["lab_name"]:setString(cc.MENetUtil:getNickName() )

    local url = cc.MENetUtil:getUserIconUrl()
    if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
        local faceId = cc.MENetUtil:getFaceID()%20 + 1
        self._children["p_playerIco"]:loadTexture("b_" ..faceId..".png", ccui.TextureResType.plistType)
    else
        --下载头像
        print("url = ", url)
        --local customid = Helper:md5sum(url)
        --local filename = Helper:getFileNameByUrl(url, customid)
        --print(filename)
        --self._children["p_playerIco"]:loadTexture(filename)
        
        GameLogicManager:downAvatar(url, 
        function ( ... )
            -- body
        end,
        function (filename)
            -- body
            print(filename)
            self._children["p_playerIco"]:loadTexture(filename)
        end)
    end
    self._children["lab_zuanshi"]:setString(cc.MENetUtil:getRoomGold() )
    
    local function showSettingLayer()
        app:openDialog("SettingSoundLayer", false)
    end
    self._children["btn_setting"]:addClickEventListener(showSettingLayer)

    local function showBank()
        app:openDialog("RankSetLayer")
    end
    self._children["btn_bank"]:addClickEventListener(showBank)

    local function showShare()
        app:openDialog("ShareLayer")
    end
    self._children["btn_share"]:addClickEventListener(showShare)

    local function showShop()
        app:openDialog("ShopLayer")
    end
    self._children["btn_shop"]:addClickEventListener(showShop)

    local function showNotice()
        app:openDialog("NoticeLayer")
    end
    self._children["btn_notice"]:addClickEventListener(showNotice)
    self._children["btn_zushi"]:addClickEventListener(showNotice)
    
    self:addEventListener(EventMsgDefine.UpdateBankData,self.updateBankData,self)
end

function UserInfoLayer:updateBankData()
    self._children["lab_gold"]:setString(cc.MENetUtil:getUserGold())
    self._children["lab_zuanshi"]:setString(cc.MENetUtil:getRoomGold() )
end

return UserInfoLayer
