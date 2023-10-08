require("UI.FacilityBarrackPanel.UIChrTalent.UIPropertyCtrl")
UIChrTalentExtraRewardElement = class("UIChrTalentExtraRewardElement", UIBaseCtrl)
function UIChrTalentExtraRewardElement:ctor(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.slotTable = {}
end
function UIChrTalentExtraRewardElement:Init(talentBonesData, index, isCurMatch)
  self.talentBonesData = talentBonesData
  self.index = index
  self.isCurMatch = isCurMatch
end
function UIChrTalentExtraRewardElement:Refresh()
  for i, slot in ipairs(self.slotTable) do
    slot:SetVisible(false)
  end
  if self.talentBonesData == nil then
    return
  end
  self.ui.mText_Num.text = tostring(self.index)
  self.ui.mText_Title.text = TableData.GetHintById(140044, self.talentBonesData.UnlockCount)
  local slotIndex = 1
  local propertyId = self.talentBonesData.PropertyId
  for i = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(i)
    if propertyType then
      local addValue = PropertyHelper.GetPropertyValueByEnum(propertyId, propertyType)
      if 0 < addValue then
        if self.slotTable[slotIndex] == nil then
          local template = self.ui.mScrollListChild_Content.childItem
          local root = instantiate(template, self.ui.mScrollListChild_Content.transform)
          local slot = UIPropertyCtrl.New()
          slot:InitRoot(root)
          table.insert(self.slotTable, slot)
        end
        local slot = self.slotTable[slotIndex]
        slot:ShowAdd(propertyType, addValue)
        slot:SetVisible(true)
        slotIndex = slotIndex + 1
      end
    end
  end
  if self.isCurMatch ~= nil then
    self.ui.mAnimator:SetBool("CurrentLevel", self.isCurMatch)
  end
end
function UIChrTalentExtraRewardElement:OnRelease(isDestroy)
  self.talentBonesData = nil
  self:ReleaseCtrlTable(self.slotTable, true)
  self.slotTable = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
