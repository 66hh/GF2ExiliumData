require("UI.UIBaseCtrl")
DarkPackAgeMoneyItem = class("DarkPackAgeMoneyItem", UIBaseCtrl)
DarkPackAgeMoneyItem.__index = DarkPackAgeMoneyItem
local self = DarkPackAgeMoneyItem
function DarkPackAgeMoneyItem:__InitCtrl()
end
function DarkPackAgeMoneyItem:InitCtrl(obj)
  self:SetRoot(obj.transform:GetChild(0))
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function DarkPackAgeMoneyItem:SetData(data)
  self.ui.mText_Num.text = data
end
function DarkPackAgeMoneyItem:OnRelease()
end
