
local MaJiangScene = class("MaJiangScene", cc.load("mvc").SceneBase)
local DDMaJiang = require("app.views.erhzb.DDMaJiang")
local MaJiangController = require("app.views.erhzb.MaJiangController")
MaJiangScene.RESOURCE_FILENAME = "game_erhzb/majiang_scene.csb"

local helper                = import(".helper")

function MaJiangScene:onCreate(params)
    print("MaJiangScene:onCreate(params) .............................", params)
    self:initData()
    --处理逻辑
    MaJiangController:init(self, params)

    self:addEventListener(EventMsgDefine.APP_ENTERBACKGROUND,self.GameEnterBackground,self)
    self:addEventListener(EventMsgDefine.APP_ENTERFOREGROUND,self.GameEnterForeground,self)

    self.isFirstShowTips = true
    self.selfCardPosList = {}
    self.targetCardPosList = {}
    self.score = 1
    self.remainJuShuCount = 0
    self.maxJuShuCount = 0
    self.curJuShuCount = 0
    self.isStart = false
    self.selfSex = cc.MENetUtil:getSex()
    self.targetSex = 0
    self.nVoiceTick = 0
    self.nVoiceTextTick = 0
    self:initUI()
    self:initListener()
    self:initTouchListener()
    self:initVoiceTouchListener()
    self:setRoomModel()
    self:addEventListener(EventMsgDefine.ShowNoticeMsg,self.ShowNoticeMsg,self)
    self:addEventListener(EventMsgDefine.PlayVoiceText,self.GameVoiceStartPlay,self)
end

function MaJiangScene:initData()
    -- body
    self.nChuPaiTimeOutCnts = 0
    self.nStateSelfDist = 0
    self.nStateTargetDist = 0
    self.aleart_pai = false
    self.curMaJiang = nil
    self.curPaiId = -1
    self.actionCard = -1
    self.lastPaiId = -1
    self.isMoPai = true
    self.paiList = {}
    self.paiList_self = {}
    self.mingPaiList = {}
    self.isPong = false
    self.pongList = {}
    self.pongList_ds = {}
    self.isPongIng = false
    self.curPaiCount = 53
    self.ds_state_pai_count = 0
    self.chuSpeed = 1.0
    self.cur_trustee_state = 0 -- 0无托管 1用户托管 2系统托管
    self.isInitPaiFinish = false
    self.isFlowGame = false
    self.isReady = false
    self.isDoing = false
    self.isCheat = false
    self.selfOutCardList = {}
    self.targetOutCardList = {}
   
    self._children["timePanel"]:setVisible(false)
    self._children["btn_ready"]:setVisible(false)
    self._children["imgSelfReady"]:setVisible(false)
    self._children["imgTargetReady"]:setVisible(false)
    self._children["lab_time_self"]:setString("")
    self._children["imgSelfZhuang"]:setVisible(false)
    self._children["imgTargetZhuang"]:setVisible(false)
end

function MaJiangScene:initUI()
    self._children["ImgNoticeBg"]:setVisible(false)
    self._children["ImgPlayVoice1"]:setVisible(false)
    self._children["lab_RoomID"]:setString("")
    self._children["lab_ds_chat"]:setString("")
    self._children["lab_chat"]:setString("")
    self.ly_self = self._children["ly_self"]
    self.ly_self_out = self._children["ly_self_out"]
    self.ly_self_state = self._children["ly_self_state"]
    self.ly_duishou = self._children["ly_duishou"]
    self.ly_duushou_out = self._children["ly_duushou_out"]
    self.ly_duishou_state = self._children["ly_duishou_state"]
    self.ly_self_out = self._children["ly_self_out"]
    self.ly_add_state = self._children["ly_add_state"]
    self.ly_add_state:setVisible(false)
    self._children["lab_target_state"]:setVisible(false)
    self.lab_self_info_name = self._children["lab_self_info_name"]
    self.lab_self_info_name:setString(cc.MENetUtil:getNickName() )
    self.lab_self_gold = self._children["lab_self_gold"]
    if not cc.MENetUtil:isCustomServer() then 
        self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    else
        self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    end

    local url = cc.MENetUtil:getUserIconUrl()
    if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
        local faceId = cc.MENetUtil:getFaceID()%20 + 1
        self._children["headkuangSelf"]:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
    else
        --下载头像
        print("url = ", url)
        local customid = Helper:md5sum(url)
        local filename = Helper:getFileNameByUrl(url, customid)
        print(filename)
        self._children["headkuangSelf"]:loadTexture(filename)
    end

    self.lab_ds_name = self._children["lab_ds_name"]
    self.lab_ds_gold = self._children["lab_ds_gold"]
    self._children["ImgTargetInfo"]:setVisible(false)
    self.lab_ds_name:setString("")
    self.lab_ds_gold:setString("")
    self._children["targetIconPanel"]:setVisible(false)

    self._children["imgSelfZhuang"]:setVisible(false)
    self._children["imgTargetZhuang"]:setVisible(false)
    self._children["btn_dizhu_setting"]:setVisible(false)
    self._children["ly_tipsMsg"]:setVisible(false)
    self._children["lab_doubleNum"]:setString("")
    self._children["lab_pai_count"]:setString("")

    for i=1,14 do
        local midX = 0
        if i == 14 then
            midX = 15
        end
        local x = me.winSize.width/2 + (i - 7)*116* 0.9 + midX
        table.insert(self.selfCardPosList, 1, x)
    end
    dump(self.selfCardPosList, "己方牌位置")

    for i=14, 1, -1 do
        local midX = 0
        if i == 1 then
            midX = -10
        end
        local x = me.winSize.width/2 + (i - 7)*120* 0.7 + midX
        table.insert(self.targetCardPosList, 1, x)
    end
    dump(self.targetCardPosList, "对方牌位置")

end

function MaJiangScene:onEnterTransitionFinish()
    print("MaJiangScene:onEnterTransitionFinish() ...................................")
    audio.playMusic("music/Audio_Game_Back.mp3",true) 
    self:registerDialogMessageListener()
    MaJiangController:initEvent()
    cc.MENetUtil:enterGame()
end

function MaJiangScene:onEnter()
    print("MaJiangScene:onEnter() ..........................................")
end

function MaJiangScene:GameEnterBackground()
    -- body
    cc.MENetUtil:setGameEnterBackground(true)
end

function MaJiangScene:GameEnterForeground()
    -- body
    cc.MENetUtil:setGameEnterBackground(false)
end

function MaJiangScene:clear()
    -- body
    self:clearDsSmale()
    --释放临时资源
    ResLoadControl:instance():ClearTempLoadRes()
end

function MaJiangScene:ShowNoticeMsg( msg )
    -- body
    print("MaJiangScene:ShowNoticeMsg( msg )", msg)
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

function MaJiangScene:resetMJState(bReset)       
    print("重新排序了.........................................", bReset)
    if self.curMaJiang then
        local s = self.curMaJiang:getContentSize() 
        if bReset ~= nil and bReset then  
            self.curMaJiang:setPosition(cc.p(self.selfCardPosList[self.curMaJiang:getIndex()], s.height / 2* self.curMaJiang:getScale() ))
        else
            self.curMaJiang:setPositionY(s.height / 2* self.curMaJiang:getScale())
        end
        self.curMaJiang:setIsMove(false)
        self.curMaJiang:setLocalZOrder(self.curMaJiang:getIndex())
        self:clearOutSameCard()
        self.curMaJiang = nil
    end
end

function MaJiangScene:initTouchListener()
    local function check(pos, obj)
        local p_pos = cc.p(obj:getPosition())
        if (pos.x < p_pos.x + obj:getContentSize().width/2 and 
            pos.x > p_pos.x - obj:getContentSize().width/2 and 
            pos.y < p_pos.y + obj:getContentSize().height/2 and 
            pos.y > p_pos.y - obj:getContentSize().height/2)
        then
            return true
        end
        return false
    end

    local function isSelect(pos)
        -- body
        for k,v in pairs(self.ly_self:getChildren()) do
            if check(pos, v) then
                return true
            end
        end
        return false
    end

    local function onTouchBegan(touch, event)
        if self.cur_trustee_state > 0 then
            print("当前处于托管模式，不能操作！")
            return false
        end
        local target = event:getCurrentTarget()
        local pos = target:convertToNodeSpace(touch:getLocation())
        print("onTouchBegan==================", pos)
        if isSelect(pos) then
            self.touchBegin = pos
            if self.curMaJiang then
                if check(pos, self.curMaJiang) then
                    print("可以出牌了44444444444444444444444")
                    local ret = self:chuPai(false, true)
                    if not ret then
                        self:resetMJState()
                    end
                    return false
                end
                -- 重新设置麻将位置
                self:resetMJState()
            else
                for k,v in pairs(self.ly_self:getChildren()) do
                    if check(pos, v) then
                        print("当前点击的索引 ===============",v:getTag())
                        v:setPositionY(v:getContentSize().height* v:getScale() * 0.9)
                        self.curMaJiang = v
                        self.curMaJiang:setLocalZOrder(100)
                        self:checkOutSameCard( v:getTag() )
                        break
                    end
                end
            end
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local pos_move = target:convertToNodeSpace(touch:getLocation())
        print("onTouchMoved==================", pos_move)
        if self.aleart_pai and self.curMaJiang then
            if self.curMaJiang:getTag() == 20 then
                return
            end
            local s = self.curMaJiang:getContentSize()
            local deltPos = cc.pSub(pos_move, self.touchBegin) 
            if math.abs(deltPos.x) > 10 or math.abs(deltPos.y) > 10 then
                self.curMaJiang:setPosition(pos_move)
                self.curMaJiang:setIsMove(true)
            end
            local scale = self.curMaJiang:getScale()
            local nY = self.ly_self:getPositionY() + self.ly_self:getContentSize().height
            if pos_move.x <= 0 + s.width/2*scale or 
                pos_move.x >= me.winSize.width - s.width/2*scale or 
                pos_move.y >= nY - s.height/2*scale then
                print("可以出牌了6666666666666666666666666666")
                local ret = self:chuPai(false, true)
                if not ret then
                    self:resetMJState(true)
                end
                return
            end

            local y = self._children["ly_battle"]:getPositionY()
            if pos_move.y <= y then
                self.curMaJiang:setPosition(cc.p(self.selfCardPosList[self.curMaJiang:getIndex()], y))
            end 
            if pos_move.y > y + self._children["ly_self_state"]:getContentSize().height then
                self.isReset = true
            elseif self.isReset and (pos_move.y <= y + self._children["ly_self_state"]:getContentSize().height) then
                --重新设置麻将位置
                self.isReset = false
                self:resetMJState(true)
            end
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local pos_end = target:convertToNodeSpace(touch:getLocation())
        print("onTouchEnded==================", pos_end)
        self.isReset = false
        MEAudioUtils.playSoundEffect("sound/audio_card_click.mp3")
        local deltPos = cc.pSub(pos_end, self.touchBegin) 
        if self.aleart_pai and self.curMaJiang and (math.abs(deltPos.x) > 10 or math.abs(deltPos.y) > 10) then
            print("可以出牌了5555555555555555555555555")
            local ret = self:chuPai(false, true)
            if not ret then
                self:resetMJState(true)
            end
        elseif(self.curMaJiang and self.curMaJiang:getIsMove()) then
            self:resetMJState(true)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_CANCELLED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    self.touchlistener_ = listener
    local eventDispatcher = self.ly_self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.ly_self)
end

function MaJiangScene:initVoiceTouchListener()
    self.imgVoice = self._children["ImgVoice"]
    self.voicePanel = self._children["voicePanel"]
    local function check(pos)
        local p_pos = cc.p(self.voicePanel:getPosition())
        if (pos.x < p_pos.x + self.voicePanel:getContentSize().width and 
            pos.x > p_pos.x and 
            pos.y < p_pos.y + self.voicePanel:getContentSize().height and 
            pos.y > p_pos.y)
        then
            return true
        end

        local p_pos = cc.p(self.imgVoice:getPosition())
        if (pos.x < p_pos.x + self.imgVoice:getContentSize().width/2 and 
            pos.x > p_pos.x - self.imgVoice:getContentSize().width/2 and 
            pos.y < p_pos.y + self.imgVoice:getContentSize().height/2 and 
            pos.y > p_pos.y - self.imgVoice:getContentSize().height/2)
        then
            return true
        end
        return false
    end

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local pos = target:convertToNodeSpace(touch:getLocation())
        if check(pos) then
            local nClock = cc.METimeUtils:clock() - self.nVoiceTick
            if nClock >= 5 then
                print("onTouchBegan Voice ==================", pos)
                self.isCancelSendVoice = false
                self.touchVoiceBegin = pos
                self:showVoiceEffect(true)
                cc.MENetUtil:startTalk()
                return true
            else
                self:GameInfoTips("发送语音太过频繁了，请稍后再试!")
            end
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local pos = target:convertToNodeSpace(touch:getLocation())
        print("onTouchMoved Voice ==================", pos)
        local deltPos = cc.pSub(pos, self.touchVoiceBegin)
        if deltPos.y >= 50 or deltPos.y <= -50 or deltPos.x >= 50 or deltPos.x <= -50 then
            print("cancel send ............................")
            self.isCancelSendVoice = true
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local pos = target:convertToNodeSpace(touch:getLocation())
        print("onTouchEnded Voice ==================", pos)
        self:showVoiceEffect(false)
        if not self.isCancelSendVoice then
            self.isCancelSendVoice = false
            cc.MENetUtil:endTalk(true)
        else
            cc.MENetUtil:endTalk(false)
        end
        self.nVoiceTick = cc.METimeUtils:clock()
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_CANCELLED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    self.touchVoicelistener_ = listener
    local eventDispatcher = self.voicePanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.voicePanel)
