UITalentExtraRewardBtnCtrl = class("UITalentExtraRewardBtnCtrl", UIBaseCtrl)
function UITalentExtraRewardBtnCtrl:ctor(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Root.gameObject, function()
    self:onClickSlot()
  end)
end
function UITalentExtraRewardBtnCtrl:Init(gunId)
  self.gunId = gunId
end
function UITalentExtraRewardBtnCtrl:Refresh()
  local curBonesGroupData = NetCmdTalentData:GetCurBonesGroupData(self.gunId)
  if not curBonesGroupData then
    self.ui.mText_Num.text = "-"
  else
    self.ui.mText_Num.text = tostring(curBonesGroupData.id)
  end
end
function UITalentExtraRewardBtnCtrl:OnRelease(isDestroy)
  self.gunId = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UITalentExtraRewardBtnCtrl:AddClickListener(callback)
  self.onClickCallback = callback
end
function UITalentExtraRewardBtnCtrl:onClickSlot()
  if self.onClickCallback then
    self.onClickCallback(self.groupIndex, self.slotIndex)
  end
end
