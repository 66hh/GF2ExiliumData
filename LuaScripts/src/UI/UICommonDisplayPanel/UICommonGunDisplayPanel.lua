require("UI.UICommonDisplayPanel.UICommonGunDisplayPanelView")
require("UI.UIBasePanel")
UICommonGunDisplayPanel = class("UICommonGunDisplayPanel", UIBasePanel)
UICommonGunDisplayPanel.__index = UICommonGunDisplayPanel
UICommonGunDisplayPanel.gunList = nil
UICommonGunDisplayPanel.itemList = {}
function UICommonGunDisplayPanel:ctor(csPanel)
  UICommonGunDisplayPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonGunDisplayPanel.Close()
  UIManager.CloseUI(UIDef.UICommonGunDisplayPanel)
end
function UICommonGunDisplayPanel:OnClose()
  UICommonGunDisplayPanel.gunList = nil
  UICommonGunDisplayPanel.itemList = {}
end
function UICommonGunDisplayPanel:OnInit(root, data)
  UICommonGunDisplayPanel.super.SetRoot(UICommonGunDisplayPanel, root)
  self.mView = UICommonGunDisplayPanelView.New()
  self.mView:InitCtrl(root)
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(self.mUIRoot, self.ui)
  self.gunList = data.gunList ~= nil and data.gunList or data
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UICommonGunDisplayPanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UICommonGunDisplayPanel.Close()
  end
  self:UpdatePanel()
end
function UICommonGunDisplayPanel:UpdatePanel()
  for i = 0, self.gunList.Count - 1 do
    do
      local gunId = self.gunList[i]
      local item = UISimCombatWeeklyRecChrInfoItem.New()
      item:InitCtrl(self.ui.mTrans_GunList)
      item:SetData(self.gunList[i])
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
        self:OnClickGun(gunId)
      end
    end
  end
end
function UICommonGunDisplayPanel:OnClickGun(id)
  UIUnitInfoPanel.Open(UIUnitInfoPanel.ShowType.GunItem, id)
end