end

function MaJiangScene:showVoiceEffect( isShow )
    -- body
    print("MaJiangScene:showVoiceEffect() ...............", isShow)
    if isShow then
        local imgBg = self._children["panel"]:getChildByName("spriteVoice")
        if imgBg ~= nil then
            imgBg:removeFromParent()
            imgBg = nil
        end

        local s = self._children["panel"]:getContentSize()
        imgBg = display.newSprite("#yuyin.png")
        self._children["panel"]:addChild(imgBg, 1024)
        imgBg:setName("spriteVoice")
        imgBg:setPosition(cc.p(s.width/2, s.height/2 - 30) )

        local armature = ccs.Armature:create("MJVoice")
        if armature ~= nil then
            local s = imgBg:getContentSize()
            armature:getAnimation():playWithIndex(0)
            armature:setPosition(cc.p(s.width/2 + 70, s.height/2))
            armature:getAnimation():setSpeedScale(0.5)
            imgBg:addChild(armature)
        end
    else
        local imgBg = self._children["panel"]:getChildByName("spriteVoice")
        if imgBg ~= nil then
            imgBg:removeFromParent()
            imgBg = nil
        end
    end
end

function MaJiangScene:GameVoiceStartPlay(data)
    dump(data, "语音消息")
    if data.cbChatType == 2 then
        self._children["ImgPlayVoice1"]:setVisible(true)

        local seq  = cc.Sequence:create(cc.Blink:create(1, 2) )
        local rep = cc.RepeatForever:create(seq)
        self._children["ImgPlayEffect"]:runAction(rep)

        self.nCurVoiceChair = data.dwSendChairID
        cc.MENetUtil:playTalk(data.dwSendChairID, data.url)
    elseif data.cbChatType == 1 then
        local labChat
        if data.dwSendChairID == cc.MENetUtil:getChairID() then
            labChat = self._children["lab_chat"]
            self.nVoiceTextTick = cc.METimeUtils:clock()
        else
            labChat = self._children["lab_ds_chat"]
        end
        local path
        if data.sex == 1 then
            path = "sound/chat/man/fix_msg_"
        else
            path = "sound/chat/woman/fix_msg_"
        end
        MEAudioUtils.playSoundEffect(path .. data.idx ..".mp3")
        labChat:setString(GameChatConfig[data.idx])
        local seq = cc.Sequence:create(
            cc.FadeIn:create(0.5),
            cc.DelayTime:create(2),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                labChat:setString("")
                MaJiangController:GameVoiceFinish()
            end)
        )
        labChat:runAction(seq) 
    end
end

function MaJiangScene:GameVoicePlayFinish()
    self._children["ImgPlayVoice1"]:setVisible(false)
    self._children["ImgPlayEffect"]:stopAllActions()

    MaJiangController:GameVoiceFinish()  
end

function MaJiangScene:initListener()

    self._children["btn_state_guo"]:addClickEventListener(function() 
        if not self.aleart_pai then
            cc.MENetUtil:operatePai(0, 0)
            self:moPai() 
        end
        self.ly_add_state:setVisible(false)
    end)

    self._children["btn_state_pong"]:addClickEventListener(function() 
        self:pong() 
    end)

    self._children["btn_state_pang"]:addClickEventListener(function() 
        self:gang() 
    end)
    self._children["btn_state_hu"]:addClickEventListener(function() 
        self:zimo() 
    end)
    
    local function setReady()
        self:ready()
    end
    self._children["btn_ready"]:addClickEventListener(setReady)

    local function setBack()
        local function doOk()
            self:GameRoomOut()
        end
        local function doCancel()

        end

        if cc.MENetUtil:isCustomServer() then
            if not self.isDoing then
                if self.customCreateUser == cc.MENetUtil:getUserID() then
                    MaJiangController:backGame(true)
                else
                    doOk()
                end
            end
        else
            if self.isDoing then
                self:showTips("是否真的强制退出？", doOk, doCancel)
            else
                doOk()
            end
        end
    end
    self._children["btn_back"]:addClickEventListener(setBack)

    self:registerKeyboardListener(function ( ... )
        -- body
        setBack()
    end)

    self._children["btn_dizhu_setting"]:addClickEventListener(function ( ... )
        -- body
        app:openDialog("MaJiangSetDiZhu")
    end)

    local function auto_send_pai(pSender)
        --if not cc.MENetUtil:isCustomServer() then
            local tag = pSender:getTag()
            if tag == 1 then
                --托管
                cc.MENetUtil:setTrustee(true)
            else
                cc.MENetUtil:setTrustee(false)
            end
        --end
    end
    self._children["btn_auto_send"]:setTag(1)
    self._children["btn_auto_send"]:addClickEventListener(auto_send_pai)
    

    self._children["btn_setting"]:addClickEventListener(function ( ... )
        -- body
        local bShow = false
        if cc.MENetUtil:isCustomServer() then
            bShow = true
        end 
        app:openDialog("SettingSoundLayer", bShow)
    end)

    self._children["btn_renshu"]:addClickEventListener(function ( ... )
        -- body
        if cc.MENetUtil:getUserGold() < self.score*GameDataConfig.RENSHUBASE then
            self:showTips("您的金币低于底注X10万，不允许认输")
            return
        end
        local function doOk()
            cc.MENetUtil:admitDefeat()
        end
        local function doCancel()
            
        end
        self:showTips("认输会扣除底注10万倍金币，是否认输？", doOk, doCancel)
    end)

    local function room_jiesan(pSender)
        self:GameJieSuan()
    end
    self._children["btn_room_jiesan"]:addClickEventListener(room_jiesan)

    local function weixin_yaoqing(pSender)
        local strDesc = "两人红中宝|房间号:" .. Helper:stringFormatRoomID(cc.MENetUtil:getCustomRoomID())
        GameLogicManager:WeiXinShareUrl("弈博棋牌",  strDesc, 0)
    end
    self._children["btn_weixin_yaoqing"]:addClickEventListener(weixin_yaoqing)

    self._children["btn_yuyin"]:addClickEventListener(function ( ... )
        -- body
        local nClock = cc.METimeUtils:clock() - self.nVoiceTextTick
        if nClock >= 5 then
            app:openDialog("VoiceChatLayer")
        else
            self:GameInfoTips("说话太过频繁了，请稍后再试!")
        end
    end)
    self._children["btn_rule"]:addClickEventListener(function ( ... )
        -- body
        app:openDialog("HZBGameRuleLayer")
    end)
    local function OnRank(pSender)
        app:openDialog("MajiangGameRankLayer", 351)
    end
    self._children["btn_rank"]:addClickEventListener(OnRank)
end

function MaJiangScene:GameJieSuan()
    -- body
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_room_jiesan"]:setVisible(false)
        if not self.isStart then
            if self.customCreateUser == cc.MENetUtil:getUserID() then 
                MaJiangController:dismisCustomServer(true)
            else
                MaJiangController:dismisCustomServer(false)
                MaJiangController:backGame()
            end
        else
            local params = {}
            params["nType"] = 1
            local nTargetChair = 0
            if cc.MENetUtil:getChairID() == 0 then
                nTargetChair = 1
            end
            params["dwRequesterID"] = cc.MENetUtil:getChairID()
            params["nChairID"] = nTargetChair
            params["nickName"] = self.lab_ds_name:getString()
            params["cbStatus"] = 0
            app:openDialog("MaJiangJieSanLayer", params)
            local seq = cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function()
                    cc.MENetUtil:dismisCustomServerStartVote()
                end)
            )
            self._children["panel"]:runAction(seq) 
        end
    end
end

function MaJiangScene:checkOutSameCard( cardid)
    -- body
    self:clearOutSameCard()
    if self.curMaJiang ~= nil then
        self.curMaJiang:setSameOutFlag(true)
    end

    for _,d in pairs(self.ly_self_out:getChildren()) do
        if cardid == d:getTag() then
            d:setSameOutFlag(false)
        end
    end
    for _,d in pairs(self.ly_duushou_out:getChildren()) do
        if cardid == d:getTag() then
            d:setSameOutFlag(false)
        end
    end
end

function MaJiangScene:clearOutSameCard()
    -- body
    for _,d in pairs(self.ly_self:getChildren()) do
        d:clearSameOutFlag()
    end

    for _,d in pairs(self.ly_self_out:getChildren()) do
        d:clearSameOutFlag()
    end

    for _,d in pairs(self.ly_duushou_out:getChildren()) do
        d:clearSameOutFlag()
    end
end

function MaJiangScene:hideBackBtn()
    -- body
    if self.isDoing and cc.MENetUtil:isCustomServer() then
        self._children["btn_back"]:setVisible(false)
        self:removeKeyboardListener()
    end
end

function MaJiangScene:setRoomModel()
    -- body
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_room_jiesan"]:setVisible(true) 
        self._children["btn_weixin_yaoqing"]:setVisible(true)
        self._children["btn_auto_send"]:setVisible(false)
        self._children["btn_renshu"]:setVisible(false)
        self._children["btn_dizhu_setting"]:setVisible(false)
        self._children["ImgRoomBg"]:setVisible(true)
        print("room id =", Helper:stringFormatRoomID(cc.MENetUtil:getCustomRoomID()) )
        self._children["lab_RoomID"]:setString("房间号:" .. Helper:stringFormatRoomID(cc.MENetUtil:getCustomRoomID()))
    else
        self._children["ImgRoomBg"]:setVisible(false)
        self._children["btn_room_jiesan"]:setVisible(false)
        self._children["btn_auto_send"]:setVisible(true)
        self._children["btn_weixin_yaoqing"]:setVisible(false)
    end
end

function MaJiangScene:setGameTrustee(data)
    -- body
    print("MaJiangScene:setGameTrustee(data)", data)
    if data.isSelf then
        if data.bTrustee then
            --托管
            if data.bSystemSet then
                self.cur_trustee_state = 2
            else
                self.cur_trustee_state = 1
                if not self.isReady then
                    self:ready()
                end
                --检测是否用户托管出牌
                self:userAutoChuPai()
            end
            self._children["btn_auto_send"]:loadTextures("canceltuoguan1.png","canceltuoguan2.png","", ccui.TextureResType.plistType)
            self._children["btn_auto_send"]:setTag(2)
            self.chuSpeed = 0.4
        else
            self._children["btn_auto_send"]:loadTextures("tuoguan1.png","tuoguan2.png","", ccui.TextureResType.plistType)
            self._children["btn_auto_send"]:setTag(1)
            self.chuSpeed = 1.0
            self.cur_trustee_state = 0
        end
    end
end

function MaJiangScene:setTargetPlayerInfo(data)
    dump(data, "玩家信息")
    if data.chair == cc.MENetUtil:getChairID() then
        return
    end    
    if data.isEnter then
        self.lab_ds_name:setString(data.nickName)
        if not cc.MENetUtil:isCustomServer() then 
            self.lab_ds_gold:setString(data.gold)
        else
            self.lab_ds_gold:setString(data.gold)
        end
        self._children["ImgTargetInfo"]:setVisible(true)
        if data.sex == 0 or data.sex == 2 then
            --todo
            self.targetSex = 0
        else
            self.targetSex = 1
        end
        if data.status == 3 or data.status == 5 then
            self._children["imgTargetReady"]:setVisible(true)
        end
        self._children["lab_target_state"]:setVisible(false)
        if data.status == 6 then
            self._children["lab_target_state"]:setVisible(true)
        end
        self._children["targetIconPanel"]:setVisible(true)
        local s = self._children["targetIconPanel"]:getContentSize()
        local sp = cc.Sprite:create("res/game_erhzb/target_icon_" .. self.targetSex .. ".png")
        sp:setPosition(s.width/2, s.height/2)
        self._children["targetIconPanel"]:addChild(sp, 1)
    else
        self.lab_ds_name:setString("")
        self.lab_ds_gold:setString("")
        self._children["ImgTargetInfo"]:setVisible(false)
        self._children["targetIconPanel"]:setVisible(false)
        self._children["targetIconPanel"]:removeAllChildren()
        self._children["imgTargetReady"]:setVisible(false)
    end
end

function MaJiangScene:setTargetPlayerScore(data)
    dump(data, "房间游戏用户分数")
    if data.chair == cc.MENetUtil:getChairID() then
        return
    end  
    
    if not cc.MENetUtil:isCustomServer() then 
        self.lab_ds_gold:setString(data.gold)
    else
        self.lab_ds_gold:setString(data.gold)       -- 其实在用户模式下，不用显示用户的分数了，而是显示钻石的数量。。。需要做修改。
    end
