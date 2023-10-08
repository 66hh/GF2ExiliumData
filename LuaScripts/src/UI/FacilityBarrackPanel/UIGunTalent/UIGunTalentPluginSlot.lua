UIGunTalentPluginSlot = class("UIGunTalentPluginSlot", UIBaseCtrl)
UIGunTalentPluginSlot.mAnimator = nil
UIGunTalentPluginSlot.mSlotItemData = nil
UIGunTalentPluginSlot.isPrivate = false
UIGunTalentPluginSlot.mGunId = nil
UIGunTalentPluginSlot.slotId = nil
function UIGunTalentPluginSlot:ctor()
  UIGunTalentPluginSlot.super.ctor(self)
end
function UIGunTalentPluginSlot:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/Btn_ChrTalentSetItemV3.prefab", self), root)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mAnimator = self.ui.mAnimator
end
function UIGunTalentPluginSlot:SetData(isPrivate, data, gunId, slotId)
  self.mSlotItemData = data
  self.isPrivate = isPrivate
  self.mGunId = gunId
  self.slotId = slotId
  self:Refresh()
end
function UIGunTalentPluginSlot:Refresh()
  if self.mSlotItemData.itemId == 0 then
    setactive(self.ui.mTrans_Content.gameObject, false)
    setactive(self.ui.mTrans_NoneShare.gameObject, not self.isPrivate)
    setactive(self.ui.mTrans_NoneCom.gameObject, true)
    local duty = TableData.listGunDatas:GetDataById(self.mGunId).duty
    local dutyData = TableData.listGunDutyDatas:GetDataById(duty)
    self.ui.mImg_ShareDutyIcon.sprite = IconUtils.GetGunTypeSprite(dutyData.icon .. "_W")
    local needRedPoint = 0
    if self.isPrivate then
      needRedPoint = NetCmdTalentData:PrivateRedPoint(self.mGunId)
      if NetCmdTalentData:IsHaveUnreadPrivateTalent(self.mGunId) then
        needRedPoint = needRedPoint + 1
      end
    else
      needRedPoint = NetCmdTalentData:PublicRedPoint(self.mGunId)
      if NetCmdTalentData:IsHaveUnreadPublicTalent(self.mGunId) then
        needRedPoint = needRedPoint + 1
      end
    end
    if needRedPoint == 0 then
      setactive(self.ui.mTrans_RedPoint.gameObject, false)
    else
      setactive(self.ui.mTrans_RedPoint.gameObject, true)
    end
  else
    setactive(self.ui.mTrans_Content.gameObject, true)
    setactive(self.ui.mTrans_NoneCom.gameObject, false)
    setactive(self.ui.mTrans_NoneShare.gameObject, false)
    local pluginItemData = TableData.listItemDatas:GetDataById(self.mSlotItemData.itemId)
    local talentKeyData = TableData.listTalentKeyDatas:GetDataById(self.mSlotItemData.itemId)
    if talentKeyData.steady_state == 0 then
      self.ui.mImg_QualityLine.color = self.ui.mRankColorList.ImageColor[0]
    else
      self.ui.mImg_QualityLine.color = self.ui.mRankColorList.ImageColor[1]
    end
    local needRedPoint = 0
    if self.isPrivate then
      if NetCmdTalentData:IsHaveUnreadPrivateTalent(self.mGunId) then
        needRedPoint = needRedPoint + 1
      end
    elseif NetCmdTalentData:IsHaveUnreadPublicTalent(self.mGunId) then
      needRedPoint = needRedPoint + 1
    end
    self.ui.mImg_Icon.sprite = IconUtils.GetIconV2(pluginItemData.icon_path, pluginItemData.icon)
    setactive(self.ui.mTrans_RedPoint.gameObject, 0 < needRedPoint)
  end
end
function UIGunTalentPluginSlot:OnRelease()
  self.mAnimator = nil
  self.mSlotItemData = nil
  self.mGunId = nil
  self.slotId = nil
end
