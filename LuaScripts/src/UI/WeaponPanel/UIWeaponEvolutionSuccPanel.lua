require("UI.UIBasePanel")
UIWeaponEvolutionSuccPanel = class("UIWeaponEvolutionSuccPanel", UIBasePanel)
UIWeaponEvolutionSuccPanel.__index = UIWeaponEvolutionSuccPanel
function UIWeaponEvolutionSuccPanel:ctor(csPanel)
  UIWeaponEvolutionSuccPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  UIWeaponEvolutionSuccPanel.mView = {}
  UIWeaponEvolutionSuccPanel.weaponItem = nil
  UIWeaponEvolutionSuccPanel.stageItem = nil
end
function UIWeaponEvolutionSuccPanel:Close()
  self = UIWeaponEvolutionSuccPanel
  UIManager.CloseUI(UIDef.UIWeaponEvolutionSuccPanel)
  if self.callback then
    self.callback()
  end
end
function UIWeaponEvolutionSuccPanel:OnInit(root, data)
  self = UIWeaponEvolutionSuccPanel
  UIWeaponEvolutionSuccPanel.super.SetRoot(UIWeaponEvolutionSuccPanel, root)
  self:LuaUIBindTable(root, self.mView)
  self.mData = TableData.listGunWeaponDatas:GetDataById(data[1])
  self.itemData = data[2]
  self.callback = data[3]
  UIWeaponEvolutionSuccPanel.super.SetPosZ(UIWeaponEvolutionSuccPanel)
  self.weaponItem = UICommonItem.New()
  self.weaponItem:InitCtrl(self.mView.mTrans_Item)
  self.stageItem = UICommonStageItem.New(self.mData.default_maxlv)
  self.stageItem:InitCtrl(self.mView.mTrans_Stage)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
end
function UIWeaponEvolutionSuccPanel:OnShowStart()
  self = UIWeaponEvolutionSuccPanel
  self:UpdatePanel()
end
function UIWeaponEvolutionSuccPanel:UpdatePanel()
  self.weaponItem:SetData(self.mData.id, self.mData.default_maxlv)
  self.mView.mText_Name.text = self.mData.name.str
  self.mView.mImage_Icon.sprite = IconUtils.GetItemIconSprite(self.itemData.id)
  self.mView.mText_Num.text = self.itemData.num
end
