
local AppBase = class("AppBase")

function AppBase:ctor(configs)
    self.configs_ = {
        viewsRoot  = {
            "app.views", 
            "app.views.layer", 
            "app.views.erhzb", 
            "app.views.fourmj", 
            "app.views.fourxz", 
            "app.views.fourhzb", 
            "app.views.bjl"
        },
        modelsRoot = "app.models",
        defaultSceneName = "MainScene",
    }

    for k, v in pairs(configs or {}) do
        self.configs_[k] = v
    end

    if type(self.configs_.viewsRoot) ~= "table" then
        self.configs_.viewsRoot = {self.configs_.viewsRoot}
    end
    if type(self.configs_.modelsRoot) ~= "table" then
        self.configs_.modelsRoot = {self.configs_.modelsRoot}
    end

    if DEBUG > 1 then
        dump(self.configs_, "AppBase configs")
    end

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
    self.dialogStack_ = {}
    self.sceneStack_ = {}
    -- bind 全局事件分发器
    cc.bind(self, "event")
    -- event
    self:onCreate()
end

function AppBase:run(initSceneName)
    initSceneName = initSceneName or self.configs_.defaultSceneName
    self:enterScene(initSceneName)
end

function AppBase:enterScene(sceneName, params, transitionArg, showLoading)
    if self.sceneName_ and self.sceneName_~="SceneSwitcher" then
        if #self.sceneStack_>=3 then
            table.remove(self.sceneStack_,1)
            table.insert(self.sceneStack_, {sceneName=self.sceneName_, params=self.params_})
        else
            table.insert(self.sceneStack_, {sceneName=self.sceneName_, params=self.params_})
        end
        --dump(self.sceneStack_)
    end
    self.dialogStack_ = {}
    if showLoading then
        local to = {name=sceneName, params=params, transition=transitionArg, from=self.currentScene_:getName()}
        local transition = {
            transition = "FADE",
            time = 0.6
        }
        self:enterScene("SceneSwitcher", to, transition)       
        return
    end

    local t1 = os.clock()
    local view = self:createView(sceneName, params)
    local t2 = os.clock()
    print("t1 , t2 ====================================", t1, t2)
    view:setVisible(true)
    self.currentScene_ = view
    self.sceneName_ = sceneName
    self.params_ = params
    local scene = display.newScene(sceneName)
    scene:addChild(view)
    view:adaptor()
    local transition, time, more
    if transitionArg then
        transition, time, more = transitionArg.transition, transitionArg.time, transitionArg.more
    else
        transition, time, more = view:getEnterTranstion()
    end
    local t3 = os.clock()
    display.runScene(scene, transition, time, more)
    local t4 = os.clock()
    print("t3 , t4 ====================================", t3, t4)
    self:onEnterScene(self.currentScene_)
   
    return view
end

function AppBase:backScene()
    if #self.sceneStack_ == 0 then
        self:enterScene("MainScene")
        return
    end

    local index=#self.sceneStack_
    local data=self.sceneStack_[index]
    -- self:enterScene(data.sceneName,data.params)

    local view = self:createView(data.sceneName, data.params)
    view:setVisible(true)
    self.currentScene_ = view
    self.sceneName_=data.sceneName
    local scene = display.newScene(data.sceneName)
    scene:addChild(view)
    local transition, time, more= view:getEnterTranstion()
    if transitionArg then
        transition, time, more = transitionArg.transition, transitionArg.time, transitionArg.more
    else
        transition, time, more = view:getEnterTranstion()
    end
    local t3 = os.clock()
    display.runScene(scene, transition, time, more)
    local t4 = os.clock()

    self:onEnterScene(self.currentScene_)

    table.remove(self.sceneStack_,index)
    -- table.remove(self.sceneStack_,index+1)
    dump(self.sceneStack_)
end

function AppBase:getCurScene()
    return self.currentScene_
end

