
local BaiJiaLeScene = class("BaiJiaLeScene", cc.load("mvc").SceneBase)
local DDMaJiang = require("app.views.bjl.DDMaJiang")
local GameController = require("app.views.bjl.GameController")
BaiJiaLeScene.RESOURCE_FILENAME = "game_bjl/bjl_scene.csb"

local helper                = import(".helper")
local tArea = 
{
    [1] = "res/game_bjl/bjl_touch_fengdui.png",
    [2] = "res/game_bjl/bjl_touch_feng.png",
    [3] = "res/game_bjl/bjl_touch_he.png",
    [4] = "res/game_bjl/bjl_touch_long.png",
    [5] = "res/game_bjl/bjl_touch_longdui.png",
}

function BaiJiaLeScene:onCreate()
    print("BaiJiaLeScene:onCreate() .............................")
    self:initData()
    --处理逻辑
    GameController:init(self)

    self:addEventListener(EventMsgDefine.APP_ENTERBACKGROUND,self.GameEnterBackground,self)
    self:addEventListener(EventMsgDefine.APP_ENTERFOREGROUND,self.GameEnterForeground,self)
    self.isFirstShowTips = true
    self.roomUsers = {}
    self.tips = {}
    self:initUI()
    self:initListener()
    self:addEventListener(EventMsgDefine.ShowNoticeMsg,self.ShowNoticeMsg,self)
end

function BaiJiaLeScene:initData()
    -- body
    self.tBetData       = {}
    self.isBet          = false
    self.longCounts_    = 0
    self.heCounts_      = 0
    self.fengCounts_    = 0
    self.recordlist     = {}
    self.isDoing        = true
    self.isCheat        = false
    self.selfSex        = cc.MENetUtil:getSex()
    self.nSelBetType    = -1
    self.tJeton =       {}
    for i=1, 5 do
        local sprite = self._children["Img_touch_" .. i]
        sprite:setVisible(false)
        local totalScorePanel = self._children["totalScorePanel" .. i]
        totalScorePanel:setLocalZOrder(120)
        totalScorePanel:setVisible(false)
    end
    self.tApplerBanker = {}
    self.tCurBanker = {}
    self.tCardList = {}
    self.dispatchCardFinishCount = 0
    self.nFengPoint = 0
    self.nLongPoint = 0

    self:addEventListener(EventMsgDefine.DispatchCardFinish,self.DispatchCardFinish,self)
end

function BaiJiaLeScene:initUI()
    self._children["ImgNoticeBg"]:setVisible(false)

    self._children["lab_time_self"]:setString("")
    self._children["lab_longNum"]:setString(0)
    self._children["lab_fengNum"]:setString(0)
    self._children["lab_heNum"]:setString(0)
    self._children["lab_duiNum"]:setString(0)

    self._children["lab_long"]:setString(0)
    self._children["lab_he"]:setString(0)
    self._children["lab_feng"]:setString(0)
    self._children["ly_tipsMsg"]:setVisible(false)
    
    self._children["ImgBanker"]:setVisible(false)
    self._children["fengPoint"]:setVisible(false)
    self._children["longPoint"]:setVisible(false)
    self._children["fengWin"]:setVisible(false)
    self._children["heWin"]:setVisible(false)
    self._children["longWin"]:setVisible(false)

    self._children["lab_ZhuangScore"]:setString(0)
    self._children["lab_ZhuangCounts"]:setString(0)

    self.lab_self_info_name = self._children["lab_self_info_name"]
    self.lab_self_info_name:setString(cc.MENetUtil:getNickName() )
    self.lab_self_gold = self._children["lab_self_gold"]
    self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )

    local url = cc.MENetUtil:getUserIconUrl()   
    if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
        local faceId = cc.MENetUtil:getFaceID()%20 + 1
        self._children["head"]:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
    else
        --下载头像
        print("url = ", url)
        local customid = Helper:md5sum(url)
        local filename = Helper:getFileNameByUrl(url, customid)
        print(filename)
        self._children["head"]:loadTexture(filename)
    end
    
    self.bankerListView = self._children["BankerListView"]
    self.item = self._children["item"]
    self.item:setVisible(false)
    self.bankerListView:setItemModel(self.item)

    self.labelTips = self._children["labelTips"]
end

function BaiJiaLeScene:onEnterTransitionFinish()
    print("BaiJiaLeScene:onEnterTransitionFinish() ...................................")
    audio.playMusic("soundbjl/BACK_GROUND.mp3",true) 
    self:registerDialogMessageListener()
    GameController:initEvent()
    cc.MENetUtil:enterGame()
end

function BaiJiaLeScene:onEnter()
    print("BaiJiaLeScene:onEnter() ..........................................")
end

function BaiJiaLeScene:GameEnterBackground()
    -- body
end

function BaiJiaLeScene:GameEnterForeground()
    -- body
end

function BaiJiaLeScene:clear()
    -- body
    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
end

function BaiJiaLeScene:ShowNoticeMsg( msg )
    -- body
    print("BaiJiaLeScene:ShowNoticeMsg( msg )", msg)
    self._children["ImgNoticeBg"]:setVisible(true)
    self._children["msgPanel"]:removeAllChildren()
    
    local s = self._children["msgPanel"]:getContentSize()
    local labelTips = cc.Label:createWithTTF(msg, "res/fonts/fzzyjt.ttf", 45) 
    labelTips:setColor(cc.c3b(255, 255, 255))
    local s1 = labelTips:getContentSize()
    labelTips:setPosition(cc.p(s.width + s1.width, s.height/2))
    self._children["msgPanel"]:addChild(labelTips)
     
    local seq = cc.Sequence:create(
        cc.MoveTo:create(12, cc.p(-s.width - s1.width, s.height/2) ),
        cc.CallFunc:create(function()
            labelTips:removeFromParent()
            self._children["ImgNoticeBg"]:setVisible(false)
        end)
    )       
    labelTips:runAction(seq)
