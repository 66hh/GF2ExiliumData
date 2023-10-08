require("UI.UIBaseView")
UIUAVUnlockPartsDialogView = class("UIUAVUnlockPartsDialogView", UIBaseView)
UIUAVUnlockPartsDialogView.__index = UIUAVUnlockPartsDialogView
function UIUAVUnlockPartsDialogView:__InitCtrl()
end
function UIUAVUnlockPartsDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
