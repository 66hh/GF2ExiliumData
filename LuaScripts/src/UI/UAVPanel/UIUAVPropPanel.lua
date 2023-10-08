require("UI.Common.UICommonPropertyItem")
UIUAVPropPanel = class("UIUAVPropPanel", UIBasePanel)
function UIUAVPropPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUAVPropPanel:OnAwake(root)
  self:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self.ui.mBtn_Close.onClick:AddListener(function()
    UIManager.CloseUI(UIDef.UIUAVPropPanel)
  end)
  self.ui.mBtn_GrpClose.onClick:AddListener(function()
    UIManager.CloseUI(UIDef.UIUAVPropPanel)
  end)
  local uavData = NetCmdUavData:GetUavData()
  self.grade = uavData.UavGrade
  self:SetTitle()
  self:Refresh()
end
function UIUAVPropPanel:OnRelease()
  self.grade = nil
  self.ui.mBtn_Close.onClick = nil
  self.ui.mBtn_GrpClose.onClick = nil
  self.ui = nil
end
function UIUAVPropPanel:Refresh()
  local propList = self:GetBarrackShowPropList()
  for i, prop in ipairs(propList) do
    local value = self:GetOriginPropValue(self.grade, prop.sys_name)
    if value ~= 0 then
      local item = UICommonPropertyItem.New()
      item:InitCtrl(self.ui.mTrans_PropList)
      item:SetUAVProp(prop, value, 0, i % 2 == 0)
    end
  end
end
function UIUAVPropPanel:SetTitle()
end
function UIUAVPropPanel:GetBarrackShowPropList()
  local propList = {}
  for i = 0, TableData.listLanguagePropertyDatas.Count - 1 do
    local propData = TableData.listLanguagePropertyDatas[i]
    if propData and propData.barrack_show ~= 0 then
      table.insert(propList, propData)
    end
  end
  table.sort(propList, function(a, b)
    return a.barrack_show < b.barrack_show
  end)
  return propList
end
function UIUAVPropPanel:GetOriginPropValue(grade, name)
  local levelData = TableData.listUavAdvanceDatas:GetDataById(grade)
  return PropertyHelper.GetPropertyValueByString(levelData.property_id, name)
end
