require("UI.UIBaseView")
UIDarkzoneReliabilityDetailDialogView = class("UIDarkzoneReliabilityDetailDialogView", UIBaseView)
UIDarkzoneReliabilityDetailDialogView.__index = UIDarkzoneReliabilityDetailDialogView
function UIDarkzoneReliabilityDetailDialogView:__InitCtrl()
end
function UIDarkzoneReliabilityDetailDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
