
local RankSetLayer = class("RankSetLayer", cc.load("mvc").DialogBase)
RankSetLayer.RESOURCE_FILENAME = "rank_set_layer.csb"

function RankSetLayer:onCreate()   
    self:setInOutEffectEnable(true)
    self:init()
    self:initUI()
end

function RankSetLayer:init()
    -- body
    --注册InsureSuccess监听回调
    local function OnInsureSuccessBackListener(strDesc)
        -- body
        print("OnInsureSuccessBackListener...........................", strDesc)
        self:showTips(strDesc)
        self:updateBankData()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onInsureSuccessBack", OnInsureSuccessBackListener)
    
    --注册InsureUpdate监听回调
    local function OnInsureUpdateBackListener()
        -- body
        print("OnInsureUpdateBackListener...........................")
        self:updateBankData()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onInsureUpdateBack", OnInsureUpdateBackListener)
    
    --注册InsureFailure监听回调
    local function OnInsureFailureBackListener(strDesc, type)
        -- body
        print("OnInsureFailureBackListener............................", strDesc, type)
        self:showTips(strDesc)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onInsureFailureBack", OnInsureFailureBackListener)

    self.bank_ = cc.BankUI:create(NET_IP_ADDRESS, NET_PORT)
    self.bank_:retain()
    self.bank_:query()
end

function RankSetLayer:onClear()
    print("RankSetLayer:onClear() -----------------------------------------")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onInsureSuccessBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onInsureUpdateBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onInsureFailureBack")

    self.bank_:release()
end


function RankSetLayer:initUI()
    local function removeSelf(pSender)
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    self.nSelType = 1
    self.nSelTrade = 1
    self.nSelChangePwd = 1
    for i=1,3 do
        self._children["Panel".. i]:setVisible(false)
        self._children["ImgBtn" .. i]:addTouchEventListener(function ( ... )
            --body
            self:onSelType(i)
        end)
    end
    self:onSelType(self.nSelType)

    local function flushGold()
        local str_gold = 0
        local con = self._children["txt_flush_gold"]:getString()
        if con ~= "" then
          str_gold = tonumber(con)
        end
        print(str_gold) 
        if str_gold > cc.MENetUtil:getUserGold() then
            self:showTips("输入的数量大于现有金币数!")
            return
        end
        if str_gold and str_gold > 0 then
            self.bank_:save(str_gold)
            self._children["txt_flush_gold"]:setString("")
        else
            self:showTips("请输入正确的金币数!")
        end
    end
    self._children["btn_flush_gold"]:addClickEventListener(flushGold)

    local function getGoldForBank()
        local str_gold = 0 
        local con = self._children["txt_get_gold"]:getString()
        if con ~= "" then
          str_gold = tonumber(con)
        end
        local str_pwd = self._children["txt_bank_pwd1"]:getString()
        print(str_gold, str_pwd, cc.MENetUtil:getPassword() )
        if str_gold <= 0 then
            self:showTips("请输入正确的金币数!")
            return
        end
        if str_gold > cc.MENetUtil:getBankGold() then
            self:showTips("输入的数量大于银行存款!")
            return
        end
        self.bank_:take(str_gold, str_pwd)
        self._children["txt_get_gold"]:setString("")
        self._children["txt_bank_pwd1"]:setString("")
    end
    self._children["btn_get_gold"]:addClickEventListener(getGoldForBank)

    local function tradeGoldForBank()
        local str_gold = 0 
        local con = self._children["txt_user_gold"]:getString()
        if con ~= "" then
          str_gold = tonumber(con)
        end

        local str_id = self._children["txt_user_id"]:getString()
        local str_pwd = self._children["txt_bank_pwd2"]:getString()
        print(str_id, str_gold, str_pwd, cc.MENetUtil:getPassword() )
        if tonumber(str_id) <= 0 then
            self:showTips("请输入正确的GameID!")
            return
        end

        if str_gold <= 0 then
            self:showTips("请输入正确的金币数!")
            return
        end

        local strText = "您是否转账" .. str_gold
        if self.nSelTrade == 1 then
            if str_gold > cc.MENetUtil:getBankGold() then
                self:showTips("输入的数量大于银行存款!")
                return
            end
            strText = strText .."金币"
        else
            if cc.MENetUtil:getUserDailiOrder() ~= 1 then
                self:showTips("非代理不能转账！")
                return
            end
            if str_gold > cc.MENetUtil:getRoomGold() then
                self:showTips("输入的数量大于现有钻石!")
                return
            end
            strText = strText .."钻石"
        end
        strText = strText .."给玩家ID[".. str_id .. "]?"
        
        local function doOk()
            self.bank_:transfer(self.nSelTrade, str_gold, str_pwd, str_id, 0)
            self._children["txt_user_gold"]:setString("")
            self._children["txt_bank_pwd2"]:setString("")
        end
        local function doCancel()

        end
        self:showTips(strText, doOk, doCancel)
        
    end
    self._children["btn_trade_gold"]:addClickEventListener(tradeGoldForBank)

    local function changePwd()
        local str_old_pwd = self._children["txt_old_pwd"]:getString()
        local str_new_pwd = self._children["txt_new_pwd"]:getString()
        local str_ok_pwd = self._children["txt_ok_pwd"]:getString()
        if string.len(str_new_pwd) < 6 or string.len(str_ok_pwd) < 6 then
            self:showTips("账号密码不能少于6位!")
            return
        end

        if str_new_pwd ~= str_ok_pwd then
            print("两次密码必须相等")
            self:showTips("两次密码必须相等!")
            return
        end

        self.bank_:modifyPassword(self.nSelChangePwd, str_old_pwd, str_ok_pwd)

        self._children["str_old_pwd"]:setString("")
        self._children["txt_new_pwd"]:setString("")
        self._children["txt_ok_pwd"]:setString("")
    end
    self._children["btn_change_pwd"]:addClickEventListener(changePwd)
