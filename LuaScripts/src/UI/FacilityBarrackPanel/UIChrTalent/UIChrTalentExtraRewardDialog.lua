require("UI.FacilityBarrackPanel.UIChrTalent.UIChrTalentExtraRewardElement")
UIChrTalentExtraRewardDialog = class("UIChrTalentExtraRewardDialog", UIBasePanel)
function UIChrTalentExtraRewardDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChrTalentExtraRewardDialog:OnAwake(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:onClickClose()
  end)
  self.elementTable = {}
end
function UIChrTalentExtraRewardDialog:OnInit(root, gunId)
  self.gunId = gunId
end
function UIChrTalentExtraRewardDialog:OnShowStart()
  self:refresh()
end
function UIChrTalentExtraRewardDialog:OnHide()
end
function UIChrTalentExtraRewardDialog:OnClose()
end
function UIChrTalentExtraRewardDialog:OnRelease()
  self:ReleaseCtrlTable(self.elementTable, true)
  self.elementTable = nil
  self.gunId = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIChrTalentExtraRewardDialog:refresh()
  for i, element in ipairs(self.elementTable) do
    element:SetVisible(false)
  end
  if self.gunId == nil then
    return
  end
  local bonusIdList = NetCmdTalentData:GetTalentBonusIdList(self.gunId)
  if bonusIdList == nil then
    return
  end
  local curBonesGroupData = NetCmdTalentData:GetCurBonesGroupData(self.gunId)
  local count = bonusIdList.Count
  for i = 0, count - 1 do
    local talentBonesData = TableDataBase.listTalentBonusDatas:GetDataById(bonusIdList[i])
    if talentBonesData ~= nil then
      if self.elementTable[i + 1] == nil then
        local template = self.ui.mScrollListChild_Content.childItem
        local root = instantiate(template, self.ui.mScrollListChild_Content.transform)
        local element = UIChrTalentExtraRewardElement.New(root)
        table.insert(self.elementTable, element)
      end
      local isCurMatch = false
      if curBonesGroupData then
        isCurMatch = curBonesGroupData.id == talentBonesData.id
      end
      local element = self.elementTable[i + 1]
      element:SetVisible(true)
      element:Init(talentBonesData, i + 1, isCurMatch)
      element:Refresh()
    end
  end
end
function UIChrTalentExtraRewardDialog:onClickClose()
  UISystem:CloseUI(self.mCSPanel)
end
