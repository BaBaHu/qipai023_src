
local TipsLayer = class("TipsLayer", cc.load("mvc").DialogBase)

TipsLayer.RESOURCE_FILENAME = "tips_layer.csb"

function TipsLayer:onCreate(params)
    print("TipsLayer:onCreate(params) ...............", params)   
    self._children["labelText"]:setString(params.content)

    local function  removeSelf()
        app:backDialog()
    end
    
    if params.okCallBack ~= nil and params.cancelCallBack ~= nil then
        local function OnOk()
            removeSelf()
            params.okCallBack()
        end
        self._children["btn_ok"]:addClickEventListener(OnOk)

        local function OnCancel()
            removeSelf()
            params.cancelCallBack()
        end
        self._children["btn_cancel"]:addClickEventListener(OnCancel)
        self._children["btn_close"]:addClickEventListener(OnCancel)
    elseif params.okCallBack ~= nil then
        self._children["btn_cancel"]:setVisible(false)
        self._children["btn_close"]:setVisible(false)
        local function OnOk()
            removeSelf()
            params.okCallBack()
        end
        self._children["btn_ok"]:addClickEventListener(OnOk)
        self._children["btn_ok"]:setPositionX(self._children["btn_ok"]:getParent():getContentSize().width/2)
    else
        self._children["btn_cancel"]:setVisible(false)
        self._children["btn_ok"]:addClickEventListener(removeSelf)
        self._children["btn_ok"]:setPositionX(self._children["btn_ok"]:getParent():getContentSize().width/2)
        self._children["btn_close"]:addClickEventListener(removeSelf)
    end
end


return TipsLayer
