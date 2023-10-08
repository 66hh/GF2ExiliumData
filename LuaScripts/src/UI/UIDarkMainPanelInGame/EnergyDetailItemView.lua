require("UI.UIBaseView")
EnergyDetailItemView = class("EnergyDetailItemView", UIBaseView)
EnergyDetailItemView.__index = EnergyDetailItemView
function EnergyDetailItemView:__InitCtrl()
end
function EnergyDetailItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
