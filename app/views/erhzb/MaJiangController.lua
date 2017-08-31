
local MaJiangController = {}

function MaJiangController:init(scene, params)
    print("MaJiangController:init(scene, params) ....................", scene, params)
    self.scene = scene
    self.params = params
    self.isDismisCustomServer = false
    self.voiceList = {}
    self.voiceState = 0
end

function MaJiangController:dismisCustomServer(bRoomCreater)
    self.isDismisCustomServer = true
    cc.MENetUtil:dismisCustomServer(bRoomCreater)
end

function MaJiangController:GameVoiceFinish()
    -- body
    self.voiceState = 0
    table.remove(self.voiceList, 1)
    if #self.voiceList > 0 then
        self.voiceState = 1
        self.scene:GameVoiceStartPlay(self.voiceList[1])
    end
end

function MaJiangController:formatTable( data )
    -- body
    --print(data)
    local t = {}
    for k,v in pairs(data) do
        --print(k,v)
        t[tonumber(k)] = v
    end
    --print(t)
    return t
end

function MaJiangController:formatTable2( data )
    -- body
    --print(data)
    local t = {}
    for k,v in pairs(data) do
        --print(k,v)
        local t2 = {}
        for j,m in pairs(v) do
            --print(j,m)
            t2[tonumber(j)] = m
        end
        t[tonumber(k)] = t2
    end
    --print(t)
    return t
end

function MaJiangController:exitGame()
    -- body
    self:clear()
    self.scene:clear()
    if app:isOpenDialog("LoadLayer") then
        app:closeDialog("LoadLayer")
    end
    audio.playMusic("music/plaza_bg_music.mp3",true)
    app:enterScene("TableScene", self.params)
end

function MaJiangController:backGame(isShowGoBack)
    -- body
    self:clear()
    self.scene:clear()
    if app:isOpenDialog("LoadLayer") then
        app:closeDialog("LoadLayer")
    end
    audio.playMusic("music/plaza_bg_music.mp3",true)
    local params = {}
    params["isShowGoBack"] = isShowGoBack
    app:enterScene("MainScene", params)
    Helper:scheduleOnce(0.1, function()
        cc.MENetUtil:exitGameRoom()
    end)
end