end

function MaJiangScene:setTargetPlayerStatus(data)
    dump(data, "房间游戏用户状态")
    if data.chair == cc.MENetUtil:getChairID() then
        return
    end  
    
    self._children["imgTargetReady"]:setVisible(false)
    if data.status == 3 then
        self._children["imgTargetReady"]:setVisible(true)
    end
    self._children["lab_target_state"]:setVisible(false)
    if data.status == 6 then
        self._children["lab_target_state"]:setVisible(true)
    end
end

function MaJiangScene:setDsSmale()
    self:clearDsSmale()

    self.nTick = 0
    self.nLastTick = math.random(3, 8)
    local function tick()
        self.nTick = self.nTick + 1
        if self.nTick == self.nLastTick then
            self.nTick = 0
            self.nLastTick = math.random(3, 8)
            self:playTargetEffect("idle")
        end 
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)
end

function MaJiangScene:clearDsSmale()
    -- body
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
end

function MaJiangScene:playTargetEffect(armatureName)
    local node = self._children["targetIconPanel"]:getChildByName("targetEffect")
    if node ~= nil then
        node:removeFromParent()
    end

    local name
    if self.targetSex == 1 then
        name = "MJMan"
    else
        name = "MJWoman"
    end
    local armature = ccs.Armature:create(name)
    if armature ~= nil then
        local s = self._children["targetIconPanel"]:getContentSize()
        armature:getAnimation():play(armatureName)
        armature:setPosition(cc.p(s.width/2, s.height/2))
        armature:getAnimation():setSpeedScale(0.5)
        armature:setName("targetEffect")
        self._children["targetIconPanel"]:addChild(armature, 10)

        --注册事件回调
        local function animationEvent(armatureBack,movementType,movementID)
            local id = movementID
            if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then    
                armatureBack:removeFromParent(true)
            end
            armature:getAnimation():setMovementEventCallFunc(animationEvent)
        end
    end
end

function MaJiangScene:ResetGame()
    -- body
    self:initData()
    self._children["btn_ready"]:setVisible(true)
    self._children["timePanel"]:setVisible(false)
    self._children["imgSelfReady"]:setVisible(false)
    self.ly_self:removeAllChildren()
    self.ly_self_out:removeAllChildren()
    self.ly_self_state:removeAllChildren()
    self.ly_duishou:removeAllChildren()
    self.ly_duushou_out:removeAllChildren()
    self.ly_duishou_state:removeAllChildren()
    self.ly_add_state:setVisible(false)
    self._children["lab_target_state"]:setVisible(false)
end

function MaJiangScene:ready()
    -- body
    self._children["btn_ready"]:setVisible(false)
    self._children["timePanel"]:setVisible(false)
    self._children["imgSelfReady"]:setVisible(true)
    cc.MENetUtil:ready()
    self.isReady = true
end

