require("UI.UIBaseView")
UISimCombatDutyOpenDateDialogView = class("UISimCombatDutyOpenDateDialogView", UIBaseView)
UISimCombatDutyOpenDateDialogView.__index = UISimCombatDutyOpenDateDialogView
function UISimCombatDutyOpenDateDialogView:__InitCtrl()
end
function UISimCombatDutyOpenDateDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
