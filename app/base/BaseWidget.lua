
local BaseWidget = class("BaseWidget", ccui.Widget)

function BaseWidget:ctor(name,...)
    self.name_ = name
    -- check CSB resource file
    self:createResoueceNode(name)

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate(...) end
end


function BaseWidget:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode("ccs/"..resourceFilename)
    local size= cc.Director:getInstance():getVisibleSize()
    assert(self.resourceNode_, string.format("BaseWidget:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
    self:setContentSize(self.resourceNode_:getContentSize())
    self:assignWidgetVariableCallBack(self.resourceNode_)
end
-- 界面控件lua端绑定
function BaseWidget:assignWidgetVariableCallBack(node)
    self._children = {}
   local function getChilds( node)
       for k,v in pairs(node:getChildren()) do
            -- print(k,v:getName())
            self._children[v:getName()] = v
            if(v:getChildrenCount() > 0) then
                getChilds(v)
            end
        end
    end

    getChilds(node)
end

function BaseWidget:createResoueceBinding(binding)
    assert(self.resourceNode_, "BaseWidget:createResoueceBinding() - not load resource node")
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



return BaseWidget