function MaJiangScene:continueGame(data)
    dump(data)
    self:enterGame(data)
    print("我的椅子 =======================================", cc.MENetUtil:getChairID())
    --添加己方出牌
    local data_chu_self = {}
    local data_chu_ds = {}
    local data_state_self = {}
    local data_state_ds = {}
    local tTrustee = {}
    tTrustee["bSystemSet"] = true
    tTrustee["isSelf"] = true
    local self_state_count = 0
    local target_state_count = 0
    if cc.MENetUtil:getChairID() == 0 then
        tTrustee["bTrustee"] = data.bTrustee[1]
        data_chu_self = data.cbDiscardCard[1]
        data_state_self = data.WeaveItemArray[1]
        data_chu_ds = data.cbDiscardCard[2]
        data_state_ds = data.WeaveItemArray[2]
        self_state_count = data.cbWeaveCount[1]
        target_state_count = data.cbWeaveCount[2]
    else
        tTrustee["bTrustee"] = data.bTrustee[2]
        data_chu_self = data.cbDiscardCard[2]
        data_state_self = data.WeaveItemArray[2]
        data_chu_ds = data.cbDiscardCard[1]
        data_state_ds = data.WeaveItemArray[1]
        self_state_count = data.cbWeaveCount[2]
        target_state_count = data.cbWeaveCount[1]
    end

    --处理特殊情况，服务器先恢复现场数据，然后出牌和发牌不在现场数据中
    if data.wOutCardUser == cc.MENetUtil:getChairID() then
        if data.cbOutCardData > 0 then
            data_chu_self[#data_chu_self + 1] = data.cbOutCardData
        end
    else
        if data.cbOutCardData > 0 then
            data_chu_ds[#data_chu_ds + 1] = data.cbOutCardData
        end
    end
    local tPai = {}
    for k,v in pairs(data.cbCardData) do
        if v > 0 then
            self.curPaiId = helper.getPaiByIndex(v)
            table.insert(tPai, self.curPaiId)
        end
    end
    if data.wCurrentUser == cc.MENetUtil:getChairID() and data.cbSendCardData > 0 and data.cbSendCardData ~= 255 then
        local count = #tPai + self_state_count*3
        print("插入牌之前count=============================", count)
        if count < 14 then
            self.curPaiId = helper.getPaiByIndex(data.cbSendCardData)
            table.insert(tPai, self.curPaiId)
        end
    end

    local targetPaiCount = 13
    if data.wCurrentUser == cc.MENetUtil:getChairID() then
        targetPaiCount = 14
    end
    print("data_chu_self = ", data_chu_self)
    print("data_chu_ds = ", data_chu_ds)
    print("data_state_self = ", data_state_self)
    print("data_state_ds = ", data_state_ds)
    print("tPai =", tPai)
    print("targetPaiCount, self_state_count, target_state_count = ", targetPaiCount, self_state_count, target_state_count )

    --添加己方的出牌
    for i,v in ipairs(data_chu_self) do
        if v > 0 then
            local count = self.ly_self_out:getChildrenCount()
            local mj_chu = DDMaJiang.new(true, 3, helper.getPaiByIndex(v))
            local s = mj_chu:getContentSize()
            local midY = 0
            local midX = self.ly_self_out:getPositionX()
            if (count >= 17) then
                midY = midY + s.height
            end
            mj_chu:setPosition(midX + (count%17)*(s.width - 11), midY )
            mj_chu:setLocalZOrder(count)
            self.ly_self_out:addChild(mj_chu)
            self.selfOutCardList[#self.selfOutCardList + 1] = mj_chu
        end
    end

    --添加对方的出牌
    local size = self.ly_duushou_out:getContentSize()
    for i,v in ipairs(data_chu_ds) do
        if v > 0 then
            local count =  self.ly_duushou_out:getChildrenCount()
            local mj_chu = DDMaJiang.new(false, 3, helper.getPaiByIndex(v))
            local s = mj_chu:getContentSize()
            local midY = self.ly_duushou_out:getContentSize().height - s.height
            local midX = self.ly_duushou_out:getPositionX()
            if count >= 17 then
                midY = midY - s.height 
            end
            mj_chu:setPosition(midX - (count%17)*(s.width - 11), midY )
            mj_chu:setLocalZOrder(count)
            self.ly_duushou_out:addChild(mj_chu)
            self.targetOutCardList[#self.targetOutCardList + 1] = mj_chu
        end
    end

    --添加己方状态牌
    for i,v in ipairs(data_state_self) do
         print("添加己方状态牌 = ", i, v)
        local cardId = helper.getPaiByIndex(v.cbCenterCard)
        if cardId > 0 then
            table.insert(self.pongList,cardId)
            self.isPong = true
            local tag   = 1
            local nType = 1
            if v.cbWeaveKind == 16 then 
                if v.cbPublicCard == 0 then
                    tag   = 2
                    nType = 2
                elseif v.cbPublicCard == 1 then
                    nType = 4
                end
            end
            for i=1,3 do
                local count = self.ly_self_state:getChildrenCount()
                local bg_pai = DDMaJiang.new(true,tag,cardId)
                bg_pai:setScale(0.8)
                bg_pai:setCurState(nType)
                local s = bg_pai:getContentSize()
                if i==2 and v.cbWeaveKind == 16 then
                    local bg_pai2 = DDMaJiang.new(true,1,cardId)
                    bg_pai2:setName("centerCard")
                    bg_pai2:setPosition(s.width/2, s.height/2+10)
                    bg_pai:addChild(bg_pai2,10)
                end
                    
                bg_pai:setPosition(count*s.width* bg_pai:getScale() + self.nStateSelfDist, s.height/2* bg_pai:getScale())
                self.ly_self_state:addChild(bg_pai)
            end
            self.nStateSelfDist = self.nStateSelfDist + 30
        end
    end

    --添加对方状态牌
    for i,v in ipairs(data_state_ds) do
        --print("添加对方状态牌 = ", i, v)
        local cardId = helper.getPaiByIndex(v.cbCenterCard)
        if cardId > 0 then
            table.insert(self.pongList_ds, cardId)
            local tag   = 1
            local nType = 1
            if v.cbWeaveKind == 16 then 
                if v.cbPublicCard == 0 then
                    tag   = 2
                    nType = 2
                elseif v.cbPublicCard == 1 then
                    nType = 4
                end
            end

            local x = self.ly_duishou_state:getPositionX()
            for i=1,3 do
                local count = self.ly_duishou_state:getChildrenCount()
                local bg_pai = DDMaJiang.new(false,tag,cardId)
                bg_pai:setScale(1.3)
                bg_pai:setCurState(nType)

                local s = bg_pai:getContentSize()
                if i == 2 and v.cbWeaveKind == 16 then
                    local bg_pai2 = DDMaJiang.new(false,1,cardId)
                    bg_pai2:setName("centerCard")
                    bg_pai2:setPosition(s.width/2, s.height/2+10)
                    bg_pai:addChild(bg_pai2)
                end

                bg_pai:setPosition(x - (count*(s.width-8)* bg_pai:getScale() + self.nStateTargetDist), s.height/2* bg_pai:getScale())
                self.ly_duishou_state:addChild(bg_pai)
            end
            self.nStateTargetDist = self.nStateTargetDist + 30
        end
    end

    --添加己方手牌
    for i,v in ipairs(tPai) do
        if v > 0 then
            local count = self.ly_self:getChildrenCount() + self.ly_self_state:getChildrenCount()
            local bg_pai = DDMaJiang.new(true,4,v)
            bg_pai:setScale(0.9)
            bg_pai:setIndex(14-count)

            local s = bg_pai:getContentSize()
            bg_pai:setPosition(self.selfCardPosList[14-count], s.height* bg_pai:getScale())
            self.ly_self:addChild(bg_pai)
            bg_pai:runAction(cc.MoveBy:create(0.1, cc.p(0,-s.height/2*bg_pai:getScale())))
            table.insert(self.paiList_self, 1, bg_pai)
        end
    end
    
    --添加对方手牌
    local listEnemy = {}
    for i=1, targetPaiCount - (target_state_count * 3) do
        table.insert(listEnemy,1)
    end
    for i,v in ipairs(listEnemy) do
        local bg_pai = DDMaJiang.new(false,4,v)
        bg_pai:setScale(0.7)
        bg_pai:setIndex(i)
        
        local s = bg_pai:getContentSize()
        bg_pai:setPosition(self.targetCardPosList[i], s.height/2* bg_pai:getScale())
        self.ly_duishou:addChild(bg_pai)
    end

    self:initPaiEffect() 
    self.isReady = true
    self.isInitPaiFinish = true
    self.isDoing = true

    --时钟
    if data.wCurrentUser ~= 65535 then
        cc.MENetUtil:setGameClock(data.wCurrentUser, 201, 25)
        if data.wCurrentUser == cc.MENetUtil:getChairID() then
            self.aleart_pai = true
            self:setCursor(false)
        else
            self:setCursor(true)
        end
    end

    if data.wOutCardUser ~= 65535 then
        if data.wOutCardUser == cc.MENetUtil:getChairID() then
            self:setCursor(true)
        else
            self:setCursor(false)
        end
        cc.MENetUtil:setGameClock(data.wOutCardUser, 203, 15) 
    end

    if data.cbActionMask ~= 0x00 then
        self.actionCard = helper.getPaiByIndex(data.cbActionCard)
        self:show_add_state_by_type(data.cbActionMask)
        if not self.aleart_pai then
            cc.MENetUtil:operatePai(0, 0)
            self:moPai()
        end
        self:setCursor(false)
        cc.MENetUtil:setGameClock(cc.MENetUtil:getChairID(), 202, 15)
    end

    self._children["btn_ready"]:setVisible(false)
    self._children["btn_dizhu_setting"]:setVisible(false)
    
    self:hideBackBtn()

    self._children["imgTargetReady"]:setVisible(false)
    if data.isBankerUser then
        self._children["imgSelfZhuang"]:setVisible(true)
    else
        self._children["imgTargetZhuang"]:setVisible(true)
    end
    
    
    self.curPaiCount = data.cbLeftCardCount
    self:updatePaiCount()
    self.score = data.lCellScore
    if cc.MENetUtil:isCustomServer() then
        self._children["lab_doubleNum"]:setString("局数:".. self.curJuShuCount .. "/" ..self.maxJuShuCount)
    else
        self._children["lab_doubleNum"]:setString("底注:".. self.score)
    end
    --强制为用户托管
    cc.MENetUtil:setTrustee(true)
    self._children["btn_room_jiesan"]:setVisible(false)
    self._children["btn_auto_send"]:setVisible(true)
    self._children["btn_weixin_yaoqing"]:setVisible(false)
    self:setDsSmale()
    self.isStart = true
end

function MaJiangScene:enterGame(data)
    dump(data, "游戏场景")
    if data.bShowReady ~= nil then
        self._children["btn_ready"]:setVisible(data.bShowReady)
        if not data.bShowReady then
            self.isReady = true
            self._children["imgSelfReady"]:setVisible(true)
        end
    end

    self._children["timePanel"]:setVisible(false)
    local s = self._children["timePanel"]:getContentSize()
    self.timeArmature = ccs.Armature:create("MJTime")
    if self.timeArmature ~= nil then
        self.timeArmature:getAnimation():play("Self")
        self.timeArmature:setPosition(cc.p(s.width/2, s.height/2))
        self._children["timePanel"]:addChild(self.timeArmature, -1)
    end

    self:addEventListener(EventMsgDefine.GameNext,self.ready,self)
    self:addEventListener(EventMsgDefine.GameRoomOut,self.GameRoomOut,self)
    self:addEventListener(EventMsgDefine.GameShowCustomResult,self.GameShowCustomResult,self)
    self:addEventListener(EventMsgDefine.GotoMainScene,self.GotoMainScene,self)
    self:addEventListener(EventMsgDefine.GameReset,self.ResetGame,self)
    self:addEventListener(EventMsgDefine.GameJieSuan,self.GameJieSuan,self)
    
    self.score = data.lCellScore
    if data ~= nil and data.isSelf and not cc.MENetUtil:isCustomServer() then
        self._children["btn_dizhu_setting"]:setVisible(true)
    end
end

function MaJiangScene:GotoMainScene()
    cc.MENetUtil:logoutGame()
    MaJiangController:backGame()
end

function MaJiangScene:UpdateTabler(data)
    if data.isSelf and not cc.MENetUtil:isCustomServer() then
        self._children["btn_dizhu_setting"]:setVisible(true)
    end
end

function MaJiangScene:UpdateUserClock(nChairID, nClock)
    self._children["lab_time_self"]:setString( string.format("%02d", nClock ))
    if self.isDoing then
        self._children["imgTargetReady"]:setVisible(false)
    end
end

function MaJiangScene:initPaiData(data)
    dump(data, "初始化牌")
    self._children["btn_ready"]:setVisible(false)
    self._children["imgSelfReady"]:setVisible(false)
    self._children["imgTargetReady"]:setVisible(false)
    self:showSaiZiDongHua(data.siceCount, function ( ... )
        -- body
        self:zhuJiaEffect(data.isBankerUser)
        --检测是否有暗杠
        if data.userAction ~= 0x00 then
            self:show_add_state_by_type(data.userAction)
        end
        cc.MENetUtil:setGameClock(data.bankerUser, 201, 25)
        self._children["timePanel"]:setVisible(true)
    end)
    if data.isBankerUser then
        self.aleart_pai = true
    else
        self.aleart_pai = false
    end
    self.paiList = {}
    for i=1,#data.cardData do
        if data.cardData[i] ~= 0 then
            table.insert(self.paiList, helper.getPaiByIndex(data.cardData[i]))  
        end
    end
    local action = cc.Sequence:create(
        cc.DelayTime:create(2),
        cc.CallFunc:create(function() self:addPai(1) end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() self:addPai(2) end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() self:addPai(3) end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() self:addPai(4) end),
        cc.DelayTime:create(2),
        cc.CallFunc:create(function()
            self.isInitPaiFinish = true
            --检测是否用户托管出牌
            self:userAutoChuPai()
        end)
    )
    self:runAction(action)
    
    self:setCursor(not data.isBankerUser)

    self._children["btn_dizhu_setting"]:setVisible(false)
    self.isDoing = true
    self:hideBackBtn()

    self:updatePaiCount()
    if cc.MENetUtil:isCustomServer() then
        self._children["lab_doubleNum"]:setString("局数:".. self.curJuShuCount .. "/" ..self.maxJuShuCount)
    else
        self._children["lab_doubleNum"]:setString("底注:".. self.score)
    end
    self._children["btn_room_jiesan"]:setVisible(false)
    self._children["btn_auto_send"]:setVisible(true)
    self._children["btn_weixin_yaoqing"]:setVisible(false)
    self:setDsSmale()
    self.isStart = true
end

function MaJiangScene:showSaiZiDongHua(count, callback)
    local dian1, dian2 = helper.getShaiZiCount(count)

    MEAudioUtils.playSoundEffect("sound/audio_shaizi.mp3")
    local sp_1 = cc.Sprite:create("res/game_erhzb/shezi/action/0.png")
    local sp_2 = cc.Sprite:create("res/game_erhzb/shezi/action/1.png")
    sp_1:setTag(dian1)
    sp_2:setTag(dian2)
    local animation = cc.Animation:create()
    for i = 1, 11 do
        animation:addSpriteFrameWithFile("res/game_erhzb/shezi/action/"..i..".png")
    end
    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)

    local function setDianShu1()
        local tag = dian1
        if tag < 1 then
            tag = 1
        end
        if tag > 6 then
            tag = 6
        end
        sp_1:setTexture("res/game_erhzb/shezi/"..tag..".png")
    end

    local function setDianShu2()
        local tag = dian2
        if tag < 1 then
            tag = 1
        end
        if tag > 6 then
            tag = 6
        end
        sp_2:setTexture("res/game_erhzb/shezi/"..tag..".png")
    end

    local function remove1()
        sp_1:removeFromParent()
    end

    local function remove2()
        sp_2:removeFromParent()
        callback()
    end
    local action = cc.Animate:create(animation)
    local cal1 = cc.CallFunc:create(function() setDianShu1() end)
    local cal2 = cc.CallFunc:create(function() setDianShu2() end)
    local cal3 = cc.CallFunc:create(function() remove1() end)
    local cal4 = cc.CallFunc:create(function() remove2() end)
    local seq_1 = cc.Sequence:create(action:clone(), cal1,cc.DelayTime:create(1),cal3)
    local seq_2 = cc.Sequence:create(action:clone(), cal2,cc.DelayTime:create(1),cal4)
    sp_1:runAction(seq_1)
    sp_2:runAction(seq_2)

    sp_1:setPosition(me.winSize.width/2 - sp_1:getContentSize().width/2, me.winSize.height/2)
    sp_2:setPosition(me.winSize.width/2 + sp_1:getContentSize().width/2, me.winSize.height/2)
    self:addChild(sp_1,99999)
    self:addChild(sp_2,99999)
end

function MaJiangScene:zhuJiaEffect(isSelf)
    -- body
    local s = self._children["ly_battle"]:getContentSize()
    local effect = cc.Sprite:createWithSpriteFrameName("majiang_7.png")
    self._children["ly_battle"]:addChild(effect)
    effect:setPosition(cc.p(s.width/2, s.height/2))
    effect:setLocalZOrder(1024)

    local pos 
    if isSelf then
        pos = self._children["imgSelfZhuang"]:convertToWorldSpaceAR(cc.p(0, 0))
    else
        pos = self._children["imgTargetZhuang"]:convertToWorldSpaceAR(cc.p(0, 0))
    end
    local seq = cc.Sequence:create(
        cc.MoveTo:create(0.2, pos),
        cc.CallFunc:create(function()
            effect:removeFromParent()
            if isSelf then
                self._children["imgSelfZhuang"]:setVisible(true)
            else
                self._children["imgTargetZhuang"]:setVisible(true)
            end
        end)
    )
    effect:runAction(seq) 
end

function MaJiangScene:GameShowCustomResult()
    -- body
    app:openDialog("MaJiangCustomResultLayer", self.customRoomData)
end

function MaJiangScene:GameRoomOut()
    -- body
    if not self.isCheat then
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)
    end
    --退出房间
    cc.MENetUtil:leaveGame()
end

function MaJiangScene:SettingDiZhu(data)
    self.score = data
    self._children["lab_doubleNum"]:setString("底注:"..self.score)
end

function MaJiangScene:GameInfoTips(str)
    local tmp = string.find(str,"两人红中宝")
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

function MaJiangScene:zimo()
    self.ly_add_state:setVisible(false)
    cc.MENetUtil:operatePai(0x40, 0)
end

--碰
function MaJiangScene:pong()
    self.ly_add_state:setVisible(false)
    cc.MENetUtil:operatePai(0x08, helper.getIndexByPai(self.actionCard) )
end

function MaJiangScene:gang()
    self.ly_add_state:setVisible(false)
    cc.MENetUtil:operatePai(0x10, helper.getIndexByPai(self.actionCard) )
end

function MaJiangScene:pengPaiEffect(isSelf, id, callback)
    -- body
    print("MaJiangScene:pengPaiEffect(isSelf, id)", isSelf, id)
    local path
    local y = 0
    if isSelf then
        if self.selfSex == 1 then
            path = "sound/man/PENG.mp3"
        else
            path = "sound/woman/PENG.mp3"
        end
        y = cc.p(self.ly_self_state:getPosition()).y + self.ly_self_state:getContentSize().height + 50
    else
        if self.targetSex == 1 then
            path = "sound/man/PENG.mp3"
        else
            path = "sound/woman/PENG.mp3"
        end
        y = cc.p(self.ly_duishou:getPosition()).y - 50
    end
    MEAudioUtils.playSoundEffect(path)

    local t = {
        [1] = -200,
        [2] = 0,
        [3] = 200,
    }
    for i=1,3 do
        local effect = DDMaJiang.new(true, 1, id)
        effect:setLocalZOrder(1024)
        self._children["ly_battle"]:addChild(effect) 
        local x
        local x2
        if i == 1 then
            x = self._children["ly_battle"]:getContentSize().width/2 - 300
            x2 = self._children["ly_battle"]:getContentSize().width/2 - effect:getContentSize().width*effect:getScale() 
        elseif i == 2 then
            x = self._children["ly_battle"]:getContentSize().width/2
            x2 = self._children["ly_battle"]:getContentSize().width/2
        elseif i == 3 then
            x = self._children["ly_battle"]:getContentSize().width/2 + 300
            x2 = self._children["ly_battle"]:getContentSize().width/2 + effect:getContentSize().width*effect:getScale() 
        end
        effect:setPosition(cc.p(x, y))

        local seq = cc.Sequence:create(
            cc.MoveTo:create(0.25, cc.p(x + t[i], y)),
            cc.MoveTo:create(0.2, cc.p(x2, y)),
            cc.DelayTime:create(0.8),
            cc.CallFunc:create(function()
                effect:removeFromParent()
            end)
        )
        effect:runAction(seq)
    end

    local armature = ccs.Armature:create("MJPeng")
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        if isSelf then
            armature:setPosition(cc.p(s.width/2, s.height/2 + 30))
        else
            local y1 = cc.p(self.ly_duishou:getPosition()).y
            local s1 = self.ly_duishou:getContentSize()
            armature:setPosition(cc.p(s.width/2, y1 + s1.height/2 + 30))
        end
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature)

        --注册事件回调
        local function animationEvent(armatureBack,movementType,movementID)
            local id = movementID
            if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then    
                armatureBack:removeFromParent(true)
                if callback then
                    callback()
                end
            end
        end
        armature:getAnimation():setMovementEventCallFunc(animationEvent)
    end
end

function MaJiangScene:gangPaiEffect(isSelf, type, id, callback)
    -- body
    print("MaJiangScene:gangPaiEffect(isSelf, type, id) ", isSelf, type, id)
    local path
    local y = 0
    if isSelf then
        if self.selfSex == 1 then
            path = "sound/man/GANG.mp3"
        else
            path = "sound/woman/GANG.mp3"
        end
        y = cc.p(self.ly_self_state:getPosition()).y + self.ly_self_state:getContentSize().height + 50
    else
        if self.targetSex == 1 then
            path = "sound/man/GANG.mp3"
        else
            path = "sound/woman/GANG.mp3"
        end
        y = cc.p(self.ly_duishou:getPosition()).y - 50
    end
    MEAudioUtils.playSoundEffect(path)

    if type == 2 then
        local x = self._children["ly_battle"]:getContentSize().width/2 - 100
        for i=1,4 do
            local effect = DDMaJiang.new(true, 2, id)
            effect:setPosition(cc.p(x, y))
            effect:setLocalZOrder(1024)
            self._children["ly_battle"]:addChild(effect) 
            x = x + effect:getContentSize().width*effect:getScale()

            local seq = cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function()
                    effect:removeFromParent()
                end)
            )
            effect:runAction(seq)
        end
    else
        local t = {
            [1] = -200,
            [2] = 0,
            [3] = 200,
        }
        
        for i=1,3 do
            local effect = DDMaJiang.new(true, 1, id)
            effect:setLocalZOrder(1024)
            self._children["ly_battle"]:addChild(effect) 
            local x
            local x2
            if i == 1 then
                x = self._children["ly_battle"]:getContentSize().width/2 - 300
                x2 = self._children["ly_battle"]:getContentSize().width/2 - effect:getContentSize().width*effect:getScale() 
            elseif i == 2 then
                x = self._children["ly_battle"]:getContentSize().width/2
                x2 = self._children["ly_battle"]:getContentSize().width/2
                local bg_pai2 = DDMaJiang.new(true, 1, id)
                bg_pai2:setPosition(effect:getContentSize().width/2, effect:getContentSize().height/2+ 10)
                effect:addChild(bg_pai2,10)
            elseif i == 3 then
                x = self._children["ly_battle"]:getContentSize().width/2 + 300
                x2 = self._children["ly_battle"]:getContentSize().width/2 + effect:getContentSize().width*effect:getScale() 
            end
            effect:setPosition(cc.p(x, y))

            local seq = cc.Sequence:create(
                cc.MoveTo:create(0.25, cc.p(x + t[i], y)),
                cc.MoveTo:create(0.2, cc.p(x2, y)),
                cc.DelayTime:create(0.8),
                cc.CallFunc:create(function()
                    effect:removeFromParent()
                end)
            )
            effect:runAction(seq) 
        end
    end

    local armature = ccs.Armature:create("MJGang")
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        if isSelf then
            armature:setPosition(cc.p(s.width/2, s.height/2 + 30))
        else
            local y1 = cc.p(self.ly_duishou:getPosition()).y
            local s1 = self.ly_duishou:getContentSize()
            armature:setPosition(cc.p(s.width/2, y1 + s1.height/2 + 30))
        end
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature)

        --注册事件回调
        local function animationEvent(armatureBack,movementType,movementID)
            local id = movementID
            if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then    
                armatureBack:removeFromParent(true)
                if callback then
                    callback()
                end
            end
        end
        armature:getAnimation():setMovementEventCallFunc(animationEvent)
    end