function MaJiangController:initEvent()
    -- body
    --注册BackToServerList监听回调
    local function OnBackToServerListBackListener(bShowTips)
        -- body
        print("OnBackToServerListBackListener........................", bShowTips)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBackToServerListBack")
        if self.isDismisCustomServer or not bShowTips then
            self:clear()
            self.scene:clear()
            audio.playMusic("music/plaza_bg_music.mp3",true)
            app:enterScene("MainScene")
            Helper:scheduleOnce(0.1, function()
                cc.MENetUtil:exitGameRoom()
            end)
        else
            local function okCallBack()
                -- body
                self:clear()
                self.scene:clear()
                audio.playMusic("music/plaza_bg_music.mp3",true)
                if cc.MENetUtil:isCustomServer() then
                    app:gotologin()
                else    
                    app:enterScene("MainScene")
                end
                Helper:scheduleOnce(0.1, function()
                    cc.MENetUtil:exitGameRoom()
                end)
            end
            self.scene:showTips(GameTipsConfig[14], okCallBack)
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onBackToServerListBack", OnBackToServerListBackListener)
    
    --注册BackToTable监听回调
    local function OnBackToTableBackListener()
        -- body
        print("OnBackToTableBackListener.....................................")
        self:exitGame()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onBackToTableBack", OnBackToTableBackListener)
    
    --注册NoticeMessage监听回调
    local function OnNoticeMessageBackListener(message)
        -- body
        --print("OnNoticeMessageBackListener.....................................", message)
        self.scene:GameInfoTips(message)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onNoticeMessageBack", OnNoticeMessageBackListener)
    
    --注册GameStateOk监听回调
    local function OnGameStateOkBackListener(dict)
        -- body
        --print("OnGameStateOkBackListener.....................................", dict)
        dict.bTrustee  = self:formatTable( dict.bTrustee )

        self.scene:enterGame(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameStateOkBack", OnGameStateOkBackListener)
    
    --注册GameStateError监听回调
    local function OnGameStateErrorBackListener()
        -- body
        --print("OnGameStateErrorBackListener.....................................")
        Helper:scheduleOnce(0.1, function()
            self.scene:GameRoomOut()
        end)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameStateErrorBack", OnGameStateErrorBackListener)
    
    --注册GameUser监听回调
    local function OnGameUserBackListener(dict)
        -- body
        --print("OnGameUserBackListener.....................................", dict)
        self.scene:setTargetPlayerInfo(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameUserBack", OnGameUserBackListener)
    
    --注册GameUserScore监听回调
    local function OnGameUserScoreBackListener(dict)
        -- body
        --print("OnGameUserScoreBackListener.....................................", dict)
        self.scene:setTargetPlayerScore(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameUserScoreBack", OnGameUserScoreBackListener)
    
    --注册GameUserStatus监听回调
    local function OnGameUserStatusBackListener(dict)
        -- body
        --print("OnGameUserStatusBackListener.....................................", dict)
        self.scene:setTargetPlayerStatus(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameUserStatusBack", OnGameUserStatusBackListener)
    
    --注册GameUser监听回调
    local function OnUserClockBackListener(nChairID, nClock)
        -- body
        --print("OnUserClockBackListener.........................", nChairID, nClock)
        self.scene:UpdateUserClock(nChairID, nClock)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onUserClockBack", OnUserClockBackListener)
    
    --注册GameCustomTable监听回调
    local function OnGameCustomTableBackListener(dict)
        -- body
        --print("OnGameCustomTableBackListener.........................", dict)
        dict.lChairScore = self:formatTable( dict.lChairScore )
        self.scene:GameCustomTable(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameCustomTableBack", OnGameCustomTableBackListener)
    
    --注册GameStart监听回调
    local function OnGameStartBackListener(dict)
        -- body
        --print("OnGameStartBackListener.....................................", dict)
        dict.cardData       = self:formatTable( dict.cardData )
        dict.heapCardInfo   = self:formatTable2( dict.heapCardInfo )

        Helper:scheduleOnce(0.1, function()
            self.scene:initPaiData(dict)
        end)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameStartBack", OnGameStartBackListener)
    
    --注册GameSetConfig监听回调
    local function OnGameSetConfigBackListener(value)
        -- body
        --print("OnGameSetConfigBackListener.....................................", value)
        self.scene:SettingDiZhu(value)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameSetConfigBack", OnGameSetConfigBackListener)
    
    --注册GameChuPai监听回调
    local function OnGameChuPaiBackListener(dict)
        -- body
        --print("OnGameChuPaiBackListener.....................................", dict)
        self.scene:GameChuPai(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameChuPaiBack", OnGameChuPaiBackListener)

    --注册GameChuPaiTimeOut监听回调
    local function OnGameChuPaiTimeOutBackListener()
        -- body
        --print("OnGameChuPaiTimeOutBackListener.....................................")
        self.scene:GameChuPaiTimeOut()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameChuPaiTimeOutBack", OnGameChuPaiTimeOutBackListener)

    --注册GameSeedPai监听回调
    local function OnGameSeedPaiBackListener(dict)
        -- body
        --print("OnGameSeedPaiBackListener.....................................", dict)
        self.scene:GameSendPai(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameSeedPaiBack", OnGameSeedPaiBackListener)

    --注册GameOperateNotify监听回调
    local function OnGameOperateNotifyBackListener(dict)
        -- body
        --print("OnGameOperateNotifyBackListener.....................................", dict)
        self.scene:GameOperateNotify(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameOperateNotifyBack", OnGameOperateNotifyBackListener)

    --注册GameOperateNotifyTimeOut监听回调
    local function OnGameOperateNotifyTimeOutBackListener()
        -- body
        --print("OnGameOperateNotifyTimeOutBackListener.....................................")
        self.scene:GameOperateNotifyTimeOut()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameOperateNotifyTimeOutBack", OnGameOperateNotifyTimeOutBackListener)

    --注册GameOperateResult监听回调
    local function OnGameOperateResultBackListener(dict)
        -- body
        --print("OnGameOperateResultBackListener.....................................", dict)
        dict.cbOperateCard = self:formatTable( dict.cbOperateCard )
        self.scene:GameOperateResult(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameOperateResultBack", OnGameOperateResultBackListener)

    --注册GameOver监听回调
    local function OnGameOverBackListener(dict)
        -- body
        --print("OnGameOverBackListener.....................................", dict)
        dict.dwChiHuRight   = self:formatTable( dict.dwChiHuRight )
        dict.dwChiHuKind    = self:formatTable( dict.dwChiHuKind )
        dict.lGameScore     = self:formatTable( dict.lGameScore )
        dict.lGangScore     = self:formatTable( dict.lGangScore )
        dict.cbCardCount    = self:formatTable( dict.cbCardCount )
        dict.cbCardData     = self:formatTable2( dict.cbCardData )
        self.scene:GameOver(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameOverBack", OnGameOverBackListener)

    --注册GameTrustee监听回调
    local function OnGameTrusteeBackListener(dict)
        -- body
        --print("OnGameTrusteeBackListener.....................................", dict)
        self.scene:setGameTrustee(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameTrusteeBack", OnGameTrusteeBackListener)

    --注册GameReplaceCard监听回调
    local function OnGameReplaceCardBackListener(dict)
        -- body
        --print("OnGameReplaceCardBackListener.....................................", dict)
        
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameReplaceCardBack", OnGameReplaceCardBackListener)

    --注册GameChangeTableOwner监听回调
    local function OnGameChangeTableOwnerBackListener(dict)
        -- body
        --print("OnGameChangeTableOwnerBackListener.....................................", dict)
        self.scene:UpdateTabler(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameChangeTableOwnerBack", OnGameChangeTableOwnerBackListener)

    --注册GameExit监听回调
    local function OnGameExitBackListener()
        -- body
        --print("OnGameExitBackListener.....................................")
        local nGold = math.floor(cc.MENetUtil:getTableMinGold()/GameDataConfig.DiZHUBASE)
        local function doOK()
            -- body
            self:exitGame()
        end
        self:showTips("您的分数已经低于设置的底注".. nGold .. "！", doOK)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameExitBack", OnGameExitBackListener)

    --注册GameRecovery监听回调
    local function OnGameRecoveryBackListener(dict)
        -- body
        --print("OnGameRecoveryBackListener.....................................", dict)
        dict.cbCardData = self:formatTable( dict.cbCardData )
        dict.bTrustee = self:formatTable( dict.bTrustee )
        dict.cbDiscardCount = self:formatTable( dict.cbDiscardCount )
        dict.cbDiscardCard = self:formatTable2( dict.cbDiscardCard )
        dict.cbWeaveCount = self:formatTable( dict.cbWeaveCount )
        dict.cbHeapCardInfo = self:formatTable2( dict.cbHeapCardInfo )

        dict.WeaveItemArray = self:formatTable2( dict.WeaveItemArray )
        for k,v in pairs(dict.WeaveItemArray) do
            --print(k,v)
            if dict.WeaveItemArray[k].cbCardData ~= nil then
                dict.WeaveItemArray[k].cbCardData = self:formatTable( dict.WeaveItemArray[k].cbCardData )
            end
        end
        --print("dict= ", dict)
        self.scene:continueGame(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameRecoveryBack", OnGameRecoveryBackListener)

    --注册GameCustomResult监听回调
    local function OnGameCustomResultBackListener(dict)
        -- body
        --print("OnGameCustomResultBackListener.....................................", dict)
        dict.dwUserID = self:formatTable( dict.dwUserID )
        dict.lUserScore = self:formatTable( dict.lUserScore )
        dict.dwUserFace = self:formatTable( dict.dwUserFace )
        dict.szNick = self:formatTable( dict.szNick )
        dict.dwDataCount = self:formatTable( dict.dwDataCount )
        
        self.scene:GameCustomResult(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameCustomResultBack", OnGameCustomResultBackListener)

    --注册GameQianGangCard监听回调
    local function OnGameQianGangCardBackListener(dict)
        -- body
        --print("OnGameQianGangCardBackListener.....................................", dict)
        self.scene:GameQianGangCard(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameQianGangCardBack", OnGameQianGangCardBackListener)

    --注册GameDismissVoteNotify监听回调
    local function OnGameDismissVoteNotifyBackListener(dict)
        -- body
        --print("OnGameDismissVoteNotifyBackListener.....................................", dict)
        dict.cbStatus = self:formatTable( dict.cbStatus )

        self.scene:GameDismissVoteNotify(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameDismissVoteNotifyBack", OnGameDismissVoteNotifyBackListener)

    --注册GameDismissVoteResult监听回调
    local function OnGameDismissVoteResultBackListener(dict)
        -- body
        --print("OnGameDismissVoteResultBackListener.....................................", dict)
        self.scene:GameDismissVoteResult(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameDismissVoteResultBack", OnGameDismissVoteResultBackListener)

    --注册GameVoiceStartPlay监听回调
    local function OnGameVoiceStartPlayBackListener(dict)
        -- body
        --print("OnGameVoiceStartPlayBackListener.....................................", dict)
        if self.voiceState == 0 then
            self.voiceState = 1
            self.scene:GameVoiceStartPlay(dict)
        else
            self.voiceList[#self.voiceList + 1] = dict
        end
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameVoiceStartPlayBack", OnGameVoiceStartPlayBackListener)

    --注册GameVoicePlayFinish监听回调
    local function OnGameVoicePlayFinishBackListener()
        -- body
        --print("OnGameVoicePlayFinishBackListener.....................................")
        self.scene:GameVoicePlayFinish()
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameVoicePlayFinishBack", OnGameVoicePlayFinishBackListener)

end

function MaJiangController:clear()
    -- body
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBackToServerListBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBackToTableBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onNoticeMessageBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameStateOkBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameStateErrorBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameUserBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameUserStatusBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameUserScoreBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onUserClockBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameCustomTableBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameStartBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameSetConfigBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameChuPaiBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameChuPaiTimeOutBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameSeedPaiBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameOperateNotifyBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameOperateNotifyTimeOutBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameOperateResultBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameOverBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameTrusteeBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameReplaceCardBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameChangeTableOwnerBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameExitBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameRecoveryBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameCustomResultBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameDismissVoteNotifyBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameDismissVoteResultBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameVoiceStartPlayBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameVoicePlayFinishBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameQianGangCardBack")
end

return MaJiangController