end

function BaiJiaLeScene:initListener()
    local function setBack()
        local function doOk()
            self:GameRoomOut()
        end
        local function doCancel()
            
        end
        self:showTips("是否真的强制退出？", doOk, doCancel)
    end
    self._children["btn_exit"]:addClickEventListener(setBack)
    self:registerKeyboardListener(function ( ... )
        -- body
        setBack()
    end)

    self._children["btn_setting"]:addClickEventListener(function ( ... )
        -- body
        app:openDialog("SettingSoundLayer", false)
    end)

    self._children["btn_bank"]:addClickEventListener(function ( ... )
        -- body
        
    end)
    self._children["btn_ludan"]:addClickEventListener(function ( ... )
        -- body
        app:openDialog("BaiJiaLeLuDanLayer", self.recordlist)
    end)

    local function applerBanker(pSender)
        local tag = pSender:getTag()
        if tag == 1 then
            --申请
            if cc.MENetUtil:GetPlayerFreeScore() < self.lApplyBankerCondition then
                self:showTips("您的自由金币无法达到申请条件!")
                return
            end
            cc.MENetUtil:applyBanker()
        else
            cc.MENetUtil:cancelBanker()
        end
    end
    self._children["btn_apple_banker"]:setTag(1)
    self._children["btn_apple_banker"]:addClickEventListener(applerBanker)

    for i=1,7 do
        local function onClicked(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                print("this is click .......................", sender:getTag() )
                if self.nSelBetType ~= -1 then
                    local nJeton = helper.getJetonByIndex(self.nSelBetType )
                    self._children["Image_ma_" .. self.nSelBetType]:loadTexture("bjl_n_" ..nJeton..".png", ccui.TextureResType.plistType)
                end
                self.nSelBetType = sender:getTag()
                local nJeton = helper.getJetonByIndex(self.nSelBetType)
                self._children["Image_ma_" .. self.nSelBetType]:loadTexture("bjl_p_" ..nJeton..".png", ccui.TextureResType.plistType)
                
            end
        end
        self._children["Image_ma_" .. i]:addTouchEventListener(onClicked)
    end


    local function checkTouch( location )
        -- body
        local nTouchIdx = -1
        for i=1, 5 do
            local bTouch = false
            local sprite = self._children["Img_touch_" .. i]
            local rect   = sprite:getBoundingBox()
            local s = sprite:getContentSize()
            if cc.rectContainsPoint(rect, location) then
                local pos = cc.pAdd(cc.pSub(location, cc.p(sprite:getPosition())), cc.p(s.width/2, s.height/2))
                if cc.MEFileUtil:checkSpritePixel(pos.x, pos.y, tArea[i]) then
                    bTouch = true
                    nTouchIdx = i
                end
            end
            sprite:setVisible(bTouch)
        end

        return nTouchIdx
    end

    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        local nTouchIdx = checkTouch(location)
        if nTouchIdx ~= -1 then
            return true
        end
        return false
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        local nTouchIdx = checkTouch(location)
        print("onTouchEnded ==============================", nTouchIdx)
        if nTouchIdx ~= -1 then
            self:placeBet(nTouchIdx)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self._children["panel"]:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._children["panel"])
end

function BaiJiaLeScene:placeBet(nIdx)
    self._children["Img_touch_" .. nIdx]:setVisible(false)
    if cc.MENetUtil:GetGameCurState() ~= 100 then
        print("当前不是下注的时间!!!!!!!!!!!!!!!!", cc.MENetUtil:GetGameCurState() )
        return
    end
    if cc.MENetUtil:getCurBanker() == cc.MENetUtil:getChairID() then
        print("你是庄家用户不能下注!!!!!!!!!!!!!!!!")
        return
    end
    if self.nSelBetType == -1 then
        print("没有选择筹码!!!!!!!!!!!!!!!!")
        return
    end
    local nAreaIdx = helper.getAreaByClientIndex(nIdx)
    local nJeton = helper.getJetonByIndex(self.nSelBetType )
    --检测区域
    local nScore = cc.MENetUtil:GetMaxPlayerScore(nAreaIdx)
    if nJeton > nScore then
        print("选择的筹码大于区域可下注的!!!!!!!!!!!!!!!!", nJeton, nScore)
        return
    end
    cc.MENetUtil:placeBet(nAreaIdx, nJeton)
    self.isBet = true
end

function BaiJiaLeScene:setTargetPlayerInfo(data)
    if data.isEnter then
        self.roomUsers[data.chair + 1] = data
    else
        self.roomUsers[data.chair + 1] = nil
    end
    --dump(self.roomUsers, "房间游戏用户")
end

function BaiJiaLeScene:getRoomUsers(nChairID)
    -- body
    return self.roomUsers[nChairID + 1]
end

function BaiJiaLeScene:UpdateUserClock(nChairID, nClock)
    self._children["lab_time_self"]:setString( string.format("%02d", nClock ))
end

function BaiJiaLeScene:GameRoomOut()
    -- body
    if not self.isCheat then
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)
    end

    --退出房间
    cc.MENetUtil:leaveGame()
