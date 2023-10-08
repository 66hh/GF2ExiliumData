UIGunTalentAssemblyUnlockItem = class("UIGunTalentAssemblyUnlockItem", UIBaseCtrl)
function UIGunTalentAssemblyUnlockItem:ctor()
end
function UIGunTalentAssemblyUnlockItem:InitCtrl(transform, obj)
  local itemPrefab = transform:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj == nil then
    instObj = instantiate(itemPrefab.childItem, transform, false)
  else
    instObj = obj
  end
  if instObj == nil then
    instObj = instantiate(UIUtils.GetGizmosPrefab("Character/Btn_ChrPowerUpSetTalentItem.prefab", self), transform)
  end
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  UIUtils.GetButtonListener(self:GetRoot()).onClick = function()
    self:OnClickTalentButton()
  end
  local notNeedLock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalent)
  setactive(self.ui.mTrans_Lock.gameObject, not notNeedLock)
  setactive(self.ui.mTrans_PrivateSlot.gameObject, notNeedLock)
  setactive(self.ui.mTrans_PublicSlot.gameObject, notNeedLock)
  setactive(self.ui.mTrans_TalentRedPoint.gameObject, false)
end
function UIGunTalentAssemblyUnlockItem:SetData(gunId)
  self.mGunId = gunId
  self.mGunCmdData = NetCmdTeamData:GetGunByID(self.mGunId)
  if self.mGunCmdData == nil then
    return
  end
  if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalent) then
    local privateSlotList = self.mGunCmdData.mGun.PrivateTalentSkillItems
    local publicSlotList = self.mGunCmdData.mGun.PublicTalentSkillItemsUid
    if privateSlotList.Count ~= 0 then
      setactive(self.ui.mPrivateSlotOff1.gameObject, privateSlotList[0] == 0)
      setactive(self.ui.mPrivateSlotOff2.gameObject, privateSlotList[1] == 0)
      setactive(self.ui.mPrivateSlotOff3.gameObject, privateSlotList[2] == 0)
      setactive(self.ui.mPrivateSlotOn1.gameObject, 0 < privateSlotList[0])
      setactive(self.ui.mPrivateSlotOn2.gameObject, 0 < privateSlotList[1])
      setactive(self.ui.mPrivateSlotOn3.gameObject, 0 < privateSlotList[2])
      if 0 < privateSlotList[0] then
        local itemData = TableData.listItemDatas:GetDataById(privateSlotList[0])
        self.ui.mPrivateSlotImage1.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mPrivateSlotImage1.color.a)
      end
      if 0 < privateSlotList[1] then
        local itemData = TableData.listItemDatas:GetDataById(privateSlotList[1])
        self.ui.mPrivateSlotImage2.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mPrivateSlotImage2.color.a)
      end
      if 0 < privateSlotList[2] then
        local itemData = TableData.listItemDatas:GetDataById(privateSlotList[2])
        self.ui.mPrivateSlotImage3.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mPrivateSlotImage3.color.a)
      end
    end
    if publicSlotList.Count ~= 0 then
      setactive(self.ui.mPublicSlotOff1.gameObject, publicSlotList[0] == 0)
      setactive(self.ui.mPublicSlotOff2.gameObject, publicSlotList[1] == 0)
      setactive(self.ui.mPublicSlotOff3.gameObject, publicSlotList[2] == 0)
      setactive(self.ui.mPublicSlotOn1.gameObject, 0 < publicSlotList[0])
      setactive(self.ui.mPublicSlotOn2.gameObject, 0 < publicSlotList[1])
      setactive(self.ui.mPublicSlotOn3.gameObject, 0 < publicSlotList[2])
      if 0 < publicSlotList[0] then
        local itemId = NetCmdTalentData:GetPublicSkillItemByUid(publicSlotList[0]).itemId
        local itemData = TableData.listItemDatas:GetDataById(itemId)
        self.ui.mPublicSlotImage1.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mPublicSlotImage1.color.a)
      end
      if 0 < publicSlotList[1] then
        local itemId = NetCmdTalentData:GetPublicSkillItemByUid(publicSlotList[1]).itemId
        local itemData = TableData.listItemDatas:GetDataById(itemId)
        self.ui.mPublicSlotImage2.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mPublicSlotImage2.color.a)
      end
      if 0 < publicSlotList[2] then
        local itemId = NetCmdTalentData:GetPublicSkillItemByUid(publicSlotList[2]).itemId
        local itemData = TableData.listItemDatas:GetDataById(itemId)
        self.ui.mPublicSlotImage3.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank, self.ui.mPublicSlotImage3.color.a)
      end
    end
    local needRedPoint = NetCmdTalentData:TalentSkillItemRedPoint(self.mGunId)
    if 0 < needRedPoint then
      setactive(self.ui.mTrans_TalentRedPoint.gameObject, true)
    else
      setactive(self.ui.mTrans_TalentRedPoint.gameObject, false)
    end
  end
  local notNeedLock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalent)
  setactive(self.ui.mTrans_Lock.gameObject, not notNeedLock)
  setactive(self.ui.mTrans_PrivateSlot.gameObject, notNeedLock)
  setactive(self.ui.mTrans_PublicSlot.gameObject, notNeedLock)
end
function UIGunTalentAssemblyUnlockItem:OnClickTalentButton()
  if self.onClickCallback then
    self.onClickCallback()
  end
end
function UIGunTalentAssemblyUnlockItem:SetRedPointVisible(visible)
  setactive(self.ui.mTrans_TalentRedPoint.gameObject, visible)
end
function UIGunTalentAssemblyUnlockItem:AddClickListener(callback)
  self.onClickCallback = callback
end