end

function MaJiangScene:huPaiEffect(isSelf, callback )
    -- body
    local armature = ccs.Armature:create("MJHu")
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        if isSelf then
            armature:setPosition(cc.p(s.width/2, s.height/2 + 30))
        else
            local y1 = cc.p(self.ly_duishou:getPosition()).y
            local s1 = self.ly_duishou:getContentSize()
            armature:setPosition(cc.p(s.width/2, y1 + s1.height/2 + 30))
        end
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature)

        --注册事件回调
        local function animationEvent(armatureBack,movementType,movementID)
            local id = movementID
            if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then    
                armatureBack:removeFromParent(true)
                if callback then
                    callback()
                end
            end
        end
        armature:getAnimation():setMovementEventCallFunc(animationEvent)
    end
end

function MaJiangScene:chuPaiEffect(isSelf, obj, id, callback)
    -- body
    local pos = cc.p(obj:getPosition())
    local effect = DDMaJiang.new(isSelf, 1, id)
    local y = 0
    if isSelf then
        y = cc.p(self.ly_self:getPosition()).y + obj:getContentSize().height + obj:getContentSize().height/2 -20
    else
        y = cc.p(self.ly_duishou:getPosition()).y - obj:getContentSize().height/2 + 20
    end
    effect:setPosition( cc.p(self._children["ly_battle"]:getContentSize().width/2, y) )
    effect:setLocalZOrder(1024)
    self._children["ly_battle"]:addChild(effect)

    local seq = cc.Sequence:create(
        cc.DelayTime:create(1*self.chuSpeed),
        cc.CallFunc:create(function()
            effect:removeFromParent()
            if callback then
                callback()
            end
        end)
    )
    effect:runAction(seq) 
end

function MaJiangScene:chuPaiArrowEffect( node )
    -- body
    for _,d in pairs(self.ly_self_out:getChildren()) do
        local imgFlag = d:getChildByName("CurOutCardFlag")
        if imgFlag ~= nil then
            imgFlag:removeFromParent()
        end
    end

    for _,d in pairs(self.ly_duushou_out:getChildren()) do
        local imgFlag = d:getChildByName("CurOutCardFlag")
        if imgFlag ~= nil then
            imgFlag:removeFromParent()
        end
    end

    local s = node:getContentSize()
    local imgFlag = cc.Sprite:createWithSpriteFrameName("cur_outCard.png")
    imgFlag:setName("CurOutCardFlag")
    node:addChild(imgFlag, 2)
    imgFlag:setPosition(cc.p(s.width/2, s.height/2+10))

    local pos = cc.p(imgFlag:getPosition())
    local seq = cc.Sequence:create(
        cc.MoveTo:create(0.5, cc.p(pos.x, pos.y + 30)),
        cc.MoveTo:create(0.5, cc.p(pos.x, pos.y))
    )
    local rpt = cc.RepeatForever:create(seq)
    imgFlag:runAction(rpt)
end

