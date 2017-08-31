
local FourMJScene = class("FourMJScene", cc.load("mvc").SceneBase)
local DDMaJiang = require("app.views.fourxz.DDMaJiang")
local MaJiangController = require("app.views.fourxz.MaJiangController")
FourMJScene.RESOURCE_FILENAME = "game_fourmj/fourmj_scene.csb"
local helper  = require("app.views.fourxz.helper")

function FourMJScene:onCreate(params)
    print("FourMJScene:onCreate(params) .............................", params)
    self:initData()
    --处理逻辑
    MaJiangController:init(self, params)

    self:addEventListener(EventMsgDefine.APP_ENTERBACKGROUND,self.GameEnterBackground,self)
    self:addEventListener(EventMsgDefine.APP_ENTERFOREGROUND,self.GameEnterForeground,self)

    self.isFirstShowTips = true
    self.selfCardPosList = {}
    self.targetCardPosList = {}
    self.roomUsers = {}
    self.score = 1
    self.remainJuShuCount = 0
    self.maxJuShuCount = 0
    self.curJuShuCount = 0
    self.isStart = false
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

function FourMJScene:initData()
    -- body
    self.isChangeFinish = true
    self.isSelectFinish = false
    self.nChuPaiTimeOutCnts = 0
    self.nStateSelfDist = 0
    self.aleart_pai = false
    self.curMaJiang = nil
    self.curPaiId = -1
    self.actionCard = -1
    self.lastPaiId = -1
    self.isMoPai = true
    self.paiList = {}
    self.paiList_self = {}
    self.changePaiList = {}
    self.mingPaiList = {}
    self.isPong = false
    self.pongList = {}
    self.isPongIng = false
    self.curPaiCount = 108
    self.chuSpeed = 1.0
    self.cur_trustee_state = 0 -- 0无托管 1用户托管 2系统托管
    self.isInitPaiFinish = false
    self.isReady = false
    self.isDoing = false
    self.isCheat = false
    self.selectType = 0
    self.isUpdateSelect = false
    self.selfOutCardList = {}
    self.lastOutUser = -1
    self.selfSex = cc.MENetUtil:getSex()
    self._children["timePanel"]:setVisible(false)
    self._children["btn_ready"]:setVisible(false)
    self._children["lab_time_self"]:setString("")
    self:updatePaiCount()
    for i=1,4 do
        self._children["ly_result".. i]:setVisible(false)
    end
end

function FourMJScene:initUI()
    self._children["ImgNoticeBg"]:setVisible(false)
    self._children["lab_RoomID"]:setString("")
    self._children["ly_tipsMsg"]:setVisible(false)
    self._children["lab_doubleNum"]:setString("")
    self._children["lab_pai_count"]:setString("")
    self._children["lobbyback_1"]:loadTexture("res/game_fourmj/sparrow_bg.png")
    self.lab_self_info_name = self._children["lab_self_info_name"]
    self.lab_self_info_name:setString(cc.MENetUtil:getNickName() )
    self.lab_self_gold = self._children["lab_self_gold"]
    if not cc.MENetUtil:isCustomServer() then
        self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    end
    local url = cc.MENetUtil:getUserIconUrl()
    if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
        local faceId = cc.MENetUtil:getFaceID()%20 + 1
        self._children["head4"]:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
    else
        --下载头像
        print("url = ", url)
        local customid = Helper:md5sum(url)
        local filename = Helper:getFileNameByUrl(url, customid)
        print(filename)
        self._children["head4"]:loadTexture(filename)
    end
    self._children["head4"]:getChildByName("imgZhuang"):setVisible(false)
    self._children["head4"]:getChildByName("imgType"):setVisible(false)
    self._children["head4"]:getChildByName("imgReady"):setVisible(false)
    self._children["head4"]:getChildByName("labWinOrder"):setVisible(false)
   

    self.ly_self = self._children["ly_self"]
    self.ly_self_out = self._children["ly_self_out"]
    self.ly_self_state = self._children["ly_self_state"]

    self.ly_add_state = self._children["ly_add_state"]
    self.ly_add_state:setVisible(false)
    
    self.ly_select_state = self._children["ly_select_state"]
    self.ly_select_state:setVisible(false)
    self._children["ImgChangeCard"]:setVisible(false)

    for i=1,3 do
        local head = self._children["head" .. i]
        head:setVisible(false)
    end
    for i=1,4 do
        self._children["timePanel"]:getChildByName("img_arrow_" .. i):setVisible(false)
        self._children["lab_chat" .. i]:setString("")
    end
    for i=1,14 do
        local midX = 0
        if i == 14 then
            midX = 15
        end
        local x = me.winSize.width/2 + (i - 7)*116* 0.9 + midX
        table.insert(self.selfCardPosList, 1, x )
    end
    dump(self.selfCardPosList, "己方牌位置")

    self.targetCardPosList[2] = {}
    for i=14, 1, -1 do
        local midX = 0
        if i == 1 then
            midX = -10
        end
        local x = me.winSize.width/2 + (i - 7.5)*120* 0.55 + midX - 80
        local y = 168*0.55
        table.insert(self.targetCardPosList[2], 1, cc.p(x,y) )
    end
    dump(self.targetCardPosList[2], "对方2牌位置")

    self.targetCardPosList[1] = {}
    for i=14, 1, -1 do
        local midY = 0
        if i == 1 then
            midY = -10
        end
        local x = 50
        local y = me.winSize.height/2 + (i - 7)*(116/2* 0.95 - 30) + midY + 20
        table.insert(self.targetCardPosList[1], 1, cc.p(x,y) )
    end
    dump(self.targetCardPosList[1], "对方1牌位置")
    
    self.targetCardPosList[3] = {}
    for i=1, 14 do
        local midY = 0
        if i == 14 then
            midY = 10
        end
        local x = 50
        local y = me.winSize.height/2 + (i - 7)*(116/2* 0.95 - 30) + midY + 100
        
        table.insert(self.targetCardPosList[3], 1, cc.p(x,y) )
    end
    dump(self.targetCardPosList[3], "对方3牌位置")

    self:setTargetUIChair()
end

function FourMJScene:ShowNoticeMsg( msg )
    -- body
    print("FourMJScene:ShowNoticeMsg( msg )", msg)
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

function FourMJScene:setTargetUIChair()
    -- body
    self.tUIChairList = {}
    local nChairID = cc.MENetUtil:getChairID()
    if nChairID == 0 then
        self.tUIChairList[1] = 1
        self.tUIChairList[2] = 2
        self.tUIChairList[3] = 3
        self.tUIChairList[4] = 0
    elseif nChairID == 1 then
        self.tUIChairList[1] = 2
        self.tUIChairList[2] = 3
        self.tUIChairList[3] = 0
        self.tUIChairList[4] = 1
    elseif nChairID == 2 then
        self.tUIChairList[1] = 3
        self.tUIChairList[2] = 0
        self.tUIChairList[3] = 1
        self.tUIChairList[4] = 2
    elseif nChairID == 3 then
        self.tUIChairList[1] = 0
        self.tUIChairList[2] = 1
        self.tUIChairList[3] = 2
        self.tUIChairList[4] = 3
    end
end

function FourMJScene:getTargetUIChair( nChairID )
    -- body
    for k,v in pairs(self.tUIChairList) do
        if v == nChairID then
            return k
        end
    end
    return nil
end

function FourMJScene:onEnterTransitionFinish()
    print("FourMJScene:onEnterTransitionFinish() ...................................")
    audio.playMusic("soundfmj/bg.mp3",true) 
    self:registerDialogMessageListener()
    MaJiangController:initEvent()
    cc.MENetUtil:enterGame()

    for i=1,6 do
        display.loadImage("res/game_fourmj/gz" .. i ..".png", function ( ... )
            -- body
        end)
    end
end

function FourMJScene:onEnter()
    print("FourMJScene:onEnter() ..........................................")
end

function FourMJScene:GameEnterBackground()
    -- body
end

function FourMJScene:GameEnterForeground()
    -- body
end

function FourMJScene:clear()
    -- body
    --释放临时资源
    ResLoadControl:instance():ClearTempLoadRes()
end

function FourMJScene:resetMJState(bReset)       
    print("重置选择牌.....................................", bReset)
    if self.curMaJiang ~= nil then
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

