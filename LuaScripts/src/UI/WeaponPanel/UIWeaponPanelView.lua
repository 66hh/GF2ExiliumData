require("UI.UIBaseView")
UIWeaponPanelView = class("UIWeaponPanelView", UIBaseView)
UIWeaponPanelView.__index = UIWeaponPanelView
function UIWeaponPanelView:ctor()
  self.ui = {}
  self.weaponListContent = nil
end
function UIWeaponPanelView:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  UIWeaponPanelView.mTrans_Mask = self.ui.mTrans_Mask
  self.weaponListContent = UIWeaponListContent.New()
  self.weaponListContent:InitCtrl(self.ui.mTrans_WeaponList)
  self.weaponBreakListContent = UIWeaponBreakListContent.New()
  self.weaponBreakListContent:InitCtrl(self.ui.mTrans_WeaponBreakList)
end
function UIWeaponPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function UIWeaponPanelView:OnClose()
  self.weaponListContent:OnClose()
end
