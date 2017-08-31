
local BaiJiaLeResultLayer = class("BaiJiaLeResultLayer", cc.load("mvc").DialogBase)
BaiJiaLeResultLayer.RESOURCE_FILENAME = "game_bjl/bjl_result_layer.csb"

function BaiJiaLeResultLayer:onCreate(data) 
    print("BaiJiaLeResultLayer:onCreate(data).............", data)

    local nPos = cc.p(self._children["panel"]:getPosition())
    local s = self._children["panel"]:getContentSize()
    self._children["panel"]:setPosition(cc.p(nPos.x, display.height + s.height))
    local seq = cc.Sequence:create(
        cc.MoveTo:create(0.5, nPos),
        cc.CallFunc:create(function()

        end)
    )
    self._children["panel"]:runAction(seq)
    self._children["panel"]:addTouchEventListener(function ( ... )
        -- body
        app:backDialog()
    end)

    self._children["ImgFengPoint"]:loadTexture("bjl_r_" .. data.cbPlayerCount .. ".png", ccui.TextureResType.plistType)
    self._children["ImgLongPoint"]:loadTexture("bjl_r_" .. data.cbBankerCount .. ".png", ccui.TextureResType.plistType)

    self._children["lab_feng"]:setString(data.lPlayScore[1])
    self._children["lab_he"]:setString(data.lPlayScore[2])
    self._children["lab_long"]:setString(data.lPlayScore[3])
    self._children["lab_fengdui"]:setString(data.lPlayScore[7])
    self._children["lab_longdui"]:setString(data.lPlayScore[8])

    self._children["label_score"]:setString( string.formatnumberthousands(data.lPlayAllScore))
end

return BaiJiaLeResultLayer
