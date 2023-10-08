require("UI.UIBaseCtrl")
UIComEquipmentInfo = class("UIComEquipmentInfo", UIBaseCtrl)
function UIComEquipmentInfo:ctor(parent)
  local go = self:Instantiate("Character/ChrWeaponEquipInfoItemV2.prefab", parent)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(go)
  self.equipSubPanel = self:newEquipSubPanel(self.ui.mTrans_EquipContent)
  setactive(self:GetRoot(), true)
end
function UIComEquipmentInfo:InitByDarkEquipItem(darkEquipItem)
  local itemId = darkEquipItem.itemID
  local mainAffix = darkEquipItem.equip.darkaffix
  local subAffixList = darkEquipItem.equip.darkaffixList
  self:Init(itemId, mainAffix, subAffixList)
end
function UIComEquipmentInfo:Init(itemId, mainAffix, subAffixList)
  self.equipSubPanel:SetData(itemId, mainAffix, subAffixList)
end
function UIComEquipmentInfo:AddBtnClickListener(callback)
  self.callback = callback
end
function UIComEquipmentInfo:Refresh()
  self.equipSubPanel:Refresh()
end
function UIComEquipmentInfo:OnRelease()
  self.callback = nil
  self.equipSubPanel:OnRelease()
  self.equipSubPanel = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIComEquipmentInfo:SetGrpEquipVisible(visible)
  self.equipSubPanel:SetVisible(visible)
end
function UIComEquipmentInfo:SetGrpActionVisible(visible)
  setactive(self.ui.mTrans_GrpAction, visible)
end
function UIComEquipmentInfo:newEquipSubPanel(root)
  local tempSubPanel = {}
  tempSubPanel.root = root
  tempSubPanel.ui = UIUtils.GetUIBindTable(root)
  tempSubPanel.attributeList = {}
  tempSubPanel.skillList = {}
  tempSubPanel.commonItem = UICommonItem.New()
  tempSubPanel.commonItem:InitObj(tempSubPanel.ui.mBtn_Select)
  tempSubPanel.commonItem:EnableButton(false)
  function tempSubPanel:SetData(itemId, mainAffix, subAffixList)
    self.itemId = itemId
    self.mainAffix = mainAffix
    self.subAffixList = subAffixList
  end
  function tempSubPanel:Refresh()
    self:refreshTitleGroup()
    self:refreshAttribute()
    self:refreshDesc()
  end
  function tempSubPanel:SetVisible(visible)
    setactive(self.root, visible)
  end
  function tempSubPanel:refreshTitleGroup()
    local itemData = TableData.listItemDatas:GetDataById(self.itemId)
    self.commonItem:SetDarkZoneEquipData(self.itemId)
    self.ui.mText_Name.text = itemData.name.str
    self.ui.mText_Class.text = TableData.GetHintById(903031)
  end
  function tempSubPanel:refreshAttribute()
    local mainAffix = self.mainAffix
    local subAffixList = self.subAffixList
    local attrList = {}
    if mainAffix then
      local tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(mainAffix.id)
      local propData = TableData.GetPropertyDataByName(tableData.effect, 0)
      self.ui.mText_MainAttrName.text = propData.ShowName.str
      if tableData.buff_base_type == 2 then
        self.ui.mText_MainAttrValue.text = mainAffix.value / 10 .. "%"
      else
        self.ui.mText_MainAttrValue.text = mainAffix.value
      end
    end
    if subAffixList then
      for i = 0, subAffixList.Count - 1 do
        table.insert(attrList, subAffixList[i])
      end
    end
    if attrList then
      local item
      for _, item in ipairs(self.attributeList) do
        item:SetData(nil)
      end
      for i = 1, #attrList do
        local prop = attrList[i]
        local tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(prop.id)
        local propData = TableData.GetPropertyDataByName(tableData.effect, 0)
        if i <= #self.attributeList then
          item = self.attributeList[i]
        else
          item = UICommonPropertyItem.New()
          item:InitCtrl(self.ui.mTrans_AttributeList)
          table.insert(self.attributeList, item)
        end
        item:SetData(propData, prop.value, false, false, i % 2 == 0, false)
      end
    end
  end
  function tempSubPanel:refreshDesc()
  end
  function tempSubPanel:OnRelease()
    self.mainAffix = nil
    self.subAffixList = nil
    self.commonItem:OnRelease()
  end
  return tempSubPanel
end