function FourMJScene:initTouchListener()
    local function check(pos, obj)
        if not obj:getCanOperate() then
            return false
        end
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
        for k,v in pairs(self.paiList_self) do
            if check(pos, v) then
                return true
            end
        end
        return false
    end

    local function isInChangeMajiang(pos)
        -- body
        for k,v in pairs(self.changePaiList) do
            if check(pos, v) then
                return v
            end
        end
        return nil
    end

    local function onTouchBegan(touch, event)
        print("start click ...............................")
        if self.cur_trustee_state > 0 then
            print("当前处于托管模式，不能操作！")
            return false
        end
        if self.isChangeFinish and not self.isSelectFinish then
            print("还有用户未选择定缺，不能操作！")
            return false
        end
        local target = event:getCurrentTarget()
        local pos = target:convertToNodeSpace(touch:getLocation())
        print("onTouchBegan==================", pos, self.isChangeFinish)
        if isSelect(pos) then
            self.touchBegin = pos
            if not self.isChangeFinish then
                local card = isInChangeMajiang(pos)
                if card ~= nil then
                    --重置
                    local s = card:getContentSize()
                    card:setPositionY(s.height / 2* card:getScale())
                    for k,v in pairs(self.changePaiList) do
                        if v:getIndex() == card:getIndex() and v:getTag() == card:getTag() then
                            table.remove(self.changePaiList, k)
                            break
                        end
                    end
                    self._children["btn_changeCard"]:setTouchEnabled(false)
                    self._children["btn_changeCard"]:setBright(false)
                else
                    if #self.changePaiList >= 3 then
                        self._children["btn_changeCard"]:setTouchEnabled(true)
                        self._children["btn_changeCard"]:setBright(true)
                        return false
                    end
                    for k,v in pairs(self.paiList_self) do
                        if check(pos, v) then
                            print("当前点击的索引 ===============",k, v:getTag())
                            if not self:canChangeCard( v:getTag() ) then
                                self:GameInfoTips("换三张必须选择三张同种花色的牌!")
                            else
                                v:setPositionY(v:getContentSize().height* v:getScale() * 0.9)
                                self.changePaiList[#self.changePaiList + 1] = v
                            end
                            break
                        end
                    end
                    if #self.changePaiList >= 3 then
                        self._children["btn_changeCard"]:setTouchEnabled(true)
                        self._children["btn_changeCard"]:setBright(true)
                    end
                end
                return false
            end

            if self.curMaJiang then
                if check(pos, self.curMaJiang) then
                    print("可以出牌了44444444444444444444444")
                    local ret = self:chuPai(false, cc.MENetUtil:getChairID() )
                    if not ret then
                        -- 重新设置麻将位置
                        self:resetMJState()
                    end
                    return false
                end
                -- 重新设置麻将位置
                self:resetMJState()
            else
                for k,v in pairs(self.paiList_self) do
                    if check(pos, v) then
                        print("当前点击的索引 ===============",k, v:getTag())
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
            local s = self.curMaJiang:getContentSize()
            local deltPos = cc.pSub(pos_move, self.touchBegin) 
            if math.abs(deltPos.x) > 10 or math.abs(deltPos.y) > 10 then
                self.curMaJiang:setPosition(pos_move)
                self.curMaJiang:setIsMove(true)
            end
            local scale = self.curMaJiang:getScale()
            local nY = self.ly_self:getPositionY() + self.ly_self:getContentSize().height
            if pos_move.x <= 0 + s.width/2*scale or 
                pos_move.x >= display.width - s.width/2*scale or 
                pos_move.y >= nY - s.height*scale then
                print("可以出牌了6666666666666666666666666666")
                self:chuPai(false, cc.MENetUtil:getChairID() )
                return
            end

            local y = self._children["ly_battle"]:getPositionY()
            if pos_move.y <= y then
                print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyy", y)
                self.curMaJiang:setPosition(cc.p(self.selfCardPosList[self.curMaJiang:getIndex()], y))
            end 
            if pos_move.y > y + self._children["ly_self_state"]:getContentSize().height then
                self.isReset = true
            elseif self.isReset and (pos_move.y <= y + self._children["ly_self_state"]:getContentSize().height) then
                --重新设置麻将位置
                self.isReset = false
                print("tttttttttttttttttttttttttttt", y)
                self:resetMJState(true)
            end
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local pos_end = target:convertToNodeSpace(touch:getLocation())
        print("onTouchEnded==================", pos_end, self.touchBegin)
        self.isReset = false
        MEAudioUtils.playSoundEffect("soundfmj/touch.mp3")
        local deltPos = cc.pSub(pos_end, self.touchBegin) 
        if self.aleart_pai and self.curMaJiang and (math.abs(deltPos.x) > 10 or math.abs(deltPos.y) > 10) then
            print("可以出牌了5555555555555555555555555")
            self:chuPai(false, cc.MENetUtil:getChairID() )
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

function FourMJScene:initVoiceTouchListener()
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

function FourMJScene:showVoiceEffect( isShow )
    -- body
    print("FourMJScene:showVoiceEffect() ...............", isShow)
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

function FourMJScene:GameVoiceStartPlay(data)
    dump(data, "语音消息")

    local nIdx = self:getTargetUIChair( data.dwSendChairID )
    if nIdx == nil then
        return
    end
    local head = self._children["head" .. nIdx]

    if data.cbChatType == 2 then 
        local ImgPlayVoice = head:getChildByName("ImgPlayVoice")
        ImgPlayVoice:setVisible(true)

        local seq  = cc.Sequence:create(cc.Blink:create(1, 2) )
        local rep = cc.RepeatForever:create(seq)
        local ImgPlayEffect = ImgPlayVoice:getChildByName("ImgPlayEffect")
        ImgPlayEffect:runAction(rep)

        self.nCurVoiceChair = data.dwSendChairID
        cc.MENetUtil:playTalk(data.dwSendChairID, data.url)
    elseif data.cbChatType == 1 then
        if data.dwSendChairID == cc.MENetUtil:getChairID() then
            self.nVoiceTextTick = cc.METimeUtils:clock()
        end
        local labChat = self._children["lab_chat" .. nIdx]
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

function FourMJScene:GameVoicePlayFinish()
    local nIdx = self:getTargetUIChair( self.nCurVoiceChair )
    if nIdx == nil then
        return
    end

    local head = self._children["head" .. nIdx]
    local ImgPlayVoice = head:getChildByName("ImgPlayVoice")
    ImgPlayVoice:setVisible(false)

    local ImgPlayEffect = ImgPlayVoice:getChildByName("ImgPlayEffect")
    ImgPlayEffect:stopAllActions()

    MaJiangController:GameVoiceFinish()
end

function FourMJScene:initListener()

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
    
    self._children["btn_select_wan"]:addClickEventListener(function() 
        self:selectPai(1) 
    end)

    self._children["btn_select_tiao"]:addClickEventListener(function() 
        self:selectPai(2) 
    end)
    self._children["btn_select_tong"]:addClickEventListener(function() 
        self:selectPai(3) 
    end)

    local function setReady()
        self:ready()
    end
    self._children["btn_ready"]:addClickEventListener(setReady)

    local function auto_send_pai(pSender)
        --if not cc.MENetUtil:isCustomServer() then
            cc.MENetUtil:setTrustee(true)
        --end
    end
    self._children["btn_auto_send"]:setVisible(true)
    self._children["btn_auto_send"]:addClickEventListener(auto_send_pai)

    local function cancel_trustee(pSender)
        --if not cc.MENetUtil:isCustomServer() then
            cc.MENetUtil:setTrustee(false)
        --end
    end
    self._children["btn_cancel_trustee"]:setVisible(false)
    self._children["btn_cancel_trustee"]:addClickEventListener(cancel_trustee)
    
    self._children["btn_menu"]:addClickEventListener(function ( ... )
        -- body
        if self._children["menuPanel"]:isVisible() then
            self._children["menuPanel"]:setVisible(false)
        else
            self._children["menuPanel"]:setVisible(true)
        end
    end)

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
    self._children["btn_exit"]:addClickEventListener(setBack)

    self:registerKeyboardListener(function ( ... )
        -- body
        setBack()
    end)

    self._children["btn_setting"]:addClickEventListener(function ( ... )
        -- body
        local bShow = false
        if cc.MENetUtil:isCustomServer() then
            bShow = true
        end 
        app:openDialog("SettingSoundLayer", bShow)
    end)

    self._children["btn_rule"]:addClickEventListener(function ( ... )
        -- body
        app:openDialog("FourXZGameRuleLayer")
    end)

    local function room_jiesan(pSender)
        self:GameJieSuan()
    end
    self._children["btn_room_jiesan"]:addClickEventListener(room_jiesan)

    local function weixin_yaoqing(pSender)
        local strWF = self._children["lab_RoomRule"]:getString()
        local strDesc = "血战麻将|房间号:" .. Helper:stringFormatRoomID(cc.MENetUtil:getCustomRoomID()) .. "  游戏玩法： " .. strWF
        GameLogicManager:WeiXinShareUrl("弈博棋牌",  strDesc, 0)
    end
    self._children["btn_weixin_yaoqing"]:addClickEventListener(weixin_yaoqing)

    local function changeCard(pSender)
        self:changeCard()
    end
    self._children["btn_changeCard"]:addClickEventListener(changeCard)

    self._children["btn_yuyin"]:addClickEventListener(function ( ... )
        -- body
        local nClock = cc.METimeUtils:clock() - self.nVoiceTextTick
        if nClock >= 5 then
            app:openDialog("VoiceChatLayer")
        else
            self:GameInfoTips("说话太过频繁了，请稍后再试!")
        end
    end)
    local function OnRank(pSender)
        app:openDialog("MajiangGameRankLayer", 302)
    end
    self._children["btn_rank"]:addClickEventListener(OnRank)
end

function FourMJScene:GameJieSuan()
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
            params["nType"] = 2
            params["dwRequesterID"] = cc.MENetUtil:getChairID()
            params["users"] = clone(self.roomUsers)
            local cbStatus = {}
            for i=0,3 do
                if i ~= cc.MENetUtil:getChairID() then
                    cbStatus[i+1] = 0
                end
            end
            params["cbStatus"] = cbStatus
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

function FourMJScene:changeCard()
    -- body
    if #self.changePaiList ~= 3 then
        print("换牌数量错误！！！！！！！！！", self.changePaiList)
        return
    end
    self._children["ImgChangeCard"]:setVisible(false)
    local cardid1 = helper.getIndexByPai(self.changePaiList[1]:getTag())
    local cardid2 = helper.getIndexByPai(self.changePaiList[2]:getTag())
    local cardid3 = helper.getIndexByPai(self.changePaiList[3]:getTag())

    cc.MENetUtil:changePai(cardid1, cardid2, cardid3)
end

function FourMJScene:checkOutSameCard( cardid)
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

    for i=1,3 do
        local ly_duushou_out = self._children["ly_duushou_out".. i]
        for _,d in pairs(ly_duushou_out:getChildren()) do
            if cardid == d:getTag() then
                d:setSameOutFlag(false)
            end
        end
    end
end

function FourMJScene:clearOutSameCard()
    -- body
    for _,d in pairs(self.ly_self:getChildren()) do
        d:clearSameOutFlag()
    end

    for _,d in pairs(self.ly_self_out:getChildren()) do
        d:clearSameOutFlag()
    end

    for i=1,3 do
        local ly_duushou_out = self._children["ly_duushou_out".. i]
        for _,d in pairs(ly_duushou_out:getChildren()) do
            d:clearSameOutFlag()
        end
    end
end

function FourMJScene:hideBackBtn()
    -- body
    if self.isDoing and cc.MENetUtil:isCustomServer() then
        self._children["btn_exit"]:setVisible(false)
        self:removeKeyboardListener()
    end
end

function FourMJScene:setRoomModel()
    -- body
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_room_jiesan"]:setVisible(true)
        self._children["btn_weixin_yaoqing"]:setVisible(true)
        self._children["btn_auto_send"]:setVisible(false)
        print("room id =", Helper:stringFormatRoomID(cc.MENetUtil:getCustomRoomID()) )
        self._children["lab_RoomID"]:setString("房间号:" .. Helper:stringFormatRoomID(cc.MENetUtil:getCustomRoomID()))
        self._children["lab_RoomRule"]:setString("")
    else
        self._children["lab_RoomID"]:setString("")
        self._children["lab_RoomRule"]:setString("")
        self._children["btn_room_jiesan"]:setVisible(false)
        self._children["btn_auto_send"]:setVisible(true)
        self._children["btn_weixin_yaoqing"]:setVisible(false)
    end
end

function FourMJScene:selectPai(nType)
    -- body
    self.ly_select_state:setVisible(false)
    if nType == 0 then
        nType = math.random(1, 3)
    end

    local nValue = 0
    if nType == 1 then
        nValue = 1
    elseif nType == 2 then
        nValue = 17
    elseif nType == 3 then
        nValue = 33
    end
    cc.MENetUtil:selectPai(nValue)
end

function FourMJScene:GameSelectPai(data)
    dump(data, "选牌命令")
    for k,v in pairs(data.wSelectCard) do
        local nIdx = self:getTargetUIChair(k-1)
        if v ~= 255 then
            local head = self._children["head" .. nIdx]
            local imgType = head:getChildByName("imgType")
            imgType:setVisible(true)
            if v == 1 then
                imgType:loadTexture("sp_wan.png", ccui.TextureResType.plistType)
            elseif v == 17 then
                imgType:loadTexture("sp_tiao.png", ccui.TextureResType.plistType)
            elseif v == 33 then
                imgType:loadTexture("sp_tong.png", ccui.TextureResType.plistType)
            end
            local users = self:getRoomUsers(k-1)
            if users ~= nil then
                users.selectType = v
            else
                if cc.MENetUtil:getChairID() == k-1 then
                    self.selectType = v
                    if not self.isUpdateSelect then
                        self.isUpdateSelect = true
                        --更新牌
                        self:updateSelectPai()
                    end
                end
            end
        end
    end

    if data.wCurrentUser ~= 65535 then
        for i=1,3 do
            self._children["head".. i]:getChildByName("imgSelPai"):setVisible(false)
        end
        self.isSelectFinish = true
        --开始出牌
        cc.MENetUtil:setGameClock(data.wCurrentUser, 201, 25)
        self:setCursor(data.wCurrentUser)
        --检测是否用户托管出牌
        self:userAutoChuPai()
    end
end

function FourMJScene:GameChangeCard(data)
    dump(data, "换三张命令")
    local nPaiCount = #self.paiList_self
    local nChairID = cc.MENetUtil:getChairID()

    local function ReSetPai()
        -- body
        print("ReSetPai ............................................", nPaiCount, nChairID)
        self.ly_self:removeAllChildren()
        self.paiList_self = {}

        local tPai = {}
        for i=1,nPaiCount do
            self.curPaiId = helper.getPaiByIndex(data.cardData[i])
            if self.curPaiId > 0 then
                table.insert(tPai, self.curPaiId)
            end
        end

        --添加己方手牌
        for i,v in ipairs(tPai) do
            local count = self.ly_self:getChildrenCount() + self.ly_self_state:getChildrenCount()
            local bg_pai = DDMaJiang.new(4,4,v)
            bg_pai:setScale(0.9)
            bg_pai:setIndex(14-count)

            local s = bg_pai:getContentSize()
            bg_pai:setPosition(self.selfCardPosList[14-count], s.height / 2* bg_pai:getScale() )
            self.ly_self:addChild(bg_pai)
            table.insert(self.paiList_self, 1, bg_pai)
        end

        local t = {}
        for k,v in pairs(self.paiList_self) do
            t[#t + 1] = v:getTag()
        end
        dump(t, "ff")
        dump(self.selfCardPosList, "tt")

        table.sort(t,function(a,b) return a>b end)
        dump(t, "初始化排序")

        --先排序
        for k,v in pairs(self.paiList_self) do
            v:reSetMJPai(t[k] )
            v:setIndex(k)
            v:setLocalZOrder(k)
        end
        for k,v in pairs(self.paiList_self) do
            print(k, v:getIndex(), v:getTag() )
        end
        self.lastPaiId = self.paiList_self[1]:getTag()

        self.isChangeFinish = true
        --定缺模式
        self.ly_select_state:setVisible(true)
        cc.MENetUtil:setGameClock(cc.MENetUtil:getChairID(), 204, 15)

        for i=1,3 do
            self._children["head".. i]:getChildByName("imgSelPai"):setVisible(true)
            self._children["head".. i]:getChildByName("imgSelPai"):loadTexture("j_selpai.png", ccui.TextureResType.plistType)
        end
    end

    for k,v in pairs(self.changePaiList) do
        v:reSetMJPai( helper.getPaiByIndex(data.cbChangeCard[nChairID+1][k]) )
        local s = v:getContentSize()
        local nPos = cc.p(v:getPosition() )
        local y = s.height / 2* v:getScale()
        local seq = cc.Sequence:create(
            cc.FadeOut:create(0.3),
            cc.FadeIn:create(0.3),
            cc.MoveTo:create(0.5, cc.p(nPos.x, y)),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function()
                if k == 3 then
                    ReSetPai()
                end
            end)
        )
        v:runAction(seq) 
    end

    --换牌顺序：0顺时针，1逆时针，2对家
    local alertMsg = ""
    if data.wChangeDirection == 0 then
        alertMsg = "顺时针方向换牌"
    elseif data.wChangeDirection == 1 then
        alertMsg = "逆时针方向换牌"
    elseif data.wChangeDirection == 2 then
        alertMsg = "对家方向换牌"
    end
    local s = self._children["ly_battle"]:getContentSize()
    local labelTips = cc.Label:createWithTTF(alertMsg, "res/fonts/fzzyjt.ttf", 40) 
    labelTips:setColor(cc.c3b(255, 255, 255))
    labelTips:enableOutline(cc.c4b(185, 89, 3, 255), 2)
    labelTips:setPosition(cc.p(s.width/2, s.height/2))
    self._children["ly_battle"]:addChild(labelTips, 200)
     
    local nPos =  cc.p(labelTips:getPosition())  
    local action = cc.Sequence:create(
        cc.ScaleTo:create(0.3, 0),
        cc.ScaleTo:create(0.3, 1.2),
        cc.ScaleTo:create(0.3, 1),
        cc.MoveTo:create(2, cc.p(nPos.x, nPos.y + 100)),
        cc.FadeOut:create(0.8),
        cc.CallFunc:create(function()
            labelTips:removeFromParent()
        end)
    )
    labelTips:runAction(action)
end

function FourMJScene:setGameTrustee(data)
    -- body
    print("FourMJScene:setGameTrustee(data)", data)
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
            self._children["btn_cancel_trustee"]:setVisible(true)
            self._children["btn_auto_send"]:setVisible(false)
            self.chuSpeed = 0.4
        else
            self.chuSpeed = 1.0
            self.cur_trustee_state = 0
            self._children["btn_cancel_trustee"]:setVisible(false)
            self._children["btn_auto_send"]:setVisible(true)
        end
    end
end

function FourMJScene:setTargetPlayerInfo(data)
    dump(data, "房间游戏用户")
    local nIdx = self:getTargetUIChair( data.chair )
    if nIdx == nil then
        return
    end

    local head = self._children["head" .. nIdx]
    if data.isEnter then
        head:setVisible(true)
        local imgReady = head:getChildByName("imgReady")
        local imgZhuang = head:getChildByName("imgZhuang")
        local imgType = head:getChildByName("imgType")
        local labWinOrder = head:getChildByName("labWinOrder")
        local lab_state = head:getChildByName("lab_state")
        local ImgPlayVoice = head:getChildByName("ImgPlayVoice")
        if ImgPlayVoice ~= nil then
            ImgPlayVoice:setVisible(false)
        end

        if lab_state ~= nil then
            lab_state:setVisible(false)
        end
        imgReady:setVisible(false)
        imgZhuang:setVisible(false)
        imgType:setVisible(false)
        labWinOrder:setVisible(false)

        if data.chair ~= cc.MENetUtil:getChairID() then
            if data.type == 0 or data.url == "" then
                local faceId = data.ficeid%20 + 1
                head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
            else
                --下载头像
                GameLogicManager:downAvatar(data.url, 
                function ( ... )
                    -- body
                end,
                function (filename)
                    -- body
                    print("chair url:" , data.chair, filename)
                    head:loadTexture(filename)
                    local action = cc.Sequence:create(
                        cc.DelayTime:create(1.0),
                        cc.CallFunc:create(function()
                            head:loadTexture(filename)
                        end)
                    )
                    head:runAction(action)
                end)
            end

            local imgSelPai = head:getChildByName("imgSelPai")
            imgSelPai:setVisible(false)
            local name = head:getChildByName("ImgInfo"):getChildByName("lab_name")
            local gold = head:getChildByName("ImgInfo"):getChildByName("lab_gold")
            name:setString(data.nickName)
            if not cc.MENetUtil:isCustomServer() then 
                gold:setString(data.gold)
            end
            if data.sex == 0 or data.sex == 2 then
                data.targetSex = 0
            else
                data.targetSex = 1
            end
            data.targetOutCardList = {}
            data.pongList_ds = {}
            data.ds_state_pai_count = 0
            data.nStateTargetDist = 0
            self.roomUsers[data.chair + 1] = data
        else
            local url = cc.MENetUtil:getUserIconUrl()
            if cc.MENetUtil:getUserType() == 0 or url == nil or url == "" then
                local faceId = cc.MENetUtil:getFaceID()%20 + 1
                head:loadTexture("s_" ..faceId..".png", ccui.TextureResType.plistType)
            else
                --下载头像
                print("url = ", url)
                local customid = Helper:md5sum(url)
                local filename = Helper:getFileNameByUrl(url, customid)
                print(filename)
                head:loadTexture(filename)
            end
        end

        if data.status == 3 or data.status == 5 then
            imgReady:setVisible(true)
        end
        if data.status == 6 and lab_state ~= nil then
            lab_state:setVisible(true)
        end

        if data.chair == cc.MENetUtil:getChairID() and data.status == 6 then
            local tTrustee = {}
            tTrustee["bSystemSet"] = true
            tTrustee["isSelf"] = true
            tTrustee["bTrustee"] = true
            self:setGameTrustee(tTrustee)
        end
    else
        self.roomUsers[data.chair + 1] = nil
        head:setVisible(false)
    end
end

function FourMJScene:setTargetPlayerScore(data)
    dump(data, "房间游戏用户分数")
    local nIdx = self:getTargetUIChair( data.chair )
    if nIdx == nil then
        return
    end
    local head = self._children["head" .. nIdx]
    if data.chair ~= cc.MENetUtil:getChairID() then
        local users = self:getRoomUsers(data.chair)
        if users ~= nil then
            local gold = head:getChildByName("ImgInfo"):getChildByName("lab_gold")
            if not cc.MENetUtil:isCustomServer() then 
                gold:setString(data.gold)
            end
            users.gold = data.gold
        end
     else
        if not cc.MENetUtil:isCustomServer() then
            self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
        end
    end
end

function FourMJScene:setTargetPlayerStatus(data)
    dump(data, "房间游戏用户状态")
    local nIdx = self:getTargetUIChair( data.chair )
    if nIdx == nil then
        return
    end
    local head = self._children["head" .. nIdx]
    local imgReady = head:getChildByName("imgReady")
    local lab_state = head:getChildByName("lab_state")
    if lab_state ~= nil then
        lab_state:setVisible(false)
    end
    imgReady:setVisible(false)
    if data.status == 3 then
        imgReady:setVisible(true)
    end

    if data.chair ~= cc.MENetUtil:getChairID() then
        local users = self:getRoomUsers(data.chair)
        if users ~= nil then
            if data.status == 6 and lab_state ~= nil then
                lab_state:setVisible(true)
            end
            users.status = data.status
        end
    else
        if data.status == 6 then
            local tTrustee = {}
            tTrustee["bSystemSet"] = true
            tTrustee["isSelf"] = true
            tTrustee["bTrustee"] = true
            self:setGameTrustee(tTrustee)
        end
    end
end

function FourMJScene:getRoomUsers(nChairID)
    -- body
    return self.roomUsers[nChairID + 1]
end

function FourMJScene:clearRoomUsersData(nChairID)
    -- body
    print("FourMJScene:clearRoomUsersData(nChairID)", nChairID)
    local users = self.roomUsers[nChairID + 1]
    if users ~= nil then
        users.targetOutCardList = {}
        users.pongList_ds = {}
        users.ds_state_pai_count = 0
        users.nStateTargetDist = 0
    end
end

function FourMJScene:ResetGame()
    -- body
    self:initData()
    for i=0,3 do
        local nIdx = self:getTargetUIChair(i)

        self._children["ly_result".. nIdx]:setVisible(false)
        self._children["head".. nIdx]:getChildByName("imgZhuang"):setVisible(false)
        self._children["head".. nIdx]:getChildByName("imgType"):setVisible(false)
        self._children["head".. nIdx]:getChildByName("labWinOrder"):setVisible(false)
        if nIdx == 4 then
            self.ly_self:removeAllChildren()
            self.ly_self_out:removeAllChildren()
            self.ly_self_state:removeAllChildren()
        else
            self._children["ly_duishou".. nIdx]:removeAllChildren()
            self._children["ly_duushou_out".. nIdx]:removeAllChildren()
            self._children["ly_duishou_state".. nIdx]:removeAllChildren()
            self:clearRoomUsersData(i)
        end
    end
    self.ly_add_state:setVisible(false)
    self.ly_select_state:setVisible(false)
    self._children["lab_doubleNum"]:setString("")
    self._children["lab_pai_count"]:setString("")
    for i=1,3 do
        self._children["head".. i]:getChildByName("imgSelPai"):setVisible(false)
    end
end

function FourMJScene:ready()
    -- body
    print("FourMJScene:ready() ...............................")
    self._children["btn_ready"]:setVisible(false)
    self._children["timePanel"]:setVisible(false)
    if not cc.MENetUtil:isCustomServer() then
        self.lab_self_gold:setString(cc.MENetUtil:getUserGold() )
    end 
    cc.MENetUtil:ready()
    self.isReady = true
end

function FourMJScene:continueGame(data)
    dump(data)
    self:enterGame(data)

    print("我的椅子 =======================================", cc.MENetUtil:getChairID())
    for i=0, 3 do
        self:recoveryUserCard(i, data)

        if not cc.MENetUtil:isCustomServer() and cc.MENetUtil:getChairID() == i then
            local tTrustee = {}
            tTrustee["bSystemSet"] = true
            tTrustee["isSelf"] = true
            tTrustee["bTrustee"] = data.bTrustee[i+1]
            self:setGameTrustee(tTrustee)
        end
    end
    self:initPaiEffect()
    self.isInitPaiFinish = true
    self.isDoing = true
    self.isReady = true

    self.bankerUser = data.wBankerUser
    local nIdx = self:getTargetUIChair( data.wBankerUser )
    local imgZhuang = self._children["head".. nIdx]:getChildByName("imgZhuang")
    imgZhuang:setVisible(true)    
    self:setDir( data.wBankerUser )

    --检测是否换三张
    if data.bChanged then 
        --换三张模式
        self._children["ImgChangeCard"]:setVisible(true)
        self.isChangeFinish = false
        self:showDefaultChangeCard()
    else
        --定缺模式
        --检测选定却
        if data.bSelectColor then
            self.ly_select_state:setVisible(true)
            cc.MENetUtil:setGameClock(cc.MENetUtil:getChairID(), 204, 15)
            for i=1,3 do
                self._children["head".. i]:getChildByName("imgSelPai"):setVisible(true)
                self._children["head".. i]:getChildByName("imgSelPai"):loadTexture("j_selpai.png", ccui.TextureResType.plistType)
            end
        else
            local typeInfo = {}
            typeInfo["wSelectCard"] = data.cbSelectCard
            typeInfo["wCurrentUser"]= 65535
            self:GameSelectPai(typeInfo)
            self.isSelectFinish = true
        end

        local isHasSel = false
        for k,v in pairs(self.paiList_self) do
            v:setIndex(k)
            local ret = helper.isSelectTypePai(self.selectType, v:getTag() )
            if ret then
                isHasSel = true
            end
            print(k, v:getIndex(), v:getTag() )
        end
        print("self.isHasSel ============================", self.isHasSel)
        if not isHasSel then
            for k,v in pairs(self.paiList_self) do
                v:setCanOperate(true)
            end
        end     
    end
    
    --胡牌检测
    for i=0, 3 do
        self:checkHuPai(i, data)
    end

    --时钟
    if data.wCurrentUser ~= 65535 then
        self:setCursor(data.wCurrentUser)
        cc.MENetUtil:setGameClock(data.wCurrentUser, 201, 25)
        if data.wCurrentUser == cc.MENetUtil:getChairID() then
            self.aleart_pai = true
        end
    end

    if data.wOutCardUser ~= 65535 then
        self:setCursor(data.wOutCardUser)
        cc.MENetUtil:setGameClock(data.wOutCardUser, 203, 15) 
    end

    if data.cbActionMask ~= 0x00 then
        self.actionCard = helper.getPaiByIndex(data.cbActionCard)
        self:show_add_state_by_type(data.cbActionMask)
        if not self.aleart_pai then
            cc.MENetUtil:operatePai(0, 0)
            self:moPai()
        end
        self:setCursor(cc.MENetUtil:getChairID() )
        cc.MENetUtil:setGameClock(cc.MENetUtil:getChairID(), 202, 15)
    end

    self:hideBackBtn()
    self._children["btn_ready"]:setVisible(false)
    for i=1,4 do
        self._children["head".. i]:getChildByName("imgReady"):setVisible(false)
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
    self.isStart = true
end

function FourMJScene:checkHuPai(nChairID, data)
    -- body
    dump(data, "检测胡牌结果")
    if data.cbProvideCard[nChairID + 1] == 255 then
        return
    end
    --检测是点炮还是自摸
    local bZiMo = false
    if nChairID == data.wProvider[nChairID + 1] then
        bZiMo = true
    end

    local nIdx = self:getTargetUIChair(nChairID)
    self._children["ly_result" .. nIdx]:setVisible(true)
    self._children["ly_result" .. nIdx]:setLocalZOrder(1024)
   
    if bZiMo then
        self._children["ly_result" .. nIdx]:getChildByName("ImgHuType"):loadTexture("img_zimo.png", ccui.TextureResType.plistType)
    else
        self._children["ly_result" .. nIdx]:getChildByName("ImgHuType"):loadTexture("img_dianpao.png", ccui.TextureResType.plistType)
    end
    local head = self._children["head" .. nIdx]
    local labWinOrder = head:getChildByName("labWinOrder")
    labWinOrder:setVisible(true)
    labWinOrder:setString(data.wWinOrder[nChairID +1])

    self:showHuPai(nIdx)
    local tData = {}
    tData["wProviderUser"] = data.wProvider[nChairID + 1]
    tData["wChiHuUser"] = nChairID
    tData["cbChiHuCard"] = data.cbProvideCard[nChairID + 1]

    if bZiMo then
        self:showZiMoPai(nIdx, tData)
    else
        self:showDianPaoPai(tData)
    end
end

function FourMJScene:recoveryUserCard(nChairID, data)
    -- body
    local nIdx = self:getTargetUIChair(nChairID)
    print("正在恢复:::::::::::::::::::::::", nChairID, nIdx)
    local data_chu = data.cbDiscardCard[nChairID+1]
    --处理特殊情况，服务器先恢复现场数据，然后出牌和发牌不在现场数据中
    if data.wOutCardUser == nChairID then
        if data.cbOutCardData > 0 then
            data_chu[#data_chu + 1] = data.cbOutCardData
        end
    end
    print("data_chu = ", data_chu)

    local data_state = data.WeaveItemArray[nChairID+1]
    print("data_state = ", data_state)

    local paiCount = 13
    if data.wCurrentUser == nChairID then
        paiCount = 14
    end
    local state_count = data.cbWeaveCount[nChairID+1]
    print("paiCount , state_count = ", paiCount, state_count)

    if nIdx == 4 then
        --添加己方的出牌
        for i,v in ipairs(data_chu) do
            if v > 0 then
                local mj_chu = self:CreateChuPai(nIdx, helper.getPaiByIndex(v))
                self.selfOutCardList[#self.selfOutCardList + 1] = mj_chu
            end
        end

        --添加己方状态牌
        for i,v in ipairs(data_state) do
            print("添加己方状态牌 = ", i, v)
            local cardId = helper.getPaiByIndex(v.cbCenterCard)
            if cardId > 0 then
                table.insert(self.pongList,cardId)
                self.isPong = true
                local type = 1
                if v.cbWeaveKind == 16 then 
                    if v.cbPublicCard == 0 then
                        type = 2
                    elseif v.cbPublicCard == 1 then
                        type = 4
                    end
                end
                for i=1,3 do
                    if i == 2 then
                        self:CreateStatePai(nChairID, type, cardId, true)
                    else
                        self:CreateStatePai(nChairID, type, cardId, false)
                    end
                end
                self.nStateSelfDist = self.nStateSelfDist + 30
            end
        end

        local tPai = {}
        for k,v in pairs(data.cbCardData) do
            if v > 0 then
                self.curPaiId = helper.getPaiByIndex(v)
                table.insert(tPai, self.curPaiId)
            end
        end
        print("tPai ====================================== ", tPai)
        if data.wCurrentUser == cc.MENetUtil:getChairID() and data.cbSendCardData > 0 and data.cbSendCardData ~= 255 then
            local count = #tPai + state_count*3
            if count < 14 then
                self.curPaiId = helper.getPaiByIndex(data.cbSendCardData)
                table.insert(tPai, self.curPaiId)
            end
        end
        print("tPai ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ", tPai)
        --添加己方手牌
        for i,v in ipairs(tPai) do
            local count = self.ly_self:getChildrenCount() + self.ly_self_state:getChildrenCount()
            local bg_pai = DDMaJiang.new(nIdx,4,v)
            bg_pai:setScale(0.9)
            bg_pai:setIndex(14-count)

            local s = bg_pai:getContentSize()
            bg_pai:setPosition(self.selfCardPosList[14-count], s.height / 2* bg_pai:getScale() )
            self.ly_self:addChild(bg_pai)
            table.insert(self.paiList_self, 1, bg_pai)
        end
    else
        local users = self:getRoomUsers(nChairID)
        --添加对方的出牌
        local ly_duushou_out = self._children["ly_duushou_out".. nIdx]
        for i,v in ipairs(data_chu) do
            if v > 0 then
                local mj_chu = self:CreateChuPai(nIdx, helper.getPaiByIndex(v) )
                users.targetOutCardList[#users.targetOutCardList + 1] = mj_chu
            end
        end

        --添加对方状态牌
        local ly_duishou_state = self._children["ly_duishou_state".. nIdx]
        for i,v in ipairs(data_state) do
            --print("添加对方状态牌 = ", i, v)
            local cardId = helper.getPaiByIndex(v.cbCenterCard)
            if cardId > 0 then
                table.insert(users.pongList_ds, cardId)
                local type = 1
                if v.cbWeaveKind == 16 then 
                    if v.cbPublicCard == 0 then
                        type = 2
                    elseif v.cbPublicCard == 1 then
                        type = 4
                    end
                end

                for i=1,3 do
                    if i == 2 then
                        self:CreateStatePai(nChairID, type, cardId, true)
                    else
                        self:CreateStatePai(nChairID, type, cardId, false)
                    end
                end
                if nIdx == 2 then
                    users.nStateTargetDist = users.nStateTargetDist + 20
                else
                    users.nStateTargetDist = users.nStateTargetDist + 10
                end
            end
        end

        --添加对方手牌
        local ly_duishou = self._children["ly_duishou".. nIdx]
        local listEnemy = {}
        for i=1, paiCount - (state_count * 3) do
            table.insert(listEnemy,1)
        end
        for i,v in ipairs(listEnemy) do
            local bg_pai = DDMaJiang.new(nIdx,4,v)
            bg_pai:setIndex(i)
            bg_pai:setPosition(self.targetCardPosList[nIdx][i])
            ly_duishou:addChild(bg_pai)
        end
    end

end

function FourMJScene:enterGame(data)
    if data.bShowReady ~= nil then
        self._children["btn_ready"]:setVisible(data.bShowReady)
        if not data.bShowReady then
            self.isReady = true
            self._children["head4"]:getChildByName("imgReady"):setVisible(true)
        end
    end

    self:addEventListener(EventMsgDefine.GameNext,self.ready,self)
    self:addEventListener(EventMsgDefine.GameRoomOut,self.GameRoomOut,self)
    self:addEventListener(EventMsgDefine.GameShowCustomResult,self.GameShowCustomResult,self)
    self:addEventListener(EventMsgDefine.GotoMainScene,self.GotoMainScene,self)
    self:addEventListener(EventMsgDefine.GameReset,self.ResetGame,self)
    self:addEventListener(EventMsgDefine.GameJieSuan,self.GameJieSuan,self)
    
    self.score = data.lCellScore
end

function FourMJScene:GotoMainScene()
    cc.MENetUtil:logoutGame()
    MaJiangController:backGame()
end

function FourMJScene:UpdateUserClock(nChairID, nClock)
    self._children["lab_time_self"]:setString( string.format("%02d", nClock ))
    if self.isDoing then
       for i=1,4 do
            self._children["head".. i]:getChildByName("imgReady"):setVisible(false)
        end
    end
end

function FourMJScene:setDir( bankerUser )
    -- body
    local nIdx = self:getTargetUIChair(bankerUser)
    local timePanel = self._children["timePanel"]
    if nIdx == 1 then
        timePanel:getChildByName("img_dir_1"):loadTexture("turntable_dong.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_2"):loadTexture("turntable_bei.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_3"):loadTexture("turntable_xi.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_4"):loadTexture("turntable_nan.png", ccui.TextureResType.plistType)
    elseif nIdx == 2 then
        timePanel:getChildByName("img_dir_1"):loadTexture("turntable_nan.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_2"):loadTexture("turntable_dong.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_3"):loadTexture("turntable_bei.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_4"):loadTexture("turntable_xi.png", ccui.TextureResType.plistType)
    elseif nIdx == 3 then
        timePanel:getChildByName("img_dir_1"):loadTexture("turntable_xi.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_2"):loadTexture("turntable_nan.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_3"):loadTexture("turntable_dong.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_4"):loadTexture("turntable_bei.png", ccui.TextureResType.plistType)
    elseif nIdx == 4 then
        timePanel:getChildByName("img_dir_1"):loadTexture("turntable_bei.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_2"):loadTexture("turntable_xi.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_3"):loadTexture("turntable_nan.png", ccui.TextureResType.plistType)
        timePanel:getChildByName("img_dir_4"):loadTexture("turntable_dong.png", ccui.TextureResType.plistType)
    end
    for i=1,4 do
        timePanel:getChildByName("img_arrow_" .. i):setVisible(false)
    end
end

function FourMJScene:setCursor(nChairID)
    -- body
    local timePanel = self._children["timePanel"]
    timePanel:setVisible(true)
    for i=1,4 do
        timePanel:getChildByName("img_arrow_" .. i):setVisible(false)
    end
    local nIdx = self:getTargetUIChair(nChairID)
    timePanel:getChildByName("img_arrow_" .. nIdx):setVisible(true)
end

function FourMJScene:initPaiData(data)
    dump(data, "初始化牌")
    for i=1,4 do
        self._children["head".. i]:getChildByName("imgReady"):setVisible(false)
    end
    self.bankerUser = data.bankerUser
    self:showSaiZiDongHua(data.sice1Count, function ( ... )
        -- body
        self:zhuJiaEffect(data.bankerUser)
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
        cc.CallFunc:create(function() self:addPai(1,data.bankerUser) end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() self:addPai(2,data.bankerUser) end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() self:addPai(3,data.bankerUser) end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function() self:addPai(4,data.bankerUser) end),
        cc.DelayTime:create(2),
        cc.CallFunc:create(function()
            self._children["timePanel"]:setVisible(true)
            self:setDir( data.bankerUser )
            if data.wGameMode == 2 then
                --换三张模式
                self._children["ImgChangeCard"]:setVisible(true)
                self.isChangeFinish = false
                self:showDefaultChangeCard()
            else
                --定缺模式
                self.ly_select_state:setVisible(true)
                cc.MENetUtil:setGameClock(cc.MENetUtil:getChairID(), 204, 15)
                for i=1,3 do
                    self._children["head".. i]:getChildByName("imgSelPai"):setVisible(true)
                    self._children["head".. i]:getChildByName("imgSelPai"):loadTexture("j_selpai.png", ccui.TextureResType.plistType)
                end
            end
        
            self.isInitPaiFinish = true
            --检测是否用户托管出牌
            self:userAutoChuPai()
        end)
    )
    self:runAction(action)

    self.curPaiCount = data.cbLeftCardCount
    self:updatePaiCount()
    self.isDoing = true
    self:hideBackBtn()
    if cc.MENetUtil:isCustomServer() then
        self._children["lab_doubleNum"]:setString("局数:".. self.curJuShuCount .. "/" ..self.maxJuShuCount)
    else
        self._children["lab_doubleNum"]:setString("底注:".. self.score)
    end
    self._children["btn_room_jiesan"]:setVisible(false)
    self._children["btn_auto_send"]:setVisible(true)
    self._children["btn_weixin_yaoqing"]:setVisible(false)
    self.isStart = true
end

function FourMJScene:GameChangeCardTimeOut()
    self:changeCard()
end

function FourMJScene:showDefaultChangeCard()
    local tWan = {}
    local tTiao = {}
    local tTong = {}
    for k,v in pairs(self.paiList_self) do
        print(k, v:getIndex(), v:getTag() )
        v:setCanOperate(true)
        local cardid = v:getTag()
        if helper.isWanPai(cardid) then
            tWan[#tWan + 1] = v
        elseif helper.isTiaoPai(cardid) then
            tTiao[#tTiao + 1] = v
        elseif helper.isTongPai(cardid) then
            tTong[#tTong + 1] = v
        end
    end
    --
    local nMin = 99
    local nIdx = 0
    if #tWan >= 3 and #tWan <= nMin then
        nMin = #tWan
        nIdx = 1
    end

    if #tTiao >= 3 and #tTiao <= nMin then
        nMin = #tTiao
        nIdx = 2
    end

    if #tTong >= 3 and #tTong <= nMin then
        nMin = #tTong
        nIdx = 3
    end
    print("change type ==========================", nIdx)

    local t = {}
    if nIdx == 1 then
        t = tWan
    elseif nIdx == 2 then
        t = tTiao
    elseif nIdx == 3 then
        t = tTong
    end

    for k,v in pairs(t) do
        print(k, v:getIndex(), v:getTag() , y)
        self.changePaiList[#self.changePaiList + 1] = v
        local y = v:getContentSize().height* v:getScale() * 0.9
        v:setPositionY(y)
        if #self.changePaiList >= 3 then
            break
        end
    end

    for i=1,3 do
        self._children["head".. i]:getChildByName("imgSelPai"):setVisible(true)
        self._children["head".. i]:getChildByName("imgSelPai"):loadTexture("xuanpai.png", ccui.TextureResType.plistType)
    end
    cc.MENetUtil:setGameClock(cc.MENetUtil:getChairID(), 205, 15)
end

function FourMJScene:canChangeCard( id )
    -- body
    if #self.changePaiList <= 0 then
        return true
    end

    local nIdx = 0
    for k,v in pairs(self.changePaiList) do
        local cardid = v:getTag()
        if helper.isWanPai(cardid) then
            nIdx = 1
        elseif helper.isTiaoPai(cardid) then
            nIdx = 2
        elseif helper.isTongPai(cardid) then
            nIdx = 3
        end
        break                          
    end

    local nIdx2
    if helper.isWanPai(id) then
        nIdx2 = 1
    elseif helper.isTiaoPai(id) then
        nIdx2 = 2
    elseif helper.isTongPai(id) then
        nIdx2 = 3
    end

    if nIdx == nIdx2 then
        return true
    end
    return false
end

function FourMJScene:showSaiZiDongHua(count, callback)
    local dian1, dian2 = helper.getShaiZiCount(count)

    MEAudioUtils.playSoundEffect("soundfmj/dice.mp3")
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

function FourMJScene:zhuJiaEffect(nChairID)
    -- body
    local s = self._children["ly_battle"]:getContentSize()
    local effect = cc.Sprite:createWithSpriteFrameName("spBanker.png")
    self._children["ly_battle"]:addChild(effect)
    effect:setPosition(cc.p(s.width/2, s.height/2))
    effect:setLocalZOrder(1024)

    local nIdx = self:getTargetUIChair( nChairID )
    local targetUI = self._children["head".. nIdx]:getChildByName("imgZhuang")
    local pos = targetUI:convertToWorldSpaceAR(cc.p(0, 0))

    local seq = cc.Sequence:create(
        cc.MoveTo:create(0.2, pos),
        cc.CallFunc:create(function()
            effect:removeFromParent()
            targetUI:setVisible(true)
        end)
    )
    effect:runAction(seq) 
end

function FourMJScene:GameShowCustomResult()
    -- body
    app:openDialog("FourCustomResultLayer", self.customRoomData)
end

function FourMJScene:GameRoomOut()
    -- body
    if not self.isCheat then
        local params = {}
        params["zorder"] = 1024
        app:openDialog("LoadLayer", params)
    end
    --退出房间
    cc.MENetUtil:leaveGame()
end

function FourMJScene:GameInfoTips(str)
    local tmp = string.find(str,"血战麻将")
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

function FourMJScene:zimo()
    self.ly_add_state:setVisible(false)
    cc.MENetUtil:operatePai(0x40, 0)
end

--碰
function FourMJScene:pong()
    self.ly_add_state:setVisible(false)
    cc.MENetUtil:operatePai(0x08, helper.getIndexByPai(self.actionCard) )
end

function FourMJScene:gang()
    self.ly_add_state:setVisible(false)
    cc.MENetUtil:operatePai(0x10, helper.getIndexByPai(self.actionCard) )
end

function FourMJScene:pengPaiEffect(nChairID, id, callback)
    -- body
    print("FourMJScene:pengPaiEffect(nChairID, id)", nChairID, id)
    local nIdx = self:getTargetUIChair(nChairID)
    local path
    if nChairID == cc.MENetUtil:getChairID() then
        if self.selfSex == 1 then
            path = "soundfmj/man/peng.mp3"
        else
            path = "soundfmj/woman/peng.mp3"
        end
        local y = cc.p(self.ly_self_state:getPosition()).y + self.ly_self_state:getContentSize().height + 50

        local t = {
            [1] = -200,
            [2] = 0,
            [3] = 200,
        }
        for i=1,3 do
            local effect = DDMaJiang.new(4, 1, id)
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
    else
        local users = self:getRoomUsers(nChairID)
        if users.targetSex == 1 then
            path = "soundfmj/man/peng.mp3"
        else
            path = "soundfmj/woman/peng.mp3"
        end
    end
    MEAudioUtils.playSoundEffect(path)

    local armature = ccs.Armature:create("MJPeng")
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        local nPos 
        if nIdx == 4 then
            nPos = cc.p(s.width/2, s.height/2 - 30)
        else
            local ly_duishou = self._children["ly_duishou" .. nIdx]
            if nIdx == 1 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x + ly_duishou:getContentSize().width/2 + 30, s.height/2)
            elseif nIdx == 2 then
                nPos = cc.p(s.width/2, cc.p(ly_duishou:getPosition()).y + ly_duishou:getContentSize().height/2 + 30)
            elseif nIdx == 3 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x - 30, s.height/2)
            end
        end
        armature:setPosition(nPos)
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature, 100)

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

function FourMJScene:gangPaiEffect(nChairID, type, id, callback)
    -- body
    print("FourMJScene:gangPaiEffect(nChairID, type, id) ", nChairID, type, id)
    local nIdx = self:getTargetUIChair(nChairID)
    local path
    if nChairID == cc.MENetUtil:getChairID() then
        if self.selfSex == 1 then
            path = "soundfmj/man/gang.mp3"
        else
            path = "soundfmj/woman/gang.mp3"
        end
        local y = cc.p(self.ly_self_state:getPosition()).y + self.ly_self_state:getContentSize().height + 50

        if type == 2 then
            local x = self._children["ly_battle"]:getContentSize().width/2 - 100
            for i=1,4 do
                local effect = DDMaJiang.new(4, 2, id)
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
                local effect = DDMaJiang.new(4, 1, id)
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
                    local bg_pai2 = DDMaJiang.new(4, 1, id)
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
    else
        local users = self:getRoomUsers(nChairID)
        if users.targetSex == 1 then
            path = "soundfmj/man/gang.mp3"
        else
            path = "soundfmj/woman/gang.mp3"
        end
    end
    MEAudioUtils.playSoundEffect(path)

    local armature = ccs.Armature:create("MJGang")
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        local nPos 
        if nIdx == 4 then
            nPos = cc.p(s.width/2, s.height/2 - 30)
        else
            local ly_duishou = self._children["ly_duishou" .. nIdx]
            if nIdx == 1 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x + ly_duishou:getContentSize().width/2 + 30, s.height/2)
            elseif nIdx == 2 then
                nPos = cc.p(s.width/2, cc.p(ly_duishou:getPosition()).y + ly_duishou:getContentSize().height/2 + 30)
            elseif nIdx == 3 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x - 30, s.height/2)
            end
        end
        armature:setPosition(nPos)
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature, 100)

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

function FourMJScene:huPaiEffect(nChairID, bZiMo, callback )
    -- body
    local nIdx = self:getTargetUIChair(nChairID)
    local strName
    if bZiMo then
        strName = "MJZiMo"
    else
        strName = "MJHu2"
    end
    local armature = ccs.Armature:create(strName)
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        local nPos 
        if nIdx == 4 then
            nPos = cc.p(s.width/2, self.ly_self:getPositionY() + 150)
        else
            local ly_duishou = self._children["ly_duishou" .. nIdx]
            if nIdx == 1 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x + ly_duishou:getContentSize().width + 50, s.height/2)
            elseif nIdx == 2 then
                nPos = cc.p(s.width/2, cc.p(ly_duishou:getPosition()).y - 50)
            elseif nIdx == 3 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x - 50, s.height/2)
            end
        end
        armature:setPosition(nPos)
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature, 100)

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

