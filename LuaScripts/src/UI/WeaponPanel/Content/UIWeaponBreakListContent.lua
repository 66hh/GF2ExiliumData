require("UI.UIBaseCtrl")
UIWeaponBreakListContent = class("UIWeaponBreakListContent", UIBaseCtrl)
UIWeaponBreakListContent.__index = UIWeaponBreakListContent
function UIWeaponBreakListContent:ctor()
  self.ui = {}
end
function UIWeaponBreakListContent:__InitCtrl()
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UIWeaponBreakListContent:InitCtrl(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
