require("UI.UIBasePanel")
UIWeaponPartLvUpSuccPanel = class("UIWeaponPartLvUpSuccPanel", UIBasePanel)
UIWeaponPartLvUpSuccPanel.__index = UIWeaponPartLvUpSuccPanel
UIWeaponPartLvUpSuccPanel.lvUpData = nil
UIWeaponPartLvUpSuccPanel.attributeList = {}
UIWeaponPartLvUpSuccPanel.mView = {}
local self = UIWeaponPartLvUpSuccPanel
function UIWeaponPartLvUpSuccPanel:ctor(csPanel)
  UIWeaponPartLvUpSuccPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeaponPartLvUpSuccPanel:Close()
  UIManager.CloseUI(UIDef.UIWeaponPartLvUpSuccPanel)
  UIWeaponPartLvUpSuccPanel.attributeList = {}
end
function UIWeaponPartLvUpSuccPanel:OnInit(root, data)
  UIWeaponPartLvUpSuccPanel.super.SetRoot(UIWeaponPartLvUpSuccPanel, root)
  self.lvUpData = data
  self:InitView(root)
end
function UIWeaponPartLvUpSuccPanel:InitView(root)
  self.mUIRoot = root
  self:LuaUIBindTable(self.mUIRoot, self.mView)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
end
function UIWeaponPartLvUpSuccPanel:OnShowStart()
  self.super.SetPosZ(self)
  self:UpdatePanel()
end
function UIWeaponPartLvUpSuccPanel:UpdatePanel()
  if self.lvUpData then
    self.mView.mText_FromLv.text = self.lvUpData.fromLv
    self.mView.mText_ToLv.text = self.lvUpData.toLv
    if self.lvUpData.attrList then
      local main = self.lvUpData.attrList[1]
      self.mView.mImage_MainIcon.sprite = IconUtils.GetAttributeIcon(main.data.icon)
      self.mView.mText_MainName.text = main.data.show_name.str
      if main.data.show_type == 2 then
        main.value = self:PercentValue(main.value)
        main.upValue = self:PercentValue(main.upValue)
      end
      self.mView.mText_MainValue.text = main.value
      self.mView.mText_MainUpValue.text = main.upValue
      for i = 2, #self.lvUpData.attrList do
        local item
        if i <= #self.attributeList then
          item = self.attributeList[i]
        else
          item = UICommonPropertyItem.New()
          item:InitCtrl(self.mView.mTrans_AttrList)
          table.insert(self.attributeList, item)
        end
        item:SetData(self.lvUpData.attrList[i].data, self.lvUpData.attrList[i].value, false, true, true, true)
        if self.lvUpData.attrList[i].isNew then
          item:SetPartNewProp()
        else
          item:SetValueUp(self.lvUpData.attrList[i].upValue)
        end
        setactive(item.mTrans_Bg, i % 2 == 0)
      end
    end
  end
end
function UIWeaponPartLvUpSuccPanel:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
