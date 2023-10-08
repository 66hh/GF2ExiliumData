UIChrWeaponPanelV3 = class("UIChrWeaponPanelV3", UIBasePanel)
UIChrWeaponPanelV3.__index = UIChrWeaponPanelV3
function UIChrWeaponPanelV3:ctor(csPanel)
  UIChrWeaponPanelV3.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  self.weaponCmdData = nil
  self.suitList = {}
  self.weaponPartUis = {}
  self.replaceBtnRedPoint = nil
  self.breakBtnRedPoint = nil
  self.needReplaceBtn = false
end
function UIChrWeaponPanelV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponPanelV3:OnInit(root, data)
  local weaponId = data[1]
  self.needReplaceBtn = data.needReplaceBtn
  if self.needReplaceBtn == nil then
    self.needReplaceBtn = false
  end
  self.openFromType = data[4]
  if self.openFromType == UIWeaponPanel.OpenFromType.BattlePass then
    self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponId)
  else
    self.weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponId)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.CloseUI(UIDef.UIWeaponPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReplace.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIChrWeaponReplacePanelV3, self.weaponCmdData.id)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIChrWeaponPowerUpPanelV3, self.weaponCmdData.stc_id)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_WeaponParts.gameObject).onClick = function()
    self:OnClickPart(1)
  end
  self.replaceBtnRedPoint = self.ui.mBtn_BtnReplace.gameObject.transform:Find("Root/Trans_RedPoint")
  self.breakBtnRedPoint = self.ui.mBtn_BtnBreak.gameObject.transform:Find("Root/Trans_RedPoint")
  self:InitSuit()
  BarrackHelper.CameraMgr:SetWeaponRT()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
end
function UIChrWeaponPanelV3:OnShowStart()
  self:SetWeaponData()
end
function UIChrWeaponPanelV3:OnRecover()
end
function UIChrWeaponPanelV3:OnBackFrom()
  self:SetWeaponData()
end
function UIChrWeaponPanelV3:OnTop()
  self:SetWeaponData()
end
function UIChrWeaponPanelV3:OnShowFinish()
  self:AddListener()
end
function UIChrWeaponPanelV3:OnCameraStart()
  return 0.01
end
function UIChrWeaponPanelV3:OnCameraBack()
end
function UIChrWeaponPanelV3:OnHide()
  UIWeaponGlobal:ReleaseWeaponToucherEvent()
end
function UIChrWeaponPanelV3:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIModelToucher.ReleaseWeaponToucher()
    UIWeaponGlobal:ReleaseWeaponModel()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  end
  self:ReleaseCtrlTable(self.suitList, true)
  for i = #self.weaponPartUis, 1, -1 do
    gfdestroy(self.weaponPartUis[i].mUIRoot)
    table.remove(self.weaponPartUis, i)
  end
end
function UIChrWeaponPanelV3:OnClose()
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  self:RemoveListener()
end
function UIChrWeaponPanelV3:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPanelV3:InitSuit()
  self.suitList = {}
  for i = 1, 2 do
    local suitItem = ChrWeaponPartsSkillItemV3.New()
    suitItem:InitCtrl(self.ui.mScrollListChild_GrpSkill.gameObject)
    table.insert(self.suitList, suitItem)
  end
end
function UIChrWeaponPanelV3:SetWeaponData()
  UIWeaponGlobal:InitWeaponToucherEvent(self.ui.mCanvasGroup_Root)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Weapon, false)
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(false)
  self.ui.mText_WeaponName.text = self.weaponCmdData.Name
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(self.weaponCmdData.Type)
  self.ui.mText_WeaponType.text = weaponTypeData.Name.str
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank)
  setactive(self.ui.mTrans_Lv, self.weaponCmdData.Rank >= 4)
  if self.weaponCmdData.BreakTimes ~= 0 and self.weaponCmdData.Rank >= 4 then
    self.ui.mImg_Num.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.weaponCmdData.BreakTimes .. "_S")
  end
  self:UpdateSkill()
  self:UpdateAttribute()
  self:UpdateSuitInfo()
  self:UpdateWeaponPartsList()
  self:UpdateAction()
  self:UpdateWeaponModel()
  if self.openFromType ~= UIWeaponPanel.OpenFromType.BattlePass then
    self:UpdateRedPoint()
  end
end
function UIChrWeaponPanelV3:UpdateWeaponModel()
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
end
function UIChrWeaponPanelV3:UpdateSkill()
  local data = self.weaponCmdData.Skill
  setactive(self.ui.mTrans_Skill, data ~= nil)
  if data then
    self.ui.mText_SkillName.text = data.name.str
    self.ui.mTextFit_Describe.text = data.description.str
    self.ui.mText_Lv.text = GlobalConfig.SetLvText(data.Level)
  end
  self.ui.mTextFit_Describe1.text = self.weaponCmdData.StcData.Description.str
end
function UIChrWeaponPanelV3:UpdateAttribute()
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    local value = self.weaponCmdData:GetPropertyByLevelAndSysNameWithPercent(lanData.sys_name, self.weaponCmdData.Level, self.weaponCmdData.BreakTimes)
    if 0 < value then
      local attr = {}
      attr.propData = lanData
      attr.value = value
      table.insert(attrList, attr)
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  local tmpAttrParent = self.ui.mScrollListChild_Content.transform
  for i = 0, tmpAttrParent.childCount - 1 do
    setactive(tmpAttrParent:GetChild(i).gameObject, false)
  end
  for i = 1, #attrList do
    local item
    item = ChrWeaponAttributeListItemV3.New()
    if i <= tmpAttrParent.childCount then
      item:InitCtrl(tmpAttrParent.gameObject, tmpAttrParent:GetChild(i - 1))
    else
      item:InitCtrl(tmpAttrParent.gameObject)
    end
    setactive(tmpAttrParent:GetChild(i - 1).gameObject, true)
    item:SetData(attrList[i].propData, attrList[i].value, true, false, false, false)
  end
