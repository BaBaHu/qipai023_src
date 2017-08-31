
local RoomJoinLayer = class("RoomJoinLayer", cc.load("mvc").DialogBase)

RoomJoinLayer.RESOURCE_FILENAME = "room_join_layer.csb"

function RoomJoinLayer:onCreate(params) 
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

    self.tNum = {}
    for i=1,6 do
        self._children["ImgNum" .. i]:setVisible(false)
    end
    for i=0,9 do
        local function  onClicked()
            print("this is click i = ", i)
            table.insert(self.tNum, i)
            self._children["ImgNum" .. #self.tNum]:setVisible(true)
            self._children["ImgNum" .. #self.tNum]:loadTexture("num_" .. i .. ".png", ccui.TextureResType.plistType)
            if #self.tNum >= 6 then
                Helper:scheduleOnce(0.5, function()
                    if #self.tNum >= 6 then
                        self:AutoJoinRoom()
                    end
                end)
            end
        end
        self._children["btn_num_" .. i]:addClickEventListener(onClicked)
    end

    local function  OnReInput()
        self.tNum = {}
        for i=1,6 do
            self._children["ImgNum" .. i]:setVisible(false)
        end
    end
    self._children["btn_reinput"]:addClickEventListener(OnReInput)

    local function  OnDel()
        if #self.tNum <= 0 then
            return
        end
        for i=#self.tNum, 6 do
            self._children["ImgNum" .. i]:setVisible(false)
        end
        table.remove(self.tNum, #self.tNum)
        print("self.tNum = ", self.tNum)
    end
    self._children["btn_del"]:addClickEventListener(OnDel)
end

function RoomJoinLayer:AutoJoinRoom()
    -- body
    print("RoomJoinLayer:AutoJoinRoom()", self.tNum)
    app:backDialog()
    
    local params = {}
    params["zorder"] = 1024
    app:openDialog("LoadingLayer", params)

    local strNum = ""
    for k,v in pairs(self.tNum) do
        strNum = strNum .. v
    end
    self.params.enterCustomRoomCallBack(tonumber(strNum))
end

return RoomJoinLayer