UIGunTalentPluginItem = class("UIGunTalentPluginItem", UIBaseCtrl)
UIGunTalentPluginItem.pluginData = nil
function UIGunTalentPluginItem:ctor()
end
function UIGunTalentPluginItem:InitCtrl()
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComItem.prefab", self))
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
end
function UIGunTalentPluginItem:SetData(data, isPrivate, gunId)
  setactive(self.ui.mTrans_Equipped_InGun.gameObject, false)
  setactive(self.ui.mTrans_Choose.gameObject, false)
  self.pluginData = data
  self.isPrivate = isPrivate
  self.gunId = gunId
  self.itemData = TableData.listItemDatas:GetDataById(self.pluginData.itemId)
  self.battleSkillId = TableData.listTalentKeyDatas:GetDataById(self.pluginData.itemId).battle_skill_id
  self.skillItemData = TableData.listBattleSkillDatas:GetDataById(self.battleSkillId)
  self.ui.mImage_Icon.sprite = IconUtils.GetIconV2(self.itemData.icon_path, self.itemData.icon)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.Rank)
  setactive(self.ui.mTrans_Num.gameObject, false)
  if self.pluginData.ownerId ~= 0 then
    if self.isPrivate then
      setactive(self.ui.mTrans_Choose.gameObject, true)
    else
      self.gunData = TableData.listGunDatas:GetDataById(self.pluginData.ownerId)
      setactive(self.ui.mTrans_Equipped_InGun.gameObject, true)
      self.ui.mImage_Head.sprite = IconUtils.GetCharacterHeadSprite(IconUtils.cCharacterAvatarType_Avatar, self.gunData.code)
    end
  else
    setactive(self.ui.mTrans_Equipped_InGun.gameObject, false)
    setactive(self.ui.mTrans_Choose.gameObject, false)
  end
  self:Refresh()
end
function UIGunTalentPluginItem:SetEquip(needShow)
  setactive(self.ui.mTrans_SelNow.gameObject, needShow)
end
function UIGunTalentPluginItem:SetSelect(needShow)
  setactive(self.ui.mTrans_Select.gameObject, needShow)
  self.ui.mBtn_Select.interactable = not needShow
  if needShow then
    if self.isPrivate then
      NetCmdTalentData:SetReadPrivateTalentItem(self.gunId, self.pluginData.itemId)
    else
      NetCmdTalentData:SetReadPublicTalentItem(self.pluginData.uId)
    end
    self:Refresh()
  end
end
function UIGunTalentPluginItem:Refresh()
  if self.isPrivate then
    local needRedPoint = NetCmdTalentData:IsUnreadPrivateTalent(self.gunId, self.pluginData.itemId)
    setactive(self.ui.mTrans_RedPoint, needRedPoint)
  else
    local needRedPoint = NetCmdTalentData:IsUnreadPublicTalent(self.pluginData.uId)
    setactive(self.ui.mTrans_RedPoint, needRedPoint)
  end
end
function UIGunTalentPluginItem:OnRelease()
  self.pluginData = nil
end