function MaJiangScene:chuPai(bAuto, isSelf)
    print("MaJiangScene:chuPai(bAuto, isSelf) ....................", bAuto, isSelf)
    if isSelf then
        print("当前牌状态",self.aleart_pai)
        if not self.aleart_pai then
            print("出牌失败，不是当前用户出牌！！")
            return false
        end
        if self.curMaJiang == nil then
            print("出牌失败，当前牌为空！！")
            return false
        end
        local id = self.curMaJiang:getTag()
        if id == 20 then
            self:GameInfoTips("红中不能打出")
            print("出牌失败，红中不能打出！！")
            return false
        end
        self:clearOutSameCard()
        print("MaJiangScene:chuPai ===============================", id, self.curMaJiang:getIndex() )
        self.ly_add_state:setVisible(false)
        self.isPongIng = false
        self.aleart_pai = false
        local path
        if self.selfSex == 1 then
            path = "sound/man/W_"..id..".mp3"
        else
            path = "sound/woman/W_"..id..".mp3"
        end
        MEAudioUtils.playSoundEffect(path)  

        self.curPaiId = id
        local count = self.ly_self_out:getChildrenCount()
        local mj_chu = DDMaJiang.new(isSelf,3,id)
        local s = mj_chu:getContentSize()
        local midY = 0
        local midX = self.ly_self_out:getPositionX()
        if (count >= 17) then
            midY = midY + s.height
        end
        mj_chu:setPosition(midX + (count%17)*(s.width - 11), midY )
        mj_chu:setLocalZOrder(count)
        self.ly_self_out:addChild(mj_chu)
        self.selfOutCardList[#self.selfOutCardList + 1] = mj_chu
        mj_chu:setVisible(false)
        self:chuPaiArrowEffect( mj_chu )

        local nPos = mj_chu:convertToWorldSpaceAR(cc.p(0, 0))
        self:chuPaiEffect(isSelf, self.curMaJiang, id, function ( ... )
            -- body
            self:showOutCard(true)
            
            if not bAuto then
                cc.MENetUtil:chuPai(helper.getIndexByPai(id))
            end
        end)

        self:reOrderByDoing()
    else
        print("MaJiangScene:chuPai ===============================", self.curPaiId)
        local path
        if self.targetSex == 1 then
            path = "sound/man/W_"..self.curPaiId..".mp3"
        else
            path = "sound/woman/W_"..self.curPaiId..".mp3"
        end
        MEAudioUtils.playSoundEffect(path)

        local count =  self.ly_duushou_out:getChildrenCount()
        local mj_chu = DDMaJiang.new(false,3,self.curPaiId)
        local s = mj_chu:getContentSize()
        local midY = self.ly_duushou_out:getContentSize().height - s.height
        local midX = self.ly_duushou_out:getPositionX()
        if count >= 17 then
            midY = midY - s.height 
        end
        mj_chu:setPosition(midX - (count%17)*(s.width - 11), midY )
        mj_chu:setLocalZOrder(count)
        self.ly_duushou_out:addChild(mj_chu)
        self.targetOutCardList[#self.targetOutCardList + 1] = mj_chu
        mj_chu:setVisible(false)
        self:chuPaiArrowEffect( mj_chu )

        local nPos = mj_chu:convertToWorldSpaceAR(cc.p(0, 0))

        local count = self.ly_duishou:getChildrenCount()
        for _,d in pairs(self.ly_duishou:getChildren()) do
            count = count - 1
            if d:getIndex() == 1 then
                self:chuPaiEffect(isSelf, d, self.curPaiId, function ( ... )
                    -- body
                    self:showOutCard(false)
                    d:removeFromParent()
                end)
                break
            end
        end
    end
    MEAudioUtils.playSoundEffect("sound/OUT_CARD.mp3")
    return true
end

function MaJiangScene:showOutCard(isSelf)
    -- body
    if isSelf then
        for _,d in pairs(self.ly_self_out:getChildren()) do
            if not d:isVisible() then
                d:setVisible(true)
            end
        end
    else
        for _,d in pairs(self.ly_duushou_out:getChildren()) do
            if not d:isVisible() then
                d:setVisible(true)
            end
        end
    end
end

function MaJiangScene:updateOutCard(isSelf, id)
    -- body
    print("MaJiangScene:updateOutCard(isSelf, id)", isSelf, id)
    if isSelf then
        print("remove self card .....................", id)
        local lastOut = self.selfOutCardList[#self.selfOutCardList]
        if lastOut:getTag() == id then
            local Out = self.selfOutCardList[#self.selfOutCardList - 1]
            if Out ~= nil then
                self:chuPaiArrowEffect( Out )
            end
            lastOut:removeFromParent()
            self.selfOutCardList[#self.selfOutCardList] = nil
        end
    else
        print("remove taget card .....................", id)
        local lastOut = self.targetOutCardList[#self.targetOutCardList]
        if lastOut:getTag() == id then
            local Out = self.targetOutCardList[#self.targetOutCardList - 1]
            if Out ~= nil then
                self:chuPaiArrowEffect( Out )
            end
            lastOut:removeFromParent()
            self.targetOutCardList[#self.targetOutCardList] = nil
        end
    end
end

function MaJiangScene:updatePaiCount()
    self._children["lab_pai_count"]:setString("牌数:"..self.curPaiCount.."张")
    if self.curPaiCount <= 0 then
        self.isFlowGame = true
    end
end

function MaJiangScene:addPai(nCount)
    local listSelf = {}
    local listEnemy = {}

    if nCount == 4 then
        table.insert(listSelf,self.paiList[1])
        table.remove(self.paiList,1)
        table.insert(listEnemy,1)

        --庄家14，闲家13
        if self.aleart_pai then
            table.insert(listSelf,self.paiList[1])
            table.remove(self.paiList,1)
        else
            table.insert(listEnemy,1)
        end
    else
        for i=1,4 do
            table.insert(listSelf,self.paiList[1])
            table.remove(self.paiList,1)
            table.insert(listEnemy,1)
        end
    end
    self:insertPai(listSelf,listEnemy)

    if nCount ==4 then
        --重新排序排
        local action = cc.Sequence:create(
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() 
                self:initPaiEffect() 
            end)
        )
        self:runAction(action)
    end
end

function MaJiangScene:insertPai(listSelf,listEnemy)
    print("MaJiangScene:insertPai...........................", listSelf,listEnemy)

    for i,v in ipairs(listSelf) do
        local count = self.ly_self:getChildrenCount() + self.ly_self_state:getChildrenCount()
        local bg_pai = DDMaJiang.new(true,4,v)
        bg_pai:setScale(0.9)
        bg_pai:setIndex(14-count)

        local s = bg_pai:getContentSize()
        bg_pai:setPosition(self.selfCardPosList[14-count], s.height* bg_pai:getScale())
        self.ly_self:addChild(bg_pai)
        bg_pai:runAction(cc.MoveBy:create(0.1, cc.p(0,-s.height/2*bg_pai:getScale())))
        table.insert(self.paiList_self, 1, bg_pai)
    end

    for i,v in ipairs(listEnemy) do
        local count = self.ly_duishou:getChildrenCount() + self.ds_state_pai_count
        local bg_pai = DDMaJiang.new(false,4,v)
        bg_pai:setScale(0.7)
        bg_pai:setIndex(14-count)

        local s = bg_pai:getContentSize()
        bg_pai:setPosition(self.targetCardPosList[14-count], s.height* bg_pai:getScale())
        self.ly_duishou:addChild(bg_pai)
        bg_pai:runAction(cc.MoveBy:create(0.1, cc.p(0,-s.height/2*bg_pai:getScale())))
    end
    MEAudioUtils.playSoundEffect("sound/SEND_CARD.mp3")
end

function MaJiangScene:getPai(isSelf, cardId)
    print("MaJiangScene:getPai...........................", isSelf, cardId)
    if isSelf then
        local bg_pai = DDMaJiang.new(true, 4, cardId)
        bg_pai:setLocalZOrder(100)
        bg_pai:setScale(0.9)
        bg_pai:setIndex(1)
        local s = bg_pai:getContentSize()
        bg_pai:setPosition(cc.p(self.selfCardPosList[1], s.height/2* bg_pai:getScale() ))
        self.ly_self:addChild(bg_pai)

        table.insert(self.paiList_self, 1, bg_pai)
        self.lastPaiId = cardId

        for k,v in pairs(self.paiList_self) do
            v:setIndex(k)
            v:setPositionX(self.selfCardPosList[k])
        end
        self.aleart_pai = true
    else
        local bg_pai = DDMaJiang.new(false,4,cardId)
        bg_pai:setLocalZOrder(100)
        bg_pai:setScale(0.7)
        bg_pai:setIndex(1)
        local s = bg_pai:getContentSize()
        bg_pai:setPosition(cc.p(self.targetCardPosList[1], s.height/2* bg_pai:getScale()) )
        self.ly_duishou:addChild(bg_pai)

        local count = self.ly_duishou:getChildrenCount()
        for k,v in pairs(self.ly_duishou:getChildren()) do
            print("target getpai:", k, v:getTag() )
            v:setIndex(k)
            v:setPosition(cc.p(self.targetCardPosList[k], v:getContentSize().height/2* v:getScale()) )
        end
    end
    MEAudioUtils.playSoundEffect("sound/SEND_CARD.mp3")
end

function MaJiangScene:initPaiEffect()
    -- body
    local t = {}
    for k,v in pairs(self.paiList_self) do
        t[#t + 1] = v:getTag()
    end
    dump(t, "ff")
    dump(self.selfCardPosList, "tt")

    table.sort(t,function(a,b) return a>b end)

    local zong_count = 0
    local data = {}
    for i=1, #t do
        if t[i] == 20 then
            zong_count = zong_count + 1
        else
            data[#data + 1] = t[i]
        end
    end
    for i=1, zong_count do
        table.insert(data,20)
    end
    dump(data, "初始化排序")

    --先排序
    for k,v in pairs(self.paiList_self) do
        v:reSetMJPai(data[k] )
        v:setIndex(k)
        v:setLocalZOrder(k)
    end

    --后盖牌
    for k,p in pairs(self.ly_self:getChildren()) do
        p:addGaiAction()
    end

    for k,v in pairs(self.paiList_self) do
        print(k, v:getIndex(), v:getTag() )
    end
    self.lastPaiId = self.paiList_self[1]:getTag()

    ---------------------------------------------------------------
    local count = self.ly_duishou:getChildrenCount()
    local nMax = count
    if nMax == 13 then
        nMax = 14
    end
    for k,v in pairs(self.ly_duishou:getChildren()) do
        v:setIndex(k)
        v:setPosition(cc.p(self.targetCardPosList[nMax], v:getContentSize().height/2* v:getScale() ))
        nMax = nMax - 1
    end
end

function MaJiangScene:reorderpai(id, count)
    print("MaJiangScene:reorderpai(id, count) ..............", id, count)
    --[[for k,v in pairs(self.paiList_self) do
        print(k, v:getIndex(), v:getTag() )
    end]]
    print("reorder start ################################################")
    local function delPai()
        -- body
        local nPos = -1
        for i=1, #self.paiList_self do
            local card = self.paiList_self[i]
            if nPos == -1 then
                if id == card:getTag() then 
                    nPos = i
                end
            else
                print(i, card:getIndex(), card:getTag(), self.selfCardPosList[i])
                card:setPositionX(self.selfCardPosList[i])
            end
        end
        if nPos ~= -1 then
            self.paiList_self[nPos]:removeFromParent()
            table.remove(self.paiList_self, nPos)
        end
    end
    
    for i=1,count do
        delPai()
    end
    print("reorder finish ################################################")
    for k,v in pairs(self.paiList_self) do
        v:setIndex(k)
        v:setPositionX(self.selfCardPosList[k])
        --print(k, v:getIndex(), v:getTag(), v:getPositionX() )
    end
    --[[print("------------------------------------------")
    for _,d in pairs(self.ly_self:getChildren()) do
        print(d:getIndex(), d:getTag() )
    end]]

    local t = {}
    for k,v in pairs(self.paiList_self) do
        t[#t + 1] = v:getTag()
    end
    dump(t, "ff")
    dump(self.selfCardPosList, "tt")

    table.sort(t,function(a,b) return a>b end)

    local zong_count = 0
    local data = {}
    for i=1, #t do
        if t[i] == 20 then
            zong_count = zong_count + 1
        else
            data[#data + 1] = t[i]
        end
    end
    for i=1, zong_count do
        table.insert(data,20)
    end
    dump(data, "杠后排序")

    --先排序
    for k,v in pairs(self.paiList_self) do
        v:reSetMJPai(data[k] )
        v:setIndex(k)
        v:setLocalZOrder(k)
    end

    self.lastPaiId = self.paiList_self[1]:getTag()
end

function MaJiangScene:reOrderByDoing()
    local nOutIdx = self.curMaJiang:getIndex()
    if nOutIdx == 1 then
        self.lastPaiId = -1
    end
    print("self.lastPaiId = ", self.lastPaiId)
    for k,v in pairs(self.paiList_self) do
        print(k,v:getIndex(), v:getTag(), v:getPositionX() )
    end
    dump(self.selfCardPosList, "tt")
    
    local function removeChuPai( ... )
        -- body
        table.remove(self.paiList_self, nOutIdx)
        self.curMaJiang:removeFromParent()
        self.curMaJiang = nil
    end

    local function ChuPaiFinish( ... )
        -- body
        print("order finish !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        local nCurCount = 0
        for k,v in pairs(self.ly_self:getChildren()) do
            nCurCount = nCurCount + 1
        end
        print("check !!!!!!!!!!!!!!!!!!!!!!!", nCurCount, #self.paiList_self )
        for k,v in pairs(self.paiList_self) do
            v:setIndex(k)
            print(k, v:getIndex(), v:getTag() )
        end
    end

    if self.lastPaiId ~= -1 then
        --找插入位置
        local nInsPos = 1
        if self.lastPaiId == 20 then
            nInsPos = #self.paiList_self
        else
            for k,v in pairs(self.paiList_self) do
                print(k,v:getIndex(), v:getTag(), v:getPositionX()  )
                local cardid = v:getTag()
                if cardid ~= 20 and self.lastPaiId < cardid then
                    nInsPos = k
                end
            end
        end
        print("nInsPos =,  nOutIdx = ", nInsPos, nOutIdx, self.selfCardPosList[nOutIdx])
        local moved = -1
        if nOutIdx < nInsPos then
            --打出去的牌在插入的右边
            for i=nOutIdx + 1, nInsPos, 1 do
                local card = self.paiList_self[i]
                print(i, card:getIndex(), card:getTag(), self.selfCardPosList[i], self.selfCardPosList[i-1] )
                card:setIndex(i-1)
                card:setPositionX(self.selfCardPosList[i-1])
            end
            moved = 1
        elseif nOutIdx == nInsPos then
            if nInsPos == 2 then
                local card = self.paiList_self[1]
                card:setIndex(2)
                card:setPositionX(self.selfCardPosList[2])
            end
            moved = 1
        else
            --打出去的牌在插入的左边
            local n = nInsPos + 1
            if nInsPos == 1 then
                n = nInsPos
            end
            for i= n, nOutIdx - 1, 1 do
                local card = self.paiList_self[i]
                print(i, card:getIndex(), card:getTag(), self.selfCardPosList[i], self.selfCardPosList[i+1] )
                card:setIndex(i+1)
                card:setPositionX(self.selfCardPosList[i+1])
            end
            moved = 2
            --比如插入的是位置3，打出的是位置4
            if nOutIdx - nInsPos == 1 then
                moved = 1
            end
            nInsPos = nInsPos + 1 
        end

        if nInsPos > 2 then
            print("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
            local insertCard = clone(self.paiList_self[1])
            local s = insertCard:getContentSize()
            local seq = cc.Sequence:create(
                cc.MoveBy:create(0.2, cc.p(0, s.height * insertCard:getScale() + 10)),
                cc.MoveTo:create(0.25, cc.p(self.selfCardPosList[nInsPos], s.height * insertCard:getScale() * 1.5 + 10)),
                cc.MoveBy:create(0.2, cc.p(0,-s.height * insertCard:getScale() - 10)),
                cc.CallFunc:create(function()
                    --重新排序
                    table.remove(self.paiList_self, 1)
                    print("插入排序之前！！！！！！！！！！！！！！！！！", moved)
                    for k,v in pairs(self.paiList_self) do
                        v:setIndex(k)
                        print(k, v:getIndex(), v:getTag() )
                    end

                    if insertCard:getTag() == 20 then
                        table.insert(self.paiList_self, #self.paiList_self + 1, insertCard)
                    else
                        if moved == 2 then
                            --插入的在打出去的右边
                            for i=1, #self.paiList_self, 1 do
                                local cardid = self.paiList_self[i]:getTag()
                                if cardid ~= 20 and insertCard:getTag() >= cardid then
                                    table.insert(self.paiList_self, i, insertCard)
                                    break
                                end
                            end
                        elseif moved == 1 then
                            --插入的在打出去的左边
                            for i=#self.paiList_self, 1, -1 do
                                local cardid = self.paiList_self[i]:getTag()
                                if cardid ~= 20 and insertCard:getTag() <= cardid then
                                    table.insert(self.paiList_self, i+1, insertCard)
                                    break
                                end
                            end
                        end
                    end

                    ChuPaiFinish()
                end)
            )
            insertCard:runAction(seq)

            removeChuPai()
        else
            removeChuPai()
            ChuPaiFinish()
        end
    else
        removeChuPai()
        ChuPaiFinish()
    end
end

--自摸或者听牌显示
function MaJiangScene:mingPai(type)
    --1 明对方（双方听牌）  2 明双方（自摸）
    if type == 2 then
        for k,v in pairs(self.ly_self:getChildren()) do
            v:setScale(1.7)
            v:setSpriteFrame("hzb_ud_".. v:getTag() ..".png")
        end
        
        dump(self.mingPaiList, "对方明牌")
        for k,v in pairs(self.ly_duishou:getChildren()) do
            print(k, self.mingPaiList[k] )
            if self.mingPaiList[k] == nil then
                v:removeFromParent()
                return
            end
            local pai_id = helper.getPaiByIndex(self.mingPaiList[k]) 
            if not pai_id or pai_id == 0 then 
                pai_id = 1
            end
            v:setScale(1.4)
            v:setSpriteFrame("hzb_ud_"..pai_id..".png")
        end
    else
        for k,v in pairs(self.ly_self:getChildren()) do
            v:setScale(1.7)
            v:setSpriteFrame("hzb_ud_".. v:getTag() ..".png")
        end
    end
end

function MaJiangScene:moPai()
    self.ly_add_state:setVisible(false)
    if self.paiList[1] == nil then
        return
    end
    self:getPai(true, self.paiList[1])
    table.remove(self.paiList,1)
end

function MaJiangScene:moPaiDs()
    self.ly_add_state:setVisible(false)
    self:getPai(false, 1)
end

function MaJiangScene:show_add_state_by_type(type)
    self.ly_add_state:setVisible(true)
     
    self._children["btn_state_pong"]:setVisible(false)
    self._children["btn_state_pang"]:setVisible(false)
    self._children["btn_state_hu"]:setVisible(false)
    self._children["btn_state_guo"]:setVisible(true)

    if cc.MEFileUtil:IsValidRight(type, 0x08) then
        --碰    
        self._children["btn_state_pong"]:setVisible(true)
    end

    if cc.MEFileUtil:IsValidRight(type, 0x10) then
        --杠
        self._children["btn_state_pang"]:setVisible(true)
    end

    if cc.MEFileUtil:IsValidRight(type, 0x40) then
        --胡
        self._children["btn_state_hu"]:setVisible(true)
    end
end

function MaJiangScene:addState(type,cardId)
    self.ly_add_state:setVisible(false)
    if type == 1  then
        --碰
        local count = 0
        for k,p in pairs(self.paiList_self) do
            if p:getTag() == cardId then
                count = count + 1
                if count >= 2 then
                    --开始碰牌
                    local list = {}
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    self:addStateByPai(type,list,true)
                    break
                end
            end
        end
    elseif type == 2 then--zi gang
        local count = 0
        for k,p in pairs(self.paiList_self) do
            if p:getTag() == cardId then
                count = count + 1
                if count >= 2 then
                    --开始杠牌
                    local list = {}
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    self:addStateByPai(type,list,true)
                    break
                end
            end
        end
    elseif type == 4 then -- 杠人 gang
        local count = 0
        for k,p in pairs(self.paiList_self) do
             if p:getTag() == cardId then
                count = count + 1
                if count >= 2 then
                    local list = {}
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    table.insert(list,cardId)
                    self:addStateByPai(type,list,true)
                    break
                end
            end
        end
    elseif type == 5 then -- 明杠 gang
        local list = {}
        table.insert(list,cardId)
        self:addStateByPai(type,list,true)
    end
end

function MaJiangScene:addStateByPai(type,list,isSelf)
    --1 碰 2暗框 3 吃 4 三杠一 5 明杠
    local delCount = 0
    if isSelf then
        print("添加自己状态##################################", type)
        if type == 1 or type == 3 or type == 4 then
            print("开始删除牌0000000000000000000000000", list[1], type)
            delCount = 2
            if type == 4 then 
                delCount = 3 
            end

            local curIndex = 0 
            for k,p in pairs(list) do
                if curIndex <=2 then
                    local count = self.ly_self_state:getChildrenCount()
                    local bg_pai = DDMaJiang.new(true,1,p)
                    bg_pai:setCurState(type)
                    bg_pai:setScale(0.8)

                    local s = bg_pai:getContentSize()
                    if (curIndex == 1 and type == 4) then
                        local bg_pai2 = DDMaJiang.new(true,1,p)
                        bg_pai2:setName("centerCard")
                        bg_pai2:setPosition(s.width/2, s.height/2+ 10)
                        bg_pai:addChild(bg_pai2,10)
                    end
                    bg_pai:setPosition(count*s.width* bg_pai:getScale() + self.nStateSelfDist, s.height/2* bg_pai:getScale())
                    self.ly_self_state:addChild(bg_pai)
                end
                curIndex = curIndex + 1
            end
            self.nStateSelfDist = self.nStateSelfDist + 30
        elseif type == 2 then
            print("开始删除暗杠牌111111111111111111111111111",list[1], type)
            for _,d in pairs(self.ly_self:getChildren()) do
                if (d:getTag() == list[1]) then
                    delCount = delCount + 1 
                end
            end

            local curIndex = 0 
            for k,p in pairs(list) do
                if curIndex <=2 then
                    local count = self.ly_self_state:getChildrenCount()
                    local bg_pai = DDMaJiang.new(true,2,p)
                    bg_pai:setCurState(type)
                    bg_pai:setScale(0.8)

                    local s = bg_pai:getContentSize()
                    if curIndex == 1 then
                        local bg_pai2 = DDMaJiang.new(true,1,p)
                        bg_pai2:setName("centerCard")
                        bg_pai2:setPosition(s.width/2, s.height/2+ 10)
                        bg_pai:addChild(bg_pai2,10)
                    end

                    bg_pai:setPosition(count*s.width* bg_pai:getScale() + self.nStateSelfDist, s.height/2* bg_pai:getScale())
                    self.ly_self_state:addChild(bg_pai)
                end
                curIndex = curIndex + 1
            end
            self.nStateSelfDist = self.nStateSelfDist + 30
        elseif type == 5 then
            print("开始删除明杠牌2222222222222222222222222",list[1], type)
            for _,d in pairs(self.ly_self:getChildren()) do
                if (d:getTag() == list[1]) then
                    delCount = delCount + 1 
                end
            end
            local index = 0
            for _,d in pairs(self.ly_self_state:getChildren()) do
                if d:getTag() == list[1] then
                    d:setCurState(type)
                    if index == 1 then
                        local bg_pai2 = DDMaJiang.new(true,1,list[1])
                        bg_pai2:setName("centerCard")
                        bg_pai2:setPosition(d:getContentSize().width/2, d:getContentSize().height/2+10)
                        d:addChild(bg_pai2,10)
                    end
                    index = index + 1
                end
            end
        end
        --排序
        self:reorderpai(list[1], delCount)
        if type == 4 then
            self:moPai()
        end
    else
        print("添加对方状态##################################", type)
        --1 碰 2暗杠 3 吃 4 三杠一 5 明杠
        if type == 1 or type == 3 or type ==4 then
            if type == 1 then 
                delCount = 2 
                self.ds_state_pai_count = self.ds_state_pai_count + 2
            end
            if type == 4 then 
                delCount = 3 
                self.ds_state_pai_count = self.ds_state_pai_count + 3
            end

            local curIndex = 0 
            local x = self.ly_duishou_state:getPositionX()
            for k,p in pairs(list) do
                if curIndex >= 3 then
                    break
                end
                local count = self.ly_duishou_state:getChildrenCount()
                local bg_pai = DDMaJiang.new(false,1,p)
                bg_pai:setScale(1.3)
                bg_pai:setCurState(type)

                local s = bg_pai:getContentSize()
                if curIndex == 1 and type == 4 then
                    local bg_pai2 = DDMaJiang.new(false,1,p)
                    bg_pai2:setName("centerCard")
                    bg_pai2:setPosition(s.width/2, s.height/2+10)
                    bg_pai:addChild(bg_pai2)
                end
                
                bg_pai:setPosition(x - (count*(s.width-10)* bg_pai:getScale() + self.nStateTargetDist), s.height/2* bg_pai:getScale())
                self.ly_duishou_state:addChild(bg_pai)
                curIndex = curIndex + 1
            end
            self.nStateTargetDist = self.nStateTargetDist + 30
        elseif type == 2 then
            self.ds_state_pai_count = self.ds_state_pai_count + 4
            delCount = 4

            local index = 0
            local x = self.ly_duishou_state:getPositionX()
            for k,p in pairs(list) do
                if index >= 3 then
                    break
                end
                local count = self.ly_duishou_state:getChildrenCount()
                local bg_pai = DDMaJiang.new(false,2,p)
                bg_pai:setScale(1.3)
                bg_pai:setCurState(type)

                local s = bg_pai:getContentSize()
                if index == 1 then
                    local bg_pai2 = DDMaJiang.new(false,1,p)
                    bg_pai2:setName("centerCard")
                    bg_pai2:setPosition(s.width/2, s.height/2+10)
                    bg_pai:addChild(bg_pai2)
                end

                bg_pai:setPosition(x - (count*(s.width-10)* bg_pai:getScale() + self.nStateTargetDist), s.height/2* bg_pai:getScale())
                self.ly_duishou_state:addChild(bg_pai)
                index = index + 1
            end
            self.nStateTargetDist = self.nStateTargetDist + 30
        elseif type == 5 then
            self.ds_state_pai_count = self.ds_state_pai_count + 1
            delCount = 1
           
            local index = 0
            for _,d in pairs(self.ly_duishou_state:getChildren()) do
                if d:getTag() == list[1] then
                    d:setCurState(type)
                    if index == 1 then
                        local bg_pai2 = DDMaJiang.new(false,1,list[1])
                        bg_pai2:setName("centerCard")
                        bg_pai2:setPosition(d:getContentSize().width/2, d:getContentSize().height/2+10)
                        d:addChild(bg_pai2,10)
                    end
                    index = index + 1
                end
            end
        end

        for _,d in pairs(self.ly_duishou:getChildren()) do
            d:removeFromParent()
            delCount = delCount - 1
            if delCount == 0 then
                break
            end
        end
        for k,v in pairs(self.ly_duishou:getChildren()) do
            v:setIndex(k)
            v:setPosition(cc.p(self.targetCardPosList[k], v:getContentSize().height/2* v:getScale() ))
        end
    end
end

function MaJiangScene:setCursor(isSelf)
    -- body
    self._children["timePanel"]:setVisible(true)
    if isSelf then
        self.timeArmature:getAnimation():play("Target")
    else
        self.timeArmature:getAnimation():play("Self")
    end
end

function MaJiangScene:userAutoChuPai()
    -- body
    print("MaJiangScene:userAutoChuPai()..........................")
    if not self.isInitPaiFinish then
        print("MaJiangScene:userAutoChuPai() 牌还没初始化完毕！！", self.isInitPaiFinish)
        return
    end
    if self.cur_trustee_state ~= 1 then
        print("MaJiangScene:userAutoChuPai() 当前不是用户托管模式！！", self.cur_trustee_state)
        return
    end
    if not self.aleart_pai then
        print("MaJiangScene:userAutoChuPai() 当前不是用户出牌！！", self.aleart_pai)
        return
    end
    if self.curPaiId == 20 or self.curPaiId == -1 then
        for i=1, #self.paiList_self, 1 do
            local card = self.paiList_self[i]
            if card:getTag() ~= 20 then
                self.curPaiId = card:getTag()
                self.curMaJiang = card
                break
            end
        end
    else
        self.curMaJiang = self.paiList_self[1]
    end

    local action = cc.Sequence:create(
        cc.DelayTime:create(2),
        cc.CallFunc:create(function()
            if self.cur_trustee_state == 1 then
                print("MaJiangScene:userAutoChuPai() finish..........................")
                self:chuPai(false, true)
            end
        end)
    )
    self:runAction(action)
end

function MaJiangScene:GameChuPai(data)
    dump(data, "出牌命令")
    self.curPaiId = helper.getPaiByIndex(data.outCardData)
    if data.isSelf then
        for k,v in pairs(self.ly_self:getChildren()) do
            if v:getTag() == self.curPaiId then
                self.curMaJiang = v
                break
            end
        end
    end
    self:setCursor(data.isSelf)
    self:chuPai(true, data.isSelf)
end

function MaJiangScene:GameChuPaiTimeOut()
    self.nChuPaiTimeOutCnts = self.nChuPaiTimeOutCnts + 1
   
    if self.curPaiId == 20 or self.curPaiId == -1 then
        for i=1, #self.paiList_self, 1 do
            local card = self.paiList_self[i]
            if card:getTag() ~= 20 then
                self.curPaiId = card:getTag()
                self.curMaJiang = card
                break
            end
        end
    else
        self.curMaJiang = self.paiList_self[1]
    end
    print("MaJiangScene:GameChuPaiTimeOut() finish..........................")
    self:chuPai(false, true)

    --强制为用户托管
    if self.nChuPaiTimeOutCnts >= 3 then
        self.nChuPaiTimeOutCnts = 0
        --if not cc.MENetUtil:isCustomServer() then
            cc.MENetUtil:setTrustee(true)
        --end
    end
end

function MaJiangScene:GameSendPai(data)
    dump(data, "发送扑克")
    self.curPaiCount = self.curPaiCount - 1
    self:updatePaiCount()

    if data.isSelf then
        self.isMoPai = true
        self.curPaiId = helper.getPaiByIndex(data.cardData)
        print("插入牌数据",data.cardData, self.curPaiId, self.paiList)
        table.insert(self.paiList, self.curPaiId)
        self:moPai()
        print("可以出牌了，最后一张牌：===============================", self.curPaiId)
        if self.cur_trustee_state > 0 then
            self.aleart_pai = true
            --是否用户托管
            self:userAutoChuPai()
        else
            if data.actionMask ~= 0x00 then
                --检测是否有杠
                if cc.MEFileUtil:IsValidRight(data.actionMask, 0x10) then
                    self.isPongIng = false
                    if data.cbGangCardData ~= 0xff and data.cbGangCardData ~= data.cardData then
                        self.actionCard = helper.getPaiByIndex(data.cbGangCardData)
                        for i=1,#self.pongList do
                            if self.actionCard == self.pongList[i] then
                                self.isPongIng = true
                                break
                            end
                        end
                    elseif data.cbGangCardData ~= 0xff and data.cbGangCardData == data.cardData then
                        --检测暗杠
                        self.actionCard = helper.getPaiByIndex(data.cbGangCardData)
                        for i=1,#self.pongList do
                            if self.actionCard == self.pongList[i] then
                                self.isPongIng = true
                                break
                            end
                        end
                    end
                    print("检测到杠牌============================", self.actionCard)
                end
                self:show_add_state_by_type(data.actionMask)
            end
        end
    else
        dump(data,"不是当前用户牌数据")
        self:moPaiDs()
    end
end

function MaJiangScene:GameOperateNotify(data)
    dump(data, "操作提示")
    if data.isSelf then
        print("操作提示代码", data.actionMask,data.actionCard)
        self.curPaiId = helper.getPaiByIndex(data.actionCard)
        self.actionCard = helper.getPaiByIndex(data.actionCard)

        if self.cur_trustee_state > 0 then
            if not self.aleart_pai then
                cc.MENetUtil:operatePai(0, 0)
                self:moPai()
            end
        else
            self:show_add_state_by_type(data.actionMask)
        end
    else
        dump(data,"不是当前用户牌数据" )
        if data.actionMask == 0x40 then
            self:show_add_state_by_type(0x40)
        end
    end
end

function MaJiangScene:GameOperateNotifyTimeOut()
    if not self.aleart_pai then
        cc.MENetUtil:operatePai(0, 0)
        self:moPai()
    end
end

function MaJiangScene:GameOperateResult(data)
    dump(data, "操作命令结果")
    local id = helper.getPaiByIndex(data.cbOperateCard[1])
    self.ly_add_state:setVisible(false)
    if data.isSelf then
        print("操作命令结果GameOperateResult", id)
        if data.cbOperateCode == 0x08 then
            table.insert(self.pongList, id)
            self.aleart_pai = true
            self.isPong = true
            self:addState(1, id)
            self:pengPaiEffect(true, id)

            self:updateOutCard(false, id)
        elseif data.cbOperateCode == 0x10 then
            self.isPong = true
            local nType
            if self.aleart_pai then
                if not self.isPongIng then
                    self:addState(2,id)
                    print("暗杠的类型 2")
                    table.insert(self.pongList,id)
                    nType = 2
                else
                    self:addState(5,id)
                    print("明杠的类型 5")
                    nType = 5
                end
            else
                self:addState(4,id)
                print("三杠一的类型 4")
                table.insert(self.pongList,id)
                nType = 4
            end
            self.aleart_pai = true
            print("可以出牌了46666666666666666666666666666")
            self:gangPaiEffect(true, nType, id)

            self:updateOutCard(false, id)
        end
    else
        dump(data,"不是当前用户牌操作命令数据 ")

        if data.cbOperateCode == 0x08 then
            --碰
            self:addStateByPai(1,{id, id, id},false)
            table.insert(self.pongList_ds, id)

            self:playTargetEffect("gang")
            self:pengPaiEffect(false, id)
            self:updateOutCard(true, id)
        elseif data.cbOperateCode == 0x10 then
            --杠
            local curType
            if data.wOperateUser == data.wProvideUser then
                --检查是否是明暗  
                curType = 2
                for i,v in ipairs(self.pongList_ds) do
                    if id == v then
                        curType = 5
                        break
                    end
                end
            else
                --检查是否是 放杠
                curType = 4
            end

            local list = {}
            table.insert(list,id)
            table.insert(list,id)
            table.insert(list,id)
            table.insert(list,id)
            table.insert(self.pongList_ds, id)
            self:addStateByPai(curType, list, false)

            self:playTargetEffect("gang")
            self:gangPaiEffect(false, curType, id)
            if curType == 4 then
                self:updateOutCard(true, id)
            end
        end
    end
end

function MaJiangScene:GameQianGangCard(data)
    -- body
    dump(data, "抢杠删除")
    local id = helper.getPaiByIndex(data.cbHuCard)
    if data.wProvideUser == cc.MENetUtil:getChairID() then
        for _,d in pairs(self.ly_self_state:getChildren()) do
            if d:getTag() == id then
                d:setCurState(1)
                local centerCard = d:getChildByName("centerCard")
                if centerCard ~= nil then
                    centerCard:removeFromParent()
                end
            end
        end
    else
        for _,d in pairs(self.ly_duishou_state:getChildren()) do
            if d:getTag() == id then
                d:setCurState(1)
                local centerCard = d:getChildByName("centerCard")
                if centerCard ~= nil then
                    centerCard:removeFromParent()
                end
            end
        end
    end
end

function MaJiangScene:GameCustomTable(data)
    -- body
    dump(data, "游戏自定义桌子更新")
    self.customCreateUser = data.dwCreateUser
    local nChairID = cc.MENetUtil:getChairID()
    if nChairID == 0 then
        self.lab_self_gold:setString(data.lChairScore[1] )
        self.lab_ds_gold:setString(data.lChairScore[2] )
    else
        self.lab_self_gold:setString(data.lChairScore[2] )
        self.lab_ds_gold:setString(data.lChairScore[1] )
    end
    self.remainJuShuCount = data.cbMaxRound - data.cbCurRound - 1
    self.maxJuShuCount = data.cbMaxRound
    self.curJuShuCount = data.cbCurRound + 1

    if not self.isDoing then
        self._children["btn_room_jiesan"]:setVisible(true)
        self._children["btn_auto_send"]:setVisible(false)
    else
        self._children["btn_room_jiesan"]:setVisible(false)
        self._children["btn_auto_send"]:setVisible(true)
        self._children["lab_doubleNum"]:setString("局数:".. self.curJuShuCount .. "/" ..self.maxJuShuCount)
    end
end

function MaJiangScene:GameOver(data)
    dump(data, "游戏结算")
    local score_data = {}
    score_data.huType = {}
    score_data.name = {}
    score_data.playerCount = 2

    local nChairID = cc.MENetUtil:getChairID() 
    self.mingPaiList = {}
    local pai_index = 1
    if nChairID == 0 then
        pai_index = 2
        score_data.name[1] = cc.MENetUtil:getNickName()
        score_data.name[2] = self.lab_ds_name:getString()
    else
        score_data.name[2] = cc.MENetUtil:getNickName()
        score_data.name[1] = self.lab_ds_name:getString()
    end

    print("我的座位", nChairID, "pai_index", pai_index)
    self.mingPaiList = data.cbCardData[pai_index]
    self:mingPai(2)

    --是否对方逃跑
    score_data.wLeftUser = data.wLeftUser
    score_data.isWin = false
    --此游戏胡牌有2种：自摸、抢杠胡
    --1、自摸：胡牌总值-8
    --2、抢杠胡：胡牌总值
    
    local t = {}
    for i=1, 2 do
        --自摸
        if i == data.wProvideUser and data.dwChiHuKind[i] > 0 then
            t[i] = "自摸"
        end
        --胡牌
        if i ~= data.wProvideUser and data.dwChiHuKind[i] > 0 then
            t[i] = "胡牌"
        end
        --点炮
        if i == data.wProvideUser and data.dwChiHuKind[i] <= 0 then
            t[i] = "点炮"
        end
    end
    score_data.result = t
    print("修正前胡牌总值 ==================================", data.dwChiHuRight, t)

    local bQianGangHuStatus = false
    for k,v in pairs(t) do
        if k-1 == nChairID then
            --自己
            if v == "自摸" then
                score_data.isWin = true
            elseif v == "胡牌" then
                score_data.isWin  = true
                bQianGangHuStatus = true
            elseif v == "点炮" then
                bQianGangHuStatus = true
            end
        else
            --对方
            if v == "自摸" then
                score_data.isWin = false
            elseif v == "胡牌" then
                score_data.isWin  = false
                bQianGangHuStatus = true
            elseif v == "点炮" then
                score_data.isWin  = true
                bQianGangHuStatus = true
            end
        end
    end

    local isHasHu = false
    for k,v in pairs(data.dwChiHuRight) do
        if v > 0 then
            isHasHu = true
            break
        end
    end
    if not isHasHu then
        --检测是否对方逃跑
        if (nChairID == 0 and data.wLeftUser == 1) or (nChairID == 1 and data.wLeftUser == 0) then
            score_data.isWin = true
            score_data.isTargetLeft = true
        end
        --检测是否对方认输
        if nChairID ~= data.wProvideUser and data.wProvideUser ~= 65535 then
            score_data.isTargetLeft = true
        end
    else
        self.isFlowGame = false
    end

    if not bQianGangHuStatus then
        for k,v in pairs(data.dwChiHuRight) do
            if v > 0 then
                data.dwChiHuRight[k] = data.dwChiHuRight[k] - 8
            end
        end
    end
    print("修正后胡牌总值 ==================================", data.dwChiHuRight)
    print("我的结果是 ==================================", score_data.isWin)

    local data_type = helper.getHuPaiType()
    local result_data ={}
    for i,v in ipairs(data_type) do
        for j=1,2 do
            if data.dwChiHuRight[j] > 0 then
                print(data.dwChiHuRight[j], string.format("%x",data.dwChiHuRight[j]) )
                local result = cc.MEFileUtil:IsValidRight(data.dwChiHuRight[j],v)
                if result then
                    table.insert(result_data,{index = i,result = result})
                    print("dwChiHuRight结果",i,result)
                end
            end
        end
    end
    print("result_data = ", result_data)
    for k,v in pairs(result_data) do
        table.insert(score_data.huType, helper.getHuPaiName(v.index) )
    end
    score_data.lGangScore = data.lGangScore
    score_data.lGameScore = data.lGameScore
    
    score_data.paiList = {}
    for i=1,2 do
        if data.dwChiHuRight[i] > 0 then
            score_data.paiList = data.cbCardData[i]
        end
    end
   
    self._children["lab_pai_count"]:setString("")
    local bShowCustomResult = false
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_auto_send"]:setVisible(false)
        self._children["lab_doubleNum"]:setString("局数:".. self.curJuShuCount .. "/" ..self.maxJuShuCount)

        if self.remainJuShuCount < 0 then
            bShowCustomResult = true
        end

        self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    else
        self._children["lab_doubleNum"]:setString("底注:".. self.score)
        self._children["btn_auto_send"]:setVisible(true)
        self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    end
    if self.cur_trustee_state ~= 0 then
        cc.MENetUtil:setTrustee(false)
    end
    score_data["bShowCustomResult"] = bShowCustomResult
    self:setGameResult(score_data)
end

function MaJiangScene:GameCustomResult(data)
    dump(data, "房卡结算")
    self.customRoomData = clone(data)
    local nTargetChair = 0
    if cc.MENetUtil:getChairID() == 0 then
        nTargetChair = 1
    end
    self.customRoomData["targetType"] = cc.MENetUtil:getUserTypeByChair(nTargetChair)
    self.customRoomData["targetUrl"] = cc.MENetUtil:getUserIconUrlByChair(nTargetChair)
end

function MaJiangScene:GameDismissVoteNotify(data)
    dump(data, "解散房间通知")
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_room_jiesan"]:setVisible(false)
        if app:isOpenDialog("MaJiangJieSanLayer") then
            EventDispatcher:dispatchEvent(EventMsgDefine.DismissVoteNotify, data)
        else
            local params = {}
            params["nType"] = 1
            params["dwRequesterID"] = data.dwRequesterID
            local nTargetChair = cc.MENetUtil:getChairID()
            params["nChairID"] = nTargetChair
            params["nickName"] = cc.MENetUtil:getNickName()
            params["cbStatus"] = data.cbStatus[nTargetChair+1]
            app:openDialog("MaJiangJieSanLayer", params)
        end
    end
end

function MaJiangScene:GameDismissVoteResult(data)
    dump(data, "解散房间结果")
    if data.cbResult == 0 then
        MaJiangController:dismisCustomServer(false)
        MaJiangController:backGame()
    end
    app:closeDialog("MaJiangJieSanLayer")
    cc.MENetUtil:setEnableGameClock(true)
    
    self:showTips(data.szDescribe)
end

--显示游戏结束
function MaJiangScene:setGameResult(data)
    -- body
    self._children["timePanel"]:setVisible(false)
    self:clearDsSmale()
    print("self.isFlowGame ==================== ", self.isFlowGame)
    if self.isFlowGame then
        local imgFlow = display.newSprite("#liuju.png")
        self._children["panel"]:addChild(imgFlow, 2)
        imgFlow:setPosition(display.center)

        local action = cc.Sequence:create(
            cc.ScaleTo:create(0.05,0),
            cc.ScaleTo:create(0.5, 1.5),
            cc.ScaleTo:create(0.5,1),
            cc.FadeOut:create(2),
            cc.CallFunc:create(function()
                imgFlow:removeFromParent()
                self:ResetGame()
                if data.bShowCustomResult then
                    EventDispatcher:dispatchEvent(EventMsgDefine.GameShowCustomResult)
                end
            end)
        )
        imgFlow:runAction(action)
        return
    end

    local str_hu, strMaxFanShuName = self:getGameHuPaiResult(data)
    local sound = helper.getHuPaiSound(strMaxFanShuName)
    if data.isTargetLeft then
        sound = nil
        str_hu = "胡牌类型："
    end

    local params = clone(data)
    params["str_hu"] = str_hu
    params["state_list"] = self:getStatePai(data.isWin)
    dump(params)

    if data.isWin then
        if not data.isTargetLeft then
            if sound ~= nil then
                local path
                if self.selfSex == 1 then
                    path = "sound/man/".. sound
                else
                    path = "sound/woman/".. sound
                end
                MEAudioUtils.playSoundEffect(path)
            end
            self:runAction(cc.MEShake:create(0.6, 10))
            self:huPaiEffect(true, function ( ... )
                -- body
                app:openDialog("MaJiangResultLayer", params)
            end)
        else
            app:openDialog("MaJiangResultLayer", params)
        end
    else
        if sound ~= nil then
            local path
            if self.targetSex == 1 then
                path = "sound/man/".. sound
            else
                path = "sound/woman/".. sound
            end
            MEAudioUtils.playSoundEffect(path)
        end
        app:openDialog("MaJiangResultLayer", params)
    end
end


function MaJiangScene:getGameHuPaiResult(data)
    -- body
    local str_hu = "胡牌类型:"
    local strMaxFanShuName 
    for k,v in pairs(data.huType) do
        if v ~= "无宝牌" then
            str_hu = str_hu .. v .."  "
            if v ~= "" then
                if strMaxFanShuName == nil then
                    strMaxFanShuName = v 
                else
                    local n1 = helper.getHuPaiFanShu(strMaxFanShuName)
                    local n2 = helper.getHuPaiFanShu(v)
                    if n2 > n1 then
                        strMaxFanShuName = v
                    end
                end
            end
        end
    end
    print("str_hu , strMaxFanShuName = ===================================", str_hu, strMaxFanShuName)
    return str_hu, strMaxFanShuName
end

function MaJiangScene:getStatePai(isWin)
    -- body
    --1 碰 2暗杠 3 吃 4 三杠一 5 明杠
    local t1 = {}
    local t2 = {}
    local t3 = {}
    local node
    if isWin then
        node = self.ly_self_state
    else
        node = self.ly_duishou_state
    end 

    for _,d in pairs(node:getChildren()) do
        local type = d:getCurState()
        if type == 1 then
            t1[d:getTag()] = d:getTag()
        elseif type == 2 then
            t2[d:getTag()] = d:getTag()
        elseif type == 4 or  type == 5 then
            t3[d:getTag()] = d:getTag()
        end
    end
    local data = {}
    data["peng"]        = t1
    data["an_gang"]     = t2
    data["ming_gang"]   = t3
    print("MaJiangScene:getStatePai()...................", data)
    return data
end

return MaJiangScene