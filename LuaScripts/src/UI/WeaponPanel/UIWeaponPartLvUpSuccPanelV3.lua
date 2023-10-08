require("UI.UIBasePanel")
UIWeaponPartLvUpSuccPanelV3 = class("UIWeaponPartLvUpSuccPanelV3", UIBasePanel)
UIWeaponPartLvUpSuccPanelV3.__index = UIWeaponPartLvUpSuccPanelV3
function UIWeaponPartLvUpSuccPanelV3:ctor(csPanel)
  UIWeaponPartLvUpSuccPanelV3.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.lvUpData = nil
  self.attributeList = {}
  self.mView = {}
end
function UIWeaponPartLvUpSuccPanelV3:Close()
  if self.lvUpData.isMaxLv then
    UIManager.CloseUI(UIDef.UIChrWeaponPartsPowerUpPanelV3)
  else
    UIManager.CloseUI(UIDef.UIWeaponPartLvUpSuccPanelV3)
  end
end
function UIWeaponPartLvUpSuccPanelV3:OnInit(root, data)
  UIWeaponPartLvUpSuccPanelV3.super.SetRoot(UIWeaponPartLvUpSuccPanelV3, root)
  self.lvUpData = data
  self:InitView(root)
end
function UIWeaponPartLvUpSuccPanelV3:InitView(root)
  self.mUIRoot = root
  self:LuaUIBindTable(self.mUIRoot, self.mView)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
end
function UIWeaponPartLvUpSuccPanelV3:OnClose()
  self:ReleaseCtrlTable(self.attributeList, true)
end
function UIWeaponPartLvUpSuccPanelV3:OnShowStart()
  self.super.SetPosZ(self)
  self:UpdatePanel()
end
function UIWeaponPartLvUpSuccPanelV3:UpdatePanel()
  if self.lvUpData then
    self.mView.mText_LevelBefore.text = self.lvUpData.fromLv
    self.mView.mText_LevelAfter.text = self.lvUpData.toLv
    if self.lvUpData.attrList then
      local main = self.lvUpData.attrList[1]
      self.mView.mText_Name.text = main.data.show_name.str
      if main.data.show_type == 2 then
        main.value = self:PercentValue(main.value)
        main.upValue = self:PercentValue(main.upValue)
      end
      self.mView.mText_NumBefore.text = main.value
      self.mView.mText_NumNow.text = main.upValue
      for i = 2, #self.lvUpData.attrList do
        local item
        if i <= #self.attributeList then
          item = self.attributeList[i]
        else
          item = ChrPartsAtrributeItemV3.New()
          item:InitCtrl(self.mView.mScrollListChild_GrpPartsAtrribute.transform)
          table.insert(self.attributeList, item)
        end
        local dataList = self.lvUpData.subPropList
        local data = dataList[i - 2]
        local rankList = UIWeaponGlobal.GetSubPropRankWithValueList(data)
        item:SetPropQualityWithValue(rankList)
        local showValue = self.lvUpData.attrList[i].upValue
        if self.lvUpData.attrList[i].isNew then
          showValue = showValue + self.lvUpData.attrList[i].value
        end
        item:SetData(self.lvUpData.attrList[i].data, showValue, false, true, true, true)
        if self.lvUpData.attrList[i].isNew then
          item:SetPartNewProp()
        end
        item:SetPartAffixNew(data.HasNewAffix or self.lvUpData.attrList[i].isNew)
        data.HasNewAffix = false
      end
    end
  end
end
function UIWeaponPartLvUpSuccPanelV3:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
