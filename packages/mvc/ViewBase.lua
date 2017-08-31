
local ViewBase = class("ViewBase", cc.Node)
local EventProxy = require("app.base.EventProxy")

function ViewBase:ctor(name, params)
    self:enableNodeEvents()
    self.name_ = name
    self:decorate(self, EventProxy, EventDispatcher)

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end
    
    if self.onCreate then self:onCreate(params) end

end

function ViewBase:registerDialogMessageListener()
    -- body
    --注册DialogMessage监听回调
    local function OnDialogMessageBackListener(dialog, buttonMask, contextID, strContext)
        -- body
        print("OnDialogMessageBackListener...............................", dialog, buttonMask, contextID, strContext)
        if contextID > 0 then
            strContext = GameTipsConfig[contextID]
        end

        if buttonMask == 0x03 then
            local function okCallBack()
                -- body
                cc.CGDialogManager:shared():PerformOkAction(dialog)
            end
            local function cancelCallBack()
                -- body
                cc.CGDialogManager:shared():PerformCancelAction(dialog)
            end
            self:showTips(strContext, okCallBack, cancelCallBack)
        elseif buttonMask == 0x01 then
            local function okCallBack()
                -- body
            end
            self:showTips(strContext, okCallBack)
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onDialogMessageBack", OnDialogMessageBackListener)
end

function ViewBase:decorate(target, decorater, ...)
    for k, v in pairs(decorater) do
        if type(v) == "function" then
            target[k] = v
        end
    end
    decorater.ctor(target, ...)
    target.is_decorate = true
    return target
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:getEnterTranstion()
    return nil
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode("ccs/"..resourceFilename)
    self.res = resourceFilename
    print(self.res,"名称ssssss")
    local size= cc.Director:getInstance():getVisibleSize()
    self.resourceNode_ :setContentSize(size)
    ccui.Helper:doLayout(self.resourceNode_)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
    self:assignWidgetVariableCallBack(self.resourceNode_)
end
-- 界面控件lua端绑定
function ViewBase:assignWidgetVariableCallBack(node)
    self._children = {}

    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            MEAudioUtils.playSoundEffect("sound/btnClick.mp3")       
        end
    end
           
   local function getChilds( node)
       for k,v in pairs(node:getChildren()) do
            -- print(k,v:getName())
            self._children[v:getName()] = v
            if tolua.type(v) == "ccui.Button" then
                v:addTouchEventListener(touchEvent)
            end
            if(v:getChildrenCount() > 0) then
                getChilds(v)
            end
        end
    end

    getChilds(node)
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

--注册Android回退键
function ViewBase:registerKeyboardListener(callback)
    self.authing  = false
    self.keypadListener_ = cc.EventListenerKeyboard:create()
    self.keypadListener_:registerScriptHandler(function( keyCode, event )
        if keyCode == cc.KeyCode.KEY_BACK then
            if self.authing then return end
            self.authing = true
            self:onKeyBack(callback)
        end
    end, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.keypadListener_, self)
end

--取消注册Android回退键
function ViewBase:removeKeyboardListener()
    -- Android 回退键
    local eventDispatcher = self:getEventDispatcher()
    if self.keypadListener_ then 
        eventDispatcher:removeEventListener(self.keypadListener_)
        self.keypadListener_ = nil
    end
    self.authing  = false
end

function ViewBase:onKeyBack(callback)
    self.authing = false
    if callback then
        callback()
    end
end

function ViewBase:onExit_()
    print("ViewBase:onExit_() -----------------------------------")
    cc.Node.onExit_(self)
    if self.onClear then 
        self:onClear() 
    end
    self:removeKeyboardListener()
    self:removeAllEventListeners()
end

function ViewBase:showTips(content, okCallBack, cancelCallBack)
    if app:isOpenDialog("LoadLayer") then
        app:closeDialog("LoadLayer")
    end
    if app:isOpenDialog("LoadingLayer") then
        app:closeDialog("LoadingLayer")
    end
    if app:isOpenDialog("TipsLayer") then
        app:closeDialog("TipsLayer")
    end
    local params = {}
    params["zorder"]            = 2048
    params["content"]           = content
    params["okCallBack"]        = okCallBack
    params["cancelCallBack"]    = cancelCallBack
    app:openDialog("TipsLayer", params)
end

return ViewBase
