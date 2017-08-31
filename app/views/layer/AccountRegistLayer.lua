
local AccountRegistLayer = class("AccountRegistLayer", cc.load("mvc").DialogBase)

AccountRegistLayer.RESOURCE_FILENAME = "account_regist_layer.csb"

function AccountRegistLayer:onCreate(params) 
    self:setInOutEffectEnable(true)
    self.params = params

    local function  removeSelf()
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    self._children["btn_regies_cancel"]:addClickEventListener(removeSelf)

    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    self._children["btn_regis_ok"]:addClickEventListener(function ( ... )
        -- body
        self:starRegis()
    end)
end

function AccountRegistLayer:starRegis()
    local str_account  = self._children["txt_regis_account"]:getString()
    local str_pwd1  = self._children["txt_regis_pwd1"]:getString()
    local str_pwd2  = self._children["txt_regis_pwd2"]:getString()
    local str_qq  = self._children["txt_regis_qq"]:getString()
    print(str_account, str_pwd1, str_pwd2, str_qq)
    if string.len(str_account) < 6 or string.len(str_pwd1) < 6 or string.len(str_pwd2) < 6 then
        print("账号密码不能少于6位")
        self:showTips("账号密码不能少于6位")
        return
    elseif  str_pwd1 ~= str_pwd2 then
        print("两次密码必须相等")
        self:showTips("两次密码必须相等")
        return
    end
    self.params.registCallBack(str_account, str_pwd2)
end

return AccountRegistLayer