end

function BaiJiaLeScene:GameNoticeMessage(str)
    local tmp = string.find(str,"百家乐")
    if tmp ~= nil then
        if not self.isFirstShowTips then
            return
        end
        self.isFirstShowTips = false
    end
    --可以坐下
    self._children["ly_tipsMsg"]:setVisible(true)
    self._children["ly_tipsMsg"]:stopAllActions()
    self._children["lab_tips"]:setString(str)
    self._children["ly_tipsMsg"]:setOpacity(255)
    local seq = cc.Sequence:create(cc.DelayTime:create(2),
        cc.FadeOut:create(1)
        )
    self._children["ly_tipsMsg"]:runAction(seq) 
end

function BaiJiaLeScene:UpdateAreaScore()
    -- body
    self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )

    --显示区域最大可下注
    self._children["lab_longNum"]:setString(cc.MENetUtil:GetMaxPlayerScore(2) )
    self._children["lab_fengNum"]:setString(cc.MENetUtil:GetMaxPlayerScore(0) )
    self._children["lab_heNum"]:setString(cc.MENetUtil:GetMaxPlayerScore(1) )
    self._children["lab_duiNum"]:setString(cc.MENetUtil:GetMaxPlayerScore(6) )
end

function BaiJiaLeScene:UpdateJeton()
    -- body
    local nGold = cc.MENetUtil:getUserGold()
    for i=1,7 do
        local nJeton = helper.getJetonByIndex(i)
        if nGold < nJeton then
            self._children["Image_ma_" .. i]:setTouchEnabled(false)
            self._children["Image_ma_" .. i]:loadTexture("bjl_d_" ..nJeton..".png", ccui.TextureResType.plistType)
            if self.nSelBetType == i then
                self.nSelBetType = -1
            end
        else
            self._children["Image_ma_" .. i]:setTouchEnabled(true)
            if self.nSelBetType == i then
                self._children["Image_ma_" .. i]:loadTexture("bjl_p_" ..nJeton..".png", ccui.TextureResType.plistType)
            else
                self._children["Image_ma_" .. i]:loadTexture("bjl_n_" ..nJeton..".png", ccui.TextureResType.plistType)
            end
        end
    end
end

