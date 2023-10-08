UIChrWeaponReplacePanelV3 = class("UIChrWeaponReplacePanelV3", UIBasePanel)
UIChrWeaponReplacePanelV3.__index = UIChrWeaponReplacePanelV3
function UIChrWeaponReplacePanelV3:ctor(csPanel)
  UIChrWeaponReplacePanelV3.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  self.curEquipWeaponCmdData = nil
  self.curSelectWeaponCmdData = nil
  self.weaponStcIdList = nil
  self.gunId = 0
  self.curWeaponItem = nil
  self.replaceBtnRedPoint = nil
  self.breakBtnRedPoint = nil
end
function UIChrWeaponReplacePanelV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitWeaponList()
end
function UIChrWeaponReplacePanelV3:OnInit(root, weaponId)
  self.curEquipWeaponCmdData = NetCmdWeaponData:GetWeaponById(weaponId)
  self.gunId = self.curEquipWeaponCmdData.gun_id
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponReplacePanelV3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReplace.gameObject).onClick = function()
    self:OnClickReplaceBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIChrWeaponPowerUpPanelV3, self.curSelectWeaponCmdData.stc_id)
  end
  self.replaceBtnRedPoint = self.ui.mBtn_BtnReplace.gameObject.transform:Find("Root/Trans_RedPoint")
  self.breakBtnRedPoint = self.ui.mBtn_BtnBreak.gameObject.transform:Find("Root/Trans_RedPoint")
end
function UIChrWeaponReplacePanelV3:OnShowStart()
  self:SetWeaponData()
end
function UIChrWeaponReplacePanelV3:OnRecover()
end
function UIChrWeaponReplacePanelV3:OnBackFrom()
  self:SetWeaponData()
end
function UIChrWeaponReplacePanelV3:OnTop()
  self:SetWeaponData()
end
function UIChrWeaponReplacePanelV3:OnShowFinish()
end
function UIChrWeaponReplacePanelV3:OnCameraStart()
  return 0.01
end
function UIChrWeaponReplacePanelV3:OnCameraBack()
end
function UIChrWeaponReplacePanelV3:OnHide()
  UIWeaponGlobal:ReleaseWeaponToucherEvent()
end
function UIChrWeaponReplacePanelV3:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIModelToucher.ReleaseWeaponToucher()
    UIWeaponGlobal:ReleaseWeaponModel()
  end
  if self.curWeaponItem ~= nil then
    self.curWeaponItem:SetSelect(false)
  end
  self.curWeaponItem = nil
  self.curSelectWeaponCmdData = nil
end
function UIChrWeaponReplacePanelV3:OnClose()
end
function UIChrWeaponReplacePanelV3:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponReplacePanelV3:InitWeaponList()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpWeaponList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpWeaponList.itemRenderer = self.itemRenderer
end
function UIChrWeaponReplacePanelV3:ItemProvider()
  local itemView = ChrWeaponListItemV3.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIChrWeaponReplacePanelV3:ItemRenderer(index, renderData)
  if self.weaponStcIdList == nil or self.weaponStcIdList.Count == 0 then
    return
  end
  local item = renderData.data
  local weaponStcId = self.weaponStcIdList[index]
  item:SetData(weaponStcId, self.gunId, function()
    self:OnClickWeaponItem(item)
  end)
  if self.curWeaponItem == nil and item.isSelected then
    self.curWeaponItem = item
    self.curWeaponItem:SetSelect(true)
    self:UpdateBtnRedPoint()
  end
end
function UIChrWeaponReplacePanelV3:SetWeaponData()
  UIWeaponGlobal:InitWeaponToucherEvent(self.ui.mCanvasGroup_Root)
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  if self.curSelectWeaponCmdData == nil then
    self.curSelectWeaponCmdData = self.curEquipWeaponCmdData
  end
  self:UpdateWeaponList()
  self:UpdateSkill()
  self:UpdateAttribute()
  self:UpdateAction()
  self:UpdateWeaponModel()
end
function UIChrWeaponReplacePanelV3:UpdateWeaponList()
  if self.curWeaponItem ~= nil then
    self.curWeaponItem:SetSelect(false)
    self.curWeaponItem = nil
  end
  self.weaponStcIdList = NetCmdWeaponData:GetAllReplaceWeaponListByGunId(self.gunId)
  self.ui.mVirtualListEx_GrpWeaponList.numItems = self.weaponStcIdList.Count
  self.ui.mVirtualListEx_GrpWeaponList:Refresh()
