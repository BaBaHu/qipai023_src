
local GameController = {}

function GameController:init(scene)
    print("GameController:init(scene) ....................", scene)
    self.scene = scene
end

function GameController:formatTable( data )
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

function GameController:formatTable2( data )
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

function GameController:exitGame()
    -- body
    self:clear()
    self.scene:clear()
    if app:isOpenDialog("LoadLayer") then
        app:closeDialog("LoadLayer")
    end
    audio.playMusic("music/plaza_bg_music.mp3",true)
    app:enterScene("MainScene")
    Helper:scheduleOnce(0.1, function()
        cc.MENetUtil:exitGameRoom()
    end)
end

function GameController:initEvent()
    -- body
    --注册BackToServerList监听回调
    local function OnBackToServerListBackListener(bShowTips)
        -- body
        print("OnBackToServerListBackListener........................", bShowTips)
        MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onBackToServerListBack")
        if not bShowTips then
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
                app:enterScene("MainScene")
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
        self.scene:GameNoticeMessage(message)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onNoticeMessageBack", OnNoticeMessageBackListener)
    
    --注册GameStateOk监听回调
    local function OnGameStateOkBackListener(dict)
        -- body
        --print("OnGameStateOkBackListener.....................................", dict)
        self.scene:enterGame(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameStateOkBack", OnGameStateOkBackListener)
    
    --注册GameStateError监听回调
    local function OnGameStateErrorBackListener()
        -- body
        --print("OnGameStateErrorBackListener.....................................")
        Helper:scheduleOnce(0.15, function()
            self.scene:GameRoomOut()
        end)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameStateErrorBack", OnGameStateErrorBackListener)
    
    --注册GameUser监听回调
    local function OnGameUserBackListener(dict)
        -- body
        --print("OnGameUserBackListener.....................................", dict)
        --self.scene:setTargetPlayerInfo(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameUserBack", OnGameUserBackListener)
    
    --注册GameUserScore监听回调
    local function OnGameUserScoreBackListener(dict)
        -- body
        --print("OnGameUserScoreBackListener.....................................", dict)
        --self.scene:setTargetPlayerScore(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameUserScoreBack", OnGameUserScoreBackListener)
    
    --注册GameUserStatus监听回调
    local function OnGameUserStatusBackListener(dict)
        -- body
        --print("OnGameUserStatusBackListener.....................................", dict)
        --self.scene:setTargetPlayerStatus(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameUserStatusBack", OnGameUserStatusBackListener)
    
    --注册GameUser监听回调
    local function OnUserClockBackListener(nChairID, nClock)
        -- body
        print("OnUserClockBackListener.........................", nChairID, nClock)
        self.scene:UpdateUserClock(nChairID, nClock)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onUserClockBack", OnUserClockBackListener)
    

    --注册GameStart监听回调
    local function OnGameStartBackListener(dict)
        -- body
        --print("OnGameStartBackListener.....................................", dict)
        self.scene:GameStart(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameStartBack", OnGameStartBackListener)
    
    --注册GameFree监听回调
    local function OnGameFreeBackListener(dict)
        -- body
        --print("OnGameFreeBackListener.....................................", dict)
        self.scene:GameFree(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameFreeBack", OnGameFreeBackListener)
    
    --注册GamePlaceBet监听回调
    local function OnGamePlaceBetBackListener(dict)
        -- body
        --print("OnGamePlaceBetBackListener.....................................", dict)
        self.scene:GamePlaceBet(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGamePlaceBetBack", OnGamePlaceBetBackListener)

    --注册GameCancelBet监听回调
    local function OnGameCancelBetBackListener(dict)
        -- body
        --print("OnGameCancelBetBackListener.....................................", dict)
        dict.lPlayBet = self:formatTable( dict.lPlayBet )
        self.scene:GameCancelBet(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameCancelBetBack", OnGameCancelBetBackListener)

    --注册GamePlaceBetFail监听回调
    local function OnGamePlaceBetFailBackListener(dict)
        -- body
        --print("OnGamePlaceBetFailBackListener.....................................", dict)
        self.scene:GamePlaceBetFail(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGamePlaceBetFailBack", OnGamePlaceBetFailBackListener)

    --注册GameApplyBanker监听回调
    local function OnGameApplyBankerBackListener(dict)
        -- body
        --print("OnGameApplyBankerBackListener.....................................", dict)
        self.scene:GameApplyBanker(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameApplyBankerBack", OnGameApplyBankerBackListener)

    --注册GameCancelBanker监听回调
    local function OnGameCancelBankerBackListener(dict)
        -- body
        --print("OnGameCancelBankerBackListener.....................................", dict)
        self.scene:GameCancelBanker(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameCancelBankerBack", OnGameCancelBankerBackListener)

    --注册GameChangeBanker监听回调
    local function OnGameChangeBankerBackListener(dict)
        -- body
        --print("OnGameChangeBankerBackListener.....................................", dict)
        self.scene:GameChangeBanker(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameChangeBankerBack", OnGameChangeBankerBackListener)

    --注册GameReSortBanker监听回调
    local function OnGameReSortBankerBackListener(dict)
        -- body
        --print("OnGameReSortBankerBackListener.....................................", dict)
        dict.wUserList = self:formatTable( dict.wUserList )
        
        self.scene:GameReSortBanker(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameReSortBankerBack", OnGameReSortBankerBackListener)


    --注册GameOver监听回调
    local function OnGameOverBackListener(dict)
        -- body
        --print("OnGameOverBackListener.....................................", dict)
        dict.lPlayScore = self:formatTable( dict.lPlayScore )
        dict.cbCardCount = self:formatTable( dict.cbCardCount )
        dict.cbTableCardArray = self:formatTable2( dict.cbTableCardArray )
        dict.cbWinArea = self:formatTable( dict.cbWinArea )

        self.scene:GameOver(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameOverBack", OnGameOverBackListener)

    --注册GameCommandResult监听回调
    local function OnGameCommandResultBackListener(dict)
        -- body
        --print("OnGameCommandResultBackListener.....................................", dict)
        dict.cbExtendData = self:formatTable( dict.cbExtendData )

        self.scene:GameCommandResult(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameCommandResultBack", OnGameCommandResultBackListener)

    --注册GameTipInfo监听回调
    local function OnGameTipInfoBackListener(dict)
        -- body
        --print("OnGameTipInfoBackListener.....................................", dict)
        self.scene:GameTipInfo(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameTipInfoBack", OnGameTipInfoBackListener)

    --注册GameSendRecord监听回调
    local function OnGameSendRecordBackListener(dict)
        -- body
        --print("OnGameSendRecordBackListener.....................................", dict)
        dict.RecordData = self:formatTable( dict.RecordData )

        self.scene:GameSendRecord(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameSendRecordBack", OnGameSendRecordBackListener)

    --注册GameRecovery监听回调
    local function OnGameRecoveryBackListener(dict)
        -- body
        --print("OnGameRecoveryBackListener.....................................", dict)
        dict.lAllBet = self:formatTable( dict.lAllBet )
        dict.lPlayBet = self:formatTable( dict.lPlayBet )
        dict.lPlayScore = self:formatTable( dict.lPlayScore )
        dict.cbCardCount = self:formatTable( dict.cbCardCount )
        dict.cbTableCardArray = self:formatTable2( dict.cbTableCardArray )
        if dict.cbWinArea ~= nil then
            dict.cbWinArea = self:formatTable( dict.cbWinArea )
        end
        self.scene:GameRecovery(dict)
    end
    MECallBackListenerHelper:getInstance():registerScriptCallBackHandler("onGameRecoveryBack", OnGameRecoveryBackListener)

end

function GameController:clear()
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
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameStartBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameFreeBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGamePlaceBetBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameCancelBetBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGamePlaceBetFailBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameApplyBankerBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameCancelBankerBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameChangeBankerBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameReSortBankerBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameOverBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameCommandResultBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameTipInfoBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameSendRecordBack")
    MECallBackListenerHelper:getInstance():unregisterScriptCallBackHandler("onGameRecoveryBack")
end

return GameController