function FourMJScene:PlayGangEffect(nChairID, bAnGang, callback )
    -- body
    local nIdx = self:getTargetUIChair(nChairID)
    local strName
    if bAnGang then
        strName = "MJXiaYu"
    else
        strName = "MJGuanFeng"
    end
    local armature = ccs.Armature:create(strName)
    if armature ~= nil then
        local s = self._children["ly_battle"]:getContentSize()
        armature:getAnimation():playWithIndex(0)
        local nPos 
        if nIdx == 4 then
            nPos = cc.p(s.width/2, self.ly_self:getPositionY() + 250)
        else
            local ly_duishou = self._children["ly_duishou" .. nIdx]
            if nIdx == 1 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x + ly_duishou:getContentSize().width + 50, s.height/2)
            elseif nIdx == 2 then
                nPos = cc.p(s.width/2, cc.p(ly_duishou:getPosition()).y - 50)
            elseif nIdx == 3 then
                nPos = cc.p(cc.p(ly_duishou:getPosition()).x - 50, s.height/2)
            end
        end
        armature:setPosition(nPos)
        armature:getAnimation():setSpeedScale(0.5)
        self._children["ly_battle"]:addChild(armature, 100)

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

function FourMJScene:chuPaiEffect(nChairID, obj, id, callback)
    -- body
    print("FourMJScene:chuPaiEffect(nChairID, obj, id", nChairID, obj, id)
    local nIdx = self:getTargetUIChair(nChairID)
    local pos = cc.p(obj:getPosition())
    local effect = DDMaJiang.new(4, 1, id)
    local nPos = cc.p(0,0)
    local nTargetPos
    if nChairID == cc.MENetUtil:getChairID() then
        nPos.x = pos.x
        nPos.y = cc.p(self.ly_self:getPosition()).y + obj:getContentSize().height + obj:getContentSize().height/2 -20
        nTargetPos = cc.p(self._children["ly_battle"]:getContentSize().width/2, nPos.y)
    else
        local ly_duishou = self._children["ly_duishou".. nIdx]
        if nIdx == 2 then
            nPos.x = pos.x
            nPos.y = cc.p(ly_duishou:getPosition()).y - obj:getContentSize().height/2 + 20
            nTargetPos = cc.p(self._children["ly_battle"]:getContentSize().width/2, nPos.y)
        elseif nIdx == 1 then
            nPos.x = cc.p(ly_duishou:getPosition()).x + obj:getContentSize().width + obj:getContentSize().width/2 + 100
            nPos.y = pos.y
            nTargetPos = cc.p(nPos.x, self._children["ly_battle"]:getContentSize().height/2)
        elseif nIdx == 3 then
            nPos.x = cc.p(ly_duishou:getPosition()).x - obj:getContentSize().width/2 - 30
            nPos.y = pos.y
            nTargetPos = cc.p(nPos.x, self._children["ly_battle"]:getContentSize().height/2)
        end
    end
    effect:setPosition(nTargetPos)
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

