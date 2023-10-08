require("UI.UIBaseView")
DarkTargetAvatarView = class("DarkTargetAvatarView", UIBaseView)
DarkTargetAvatarView.__index = DarkTargetAvatarView
function DarkTargetAvatarView:__InitCtrl()
end
function DarkTargetAvatarView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