function AppBase:getSceneName()
    return self.sceneName_
end

function AppBase:getViewRoots()
    return clone(self.configs_.viewsRoot)
end

function AppBase:openDialog(dialogName, args)
    if app:isOpenDialog(dialogName) then
        return
    end
    local dialog = self:createView(dialogName, args)
    assert(dialog)
    local runningScene = self:getCurScene()
    runningScene:addChild(dialog, 999)
    if type(args) == "table" and args.zorder then
        dialog:setLocalZOrder(args.zorder)
    end
    dialog:open(args)
    self.currentDialog_ = dialog
    self.dialog_params_ = args
    
    self:onOpenDialog(dialog)
    table.insert(self.dialogStack_,dialog)
    
    return dialog
end

function AppBase:backDialog()
    local index = #self.dialogStack_
    if index > 0 then
        self.currentDialog_ = self.dialogStack_[index]
        table.remove(self.dialogStack_,index)
    end

    if self.currentDialog_ ~= nil then
        self.currentDialog_:close()
        self.currentDialog_ = nil
    end
    dump(self.dialogStack_)
end

function AppBase:getCurDialog()
    return self.currentDialog_
end

function AppBase:getDialogCounts()
    return #self.dialogStack_
end

function AppBase:closeDialog(dialogName)
    if self.currentDialog_ ~= nil and self.currentDialog_:getName() == dialogName then
        self.currentDialog_:close()
        self.currentDialog_ = nil
    end
end

function AppBase:isOpenDialog(dialogName)
    for k,v in pairs(self.dialogStack_) do
        if v:getName() == dialogName then
            return true
        end
    end
    return false
end

function AppBase:onDialogClosed(closingDialog)
    if closingDialog == nil then
        print("Dialog: closed error closingDialog == nil !!!!!")
        return
    end
    for k,v in pairs(self.dialogStack_) do
        if v:getName() == closingDialog:getName() then
            table.remove(self.dialogStack_,k)
        end
    end
    me.TextureCache:removeUnusedTextures()
    print("Dialog: [%s],  count[%d] closed!", closingDialog:getName(), #self.dialogStack_)
end

function AppBase:createView(name, params)
    print("createView "..name)
    dump(self.configs_.viewsRoot)
    for _, root in ipairs(self.configs_.viewsRoot) do
        local packageName = string.format("%s.%s", root, name)
        local file = string.gsub(clone(packageName), "%.", "/")
        if cc.FileUtils:getInstance():isFileExist( file..".lua" ) or cc.FileUtils:getInstance():isFileExist( file..".luac" ) then
            local status, view = xpcall(function()
                    return require(packageName)
                end, function(msg)
                print(msg)
                if not string.find(msg, string.format("'%s' not found:", packageName)) then
                    print("load view error: ", msg)
                end
            end)
            local t = type(view)
            if status and (t == "table" or t == "userdata") then
                return view:create(name, params)
            end
        end
    end
    error(string.format("AppBase:createView() - not found view \"%s\" in search paths \"%s\"",
        name, table.concat(self.configs_.viewsRoot, ",")), 0)
end

function AppBase:onCreate()
end

function AppBase:onExit()
end

function AppBase:onEnterScene(scene)
    print("enter scene [%s]", scene:getName())
end

function AppBase:onOpenDialog(dialog)
    print("open dialog [%s]", dialog:getName())
end

--不同分辨率下，场景居中偏移量
function AppBase:getSceneCenteroffset()
    --分辨率居中偏移
    local director = cc.Director:getInstance()
    local size = director:getWinSize()
    local y = math.abs(me.designHeight - size.height)/2
    local x = math.abs(me.designWidth - size.width)/2
    print("getSceneCenteroffset = ", x, y, me.designWidth, me.designHeight, size.width, size.height)
    return cc.p(x,y)
end

function AppBase:exit()
    self:onExit()
    cc.Director:getInstance():endToLua()
end

return AppBase
