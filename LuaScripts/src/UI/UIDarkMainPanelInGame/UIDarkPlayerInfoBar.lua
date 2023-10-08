require("UI.UIBaseCtrl")
UIDarkPlayerInfoBar = class("UIDarkPlayerInfoBar", UIBaseCtrl)
function UIDarkPlayerInfoBar:ctor(root)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
end
function UIDarkPlayerInfoBar:SetData(darkPlayer, index, onClickEquipmentCallback)
  self.darkPlayer = darkPlayer
  self.index = index
  self.onClickEquipmentCallback = onClickEquipmentCallback
  self.playerAvatarItem = UICommonPlayerAvatarItem.New()
  self.playerAvatarItem:InitCtrl(self.ui.mScrollItem_PlayerAvatarItemV2.transform)
  self.playerAvatarItem:EnableBtn(false)
  self.playerAvatarItem:AddBtnListener(function()
    self:onClickUserAvatar()
  end)
  self.gunItemTable = {}
  self.equipmentItemTable = {}
  self:initGunGroup()
  self:initEquipmentGroup()
end
function UIDarkPlayerInfoBar:Refresh()
  if not self.darkPlayer then
    gferror("data is nil!!!")
    return
  end
  self:refreshPlayerInfo()
  self:refreshGunGroup()
  self:refreshEquipmentGroup()
  self:refreshBackground()
end
function UIDarkPlayerInfoBar:OnRelease()
  self:ReleaseCtrlTable(self.gunItemTable)
  self:ReleaseCtrlTable(self.equipmentItemTable)
  self.darkPlayer = nil
  self.index = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIDarkPlayerInfoBar:initGunGroup()
  local gunLimit = 4
  local i = 1
  for id, darkGunData in pairs(self.darkPlayer.DarkPlayerData.InitGunCmdDataDic) do
    if gunLimit < i then
      break
    end
    local gunItem = UIGunAvatarItem.New(self.ui.mTrans_GrpChrList)
    gunItem:InitByGunCmdData(darkGunData)
    gunItem:AddBtnClickListener(function(tempGunCmdData)
      self:onClickGun(tempGunCmdData)
    end)
    table.insert(self.gunItemTable, gunItem)
    i = i + 1
  end
end
function UIDarkPlayerInfoBar:initEquipmentGroup()
  local equipLimit = self.ui.mTrans_GrpEquipList.childCount
  local equipList = self.darkPlayer.DarkPlayerData.DarkPlayerBag:GetEquip()
  if not equipLimit then
    return
  end
  for i = 0, equipList.Count - 1 do
    if i >= equipLimit then
      return
    end
    local darkEquipItem = equipList[i]
    local childTrans = self.ui.mTrans_GrpEquipList:GetChild(i)
    local childItem = childTrans:GetComponent(typeof(ScrollListChild)).childItem
    local equipItem = UIComItemV2.New(childTrans, childItem)
    equipItem:SetData(darkEquipItem.itemID, 1, function(itemId)
      self:onClickEquipment(itemId)
    end)
    equipItem:SetNumVisible(false)
    equipItem:EnableTips(false)
    table.insert(self.equipmentItemTable, equipItem)
  end
end
function UIDarkPlayerInfoBar:refreshPlayerInfo()
  self.playerAvatarItem:SetData(TableData.GetPlayerAvatarIconById(self.darkPlayer.User.Portrait, self.darkPlayer.User.Sex.value__))
  self.ui.mText_Name.text = self.darkPlayer.User.Name
  self.ui.mText_EffectNum.text = self.darkPlayer.Power
  self.ui.mText_KillPlayerNum.text = tostring(self.darkPlayer.DarkPlayerData.KillPlayerCount)
  self.ui.mText_KillMonsterNum.text = tostring(self.darkPlayer.DarkPlayerData.KillMonsterCount)
end
function UIDarkPlayerInfoBar:refreshGunGroup()
  if not self.gunItemTable then
    gferror("data is nil!!!")
    return
  end
  for i, gunItem in ipairs(self.gunItemTable) do
    gunItem:Refresh()
  end
end
function UIDarkPlayerInfoBar:refreshEquipmentGroup()
  if not self.equipmentItemTable then
    gferror("data is nil!!!")
    return
  end
  for i, equipmentItem in ipairs(self.equipmentItemTable) do
    equipmentItem:Refresh()
  end
end
function UIDarkPlayerInfoBar:refreshBackground()
  setactive(self.ui.mTrans_EffectNum, false)
  setactive(self.ui.mTrans_Exit, false)
  setactive(self.ui.mTrans_LeftDie, false)
  setactive(self.ui.mTrans_LeftUnknown, false)
  setactive(self.ui.mTrans_RightKnow, false)
  setactive(self.ui.mTrans_RightDie, false)
  setactive(self.ui.mTrans_RightUnknown, false)
  setactive(self.ui.mTrans_Mask, false)
  if self.darkPlayer.IsMainPlayer then
    self.ui.mImage_State.color = ColorUtils.StringToColor("F6A72A")
  else
    self.ui.mImage_State.color = ColorUtils.StringToColor("3D4B52")
  end
  local haveMet = self.darkPlayer.IsMainPlayer or CS.SysMgr.dzFogMgr:HaveMet(self.darkPlayer)
  if haveMet then
    local darkResult = CS.DarkUnitWorld.DarkResult
    if self.darkPlayer.DarkResult == darkResult.None then
      setactive(self.ui.mTrans_EffectNum, true)
      setactive(self.ui.mTrans_RightKnow, true)
    elseif self.darkPlayer.DarkResult == darkResult.Win then
      self.ui.mImage_State.color = ColorUtils.StringToColor("4BB56C")
      setactive(self.ui.mTrans_Exit, true)
      setactive(self.ui.mTrans_RightKnow, true)
    elseif self.darkPlayer.DarkResult == darkResult.Lose then
      setactive(self.ui.mTrans_LeftDie, true)
      setactive(self.ui.mTrans_RightDie, true)
    end
    setactive(self.ui.mTrans_Mask, false)
  else
    setactive(self.ui.mTrans_LeftUnknown, false)
    setactive(self.ui.mTrans_RightKnow, false)
    setactive(self.ui.mTrans_RightUnknown, true)
    setactive(self.ui.mTrans_Mask, true)
  end
end
function UIDarkPlayerInfoBar:onClickUserAvatar()
end
function UIDarkPlayerInfoBar:onClickGun(gunCmdData)
  CS.RoleInfoCtrlHelper.Instance:InitDarkZoneGameData(gunCmdData)
end
function UIDarkPlayerInfoBar:onClickEquipment(itemId)
  local darkEquipItem = self:getDarkEquipItemByItemId(itemId)
  if self.onClickEquipmentCallback then
    self.onClickEquipmentCallback(darkEquipItem)
  end
end
function UIDarkPlayerInfoBar:getDarkEquipItemByItemId(itemId)
  local equipList = self.darkPlayer.DarkPlayerData.DarkPlayerBag:GetEquip()
  for i = 0, equipList.Count - 1 do
    if equipList[i].itemID == itemId then
      return equipList[i]
    end
  end
  return nil
end