end
function UIChrWeaponReplacePanelV3:UpdateSkill()
  local data = self.curSelectWeaponCmdData.Skill
  setactive(self.ui.mTrans_Skill, data ~= nil)
  if data then
    self.ui.mText_SkillName.text = data.name.str
    self.ui.mTextFit_Describe.text = data.description.str
    self.ui.mText_Text.text = GlobalConfig.SetLvText(data.Level)
  end
  self.ui.mTextFit_Describe1.text = self.curSelectWeaponCmdData.StcData.Description.str
end
function UIChrWeaponReplacePanelV3:UpdateAttribute()
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    local value = self.curSelectWeaponCmdData:GetPropertyByLevelAndSysName(lanData.sys_name, self.curSelectWeaponCmdData.Level, self.curSelectWeaponCmdData.BreakTimes)
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
  local tmpAttrParent = self.ui.mScrollListChild_AttrContent.transform
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
function UIChrWeaponReplacePanelV3:UpdateAction()
  local isMaxBreakTimes = self.curSelectWeaponCmdData.BreakTimes == self.curSelectWeaponCmdData.StcData.MaxBreak
  local noBreak = self.curSelectWeaponCmdData.Rank < 4 and not self.curSelectWeaponCmdData.IsUnGetWeapon
  local needReplaceBtn = not self.curSelectWeaponCmdData.IsUnGetWeapon and self.curSelectWeaponCmdData.stc_id ~= self.curEquipWeaponCmdData.stc_id
  local needBreakBtn = not self.curSelectWeaponCmdData.IsUnGetWeapon and self.curSelectWeaponCmdData.BreakTimes < self.curSelectWeaponCmdData.StcData.MaxBreak and self.curSelectWeaponCmdData.Rank >= 4
  setactive(self.ui.mTrans_NowMax.gameObject, isMaxBreakTimes)
  setactive(self.ui.mTrans_NoBreak.gameObject, noBreak)
  setactive(self.ui.mTrans_Action.gameObject, not isMaxBreakTimes and not noBreak or needBreakBtn or needReplaceBtn)
  setactive(self.ui.mTrans_Locked.gameObject, self.curSelectWeaponCmdData.IsUnGetWeapon)
  setactive(self.ui.mBtn_BtnBreak.transform.parent, needBreakBtn)
  setactive(self.ui.mBtn_BtnReplace.transform.parent.gameObject, needReplaceBtn)
end
function UIChrWeaponReplacePanelV3:UpdateWeaponModel()
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.curSelectWeaponCmdData)
end
function UIChrWeaponReplacePanelV3:UpdateBtnRedPoint()
  setactive(self.replaceBtnRedPoint.gameObject, false)
  setactive(self.breakBtnRedPoint.gameObject, false)
  if self.curWeaponItem ~= nil then
    setactive(self.replaceBtnRedPoint.gameObject, self.curWeaponItem.redPointCount > 0)
    setactive(self.breakBtnRedPoint.gameObject, 0 < self.curWeaponItem.weaponCmdData.WeaponduplicateNum and self.curWeaponItem.weaponCmdData.BreakTimes < self.curWeaponItem.weaponCmdData.StcData.MaxBreak)
  end
end
function UIChrWeaponReplacePanelV3:OnClickWeaponItem(item)
  self.curSelectWeaponCmdData = item.weaponCmdData
  self:SetWeaponData()
  if self.curWeaponItem ~= nil then
    self.curWeaponItem:SetSelect(false)
  end
  self.curWeaponItem = item
  self.curWeaponItem:SetSelect(true)
  self:UpdateBtnRedPoint()
end
function UIChrWeaponReplacePanelV3:OnClickReplaceBtn()
  local tmpWeaponCmdData = self.curSelectWeaponCmdData
  NetCmdWeaponData:SendGunWeaponBelong(tmpWeaponCmdData.id, self.gunId, function(ret)
    if ret == ErrorCodeSuc then
      MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnChangeWeapon, tmpWeaponCmdData.id)
      UIUtils.PopupPositiveHintMessage(40071)
      self.curEquipWeaponCmdData = tmpWeaponCmdData
      self:SetWeaponData()
      UIManager.CloseUI(UIDef.UIChrWeaponReplacePanelV3)
    end
  end)
end
