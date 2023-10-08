require("UI.UIBasePanel")
UIWeaponLvUpSuccPanel = class("UIWeaponLvUpSuccPanel", UIBasePanel)
UIWeaponLvUpSuccPanel.__index = UIWeaponLvUpSuccPanel
UIWeaponLvUpSuccPanel.lvUpData = nil
UIWeaponLvUpSuccPanel.attributeList = {}
function UIWeaponLvUpSuccPanel:ctor(csPanel)
  UIWeaponLvUpSuccPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeaponLvUpSuccPanel:Close()
  UIManager.CloseUI(UIDef.UIWeaponLvUpSuccPanel)
end
function UIWeaponLvUpSuccPanel:OnHide()
  UIWeaponLvUpSuccPanel.attributeList = {}
end
function UIWeaponLvUpSuccPanel:OnInit(root, data)
  self = UIWeaponLvUpSuccPanel
  UIWeaponLvUpSuccPanel.super.SetRoot(UIWeaponLvUpSuccPanel, root)
  self.lvUpData = data
  self:InitView(root)
end
function UIWeaponLvUpSuccPanel:InitView(root)
  self.mUIRoot = root
  self.mBtn_Close = UIUtils.GetRectTransform(root, "Root/GrpBg/Btn_Close")
  self.mText_FromLv = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpLevelUp/GrpTextLevelUp/GrpTextNow/Text_Level")
  self.mText_ToLv = UIUtils.GetText(root, "Root/GrpDialog/GrpCenter/GrpLevelUp/GrpTextLevelUp/GrpTextSoon/Text_Level")
  self.mTrans_AttrList = UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpCenter/GrpPowerUp/AttributeList/Viewport/Content")
  self.mTrans_EffectBg = UIUtils.GetRectTransform(root, "Root/GrpDialog/GrpTittle/GrpBg/ImgBg1")
  UIUtils.GetButtonListener(self.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
end
function UIWeaponLvUpSuccPanel:OnShowStart()
  self.super.SetPosZ(self)
  self:UpdatePanel()
end
function UIWeaponLvUpSuccPanel:UpdatePanel()
  if self.lvUpData then
    self.mText_FromLv.text = self.lvUpData.fromLv
    self.mText_ToLv.text = self.lvUpData.toLv
    if self.lvUpData.attrList then
      for i = 1, #self.lvUpData.attrList do
        local item
        if i <= #self.attributeList then
          item = self.attributeList[i]
        else
          item = UICommonPropertyItem.New()
          item:InitCtrl(self.mTrans_AttrList)
          table.insert(self.attributeList, item)
        end
        item:SetData(self.lvUpData.attrList[i].data, self.lvUpData.attrList[i].value, false, false, true, false)
        item:SetValueUp(self.lvUpData.attrList[i].upValue)
      end
    end
  end
end
function UIWeaponLvUpSuccPanel:SetEffectSortOrder(root)
  UIUtils.SetMeshRenderSortOrder(root.gameObject, UIManager.GetTopPanelSortOrder())
end
