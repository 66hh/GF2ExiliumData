require("UI.UIDarkBagPanel.UIDarkZonePropertyDetailDialogView")
require("UI.UIBasePanel")
UIDarkZonePropertyDetailDialog = class("UIDarkZonePropertyDetailDialog", UIBasePanel)
UIDarkZonePropertyDetailDialog.__index = UIDarkZonePropertyDetailDialog
function UIDarkZonePropertyDetailDialog:ctor(csPanel)
  UIDarkZonePropertyDetailDialog.super.ctor(UIDarkZonePropertyDetailDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZonePropertyDetailDialog:OnInit(root, data)
  UIDarkZonePropertyDetailDialog.super.SetRoot(UIDarkZonePropertyDetailDialog, root)
  self:InitBaseData()
  self.mData = data
  self.mView = UIDarkZonePropertyDetailDialogView.New()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListener()
  if self.mData.dataType == 1 then
    self:RefreshPropertyDetail()
  else
    self:RefreshPropertyDetailByRepositoryData()
  end
end
function UIDarkZonePropertyDetailDialog:OnShowFinish()
end
function UIDarkZonePropertyDetailDialog:Close()
  UIManager.CloseUI(UIDef.UIDarkZonePropertyDetailDialog)
end
function UIDarkZonePropertyDetailDialog:OnClose()
  self.ui = nil
  self.mData = nil
  self.mView = nil
  self:ReleaseCtrlTable(self.propertyItemList, true)
  self.propertyItemList = nil
  self.attrList = nil
  self.skillList = nil
  self:ReleaseCtrlTable(self.skillItemList, true)
  self.skillItemList = nil
end
function UIDarkZonePropertyDetailDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZonePropertyDetailDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close2.gameObject).onClick = function()
    self:Close()
  end
end
function UIDarkZonePropertyDetailDialog:InitBaseData()
  self.ui = {}
  self.propertyItemList = {}
  self.attrList = {}
  self.skillList = {}
  self.skillItemList = {}
end
function UIDarkZonePropertyDetailDialog:RefreshPropertyDetailByRepositoryData()
  local list = self.mData.list
  local allLightNum = 0
  for i = 1, 6 do
    if list:ContainsKey(i) then
      local data = list[i]
      allLightNum = allLightNum + list[i].lightLv
      self:UpdateEquipAttribute(data.MainAffix.Id, data.MainAffix.Value)
      for n = 0, data.SubAffix.Count - 1 do
        self:UpdateEquipAttribute(data.SubAffix[n].Id, data.SubAffix[n].Value)
      end
      if 0 < list[i].DZSkillId then
        table.insert(self.skillList, list[i].DZSkillId)
      end
    end
  end
  allLightNum = allLightNum // 6
  if list:ContainsKey(7) then
    local data = list[7]
    setactive(self.ui.mTrans_GrpNum, true)
    self.ui.mText_AddNum.text = "+" .. list[7].lightLv
    self.ui.mText_BasisNum.text = allLightNum
    allLightNum = allLightNum + list[7].lightLv
    self:UpdateEquipAttribute(data.MainAffix.Id, data.MainAffix.Value)
    for n = 0, data.SubAffix.Count - 1 do
      self:UpdateEquipAttribute(data.SubAffix[n].Id, data.SubAffix[n].Value)
    end
    if 0 < list[7].DZSkillId then
      table.insert(self.skillList, list[7].DZSkillId)
    end
  else
    setactive(self.ui.mTrans_GrpNum, false)
  end
  self.ui.mText_AllLightNum.text = allLightNum
  if 0 >= list.Count then
    setactive(self.ui.mText_No, true)
    self.ui.mText_No.text = TableData.GetHintById(903469)
  else
    setactive(self.ui.mText_No, false)
  end
  local imgBg3 = self.mUIRoot:Find("Root/GrpDialog/GrpBg/ComDialogBgItemV2(Clone)/GrpBg/ImgBg3")
  setactive(imgBg3.gameObject, false)
  self:RefreshPropertyItem()
end
function UIDarkZonePropertyDetailDialog:RefreshPropertyDetail()
  local list = self.mData.list
  local allLightNum = 0
  local type7Data
  for i = 1, #list do
    if list[i].buffData.buff_type ~= 7 then
      local data = list[i].equip
      allLightNum = allLightNum + list[i].lightLv
      self:UpdateEquipAttribute(data.darkaffix.id, data.darkaffix.value)
      for n = 0, data.darkaffixList.Count - 1 do
        self:UpdateEquipAttribute(data.darkaffixList[n].id, data.darkaffixList[n].value)
      end
      if 0 < list[i].dz_skill_id then
        table.insert(self.skillList, list[i].dz_skill_id)
      end
    else
      type7Data = list[i]
    end
  end
  allLightNum = allLightNum // 6
  if type7Data then
    local data = type7Data.equip
    setactive(self.ui.mTrans_GrpNum, true)
    self.ui.mText_AddNum.text = "+" .. type7Data.lightLv
    self.ui.mText_BasisNum.text = allLightNum
    allLightNum = allLightNum + type7Data.lightLv
    self:UpdateEquipAttribute(data.darkaffix.id, data.darkaffix.value)
    for n = 0, data.darkaffixList.Count - 1 do
      self:UpdateEquipAttribute(data.darkaffixList[n].id, data.darkaffixList[n].value)
    end
    if 0 < type7Data.dz_skill_id then
      table.insert(self.skillList, type7Data.dz_skill_id)
    end
  else
    setactive(self.ui.mTrans_GrpNum, false)
  end
  self.ui.mText_AllLightNum.text = allLightNum
  self:RefreshPropertyItem()
end
function UIDarkZonePropertyDetailDialog:RefreshPropertyItem()
  for i = 1, #self.skillList do
    if self.skillItemList[i] == nil then
      self.skillItemList[i] = UIDarkZoneEquipSkillItem.New()
      self.skillItemList[i]:InitCtrl(self.ui.mTrans_Content, self.ui.mTrans_SkillItem.gameObject)
    end
  end
  local index = 1
  for i, v in pairs(self.attrList) do
    if self.propertyItemList[index] == nil then
      local item1 = UICommonPropertyItem.New()
      item1:InitCtrl(self.ui.mTrans_List, true)
      self.propertyItemList[index] = item1
    end
    local item = self.propertyItemList[index]
    item:SetDataByName(i, v, false, true, index % 2 == 0)
    index = index + 1
  end
end
function UIDarkZonePropertyDetailDialog:UpdateEquipAttribute(Id, Value)
  local tableData, propData
  tableData = TableData.listDarkzoneEquipAffixEffectDatas:GetDataById(Id)
  propData = TableData.GetPropertyDataByName(tableData.effect, 0)
  if self.attrList[tableData.effect] == nil then
    self.attrList[tableData.effect] = 0
  end
  self.attrList[tableData.effect] = self.attrList[tableData.effect] + Value
end
