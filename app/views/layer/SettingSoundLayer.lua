
local SettingSoundLayer = class("SettingSoundLayer", cc.load("mvc").DialogBase)

SettingSoundLayer.RESOURCE_FILENAME = "sound_set_layer.csb"

function SettingSoundLayer:onCreate(isShow) 
    self:setInOutEffectEnable(true)

    local function  removeSelf()
        cc.UserDefault:getInstance():setIntegerForKey("sound_music", self.volume_music)
        cc.UserDefault:getInstance():setIntegerForKey("sound_effect", self.volume_effect)
        cc.UserDefault:getInstance():flush()
        app:backDialog()
    end
    self._children["btn_close"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    local function  jiesuan()
        app:backDialog()
        EventDispatcher:dispatchEvent(EventMsgDefine.GameJieSuan)
    end
    self._children["btn_jiesuan"]:addClickEventListener(jiesuan)
    self._children["btn_jiesuan"]:setVisible(isShow)

    local volume_music = cc.UserDefault:getInstance():getIntegerForKey("sound_music", 100)
    local volume_effect = cc.UserDefault:getInstance():getIntegerForKey("sound_effect", 100)
    self._children["slider_music"]:setPercent(volume_music)
    self._children["slider_music"]:setTag(1)
    self._children["slider_sound"]:setPercent(volume_effect)
    self._children["slider_sound"]:setTag(2)

    self.volume_music = volume_music
    self.volume_effect = volume_effect

    local function percentChangedEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local tag = sender:getTag()
            local percent = sender:getPercent() / sender:getMaxPercent() * 100
            print("tag, percent", tag, percent)
            if tag == 1 then
                self.volume_music = percent
                audio.setMusicVolume(percent*0.01)
            elseif tag == 2 then
                self.volume_effect = percent
                audio.setSoundsVolume(percent*0.01)
            end
        end
    end

    self._children["slider_music"]:addEventListener(percentChangedEvent)
    self._children["slider_sound"]:addEventListener(percentChangedEvent)
end


return SettingSoundLayer
