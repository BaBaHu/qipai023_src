
local AccountLoginLayer = class("AccountLoginLayer", cc.load("mvc").DialogBase)

AccountLoginLayer.RESOURCE_FILENAME = "account_login_layer.csb"

function AccountLoginLayer:onCreate(params) 
    self:setInOutEffectEnable(true)
    self.params = params

    local function  removeSelf()
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    local str_account = cc.UserDefault:getInstance():getStringForKey("account", "")
    local str_pwd= cc.UserDefault:getInstance():getStringForKey("password", "")
    self._children["txt_accout"]:setString(str_account)
    self._children["txt_pwd"]:setString(str_pwd)

    self._children["btn_quick_login"]:addClickEventListener(function ( ... )
        -- body
        self.params.quickloginCallBack()
    end)

     self._children["btn_login"]:addClickEventListener(function ( ... )
        -- body
        local account = self._children["txt_accout"]:getString()
        local pwd     = self._children["txt_pwd"]:getString()
        print(account, pwd)
        if string.len(account) < 6 or string.len(pwd) < 6 then
            print("账号密码不能少于6位")
            self:showTips("账号密码不能少于6位")
            return
        end
        self.params.loginCallBack(account, pwd)
    end)

    self._children["btn_regies"]:addClickEventListener(function ( ... )
        -- body
        app:openDialog("AccountRegistLayer", self.params)
    end)
end


return AccountLoginLayer
