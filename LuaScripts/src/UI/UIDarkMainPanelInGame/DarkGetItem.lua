require("UI.UIBaseCtrl")
DarkGetItem = class("DarkGetItem", UIBaseCtrl)
DarkGetItem.__index = DarkGetItem
local self = DarkGetItem
function DarkGetItem:__InitCtrl()
end
function DarkGetItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetDarkGetItem("", self))
  if instObj == nil then
    return
  end
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  self:SetRoot(instObj.transform)
  self.destory = false
  self.time = 0
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function DarkGetItem:SetData(data)
  self.ui.mTex_Name.text = data.name
  self.ui.mTex_Name.text = CS.UIDarkZoneUtils.CheckTextByFontSize(self.ui.mTex_Name, 118.8)
  self.ui.mText_Num.text = data.num
  self.ui.mIma_Icon.sprite = IconUtils.GetItemIconSprite(data.itemID)
  CS.LuaDOTweenUtils.TimerOfDG(1.2, function()
    gfdestroy(self.mUIRoot)
    self.destory = true
  end)
end
function DarkGetItem:UpdateSelf()
  self.time = self.time + 1
  if self.destory then
    return true
  end
  if self.time == 40 then
  end
  if self.time > 40 then
    self.ui.mLay_Out.minHeight = self.ui.mLay_Out.minHeight - 6
  end
  if 1 >= self.ui.mLay_Out.minHeight then
    return true
  end
end
function DarkGetItem:DesSelf()
  if self.destory == false then
    gfdestroy(self.mUIRoot)
  end
end