--添加筹码
function BaiJiaLeScene:AddChip(nChairID, cbViewIndex, lScoreCount)
    -- body
    local nArea = helper.getAreaByServerIndex(cbViewIndex)
    if nArea == -1 then
        return
    end

    --筹码
    local imgJeton = display.newSprite("#bjl_n_" ..lScoreCount..".png")
    imgJeton:setScale(0.5)
    local s1 = imgJeton:getContentSize()
    local s = self._children["Img_touch_" .. nArea]:getContentSize()
    local nPos = cc.p(self._children["Img_touch_" .. nArea]:getPosition())
    local nAddPos 
    while true do
        local x = math.random(nPos.x - s.width/2 + s1.width/2*imgJeton:getScale()+50, nPos.x + s.width/2 - s1.width/2*imgJeton:getScale() - 50)
        local y = math.random(nPos.y - s.height/2 + s1.height/2*imgJeton:getScale()+50, nPos.y + s.height/2 - s1.height/2*imgJeton:getScale() -50)
        nAddPos = cc.p(x, y)
        local pos = cc.pAdd(cc.pSub(nAddPos, nPos), cc.p(s.width/2, s.height/2))
        if cc.MEFileUtil:checkSpritePixel(pos.x, pos.y, tArea[nArea]) then
            break
        end
    end
    imgJeton:setPosition(nAddPos)
    self._children["panel"]:addChild(imgJeton, 100)
    if self.tJeton[nArea] == nil then
        self.tJeton[nArea] = {}
    end
    self.tJeton[nArea][#self.tJeton[nArea] + 1] = imgJeton
    print("nArea =============================", nArea, #self.tJeton[nArea])

    if nChairID == cc.MENetUtil:getChairID() then
        --自己筹码数量
        local imgJetonNumBg = self._children["panel"]:getChildByName("imgJetonNumBg" .. nArea)
        if imgJetonNumBg == nil then
            imgJetonNumBg = display.newSprite("#bjl_zhu_bg.png")
            imgJetonNumBg:setPosition(nPos)
            imgJetonNumBg:setName("imgJetonNumBg" .. nArea)
            self._children["panel"]:addChild(imgJetonNumBg, 200)
        end
        local labScore = imgJetonNumBg:getChildByName("labAreaPlayerScore")
        if labScore == nil then
            local s = imgJetonNumBg:getContentSize()
            labScore = ccui.TextBMFont:create()
            labScore:setName("labAreaPlayerScore")
            labScore:setFntFile("res/fonts/fnt_9.fnt")
            labScore:setPosition(cc.p(s.width/2, s.height/2))
            imgJetonNumBg:addChild(labScore, 3)
        end
        labScore:setString(cc.MENetUtil:GetAreaPlayerScore(cbViewIndex) )
    end

    local totalScorePanel = self._children["totalScorePanel" .. nArea]
    totalScorePanel:setVisible(true)
    local labelAllScore = totalScorePanel:getChildByName("labelAllScore")
    labelAllScore:setString(cc.MENetUtil:GetAreaTotalScore(cbViewIndex) )

    --
    if lScoreCount == 5000000 or lScoreCount == 10000000 then
        local armature = ccs.Armature:create("BJLEffect1")
        if armature ~= nil then
            armature:getAnimation():playWithIndex(0)
            armature:setPosition(cc.p(nPos.x , nPos.y + 50) )
            armature:getAnimation():setSpeedScale(0.5)
            self._children["panel"]:addChild(armature, 1024)

            --注册事件回调
            local function animationEvent(armatureBack,movementType,movementID)
                local id = movementID
                if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then    
                    armatureBack:removeFromParent(true)
                end
            end
            armature:getAnimation():setMovementEventCallFunc(animationEvent)
        end
        MEAudioUtils.playSoundEffect("soundbjl/ADD_GOLD_EX.mp3")
    else
        MEAudioUtils.playSoundEffect("soundbjl/ADD_GOLD.mp3")
    end
end

--删除筹码
function BaiJiaLeScene:RemoveChip(nChairID, cbViewIndex, lScoreCount)
    -- body
    local nArea = helper.getAreaByServerIndex(cbViewIndex)
    if nArea == -1 then
        return
    end
    local imgJeton = self.tJeton[nArea][#self.tJeton[nArea]]
    if imgJeton ~= nil then
        imgJeton:removeFromParent()
    end
    self.tJeton[nArea][#self.tJeton[nArea]] = nil

    if nChairID == cc.MENetUtil:getChairID() then
        --自己筹码数量
        local imgJetonNumBg = self._children["panel"]:getChildByName("imgJetonNumBg" .. nArea)
        if imgJetonNumBg == nil then
            return
        end
        local nScore = cc.MENetUtil:GetAreaPlayerScore(cbViewIndex)
        if nScore <= 0 then
            imgJetonNumBg:removeFromParent()
        end
        local labScore = imgJetonNumBg:getChildByName("labAreaPlayerScore")
        if labScore ~= nil then
            labScore:setString(nScore )
        end
    end

    local totalScorePanel = self._children["totalScorePanel" .. nArea]
    local nScore = cc.MENetUtil:GetAreaTotalScore(cbViewIndex)
    if nScore <= 0 then
        totalScorePanel:setVisible(false)
    end
    local labelAllScore = totalScorePanel:getChildByName("labelAllScore")
    labelAllScore:setString(nScore)
end

function BaiJiaLeScene:UpdateBankerListView()
    self.bankerListView:removeAllChildren()

    local t = {}
    t[#t + 1] = self.tCurBanker

    for i=1, #self.tApplerBanker do
        t[#t + 1] = self.tApplerBanker[i]
    end

    for i=1, #t do
        self.bankerListView:pushBackDefaultItem()
    end

    for i = 1, #t do
        local item       = self.bankerListView:getItem(i - 1)
        local img_zhuang = item:getChildByName("img_zhuang")
        local lab_name   = item:getChildByName("lab_name")   
        local lab_count  = item:getChildByName("lab_count")
        item:setVisible(true)

        local data = t[i]

        img_zhuang:setVisible(data.isBankerUser)
        lab_name:setString(data.nickname)
        lab_count:setString(data.nGold)
    end
end

function BaiJiaLeScene:GameTipInfo(data)
    dump(data, "游戏提示")
    self.tips[#self.tips + 1] = data.szTipInfo
    self.labelTips:setString("[系统提示]:" .. data.szTipInfo)
end

function BaiJiaLeScene:enterGame(data)
    if data.isPlayerBanker == 0 then
        --[[self._children["ImgBanker"]:setVisible(true)
        if data.wBankerUser == cc.MENetUtil:getChairID() then
            self._children["ImgBanker"]:loadTexture("bjl_nin.png", ccui.TextureResType.plistType)
        else
            self._children["ImgBanker"]:loadTexture("bjl_lun.png", ccui.TextureResType.plistType)
        end
        local action = cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.CallFunc:create(function()
                self._children["ImgBanker"]:setVisible(false) 
            end)
            )
        self._children["ImgBanker"]:runAction(action)]]
         
        self.tCurBanker["isBankerUser"] = true
        self.tCurBanker["nGold"] = data.nGold
        self.tCurBanker["nChairID"] = data.wBankerUser
        self.tCurBanker["nickname"] = data.szName
    elseif data.isPlayerBanker == 1 then
        self._children["ImgBanker"]:setVisible(true)
        self._children["ImgBanker"]:loadTexture("bjl_xitong.png", ccui.TextureResType.plistType)
        self.tCurBanker = {}
    elseif data.isPlayerBanker == 2 then
        self._children["ImgBanker"]:setVisible(true)
        self._children["ImgBanker"]:loadTexture("bjl_wu.png", ccui.TextureResType.plistType)
        self.tCurBanker = {}
    end
    self:UpdateBankerListView()

    if data.wBankerUser == cc.MENetUtil:getChairID() then
        self._children["btn_apple_banker"]:loadTextures("bjl_btn_zhuang3.png","bjl_btn_zhuang4.png","", ccui.TextureResType.plistType)
        self._children["btn_apple_banker"]:setTag(2)
    end
    self.lApplyBankerCondition = data.lApplyBankerCondition
    self._children["lab_ZhuangScore"]:setString(data.lBankerWinScore)
    self._children["lab_ZhuangCounts"]:setString(data.wBankerTime)
    self:UpdateJeton()
end

function BaiJiaLeScene:RecoveryJeton(cbViewIndex, lScoreCount)
    for i=7, 1, -1 do
        local nJeton = helper.getJetonByIndex(i)
        local lCellCount = math.floor(lScoreCount / nJeton)
        if lCellCount ~= 0 then
            for j=1, lCellCount  do
                self:AddChip(nil, cbViewIndex, nJeton)
            end
        end
        --减少数目
        lScoreCount = lScoreCount - lCellCount*nJeton
    end
end

function BaiJiaLeScene:RecoverySelfJeton(cbViewIndex, lScoreCount)
    -- body
    local nArea = helper.getAreaByServerIndex(cbViewIndex)
    if nArea == -1 then
        return
    end
    local nPos = cc.p(self._children["Img_touch_" .. nArea]:getPosition())
    --自己筹码数量
    local imgJetonNumBg = self._children["panel"]:getChildByName("imgJetonNumBg" .. nArea)
    if imgJetonNumBg == nil then
        imgJetonNumBg = display.newSprite("#bjl_zhu_bg.png")
        imgJetonNumBg:setPosition(nPos)
        imgJetonNumBg:setName("imgJetonNumBg" .. nArea)
        self._children["panel"]:addChild(imgJetonNumBg, 200)
    end
    local labScore = imgJetonNumBg:getChildByName("labAreaPlayerScore")
    if labScore == nil then
        local s = imgJetonNumBg:getContentSize()
        labScore = ccui.TextBMFont:create()
        labScore:setName("labAreaPlayerScore")
        labScore:setFntFile("res/fonts/fnt_9.fnt")
        labScore:setPosition(cc.p(s.width/2, s.height/2))
        imgJetonNumBg:addChild(labScore, 3)
    end
    labScore:setString(lScoreCount)
end

function BaiJiaLeScene:GameRecovery(data)
    dump(data, "游戏中")
    self:enterGame(data)
    self:UpdateAreaScore()
    print("我的椅子 =======================================", cc.MENetUtil:getChairID())
    if data.cbGameStatus == 101 then
        self:showGameOver(data)
    elseif data.cbGameStatus == 100 then
        self._children["ImgCurTime"]:loadTexture("bjl_bet_time.png", ccui.TextureResType.plistType)
        for i=1,5 do
            local nArea = helper.getAreaByClientIndex(i)
            local lScoreCount = data.lAllBet[nArea+1]
            self:RecoveryJeton(nArea, lScoreCount)

            local lSelfScoreCount = data.lPlayBet[nArea+1]
            if lSelfScoreCount > 0 then
                self:RecoverySelfJeton(nArea, lSelfScoreCount)
            end
        end
    end
end

function BaiJiaLeScene:GameFree(data)
    dump(data, "游戏空闲")
    self.tBetData       = {}
    self._children["ImgCurTime"]:loadTexture("bjl_free_time.png", ccui.TextureResType.plistType)

    if app:isOpenDialog("BaiJiaLeResultLayer") then
        app:closeDialog("BaiJiaLeResultLayer")
    end
    --清除筹码
    for k,v in pairs(self.tJeton) do
        for m,n in pairs(v) do
            n:removeFromParent()
        end
    end
    self.tJeton = {}

    if self.nSelBetType ~= -1 then
        local nJeton = helper.getJetonByIndex(self.nSelBetType )
        self._children["Image_ma_" .. self.nSelBetType]:loadTexture("bjl_n_" ..nJeton..".png", ccui.TextureResType.plistType)
    end
    self.nSelBetType = -1

    for i=1,5 do
        local sprite = self._children["Img_touch_" .. i]
        sprite:stopAllActions()
        sprite:setVisible(false)
        
        local totalScorePanel = self._children["totalScorePanel" .. i]
        totalScorePanel:setVisible(false)

        local imgJetonNumBg = self._children["panel"]:getChildByName("imgJetonNumBg" .. i)
        if imgJetonNumBg ~= nil then
            imgJetonNumBg:removeFromParent()
        end
    end

    for k,v in pairs(self.tCardList) do
        for m,n in pairs(v) do
            n:removeFromParent()
        end
    end
    self.tCardList = {}

    self._children["fengPoint"]:setVisible(false)
    self._children["longPoint"]:setVisible(false)
    self._children["fengWin"]:setVisible(false)
    self._children["heWin"]:setVisible(false)
    self._children["longWin"]:setVisible(false)
    self.nFengPoint = 0
    self.nLongPoint = 0

    self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    if self.tCurBanker.nChairID == cc.MENetUtil:getChairID() then
        self.tCurBanker["nGold"] = cc.MENetUtil:getUserGold()
    end
    for k,v in pairs(self.tApplerBanker) do
        if v.nChairID == cc.MENetUtil:getChairID() then
            v.nGold = cc.MENetUtil:getUserGold()
            break
        end
    end
    self:UpdateBankerListView()
end

function BaiJiaLeScene:GameStart(data)
    dump(data, "游戏开始")

    self._children["ImgCurTime"]:loadTexture("bjl_bet_time.png", ccui.TextureResType.plistType)

    MEAudioUtils.playSoundEffect("soundbjl/GAME_START.mp3")
    if app:isOpenDialog("BaiJiaLeResultLayer") then
        app:closeDialog("BaiJiaLeResultLayer")
    end

    if data.isPlayerBanker == 0 then
        --[[self._children["ImgBanker"]:setVisible(true)
        if data.wBankerUser == cc.MENetUtil:getChairID() then
            self._children["ImgBanker"]:loadTexture("bjl_nin.png", ccui.TextureResType.plistType)
        else
            self._children["ImgBanker"]:loadTexture("bjl_lun.png", ccui.TextureResType.plistType)
        end
        local action = cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.CallFunc:create(function()
                self._children["ImgBanker"]:setVisible(false) 
            end)
            )
        self._children["ImgBanker"]:runAction(action)
        ]] 
        self.tCurBanker["isBankerUser"] = true
        self.tCurBanker["nGold"] = data.nGold
        self.tCurBanker["nChairID"] = data.wBankerUser
        self.tCurBanker["nickname"] = data.szName
    elseif data.isPlayerBanker == 1 then
        self._children["ImgBanker"]:setVisible(true)
        self._children["ImgBanker"]:loadTexture("bjl_xitong.png", ccui.TextureResType.plistType)
        self.tCurBanker = {}
    elseif data.isPlayerBanker == 2 then
        self._children["ImgBanker"]:setVisible(true)
        self._children["ImgBanker"]:loadTexture("bjl_wu.png", ccui.TextureResType.plistType)
        self.tCurBanker = {}
    end
    
    self:UpdateBankerListView()

    self:UpdateAreaScore()
    self:UpdateJeton()

    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
    local function tick()
        cc.MENetUtil:getBet()
    end
    self.schedulerID = me.Scheduler:scheduleScriptFunc(tick, 0.02, false)
end

function BaiJiaLeScene:GamePlaceBet(data)
    dump(data, "用户下注")
   
    self:AddChip(data.wChairID, data.cbBetArea, data.lBetScore)

    self:UpdateAreaScore()
    self:UpdateJeton()
end

function BaiJiaLeScene:GameCancelBet(data)
    dump(data, "取消下注")

    --self:UpdateAreaScore()
    --self:UpdateJeton()
end

function BaiJiaLeScene:GamePlaceBetFail(data)
    dump(data, "下注失败")

    self:RemoveChip(data.wPlaceUser, data.lBetArea, data.lPlaceScore)

    self:UpdateAreaScore()
    self:UpdateJeton()
end

function BaiJiaLeScene:GameApplyBanker(data)
    dump(data, "申请庄家")
    local t = {}
    t["isBankerUser"] = false
    t["nChairID"]   = data.wApplyUser
    t["nickname"]   = data.szName
    t["nGold"]      = data.nGold
    self.tApplerBanker[#self.tApplerBanker + 1] = t

    if data.wApplyUser == cc.MENetUtil:getChairID() then
        self._children["btn_apple_banker"]:loadTextures("bjl_quxiao.png","bjl_quxiao2.png","", ccui.TextureResType.plistType)
        self._children["btn_apple_banker"]:setTag(2)
    end
    self:UpdateBankerListView()
end

function BaiJiaLeScene:GameCancelBanker(data)
    dump(data, "取消申请")

    if data.wCancelUser == cc.MENetUtil:getChairID() then 
        self._children["btn_apple_banker"]:loadTextures("bjl_btn_zhuang1.png","bjl_btn_zhuang2.png","", ccui.TextureResType.plistType)
        self._children["btn_apple_banker"]:setTag(1)
    end

    for k,v in pairs(self.tApplerBanker) do
        if v.nChairID == data.wCancelUser then
            table.remove(self.tApplerBanker, k)
            break
        end
    end
    self:UpdateBankerListView()
end

function BaiJiaLeScene:GameChangeBanker(data)
    dump(data, "更改庄家")

    if self.tCurBanker.nChairID == cc.MENetUtil:getChairID() then
        self._children["btn_apple_banker"]:loadTextures("bjl_btn_zhuang1.png","bjl_btn_zhuang2.png","", ccui.TextureResType.plistType)
        self._children["btn_apple_banker"]:setTag(1)
    end

    if data.isPlayerBanker == 0 then
        self._children["ImgBanker"]:setVisible(true)
        if data.wBankerUser == cc.MENetUtil:getChairID() then
            self._children["ImgBanker"]:loadTexture("bjl_nin.png", ccui.TextureResType.plistType)
        else
            self._children["ImgBanker"]:loadTexture("bjl_lun.png", ccui.TextureResType.plistType)
        end
        local action = cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.CallFunc:create(function()
                self._children["ImgBanker"]:setVisible(false) 
            end)
            )
        self._children["ImgBanker"]:runAction(action)
         
        self.tCurBanker["isBankerUser"] = true
        self.tCurBanker["nGold"] = data.nGold
        self.tCurBanker["nChairID"] = data.wBankerUser
        self.tCurBanker["nickname"] = data.szName
    elseif data.isPlayerBanker == 1 then
        self._children["ImgBanker"]:setVisible(true)
        self._children["ImgBanker"]:loadTexture("bjl_xitong.png", ccui.TextureResType.plistType)
        self.tCurBanker = {}
    elseif data.isPlayerBanker == 2 then
        self._children["ImgBanker"]:setVisible(true)
        self._children["ImgBanker"]:loadTexture("bjl_wu.png", ccui.TextureResType.plistType)
        self.tCurBanker = {}
    end
    for k,v in pairs(self.tApplerBanker) do
        if v.nChairID == data.wBankerUser then
            table.remove(self.tApplerBanker, k)
            break
        end
    end
    self:UpdateBankerListView()

    if data.wBankerUser == cc.MENetUtil:getChairID() then
        self._children["btn_apple_banker"]:loadTextures("bjl_btn_zhuang3.png","bjl_btn_zhuang4.png","", ccui.TextureResType.plistType)
        self._children["btn_apple_banker"]:setTag(2)
    end
    self._children["lab_ZhuangScore"]:setString(0)
    self._children["lab_ZhuangCounts"]:setString(0)

    self:UpdateAreaScore()
end

function BaiJiaLeScene:GameReSortBanker(data)
    dump(data, "重排序庄家")

    self.tApplerBanker = {}
    for k,v in pairs(data.wUserList) do
        local t = {}
        t["isBankerUser"] = false
        t["nChairID"]   = v.wUserChairID
        t["nickname"]   = v.szName
        t["nGold"]      = v.nGold
        self.tApplerBanker[#self.tApplerBanker + 1] = t
    end
    self:UpdateBankerListView()
end

function BaiJiaLeScene:GameCommandResult(data)
    dump(data, "管理员命令结果")
end

function BaiJiaLeScene:GameSendRecord(data)
    dump(data, "游戏记录")
    self.recordlist = data.RecordData
    print(self.recordlist)
    self.longCounts_ = 0
    self.heCounts_ = 0
    self.fengCounts_ = 0
    for k,v in pairs(self.recordlist) do
        if v.cbPlayerCount > v.cbBankerCount then
            self.fengCounts_ = self.fengCounts_ + 1
        elseif v.cbPlayerCount < v.cbBankerCount then
            self.longCounts_ = self.longCounts_ + 1
        else
            self.heCounts_ =  self.heCounts_ + 1
        end
    end
    self._children["lab_long"]:setString(self.longCounts_)
    self._children["lab_he"]:setString(self.heCounts_)
    self._children["lab_feng"]:setString(self.fengCounts_)
end

function BaiJiaLeScene:GameOver(data)
    dump(data, "游戏结算")
    if self.schedulerID ~= nil then
        me.Scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end

    self._children["ImgCurTime"]:loadTexture("bjl_result_time.png", ccui.TextureResType.plistType)

    self.result_data = data
    self:UpdateAreaScore()
    self:UpdateJeton()
    
    --开始发牌
    local function dispatchCard(idx, nFlag)
        -- body
        MEAudioUtils.playSoundEffect("soundbjl/DISPATCH_CARD.mp3")

        local id = helper.getPaiByIndex(data.cbTableCardArray[nFlag][idx])
        print("dispatchCard =====================", idx, nFlag, id)
        local nPos = cc.p(self._children["Image_card_send"]:getPosition())
        local nTargetPos
        if nFlag == 1 then
            nTargetPos = cc.p(self._children["fengCardPanel"]:getPosition())
        else
            nTargetPos = cc.p(self._children["longCardPanel"]:getPosition())
        end

        --背面
        local backCard = DDMaJiang.new(2, id)
        backCard:setPosition(nPos)
        self._children["panel"]:addChild(backCard)
        
        local s = backCard:getContentSize()

        nTargetPos.x = nTargetPos.x + s.width/2 + (idx-1)*70
        nTargetPos.y = nTargetPos.y + s.height/2

        --正面
        local frontCard = DDMaJiang.new(1, id)
        frontCard:setPosition(nTargetPos)
        self._children["panel"]:addChild(frontCard)
        if self.tCardList[nFlag] == nil then
            self.tCardList[nFlag] = {}
        end
        self.tCardList[nFlag][#self.tCardList[nFlag] +1] = frontCard

        --正面z轴起始角度为90度（向左旋转90度），然后向右旋转90度
        local orbitFront = cc.OrbitCamera:create(0.2,1,0,90,-90,0,0)
        --正面z轴起始角度为0度，然后向右旋转90度
        local orbitBack = cc.OrbitCamera:create(0.2,1,0,0,-90,0,0)
        frontCard:setVisible(false)
      
        local action = cc.Sequence:create(
            cc.FadeIn:create(0.1),
            cc.MoveTo:create(0.4, nTargetPos),
            cc.DelayTime:create(0.2),
            cc.Show:create(),
            orbitBack,
            cc.Hide:create(),
            cc.TargetedAction:create(frontCard, cc.Sequence:create( cc.Show:create(), orbitFront ) ),
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function()
                backCard:removeFromParent()
                --显示牌点
                if nFlag == 1 then
                    self._children["fengPoint"]:setVisible(true)
                    print("idx, id, nPoint =", nFlag, id, helper.getIndexByPai(id), cc.MENetUtil:GetCardPip( helper.getIndexByPai(id) ) )
                    self.nFengPoint = self.nFengPoint + cc.MENetUtil:GetCardPip( helper.getIndexByPai(id) )
                    self._children["fengPoint"]:loadTexture("bjl_" .. self.nFengPoint % 10 .. ".png", ccui.TextureResType.plistType)
                elseif nFlag == 2 then
                    self._children["longPoint"]:setVisible(true)
                    print("idx, id, nPoint =", nFlag, id, helper.getIndexByPai(id), cc.MENetUtil:GetCardPip( helper.getIndexByPai(id) ) )
                    self.nLongPoint = self.nLongPoint + cc.MENetUtil:GetCardPip( helper.getIndexByPai(id) )
                    self._children["longPoint"]:loadTexture("bjl_" .. self.nLongPoint % 10 .. ".png", ccui.TextureResType.plistType)
                end

                idx = idx + 1
                if idx <= data.cbCardCount[nFlag] then
                    dispatchCard(idx, nFlag)
                else
                    print("dispatchCard finish ..........................", idx, nFlag)
                    EventDispatcher:dispatchEvent(EventMsgDefine.DispatchCardFinish)
                end
            end)
        )
        backCard:runAction(action)
    end

    --凤
    Helper:scheduleOnce(0.1, function()
        dispatchCard(1, 1)
    end)

    --龙
    Helper:scheduleOnce(0.8, function()
        dispatchCard(1, 2)
    end)
end

function BaiJiaLeScene:showGameOver(data)
    dump(data, "游戏结算")

    self._children["ImgCurTime"]:loadTexture("bjl_result_time.png", ccui.TextureResType.plistType)

    self.result_data = data
    self:UpdateAreaScore()
    self:UpdateJeton()
    
    --开始发牌
    local function dispatchCard(idx, nFlag)
        -- body
        local id = helper.getPaiByIndex(data.cbTableCardArray[nFlag][idx])
        print("dispatchCard =====================", idx, nFlag, id)
        local nTargetPos
        if nFlag == 1 then
            nTargetPos = cc.p(self._children["fengCardPanel"]:getPosition())
        else
            nTargetPos = cc.p(self._children["longCardPanel"]:getPosition())
        end

        --正面
        local frontCard = DDMaJiang.new(1, id)
        local s = frontCard:getContentSize()
        nTargetPos.x = nTargetPos.x + s.width/2 + (idx-1)*70
        nTargetPos.y = nTargetPos.y + s.height/2
        frontCard:setPosition(nTargetPos)
        self._children["panel"]:addChild(frontCard)

        if self.tCardList[nFlag] == nil then
            self.tCardList[nFlag] = {}
        end
        self.tCardList[nFlag][#self.tCardList[nFlag] +1] = frontCard
    end

    --凤
    for i=1, data.cbCardCount[1] do
        dispatchCard(i, 1)
    end

    --龙
    for i=1, data.cbCardCount[2]  do
        dispatchCard(i, 2)
    end
    self:showWinArea()
end

function BaiJiaLeScene:DispatchCardFinish()
    -- body
    self.dispatchCardFinishCount = self.dispatchCardFinishCount + 1
    if self.dispatchCardFinishCount == 2 then
        self.dispatchCardFinishCount = 0
        self:showWinArea()
        if self.isBet or self.result_data.nResult == 1 or self.result_data.nResult == 2 then
            self.isBet = false
            if self.result_data.nResult == 1 then
                MEAudioUtils.playSoundEffect("soundbjl/END_WIN.mp3")
            elseif self.result_data.nResult == 2 then
                MEAudioUtils.playSoundEffect("soundbjl/END_LOST.mp3")
            else
                MEAudioUtils.playSoundEffect("soundbjl/END_DRAW.mp3")
            end
            Helper:scheduleOnce(2, function()
                app:openDialog("BaiJiaLeResultLayer", self.result_data)
            end)   
        else
            MEAudioUtils.playSoundEffect("soundbjl/END_DRAW.mp3")
        end
    end
end

function BaiJiaLeScene:showWinArea()
    -- body
    self.nFengPoint = 0
    self.nLongPoint = 0
    self._children["fengPoint"]:loadTexture("bjl_" .. self.result_data.cbPlayerCount .. ".png", ccui.TextureResType.plistType)
    self._children["longPoint"]:loadTexture("bjl_" .. self.result_data.cbBankerCount .. ".png", ccui.TextureResType.plistType)

    self._children["lab_ZhuangScore"]:setString(self.result_data.lBankerWinScore)
    self._children["lab_ZhuangCounts"]:setString(self.result_data.wBankerTime)
    
    if self.result_data.wBankerUser ~= nil then
        self.tCurBanker["isBankerUser"] = true
        self.tCurBanker["nGold"] = self.result_data.nGold
        self.tCurBanker["nChairID"] = self.result_data.wBankerUser
        self.tCurBanker["nickname"] = self.result_data.szName
        self:UpdateBankerListView()
    end
    
    local tData = {}
    tData["bBankerTwoPair"] = self.result_data.bBankerTwoPair
    tData["bPlayerTwoPair"] = self.result_data.bPlayerTwoPair
    tData["cbBankerCount"]  = self.result_data.cbBankerCount
    tData["cbKingWinner"]   = self.result_data.cbKingWinner
    tData["cbPlayerCount"]  = self.result_data.cbPlayerCount
    self.recordlist[#self.recordlist + 1] = tData
    
    local imgWin
    if self.result_data.cbWinner == 0 then
        imgWin = self._children["fengWin"]
    elseif self.result_data.cbWinner == 1 then
        imgWin = self._children["heWin"]
    elseif self.result_data.cbWinner == 2 then
        imgWin = self._children["longWin"]
    end
    if imgWin ~= nil then
        imgWin:setVisible(true)
        local action = cc.Sequence:create(
            cc.ScaleTo:create(0.05,0),
            cc.ScaleTo:create(0.6,1.5),
            cc.ScaleTo:create(0.4,1)
        )
        imgWin:runAction(action)
    end

    if self.result_data.cbPlayerCount > self.result_data.cbBankerCount then
        self.fengCounts_ = self.fengCounts_ + 1
    elseif self.result_data.cbPlayerCount < self.result_data.cbBankerCount then
        self.longCounts_ = self.longCounts_ + 1
    else
        self.heCounts_ =  self.heCounts_ + 1
    end
    self._children["lab_long"]:setString(self.longCounts_)
    self._children["lab_he"]:setString(self.heCounts_)
    self._children["lab_feng"]:setString(self.fengCounts_)

    for i=1,5 do
        local nArea = helper.getAreaByClientIndex(i)
        local bWin = self.result_data.cbWinArea[nArea+1]
        if bWin then
            local rpt = cc.RepeatForever:create( cc.Blink:create(1, 1) ) 
            self._children["Img_touch_" .. i]:runAction(rpt)
        end
    end
end

return BaiJiaLeScene