function FourMJScene:chuPaiArrowEffect( node )
    -- body
    for _,d in pairs(self.ly_self_out:getChildren()) do
        local imgFlag = d:getChildByName("CurOutCardFlag")
        if imgFlag ~= nil then
            imgFlag:removeFromParent()
        end
    end

    for i=1,3 do
        local ly_duushou_out = self._children["ly_duushou_out".. i]
        for _,d in pairs(ly_duushou_out:getChildren()) do
            local imgFlag = d:getChildByName("CurOutCardFlag")
            if imgFlag ~= nil then
                imgFlag:removeFromParent()
            end
        end
    end

    local s = node:getContentSize()
    local armature = ccs.Armature:create("MjCardArrow")
    if armature ~= nil then
        armature:getAnimation():playWithIndex(0)
        armature:setPosition(cc.p(s.width/2, s.height/2 + 50) )
        armature:getAnimation():setSpeedScale(0.5)
        armature:setName("CurOutCardFlag")
        node:addChild(armature, 10)
    end
end

function FourMJScene:chuPai(bAuto, nChairID, nOutCard)
    print("FourMJScene:chuPai(bAuto, nChairID) ....................", bAuto, nChairID, nOutCard)
    local nIdx = self:getTargetUIChair(nChairID)

    if nChairID == cc.MENetUtil:getChairID() then
        print("当前牌状态",self.aleart_pai)
        if not self.aleart_pai then
            print("出牌失败，不是当前用户出牌！！")
            return false
        end
        if self.curMaJiang == nil then
            print("出牌失败，当前牌为空！！")
            return false
        end
        if not self.isChangeFinish then
            print("现在正在换三张，不能出牌！")
            return
        end
        if not self.isSelectFinish then
            print("未选择定缺，不能出牌！")
            return
        end
        local id = self.curMaJiang:getTag()
        if not self.curMaJiang:getCanOperate() then
            print("出牌失败，当前牌是未定缺类型，不能打出！！", id)
            return false
        end
        self:clearOutSameCard()
        print("FourMJScene:chuPai ===============================", id, self.curMaJiang:getIndex() )
        self.ly_add_state:setVisible(false)
        self.isPongIng = false
        self.aleart_pai = false
        local path
        if self.selfSex == 1 then
            path = "soundfmj/man/W_"..id..".mp3"
        else
            path = "soundfmj/woman/W_"..id..".mp3"
        end
        MEAudioUtils.playSoundEffect(path)  

        self.curPaiId = id

        local mj_chu = self:CreateChuPai(nIdx, id)
        self.selfOutCardList[#self.selfOutCardList + 1] = mj_chu
        mj_chu:setVisible(false)

        self:chuPaiArrowEffect( mj_chu )

        local nPos = mj_chu:convertToWorldSpaceAR(cc.p(0, 0))
        self:chuPaiEffect(nChairID, self.curMaJiang, id, function ( ... )
            -- body
            self:showOutCard(nChairID)
            
            if not bAuto then
                cc.MENetUtil:chuPai(helper.getIndexByPai(id))
            end
        end)

        self:reOrderByDoing()
    else
        local users = self:getRoomUsers(nChairID)
       
        print("FourMJScene:chuPai ===============================",nIdx, nOutCard)
        local path
        if users.targetSex == 1 then
            path = "soundfmj/man/W_"..nOutCard..".mp3"
        else
            path = "soundfmj/woman/W_"..nOutCard..".mp3"
        end
        MEAudioUtils.playSoundEffect(path)

        local mj_chu = self:CreateChuPai(nIdx, nOutCard)
        users.targetOutCardList[#users.targetOutCardList + 1] = mj_chu
        mj_chu:setVisible(false)
        
        self:chuPaiArrowEffect( mj_chu )

        local nPos = mj_chu:convertToWorldSpaceAR(cc.p(0, 0))

        local nIdx = self:getTargetUIChair(nChairID)
        local ly_duishou = self._children["ly_duishou".. nIdx]
        local count = ly_duishou:getChildrenCount()
        if nIdx ~= 1 then
            count = 1
        end
        for _,d in pairs(ly_duishou:getChildren()) do
            count = count - 1
            if count == 0 then
                self:chuPaiEffect(nChairID, d, nOutCard, function ( ... )
                    -- body
                    self:showOutCard(nChairID)
                    d:removeFromParent()
                end)
                break
            end
        end
    end
    MEAudioUtils.playSoundEffect("sound/OUT_CARD.mp3")
    return true
end


function FourMJScene:CreateChuPai(nIdx, nOutCard)
    -- body
    local mj_chu = DDMaJiang.new(nIdx,3,nOutCard)
    local s = mj_chu:getContentSize()
    if nIdx == 4 then
        local count = self.ly_self_out:getChildrenCount()
        local midY = 0
        local midX = 0
        if (count >= 12) then
            midY = midY + s.height
        end
        mj_chu:setPosition(midX + (count%12)*(s.width - 11), midY )
        mj_chu:setLocalZOrder(count)
        self.ly_self_out:addChild(mj_chu)
    else
        local ly_duushou_out = self._children["ly_duushou_out".. nIdx]
        local count = ly_duushou_out:getChildrenCount()

        if nIdx == 2 then
            local midY = ly_duushou_out:getContentSize().height - s.height
            local midX = ly_duushou_out:getContentSize().width - s.width
            if count >= 12 then
                midY = midY - s.height
            end
            mj_chu:setPosition(midX - (count%12)*(s.width - 11), midY )
            mj_chu:setLocalZOrder(count)
        elseif nIdx == 1 then
            local midY = ly_duushou_out:getContentSize().height - s.height
            local midX = 0
            if count >= 9 then
                midX = midX + s.width
            end
            mj_chu:setPosition(midX, midY - (count%9)*(s.height - 11))
            mj_chu:setLocalZOrder(count)
        elseif nIdx == 3 then
            local midY = 0
            local midX = ly_duushou_out:getContentSize().width - s.width
            if count >= 9 then
                midX = midX - s.width 
            end
            mj_chu:setPosition(midX, midY + (count%9)*(s.height - 11))
            mj_chu:setLocalZOrder(100-count)
        end
        ly_duushou_out:addChild(mj_chu)
    end
    
    return mj_chu
end

function FourMJScene:showOutCard(nChairID)
    -- body
    if nChairID == cc.MENetUtil:getChairID() then
        for _,d in pairs(self.ly_self_out:getChildren()) do
            if not d:isVisible() then
                d:setVisible(true)
            end
        end
    else
        local nIdx = self:getTargetUIChair(nChairID)
        local ly_duushou_out = self._children["ly_duushou_out".. nIdx]
        for _,d in pairs(ly_duushou_out:getChildren()) do
            if not d:isVisible() then
                d:setVisible(true)
            end
        end
    end
end

function FourMJScene:updateOutCard(nChairID, id)
    -- body
    print("FourMJScene:updateOutCard(nChairID, id)", nChairID, id)
    if nChairID == cc.MENetUtil:getChairID() then
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
        local users = self:getRoomUsers(nChairID)
        local lastOut = users.targetOutCardList[#users.targetOutCardList]
        if lastOut:getTag() == id then
            local Out = users.targetOutCardList[#users.targetOutCardList - 1]
            if Out ~= nil then
                self:chuPaiArrowEffect( Out )
            end
            lastOut:removeFromParent()
            users.targetOutCardList[#users.targetOutCardList] = nil
        end
    end
end

function FourMJScene:updatePaiCount()
    self._children["lab_pai_count"]:setString("牌数:"..self.curPaiCount.."张")
end

function FourMJScene:addPai(nCount, bankerUser)
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

            for k,v in pairs(self.roomUsers) do
                self:insertPai(v.chair, listEnemy)
            end
        else
            for k,v in pairs(self.roomUsers) do
                if v.chair == bankerUser then
                    local t = clone(listEnemy)
                    table.insert(t,1)
                    self:insertPai(v.chair, t)
                else
                    self:insertPai(v.chair, listEnemy)
                end
            end
        end
        self:insertPai(nil, listSelf)

        --重新排序排
        local action = cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function() 
                self:initPaiEffect() 
            end)
        )
        self:runAction(action)
    else
        for i=1,4 do
            table.insert(listSelf,self.paiList[1])
            table.remove(self.paiList,1)
            table.insert(listEnemy,1)
        end
        self:insertPai(nil, listSelf)

        for k,v in pairs(self.roomUsers) do
            self:insertPai(v.chair, listEnemy)
        end
    end
end

function FourMJScene:insertPai(inserter, list)
    print("FourMJScene:insertPai...........................", inserter, list)
    if inserter == nil then
        for i,v in ipairs(list) do
            local count = self.ly_self:getChildrenCount() + self.ly_self_state:getChildrenCount()
            local bg_pai = DDMaJiang.new(4,4,v)
            bg_pai:setIndex(14-count)

            local s = bg_pai:getContentSize()
            bg_pai:setPosition(self.selfCardPosList[14-count], s.height* bg_pai:getScale())
            self.ly_self:addChild(bg_pai)
            bg_pai:runAction(cc.MoveBy:create(0.1, cc.p(0,-s.height/2*bg_pai:getScale())))
            table.insert(self.paiList_self, 1, bg_pai)
        end
    else
        local nIdx = self:getTargetUIChair(inserter)
        local users = self:getRoomUsers(inserter)
        local ly_duishou = self._children["ly_duishou".. nIdx]
        for i,v in ipairs(list) do
            local count = ly_duishou:getChildrenCount()
            local bg_pai = DDMaJiang.new(nIdx,4,v)
            bg_pai:setIndex(14-count)
            if nIdx == 3 then
                bg_pai:setLocalZOrder(14-count)
            elseif nIdx == 1 then
                bg_pai:setLocalZOrder(count)
            end
            local s = bg_pai:getContentSize()
            bg_pai:setPosition(self.targetCardPosList[nIdx][14-count])
            ly_duishou:addChild(bg_pai)
        end
    end
    MEAudioUtils.playSoundEffect("sound/SEND_CARD.mp3")
end


function FourMJScene:getPai(nChairID, cardId)
    print("FourMJScene:getPai...........................", nChairID, cardId)
    if nChairID == cc.MENetUtil:getChairID() then
        local bg_pai = DDMaJiang.new(4, 4, cardId)
        bg_pai:setLocalZOrder(100)
        bg_pai:setIndex(1)
        local s = bg_pai:getContentSize()
        bg_pai:setPosition(cc.p(self.selfCardPosList[1], s.height/2* bg_pai:getScale() ) )
        self.ly_self:addChild(bg_pai)
        local bCan = helper.isSelectTypePai(self.selectType, cardId)
        bg_pai:setCanOperate(bCan)

        table.insert(self.paiList_self, 1, bg_pai)
        self.lastPaiId = cardId

        local isHasSel = false
        for k,v in pairs(self.paiList_self) do
            print("self getpai:", k, v:getTag() )
            v:setIndex(k)
            v:setPositionX(self.selfCardPosList[k])
            local ret = helper.isSelectTypePai(self.selectType, v:getTag() )
            v:setCanOperate(ret)
            if ret then
                isHasSel = true
            end
        end
        if not isHasSel then
            for k,v in pairs(self.paiList_self) do
                v:setCanOperate(true)
            end
        end
        self.aleart_pai = true
    else
        local nIdx = self:getTargetUIChair(nChairID)
        local users = self:getRoomUsers(nChairID)
        local ly_duishou = self._children["ly_duishou".. nIdx]

        local bg_pai = DDMaJiang.new(nIdx,4,cardId)
        bg_pai:setLocalZOrder(100)
        bg_pai:setIndex(1)
        bg_pai:setPosition(self.targetCardPosList[nIdx][1] )
        ly_duishou:addChild(bg_pai)

        local count = ly_duishou:getChildrenCount()
        for k,v in pairs(ly_duishou:getChildren()) do
            print("target getpai:", k, v:getTag() )
            v:setIndex(k)
            if nIdx == 1 then
                v:setLocalZOrder(count-k)
            elseif nIdx == 3 then
                v:setLocalZOrder(k)
            end
            v:setPosition(self.targetCardPosList[nIdx][k])
        end
    end
    MEAudioUtils.playSoundEffect("sound/SEND_CARD.mp3")
end

function FourMJScene:initPaiEffect()
    -- body
    local t = {}
    for k,v in pairs(self.paiList_self) do
        t[#t + 1] = v:getTag()
    end
    dump(t, "ff")
    dump(self.selfCardPosList, "tt")

    table.sort(t,function(a,b) return a>b end)
    dump(t, "初始化排序")

    --先排序
    for k,v in pairs(self.paiList_self) do
        v:reSetMJPai(t[k] )
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
    for k,v in pairs(self.roomUsers) do
        --print(k,v)
        local nIdx = self:getTargetUIChair(v.chair)
        local ly_duishou = self._children["ly_duishou".. nIdx]
        local count = ly_duishou:getChildrenCount()
        local nMax = count
        if nMax == 13 then
            nMax = 14
        end
        for k,v in pairs(ly_duishou:getChildren()) do
            v:setIndex(k)
            v:setPosition(self.targetCardPosList[nIdx][nMax])
            if nIdx == 3 then
                v:setLocalZOrder(count-k)
            elseif nIdx == 1 then
                v:setLocalZOrder(k)
            end
            nMax = nMax - 1
        end
    end
end

function FourMJScene:updateSelectPai()
    -- body
    --先排序
    local t1 = {}
    local t2 = {}
    for k,v in pairs(self.paiList_self) do
        local id = v:getTag()
        if not helper.isSelectTypePai(self.selectType, id) then
            t1[#t1 + 1] = id
        else
            t2[#t2 + 1] = id
        end
    end
    dump(t1, "未选中")
    dump(t2, "被选中")
    dump(self.selfCardPosList, "tt")

    table.sort(t1,function(a,b) return a>b end)
    table.sort(t2,function(a,b) return a>b end)
    dump(t1, "未选中排序")
    dump(t2, "被选中排序")

    local data = {}
    for i=1,#t2 do
        data[i] = t2[i]
    end
    for i=1,#t1 do
        data[#data + 1] = t1[i]
    end
    dump(data, "最终排序")
    for k,v in pairs(self.paiList_self) do
        v:reSetMJPai(data[k])
        v:setIndex(k)
        v:setLocalZOrder(k)
        local bCan = helper.isSelectTypePai(self.selectType, data[k])
        v:setCanOperate(bCan)
    end
    local isHasSel = false
    for k,v in pairs(self.paiList_self) do
        local ret = helper.isSelectTypePai(self.selectType, v:getTag() )
        if ret then
            isHasSel = true
        end
    end
    print("self.isHasSel ============================", self.isHasSel)
    if not isHasSel then
        for k,v in pairs(self.paiList_self) do
            v:setCanOperate(true)
        end
    end
    for k,v in pairs(self.paiList_self) do
        print(k, v:getIndex(), v:getTag(), v:getCanOperate())
    end
    self.lastPaiId = self.paiList_self[1]:getTag()
end

function FourMJScene:reorderpai(id, count)
    print("FourMJScene:reorderpai(id, count) ..............", id, count)
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
        print("k=", k, v)
        v:setIndex(k)
        v:setPositionX(self.selfCardPosList[k])
        --print(k, v:getIndex(), v:getTag(), v:getPositionX() )
    end
    --[[print("------------------------------------------")
    for _,d in pairs(self.ly_self:getChildren()) do
        print(d:getIndex(), d:getTag() )
    end
    self.lastPaiId = self.paiList_self[1]:getTag()
    ]]
    self:updateSelectPai()
end

function FourMJScene:reOrderByDoing()
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
        local isHasSel = false
        for k,v in pairs(self.paiList_self) do
            v:setIndex(k)
            local ret = helper.isSelectTypePai(self.selectType, v:getTag() )
            if ret then
                isHasSel = true
            end
            print(k, v:getIndex(), v:getTag() )
        end
        print("self.isHasSel ============================", self.isHasSel)
        if not isHasSel then
            for k,v in pairs(self.paiList_self) do
                v:setCanOperate(true)
            end
        end
    end

    if self.lastPaiId ~= -1 then
        --找插入位置
        local nInsPos = 1
        local nSelType = helper.isSelectTypePai(self.selectType, self.lastPaiId)
        
        local index
        for k,v in pairs(self.paiList_self) do
            print("find:", k,v:getIndex(), v:getTag(), v:getPositionX()  )
            local cardid = v:getTag()
            local ret = helper.isSelectTypePai(self.selectType, cardid)
            if nSelType == ret then
                if index == nil then
                    if k ~= 1 then
                        nInsPos = k - 1
                        index = k - 1
                    else
                        nInsPos = k
                        index = k
                    end
                end
                if self.lastPaiId <= cardid then
                    nInsPos = k
                end
            else
                index = nil
            end
        end

        print("nInsPos =,  nOutIdx = ", nInsPos, nOutIdx, self.selfCardPosList[nOutIdx])
        if nOutIdx < nInsPos then
            --打出去的牌在插入的右边
            for i=nOutIdx + 1, nInsPos, 1 do
                local card = self.paiList_self[i]
                --print(i, card:getIndex(), card:getTag(), self.selfCardPosList[i], self.selfCardPosList[i-1] )
                card:setIndex(i-1)
                card:setPositionX(self.selfCardPosList[i-1])
            end
        elseif nOutIdx == nInsPos then
            if nInsPos == 2 then
                local card = self.paiList_self[1]
                card:setIndex(2)
                card:setPositionX(self.selfCardPosList[2])
            end
        else
            --打出去的牌在插入的左边
            local n = nInsPos + 1
            if nInsPos == 1 then
                n = nInsPos
            end
            for i= n, nOutIdx - 1, 1 do
                local card = self.paiList_self[i]
                --print(i, card:getIndex(), card:getTag(), self.selfCardPosList[i], self.selfCardPosList[i+1] )
                card:setIndex(i+1)
                card:setPositionX(self.selfCardPosList[i+1])
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
                    print("插入排序之前！！！！！！！！！！！！！！！！！")
                    for k,v in pairs(self.paiList_self) do
                        v:setIndex(k)
                        print(k, v:getIndex(), v:getTag() )
                    end

                    local nInSert = 0
                    local index
                    for k,v in pairs(self.paiList_self) do
                        print("sort:", k,v:getIndex(), v:getTag() )
                        local cardid = v:getTag()
                        local ret = helper.isSelectTypePai(self.selectType, cardid)
                        if nSelType == ret then
                            if index == nil then
                                if k ~= 1 then
                                    nInSert = k - 1
                                    index = k - 1
                                else
                                    nInSert = k
                                    index = k
                                end
                            end
                            if insertCard:getTag() <= cardid then
                                nInSert = k
                            end
                        else
                            index = nil
                        end
                    end
                    print("nInSert2 ==========================", nInSert, nInSert+1)
                    table.insert(self.paiList_self, nInSert+1, insertCard)

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

function FourMJScene:moPai(nChairID)
    self.ly_add_state:setVisible(false)
    if self.paiList[1] == nil then
        return
    end
    self:getPai(nChairID, self.paiList[1])
    table.remove(self.paiList,1)
end

function FourMJScene:moPaiDs(nChairID)
    self.ly_add_state:setVisible(false)
    self:getPai(nChairID, 1)
end

function FourMJScene:show_add_state_by_type(type)
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

function FourMJScene:addState(type,cardId)
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
                    self:addStateByPai(type,list,cc.MENetUtil:getChairID())
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
                    self:addStateByPai(type,list,cc.MENetUtil:getChairID())
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
                    self:addStateByPai(type,list,cc.MENetUtil:getChairID())
                    break
                end
            end
        end
    elseif type == 5 then -- 明杠 gang
        local list = {}
        table.insert(list,cardId)
        self:addStateByPai(type,list,cc.MENetUtil:getChairID())
    end
end

function FourMJScene:addStateByPai(type,list,nChairID)
    local nIdx = self:getTargetUIChair(nChairID)
    --1 碰 2暗杠 3 吃 4 三杠一 5 明杠
    local delCount = 0
    if nChairID == cc.MENetUtil:getChairID() then
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
                    if curIndex == 1 then
                        self:CreateStatePai(nChairID, type, p, true)
                    else
                        self:CreateStatePai(nChairID, type, p, false)
                    end
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
                    if curIndex == 1 then
                        self:CreateStatePai(nChairID, type, p, true)
                    else
                        self:CreateStatePai(nChairID, type, p, false)
                    end
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
                        local bg_pai2 = DDMaJiang.new(4,1,list[1])
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
            self:moPai(cc.MENetUtil:getChairID())
        end
    else
        print("添加对方状态##################################", type)
        local users = self:getRoomUsers(nChairID)
        local ly_duishou_state = self._children["ly_duishou_state".. nIdx]

        --1 碰 2暗杠 3 吃 4 三杠一 5 明杠
        if type == 1 or type == 3 or type ==4 then
            print("开始删除牌0000000000000000000000000", list[1], type)
            if type == 1 then 
                delCount = 2 
                users.ds_state_pai_count = users.ds_state_pai_count + 2
            end
            if type == 4 then 
                delCount = 3 
                users.ds_state_pai_count = users.ds_state_pai_count + 3
            end

            local curIndex = 0 
            for k,p in pairs(list) do
                if curIndex >= 3 then
                    break
                end
                if curIndex == 1 then
                    self:CreateStatePai(nChairID, type, p, true)
                else
                    self:CreateStatePai(nChairID, type, p, false)
                end
                curIndex = curIndex + 1
            end
            if nIdx == 2 then
                users.nStateTargetDist = users.nStateTargetDist + 20
            else
                users.nStateTargetDist = users.nStateTargetDist + 10
            end
        elseif type == 2 then
            print("开始删除暗杠牌111111111111111111111111111",list[1], type)
            users.ds_state_pai_count = users.ds_state_pai_count + 4
            delCount = 4

            local curIndex = 0
            for k,p in pairs(list) do
                if curIndex >= 3 then
                    break
                end
                if curIndex == 1 then
                    self:CreateStatePai(nChairID, type, p, true)
                else
                    self:CreateStatePai(nChairID, type, p, false)
                end
                curIndex = curIndex + 1
            end
            if nIdx == 2 then
                users.nStateTargetDist = users.nStateTargetDist + 20
            else
                users.nStateTargetDist = users.nStateTargetDist + 10
            end
        elseif type == 5 then
            print("开始删除明杠牌2222222222222222222222222",list[1], type)

            users.ds_state_pai_count = users.ds_state_pai_count + 1
            delCount = 1
           
            local index = 0
            for _,d in pairs(ly_duishou_state:getChildren()) do
                if d:getTag() == list[1] then
                    d:setCurState(type)
                    if index == 1 then
                        local bg_pai2 = DDMaJiang.new(nIdx,1,list[1])
                        bg_pai2:setName("centerCard")
                        bg_pai2:setPosition(d:getContentSize().width/2, d:getContentSize().height/2+10)
                        d:addChild(bg_pai2,10)
                    end
                    index = index + 1
                end
            end
        end

        local ly_duishou = self._children["ly_duishou".. nIdx]
        for _,d in pairs(ly_duishou:getChildren()) do
            d:removeFromParent()
            delCount = delCount - 1
            if delCount == 0 then
                break
            end
        end
        local count = ly_duishou:getChildrenCount()
        for k,v in pairs(ly_duishou:getChildren()) do
            v:setIndex(k)
            v:setPosition(self.targetCardPosList[nIdx][k])
            if nIdx == 1 then
                v:setLocalZOrder(count-k)
            elseif nIdx == 3 then
                v:setLocalZOrder(k)
            end
        end
    end
end

function FourMJScene:CreateStatePai(nChairID, type, id, isCenter)
    -- body
    local nIdx = self:getTargetUIChair(nChairID)

    local bg_pai 
    if type == 2 then
        bg_pai= DDMaJiang.new(nIdx,2,id)
    else
        bg_pai= DDMaJiang.new(nIdx,1,id)
    end
    bg_pai:setCurState(type)
    if nIdx == 4 then
        bg_pai:setScale(0.8)
        local count = self.ly_self_state:getChildrenCount()
        local s = bg_pai:getContentSize()
        if isCenter then
            local bg_pai2
            if type == 4 or type == 2 then
                bg_pai2 = DDMaJiang.new(nIdx,1,id)
            end
            if bg_pai2 ~= nil then
                bg_pai2:setName("centerCard") 
                bg_pai2:setPosition(s.width/2, s.height/2+ 10)
                bg_pai:addChild(bg_pai2,10)
            end
        end
        bg_pai:setPosition(count*s.width* bg_pai:getScale() + self.nStateSelfDist, s.height/2* bg_pai:getScale())
        self.ly_self_state:addChild(bg_pai)
    else
        local users = self:getRoomUsers(nChairID)
        local ly_duishou_state = self._children["ly_duishou_state".. nIdx]
        local size = ly_duishou_state:getContentSize()
        local count = ly_duishou_state:getChildrenCount()
        local s = bg_pai:getContentSize()

        if isCenter then
            local bg_pai2
            if type == 4 or type == 2 then
                bg_pai2 = DDMaJiang.new(nIdx,1,id)
            end
            if bg_pai2 ~= nil then
                bg_pai2:setName("centerCard")
                bg_pai2:setPosition(s.width/2, s.height/2+ 10)
                bg_pai:addChild(bg_pai2,10)
            end
        end

        local nPos
        if nIdx == 2 then
            nPos = cc.p(size.width - (count*(s.width-10)* bg_pai:getScale() + users.nStateTargetDist), s.height* bg_pai:getScale() )
        elseif nIdx == 1 then
            nPos = cc.p(s.width/2* bg_pai:getScale(), size.height - (count*(s.height-16)* bg_pai:getScale() + users.nStateTargetDist) )
            bg_pai:setLocalZOrder(count)
        elseif nIdx == 3 then
            nPos = cc.p(size.width - s.width/2* bg_pai:getScale(), (count*(s.height-16)* bg_pai:getScale() + users.nStateTargetDist) )
            bg_pai:setLocalZOrder(100-count)
        end
        bg_pai:setPosition(nPos)
        ly_duishou_state:addChild(bg_pai)
    end
    return bg_pai
end

function FourMJScene:userAutoChuPai()
    -- body
    print("FourMJScene:userAutoChuPai()..........................")
    if not self.isInitPaiFinish then
        print("FourMJScene:userAutoChuPai() 牌还没初始化完毕！！", self.isInitPaiFinish)
        return
    end
    if self.cur_trustee_state ~= 1 then
        print("FourMJScene:userAutoChuPai() 当前不是用户托管模式！！", self.cur_trustee_state)
        return
    end
    if not self.aleart_pai then
        print("FourMJScene:userAutoChuPai() 当前不是用户出牌！！", self.aleart_pai)
        return
    end
    
    --检测刚发的牌是否是定缺的
    if not helper.isSelectTypePai(self.selectType, self.curPaiId ) then
        local bFind = false
        for k,v in pairs(self.paiList_self) do
            if helper.isSelectTypePai(self.selectType, v:getTag() ) then
                self.curPaiId = v:getTag()
                self.curMaJiang = v
                bFind = true
                break
            end
        end
        --表示未找到定缺类型的
        if not bFind then
            self.curMaJiang = self.paiList_self[1] 
            self.curPaiId = self.curMaJiang:getTag()
        end
    else
        self.curMaJiang = self.paiList_self[1] 
        self.curPaiId = self.curMaJiang:getTag()
    end
    
    local action = cc.Sequence:create(
        cc.DelayTime:create(3),
        cc.CallFunc:create(function()
            if self.cur_trustee_state == 1 then
                print("FourMJScene:userAutoChuPai() finish..........................", self.curPaiId)
                self:chuPai(false, cc.MENetUtil:getChairID() )
            end
        end)
    )
    self:runAction(action)
end

function FourMJScene:GameChuPai(data)
    dump(data, "出牌命令")
    if data.outCardUser == cc.MENetUtil:getChairID() then
        self.curPaiId = helper.getPaiByIndex(data.outCardData)
        for k,v in pairs(self.ly_self:getChildren()) do
            if v:getTag() == self.curPaiId then
                self.curMaJiang = v
                break
            end
        end
    end
    self:chuPai(true, data.outCardUser, helper.getPaiByIndex(data.outCardData) )
    self.lastOutUser = data.outCardUser
    print("我的椅子是=，最后一次出牌的用户是:", cc.MENetUtil:getChairID(), self.lastOutUser)
end

function FourMJScene:GameChuPaiTimeOut()
    self.nChuPaiTimeOutCnts = self.nChuPaiTimeOutCnts + 1

    --检测刚发的牌是否是定缺的
    if not helper.isSelectTypePai(self.selectType, self.curPaiId ) then
        local bFind = false
        for k,v in pairs(self.paiList_self) do
            if helper.isSelectTypePai(self.selectType, v:getTag() ) then
                self.curPaiId = v:getTag()
                self.curMaJiang = v
                bFind = true
                break
            end
        end
        --表示未找到定缺类型的
        if not bFind then
            self.curMaJiang = self.paiList_self[1] 
            self.curPaiId = self.curMaJiang:getTag()
        end
    else
        self.curMaJiang = self.paiList_self[1] 
        self.curPaiId = self.curMaJiang:getTag()
    end

    print("FourMJScene:GameChuPaiTimeOut() finish..........................", self.curPaiId)
    self:chuPai(false, cc.MENetUtil:getChairID() )

    --强制为用户托管
     if self.nChuPaiTimeOutCnts >= 3 then
        self.nChuPaiTimeOutCnts = 0
        --if not cc.MENetUtil:isCustomServer() then
            cc.MENetUtil:setTrustee(true)
        --end
    end
end

function FourMJScene:GameSendPai(data)
    dump(data, "发送扑克")
    self.curPaiCount = self.curPaiCount - 1
    self:updatePaiCount()
    self:setCursor(data.crrentUser)

    if data.crrentUser == cc.MENetUtil:getChairID() then
        self.isMoPai = true
        self.curPaiId = helper.getPaiByIndex(data.cardData)
        print("插入牌数据",data.cardData, self.curPaiId, self.paiList)
        table.insert(self.paiList, self.curPaiId)
        self:moPai(data.crrentUser)
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
        print("GameSendPai finish !!!!!!!!!!!!!!!!!!!!!!!!!!!")
    else
        dump(data,"不是当前用户牌数据")
        self:moPaiDs(data.crrentUser)
    end
end

function FourMJScene:GameOperateNotify(data)
    dump(data, "操作提示")
    if data.actionMask == 0x00 then
        return
    end
    print("操作提示代码", data.actionMask, data.actionCard)
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
end

function FourMJScene:GameOperateNotifyTimeOut()
    if not self.aleart_pai then
        cc.MENetUtil:operatePai(0, 0)
        self:moPai()
    end
end

function FourMJScene:GameOperateResult(data)
    dump(data, "操作命令结果")
    local id = helper.getPaiByIndex(data.cbOperateCard)
    self:setCursor(data.wOperateUser)
    self.ly_add_state:setVisible(false)
    if data.wOperateUser == cc.MENetUtil:getChairID() then
        print("操作命令结果GameOperateResult.................")
        if data.cbOperateCode == 0x08 then
            table.insert(self.pongList, id)
            self.aleart_pai = true
            self.isPong = true
            self:addState(1, id)
            self:pengPaiEffect(cc.MENetUtil:getChairID(), id)

            self:updateOutCard(data.wProvideUser, id)
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
            self:gangPaiEffect(cc.MENetUtil:getChairID(), nType, id, function ( ... )
                -- body
                local bAnGang = false
                if nType == 2 then
                    bAnGang = true
                end
                self:PlayGangEffect(cc.MENetUtil:getChairID(), bAnGang)
            end)

            self:updateOutCard(data.wProvideUser, id)
        elseif data.cbOperateCode == 0x90 then
            print("抢杠删除。。。。。。。。。。。。。。。。。。。。。。。。。 ")
            for _,d in pairs(self.ly_self_state:getChildren()) do
                if d:getTag() == id then
                    d:setCurState(1)
                    local centerCard = d:getChildByName("centerCard")
                    if centerCard ~= nil then
                        centerCard:removeFromParent()
                    end
                end
            end
        end
    else
        dump(data,"不是当前用户牌操作命令数据 ")
        local users = self:getRoomUsers(data.wOperateUser)
        if data.cbOperateCode == 0x08 then
            --碰
            self:addStateByPai(1,{id, id, id},data.wOperateUser)
            table.insert(users.pongList_ds, id)

            self:pengPaiEffect(data.wOperateUser, id)
            self:updateOutCard(data.wProvideUser, id)
        elseif data.cbOperateCode == 0x10 then
            --杠 --1 碰 2暗框 3 吃 4 三杠一 5 明杠
            local curType
            if data.wOperateUser == data.wProvideUser then
                --检查是否是明暗  
                curType = 2
                for i,v in ipairs(users.pongList_ds) do
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
            table.insert(users.pongList_ds, id)
            self:addStateByPai(curType, list, data.wOperateUser)

            self:gangPaiEffect(data.wOperateUser, curType, id, function ( ... )
                -- body
                local bAnGang = false
                if curType == 2 then
                    bAnGang = true
                end
                self:PlayGangEffect(data.wOperateUser, bAnGang)
            end)


            if curType == 4 then
                self:updateOutCard(data.wProvideUser, id)
            end
        elseif data.cbOperateCode == 0x90 then
            print("抢杠删除。。。。。。。。。。。。。。。。。。。。。。。。。 ")
            local nIdx = self:getTargetUIChair(data.wOperateUser)
            local ly_duishou_state = self._children["ly_duishou_state".. nIdx]
            for _,d in pairs(ly_duishou_state:getChildren()) do
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
end

function FourMJScene:GameChiHu(data)
    dump(data, "吃胡结果")
    --检测是点炮还是自摸
    local bZiMo = false
    if data.wChiHuUser == data.wProviderUser then
        bZiMo = true
    end

    local nIdx = self:getTargetUIChair(data.wChiHuUser)
    self._children["ly_result" .. nIdx]:setVisible(true)
    self._children["ly_result" .. nIdx]:setLocalZOrder(1024)

    if bZiMo then
        self._children["ly_result" .. nIdx]:getChildByName("ImgHuType"):loadTexture("img_zimo.png", ccui.TextureResType.plistType)
    else
        self._children["ly_result" .. nIdx]:getChildByName("ImgHuType"):loadTexture("img_dianpao.png", ccui.TextureResType.plistType)
    end
    self:huPaiEffect(data.wChiHuUser, bZiMo)
    
    local head = self._children["head" .. nIdx]
    local labWinOrder = head:getChildByName("labWinOrder")
    labWinOrder:setVisible(true)
    labWinOrder:setString(data.cbWinOrder)

    if data.wChiHuUser == cc.MENetUtil:getChairID() then
        local path
        if self.selfSex == 1 then
            if bZiMo then
                path = "soundfmj/man/zi_1.mp3"
            else
                local id = math.random(1,3)
                path = "soundfmj/man/hu_" .. id .. ".mp3"
            end
        else
            if bZiMo then
                path = "soundfmj/woman/zi_1.mp3"
            else
                path = "soundfmj/woman/hu_1.mp3"
            end
        end
        MEAudioUtils.playSoundEffect(path)
    else
        local users = self:getRoomUsers(data.wChiHuUser)
        local path
        if users.targetSex == 1 then
            if bZiMo then
                path = "soundfmj/man/zi_1.mp3"
            else
                local id = math.random(1,3)
                path = "soundfmj/man/hu_" .. id .. ".mp3"
            end
        else
            if bZiMo then
                path = "soundfmj/woman/zi_1.mp3"
            else
                path = "soundfmj/woman/hu_1.mp3"
            end
        end
        MEAudioUtils.playSoundEffect(path)
    end
    self:showHuPai(nIdx)
    if bZiMo then
        self:showZiMoPai(nIdx, data)
    else
        self:showDianPaoPai(data)
    end
end

function FourMJScene:GameGangScore(data)
    --[[dump(data, "杠操作分数")

    local function showGangScore( isGang, nChairID, nScore )
        -- body
        local nIdx = self:getTargetUIChair(nChairID)

        local labelScore = ccui.TextBMFont:create()
        if isGang then
            labelScore:setFntFile("res/fonts/fnt_8.fnt")
            labelScore:setString("+" .. nScore)
        else
            labelScore:setFntFile("res/fonts/fnt_7.fnt")
            labelScore:setString("-" .. math.abs(nScore))
        end
        local nPos
        if nIdx == 4 then
            nPos = cc.p(me.winSize.width/2, self.ly_self:getPositionY() + 50)
        else
            local ly_duishou = self._children["ly_duishou" .. nIdx]
            if nIdx == 1 then
                nPos = cc.p(ly_duishou:getPositionX() + 50, me.winSize.height/2)
            elseif nIdx == 2 then
                nPos = cc.p(me.winSize.width/2, ly_duishou:getPositionY() + 50)
            elseif nIdx == 3 then
                nPos = cc.p(ly_duishou:getPositionX() + 50, me.winSize.height/2)
            end
        end
        labelScore:setPosition(nPos)
        self._children["ly_battle"]:addChild(labelScore, 200)
        
        local action = cc.Sequence:create(
            cc.ScaleTo:create(0.3, 1.2),
            cc.MoveTo:create(2, cc.p(nPos.x, nPos.y + 50)),
            cc.FadeOut:create(0.8),
            cc.CallFunc:create(function()
                labelScore:removeFromParent()
            end)
        )
        labelScore:runAction(action)
    end

    for i=0, 3 do
        if i == data.wChairId then
            showGangScore(true, i, data.lGangScore[i+1])
        else
            showGangScore(false, i, data.lGangScore[i+1])
        end
    end]]
end

--点炮或自摸
function FourMJScene:showHuPai(nIdx)
    if nIdx == 4 then
        for k,v in pairs(self.ly_self:getChildren()) do
            v:mingPai()
        end
    else 
        local ly_duishou = self._children["ly_duishou".. nIdx]
        for k,v in pairs(ly_duishou:getChildren()) do
            v:gaiPai()
        end
    end
end

--显示自摸的牌
function FourMJScene:showZiMoPai(nIdx, data)
    if nIdx == 4 then

    else
        local ly_duishou = self._children["ly_duishou".. nIdx]
        local id = helper.getPaiByIndex(data.cbChiHuCard)
        for k,v in pairs(ly_duishou:getChildren()) do
            if v:getIndex() == 1 then
                v:setTag(id)
                v:mingPai()
            end
        end
    end
end

--显示点炮的牌
function FourMJScene:showDianPaoPai(data)
    local nIdx = self:getTargetUIChair(data.wChiHuUser)
    local id = helper.getPaiByIndex(data.cbChiHuCard)
    if nIdx == 4 then
        local bg_pai = DDMaJiang.new(nIdx,1, id)
        bg_pai:setScale(0.9)
        local s = bg_pai:getContentSize()
        bg_pai:setPosition(cc.p(self.selfCardPosList[1], s.height/2* bg_pai:getScale() ))
        self.ly_self:addChild(bg_pai)
    else 
        local ly_duishou = self._children["ly_duishou".. nIdx]
        local bg_pai = DDMaJiang.new(nIdx,1,id)
        if nIdx == 2 then
            bg_pai:setScale(1.3)
        end
        local s = bg_pai:getContentSize()
        local pos = self.targetCardPosList[nIdx][1]
        if nIdx == 1 then
            pos.y = pos.y - 10
        elseif nIdx == 3 then
            pos.y = pos.y + 5
        end
        bg_pai:setPosition(pos)
        ly_duishou:addChild(bg_pai)
    end

    nIdx = self:getTargetUIChair(data.wProviderUser)
    if nIdx == 4 then
        for i=#self.selfOutCardList,1, -1 do
            local mj_chu = self.selfOutCardList[i]
            if mj_chu ~= nil and mj_chu:getTag() == id then
                mj_chu:removeFromParent()
                self.selfOutCardList[i] = nil
                break
            end
        end
    else
        local users = self:getRoomUsers(data.wProviderUser)
        for i=#users.targetOutCardList,1, -1 do
            local mj_chu = users.targetOutCardList[i]
            if mj_chu ~= nil and mj_chu:getTag() == id then
                mj_chu:removeFromParent()
                users.targetOutCardList[i] = nil
                break
            end
        end
    end
end

function FourMJScene:GameCustomTable(data)
    -- body
    dump(data, "游戏自定义桌子更新")
    self.customCreateUser = data.dwCreateUser
    for i=0,3 do
        local nIdx = self:getTargetUIChair(i)
        if nIdx == 4 then
            self.lab_self_gold:setString(data.lChairScore[i+1] )
        else
            local head = self._children["head" .. nIdx]
            local gold = head:getChildByName("ImgInfo"):getChildByName("lab_gold")
            gold:setString(data.lChairScore[i+1])
        end
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
    self:showGameRule(data.dwCreateFlag)
end

function FourMJScene:showGameRule(nFlag)
    local tStr = {}
    --番数
    if cc.MEFvMask:HasAny(nFlag, RULE_3_1_1) then
        tStr[#tStr + 1] = helper.getWFName(1)
    end
    if cc.MEFvMask:HasAny(nFlag, RULE_3_1_2) then
        tStr[#tStr + 1] = helper.getWFName(2)
    end
    if cc.MEFvMask:HasAny(nFlag, RULE_3_1_3) then
        tStr[#tStr + 1] = helper.getWFName(3)
    end

    --自摸玩法
    if cc.MEFvMask:HasAny(nFlag, RULE_2_1) then
        tStr[#tStr + 1] = helper.getWFName(4)
    else
        tStr[#tStr + 1] = helper.getWFName(5)
    end

    --点杠花玩法
    if cc.MEFvMask:HasAny(nFlag, RULE_2_2) then
        tStr[#tStr + 1] = helper.getWFName(6)
    else
        tStr[#tStr + 1] = helper.getWFName(7)
    end

    --其他多选玩法
    local tWF = {RULE_4_1_1, RULE_4_1_2, RULE_4_1_3, RULE_4_1_4}
    for k,v in pairs(tWF) do
        if cc.MEFvMask:HasAny(nFlag, v) then
            tStr[#tStr + 1] = helper.getWFName(7+k)
        end
    end
    
    local strWF = ""
    for k,v in pairs(tStr) do
        strWF = strWF .. v .. " "
    end
    self._children["lab_RoomRule"]:setString(strWF)
end

function FourMJScene:GameOver(data)
    dump(data, "游戏结算")
    local nChairID = cc.MENetUtil:getChairID() 
    print("我的座位==================================", nChairID)

    self._children["lab_pai_count"]:setString("")
    local bShowCustomResult = false
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_auto_send"]:setVisible(false)
        self._children["lab_doubleNum"]:setString("局数:".. self.curJuShuCount .. "/" ..self.maxJuShuCount)

        if self.remainJuShuCount < 0 then
            bShowCustomResult = true
        end
    else
        self._children["lab_doubleNum"]:setString("底注:".. self.score)
        self._children["btn_auto_send"]:setVisible(true)
    end
    if self.cur_trustee_state ~= 0 then
        cc.MENetUtil:setTrustee(false)
    end
    data["bShowCustomResult"] = bShowCustomResult
    self:setGameResult(data)
end

function FourMJScene:GameCustomResult(data)
    dump(data, "房卡结算")
    self.customRoomData = clone(data)
    self.customRoomData["users"] = clone(self.roomUsers)
end

function FourMJScene:GameDismissVoteNotify(data)
    dump(data, "解散房间通知")
    if cc.MENetUtil:isCustomServer() then
        self._children["btn_room_jiesan"]:setVisible(false)
        if app:isOpenDialog("MaJiangJieSanLayer") then
            EventDispatcher:dispatchEvent(EventMsgDefine.DismissVoteNotify, data)
        else
            local t = {}
            local info = {}
            info["chair"] = cc.MENetUtil:getChairID()
            info["nickName"] = cc.MENetUtil:getNickName()
            t[cc.MENetUtil:getChairID() + 1] = info

            for k,v in pairs(self.roomUsers) do
                local info = {}
                info["chair"] = v.chair
                info["nickName"] = v.nickName
                t[v.chair + 1] = info
            end
            local params = {}
            params["nType"] = 2
            params["dwRequesterID"] = data.dwRequesterID
            params["users"] = t
            params["cbStatus"] = data.cbStatus
            app:openDialog("MaJiangJieSanLayer", params)
        end
    end
end

function FourMJScene:GameDismissVoteResult(data)
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
function FourMJScene:setGameResult(data)
    -- body
    self._children["timePanel"]:setVisible(false)
    MEAudioUtils.playSoundEffect("soundfmj/game_over.mp3")
   
    local params = clone(data)
    params.users = {}
    for k,v in pairs(self.roomUsers) do
        local info = {}
        info["chair"] = v.chair
        info["nickName"] = v.nickName
        info["type"] = v.type
        info["ficeid"] = v.ficeid
        info["url"] = v.url
        params.users[v.chair + 1] = info
    end
    params.bankerUser = self.bankerUser

    local state_list = {}
    for i=0,3 do
        state_list[i+1] = self:getStatePai(i)
    end
    params["state_list"] = state_list
    --dump(params)
    app:openDialog("FourMJResultLayer", params)
end

function FourMJScene:getStatePai(nChairID)
    -- body
    local nIdx = self:getTargetUIChair(nChairID)
    --1 碰 2暗杠 3 吃 4 三杠一 5 明杠
    local t1 = {}
    local t2 = {}
    local t3 = {}
    local t4 = {}
    local node
    if nIdx == 4 then
        node = self.ly_self_state
    else
        node = self._children["ly_duishou_state" .. nIdx]
    end 

    for _,d in pairs(node:getChildren()) do
        local type = d:getCurState()
        if type == 1 then
            t1[d:getTag()] = d:getTag()
        elseif type == 2 then
            t2[d:getTag()] = d:getTag()
        elseif type == 4 then
            t3[d:getTag()] = d:getTag()
        elseif type == 5 then
            t4[d:getTag()] = d:getTag()
        end
    end
    local data = {}
    data["peng"]        = t1
    data["an_gang"]     = t2
    data["dian_gang"]   = t3
    data["ming_gang"]   = t4
    print("FourMJScene:getStatePai()...................", nIdx, data)
    return data
end

return FourMJScene