end
function UIChrWeaponPanelV3:UpdateSuitInfo()
  if #self.suitList == 0 then
    self:InitSuit()
  end
  for i, item in ipairs(self.suitList) do
    item:SetData(nil)
  end
  local list = self.weaponCmdData:GetSuitList()
  for i = 0, list.Count - 1 do
    local item = self.suitList[i + 1]
    local count = self.weaponCmdData:GetSuitCountById(list[i])
    if item ~= nil then
      item:SetData(list[i], count, true)
    end
  end
end
function UIChrWeaponPanelV3:UpdateAction()
  setactive(self.ui.mTrans_Locked.gameObject, self.weaponCmdData.IsUnGetWeapon)
  setactive(self.ui.mTrans_Max.gameObject, self.weaponCmdData.BreakTimes == self.weaponCmdData.StcData.MaxBreak)
  setactive(self.ui.mTrans_NowMax.gameObject, self.weaponCmdData.Rank < 4)
  setactive(self.ui.mBtn_BtnBreak.transform.parent, self.weaponCmdData.Rank >= 4 and self.weaponCmdData.BreakTimes < self.weaponCmdData.StcData.MaxBreak)
  setactive(self.ui.mBtn_BtnReplace.gameObject, self.needReplaceBtn)
  setactive(self.ui.mBtn_BtnReplace.transform.parent.gameObject, self.needReplaceBtn)
end
function UIChrWeaponPanelV3:UpdateWeaponPartsList()
  local tmpWeaponPartsParent = self.ui.mTrans_WeaponPartsParent
  local tmpWeaponPartsContent = self.ui.mTrans_Content
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) or self.weaponCmdData.Rank < 4 then
    setactive(tmpWeaponPartsParent.gameObject, false)
    setactive(self.ui.mScrollListChild_GrpSkill.gameObject, false)
    return
  end
  setactive(tmpWeaponPartsParent.gameObject, true)
  setactive(self.ui.mScrollListChild_GrpSkill.gameObject, true)
  if self.weaponCmdData == nil then
    return
  end
  setactive(self.ui.mTrans_WeaponParts.gameObject, false)
  local slotList = self.weaponCmdData.slotList
  for i = 0, slotList.Count - 1 do
    local item
    local partItemUI = {}
    if i + 1 > #self.weaponPartUis then
      item = instantiate(self.ui.mTrans_WeaponParts, tmpWeaponPartsContent)
      self:LuaUIBindTable(item, partItemUI)
      table.insert(self.weaponPartUis, partItemUI)
    else
      item = self.weaponPartUis[i + 1].mUIRoot
      self:LuaUIBindTable(item, partItemUI)
    end
    setactive(item.gameObject, true)
    local gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(i)
    self:SetSlotData(partItemUI, gunWeaponModData, slotList[i], i + 1)
  end
end
function UIChrWeaponPanelV3:SetSlotData(partItem, gunWeaponModData, typeId, slotId)
  setactive(partItem.mImg_Quality.gameObject, gunWeaponModData ~= nil)
  setactive(partItem.mImg_PartsIconE.gameObject, gunWeaponModData ~= nil)
  setactive(partItem.mImg_PartsIcon.gameObject, gunWeaponModData == nil)
  if gunWeaponModData == nil then
    local slotData = TableData.listWeaponModTypeDatas:GetDataById(typeId)
    partItem.mImg_PartsIcon.sprite = IconUtils.GetWeaponPartIconSprite(slotData.icon, false)
    setactive(partItem.mImg_SuitIcon.gameObject, false)
    setactive(partItem.mObj_RedPoint.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, 0))
  else
    local suitData = TableData.listModPowerDatas:GetDataById(gunWeaponModData.suitId)
    partItem.mImg_PartsIconE.sprite = IconUtils.GetWeaponPartIconSprite(gunWeaponModData.icon)
    partItem.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(gunWeaponModData.rank)
    if suitData ~= nil then
      setactive(partItem.mImg_SuitIcon.gameObject, true)
      partItem.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(suitData.image, false)
    else
      setactive(partItem.mImg_SuitIcon.gameObject, false)
    end
    setactive(partItem.mObj_RedPoint.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, gunWeaponModData.stcId))
  end
end
function UIChrWeaponPanelV3:OnClickPart(slotIndex)
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
    return
  end
  local param = {
    weaponStcId = self.weaponCmdData.id,
    slotIndex = slotIndex
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsPanelV3, param)
end
function UIChrWeaponPanelV3:UpdateRedPoint()
  if self.weaponCmdData ~= nil then
    local redPoint = NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.weaponCmdData.stc_id, self.weaponCmdData.gun_id)
    self.redPointCount = redPoint
    setactive(self.replaceBtnRedPoint.gameObject, 0 < redPoint)
    setactive(self.breakBtnRedPoint.gameObject, 0 < self.weaponCmdData.WeaponduplicateNum and self.weaponCmdData.BreakTimes < self.weaponCmdData.StcData.MaxBreak)
  end
end
function UIChrWeaponPanelV3:OnChangeWeapon(message)
  local id = message.Sender
  self.weaponCmdData = NetCmdWeaponData:GetWeaponById(id)
end
function UIChrWeaponPanelV3:AddListener()
  function self.onChangeWeapon(message)
    self:OnChangeWeapon(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, self.onChangeWeapon)
end
function UIChrWeaponPanelV3:RemoveListener()
  MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, self.onChangeWeapon)
end
