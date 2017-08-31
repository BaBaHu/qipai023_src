
local MaJiangSetDiZhu = class("MaJiangSetDiZhu", cc.load("mvc").DialogBase)

MaJiangSetDiZhu.RESOURCE_FILENAME = "game_erhzb/dizhu_set_layer.csb"

function MaJiangSetDiZhu:onCreate()   
    local function removeSelf()
        app:backDialog()
    end
    self._children["btn_dizhu_cancel"]:addClickEventListener(removeSelf)
    
    self:registerKeyboardListener(function ( ... )
        -- body
        removeSelf()
    end)

    local function settingDiZhu()
        local nDizhu = 0 
        local con = self._children["txt_dizhu"]:getString()
        if con ~= "" then
            nDizhu = tonumber(con)
        end
        if nDizhu <= 0 then
            self:showTips("请输入正确的底注信息！")
            return
        end
        local nGold = math.floor(cc.MENetUtil:getTableMinGold()/GameDataConfig.DiZHUBASE)
        if nDizhu > nGold then
            self:showTips("输入的底注过大!根据当前玩家的分数,您可设置的底注最大为:".. nGold)
            return
        end
        removeSelf()
        cc.MENetUtil:setDizhu(nDizhu)
    end
    self._children["btn_dizhu_ok"]:addClickEventListener(settingDiZhu) 
end

return MaJiangSetDiZhu