end

function RankSetLayer:onSelType(selType)
    -- body
    print("RankSetLayer:onSelType()", selType)
    if selType == nil then
        return
    end
    self.nSelType = selType
    if self.nSelType == 1 then
        self._children["ImgBtn1"]:loadTexture("cunqu.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("zhuan2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("xiugai2.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 2 then
        self._children["ImgBtn1"]:loadTexture("cunqu2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("zhuan.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("xiugai2.png", ccui.TextureResType.plistType)
    elseif self.nSelType == 3 then
        self._children["ImgBtn1"]:loadTexture("cunqu2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn2"]:loadTexture("zhuan2.png", ccui.TextureResType.plistType)
        self._children["ImgBtn3"]:loadTexture("xiugai1.png", ccui.TextureResType.plistType)
    end
    self:initView()
end

function RankSetLayer:initView()
    -- body
    if self.nSelType == 1 then
        self._children["Panel1"]:setVisible(true)
        self._children["Panel2"]:setVisible(false)
        self._children["Panel3"]:setVisible(false)

        self:updateBankData()
    elseif self.nSelType == 2 then
        self._children["Panel1"]:setVisible(false)
        self._children["Panel2"]:setVisible(true)
        self._children["Panel3"]:setVisible(false)

        local panel = self._children["Panel2"]  
        for i=1,2 do
            local imgTrade = panel:getChildByName("ImgTrade" .. i)
            local ImgSelFlag = imgTrade:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelTrade then
                ImgSelFlag:setVisible(true)
            end

            imgTrade:addTouchEventListener(function ( ... )
                --body
                self:onSelTradeType(i)
            end)  
        end
        self:updateBankData()

    elseif self.nSelType == 3 then
        self._children["Panel1"]:setVisible(false)
        self._children["Panel2"]:setVisible(false)
        self._children["Panel3"]:setVisible(true)

        local panel = self._children["Panel3"]  
        for i=1,2 do
            local ImgPwd = panel:getChildByName("ImgPwd" .. i)
            local ImgSelFlag = ImgPwd:getChildByName("ImgSelFlag")
            ImgSelFlag:setVisible(false)
            if i == self.nSelChangePwd then
                ImgSelFlag:setVisible(true)
            end

            ImgPwd:addTouchEventListener(function ( ... )
                --body
                self:onSelChangePwdType(i)
            end)  
        end

        if cc.MENetUtil:getUserType() ~= 0 then
            local ImgPwd = panel:getChildByName("ImgPwd2")
            ImgPwd:setVisible(false)
            local labLoginText = panel:getChildByName("labLoginText")
            labLoginText:setVisible(false)
        end
    end

end

function RankSetLayer:onSelTradeType(nSelType)
    -- body
    self.nSelTrade = nSelType
    local panel = self._children["Panel2"]
    for i=1,2 do
        local imgTrade = panel:getChildByName("ImgTrade" .. i)
        local ImgSelFlag = imgTrade:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelTrade then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RankSetLayer:onSelChangePwdType(nSelType)
    -- body
    self.nSelChangePwd = nSelType
    local panel = self._children["Panel3"]
    for i=1,2 do
        local ImgPwd = panel:getChildByName("ImgPwd" .. i)
        local ImgSelFlag = ImgPwd:getChildByName("ImgSelFlag")
        ImgSelFlag:setVisible(false)
        if i == self.nSelChangePwd then
            ImgSelFlag:setVisible(true)
        end
    end
end

function RankSetLayer:updateBankData()
    self._children["txt_account_gold1"]:setString(cc.MENetUtil:getUserGold())
    self._children["txt_bank_gold1"]:setString(cc.MENetUtil:getBankGold())
    self._children["txt_account_zanshi1"]:setString(cc.MENetUtil:getRoomGold())

    self._children["txt_account_gold2"]:setString(cc.MENetUtil:getUserGold())
    self._children["txt_bank_gold2"]:setString(cc.MENetUtil:getBankGold())
    self._children["txt_account_zanshi2"]:setString(cc.MENetUtil:getRoomGold())

    EventDispatcher:dispatchEvent(EventMsgDefine.UpdateBankData)
end

return RankSetLayer
