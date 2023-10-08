UIChrWeaponBreakPanelV4 = class("UIChrWeaponBreakPanelV4", UIBasePanel)
UIChrWeaponBreakPanelV4.__index = UIChrWeaponBreakPanelV4
function UIChrWeaponBreakPanelV4:ctor(root, uiChrWeaponPowerUpPanelV4)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.weaponCmdData = nil
  self.curCostWeaponCmdData = nil
  self.curCostItemData = nil
  self.MaxWeaponBreakTimes = 0
  self.targetBreakTimes = 0
  self.breakTimesItems = {}
  self.isWeaponEnough = false
  self.costWeaponNum = 0
  self.ringObj = nil
  self.bgObj = nil
  self.bgObjAnimator = nil
end
function UIChrWeaponBreakPanelV4:OnAwake(root, data)
  self:SetRoot(root)
end
function UIChrWeaponBreakPanelV4:OnInit(data)
  self.weaponCmdData = data
  self.MaxWeaponBreakTimes = self.weaponCmdData.StcData.MaxBreak
  self.curCostItemData = TableData.GetItemData(self.weaponCmdData.stc_id)
  UIUtils.GetButtonListener(self.ui.mBtn_GrpWeaponConsume.gameObject).onClick = function()
    local id
    if self.curCostWeaponCmdData ~= nil then
      id = self.curCostWeaponCmdData.id
    end
    UITipsPanel.Open(self.curCostItemData, 0, true, nil, id)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
    self:OnClickBreak()
  end
  local breakContainner = self.ui.mBtn_BtnBreak.transform:Find("Root/Trans_RedPoint").gameObject:GetComponent(typeof(CS.UICommonContainer))
  self.breakRedpoint = breakContainner.transform
  self:InitBreakeTimesItem()
end
function UIChrWeaponBreakPanelV4:OnShowStart()
  self:SetWeaponData()
end
function UIChrWeaponBreakPanelV4:OnRecover()
end
function UIChrWeaponBreakPanelV4:OnBackFrom()
  self:SetWeaponData()
end
function UIChrWeaponBreakPanelV4:OnTop()
end
function UIChrWeaponBreakPanelV4:OnShowFinish()
end
function UIChrWeaponBreakPanelV4:OnCameraStart()
  return 0.01
end
function UIChrWeaponBreakPanelV4:OnCameraBack()
end
function UIChrWeaponBreakPanelV4:OnHide()
  if self.bgObjAnimator ~= nil then
    self.bgObjAnimator:SetTrigger("FadeOut")
  end
end
function UIChrWeaponBreakPanelV4:OnHideFinish()
end
function UIChrWeaponBreakPanelV4:OnClose()
  setactive(self.ringObj, true)
  setactive(self.bgObj, false)
end
function UIChrWeaponBreakPanelV4:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponBreakPanelV4:InitBreakeTimesItem()
  self.breakTimesItems = {}
  local tmpBreakTimesParent = self.ui.mTrans_Bar.transform
  local item
  for i = 0, self.MaxWeaponBreakTimes - 1 do
    if i > tmpBreakTimesParent.childCount - 1 then
      item = instantiate(self.ui.mTrans_Level1.gameObject, tmpBreakTimesParent)
    else
      item = tmpBreakTimesParent:GetChild(i)
    end
    local breakTimesItem = {}
    self:LuaUIBindTable(item, breakTimesItem)
    table.insert(self.breakTimesItems, breakTimesItem)
  end
end
function UIChrWeaponBreakPanelV4:SetWeaponData()
  if self.weaponCmdData.BreakTimes == self.MaxWeaponBreakTimes then
    self:UpdateMaxBreakTimes(true)
  end
  self.ringObj = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("UI_ChrWeapon_Bg_Ring")
  self.bgObj = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("GrpBg")
  self.bgObjAnimator = self.bgObj:GetComponent(typeof(CS.UnityEngine.Animator))
  setactive(self.ringObj, false)
  setactive(self.bgObj, false)
  self.MaxWeaponBreakTimes = self.weaponCmdData.StcData.MaxBreak
  UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_Num, self.weaponCmdData.BreakTimes, self.MaxWeaponBreakTimes)
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_QualityLine.color.a)
  self.ui.mImg_QualityBg.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_QualityBg.color.a)
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mText_Name.text = self.weaponCmdData.Name
  setactive(self.ui.mTrans_WeaponSkillAfter.gameObject, self.weaponCmdData.BreakTimes ~= self.MaxWeaponBreakTimes)
  setactive(self.ui.mTrans_ImgLine.gameObject, self.weaponCmdData.BreakTimes ~= self.MaxWeaponBreakTimes)
  self:UpdateBreakTime()
  self:UpdateRedPoint()
end
function UIChrWeaponBreakPanelV4:UpdateBreakTime()
  local curBreakTimes = self.weaponCmdData.BreakTimes
  self.targetBreakTimes = curBreakTimes + 1
  if self.targetBreakTimes > self.MaxWeaponBreakTimes then
    self.targetBreakTimes = self.MaxWeaponBreakTimes
  end
  local weaponCostList = self.weaponCmdData:GetBreakWeaponCmdDataList()
  self.isWeaponEnough = weaponCostList ~= nil and weaponCostList.Count > 0
  setactive(self.ui.mTrans_Locked.gameObject, false)
  if self.isWeaponEnough then
    self.curCostWeaponCmdData = weaponCostList[0]
    setactive(self.ui.mImg_BreakNum.gameObject, true)
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_BreakNum, self.curCostWeaponCmdData.BreakTimes, self.curCostWeaponCmdData.MaxBreakTime)
    local haveACount = CS.LuaUIUtils.GetNumberText(weaponCostList.Count)
    self.ui.mText_Num.text = haveACount .. "/1"
    self.ui.mText_Lv2.text = GlobalConfig.SetLvText(self.curCostWeaponCmdData.Level)
    setactive(self.ui.mTrans_Locked.gameObject, self.curCostWeaponCmdData.IsLocked)
  else
    self.curCostWeaponCmdData = nil
    setactive(self.ui.mImg_BreakNum.gameObject, true)
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_BreakNum, 1, self.MaxWeaponBreakTimes)
    self.ui.mText_Lv2.text = GlobalConfig.SetLvText(1)
    self.ui.mText_Num.text = "<color=#FF5E41>" .. 0 .. "</color>/1"
  end
  self.ui.mImg_TargetNum.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.targetBreakTimes)
  local targetBreakTimes = self.targetBreakTimes
  for i = 1, #self.breakTimesItems do
    local targetInt = 0
    if i == targetBreakTimes and targetBreakTimes ~= self.MaxWeaponBreakTimes then
      targetInt = 1
    elseif i < targetBreakTimes or targetBreakTimes == self.MaxWeaponBreakTimes then
      targetInt = 2
    end
    self.breakTimesItems[i].mAnimator_ProgressBarAfter:SetInteger("Level_Bar", targetInt)
  end
  self:UpdateMaxBreakTimes(curBreakTimes == self.MaxWeaponBreakTimes)
  self:UpdateSkill()
end
function UIChrWeaponBreakPanelV4:UpdateSkill()
  local SkillId = self.weaponCmdData.SkillId
  if SkillId == 0 then
    setactive(self.ui.mTrans_Left.gameObject, false)
    return
  end
  setactive(self.ui.mTrans_Left.gameObject, true)
  local data = self.weaponCmdData.Skill
  if data then
    self.ui.mText_Lv.text = GlobalConfig.SetLvText(data.Level)
    self.ui.mText_SkillName.text = data.name.str
    self.ui.mTextFit_Describe.text = data.description.str
  end
  local targetBreakTimes = self.targetBreakTimes
  local breakData = TableData.listWeaponBreakDatas:GetDataById(self.weaponCmdData.stc_id * 10 + targetBreakTimes)
  local skillData = TableData.GetSkillData(breakData.skill)
  if skillData then
    self.ui.mText_Lv1.text = GlobalConfig.SetLvText(skillData.Level)
    self.ui.mText_SkillName1.text = skillData.name.str
    self.ui.mTextFit_Describe1.text = skillData.description.str
  end
end
function UIChrWeaponBreakPanelV4:UpdateMaxBreakTimes(boolean)
  setactive(self.ui.mTrans_BtnBreak.gameObject, not boolean)
  setactive(self.ui.mTrans_MaxLevel.gameObject, boolean)
  setactive(self.ui.mTrans_WeaponConsume.gameObject, not boolean)
  setactive(self.ui.mTrans_TextAim.gameObject, not boolean)
  setactive(self.ui.mTrans_TextTip.gameObject, not boolean)
end
function UIChrWeaponBreakPanelV4:UpdateRedPoint()
  local redPoint = self.weaponCmdData:GetWeaponBreakRedPoint()
  setactive(self.breakRedpoint.gameObject, 0 < redPoint)
end
function UIChrWeaponBreakPanelV4:SwitchGun(gunCmdData, isShow)
  self.weaponCmdData = gunCmdData.WeaponData
  self.MaxWeaponBreakTimes = self.weaponCmdData.StcData.MaxBreak
  self.curCostItemData = TableData.GetItemData(self.weaponCmdData.stc_id)
  self:SetWeaponData()
end
function UIChrWeaponBreakPanelV4:OnClickBreak()
  if not self.isWeaponEnough then
    UITipsPanel.Open(self.curCostItemData, 0, true)
    return
  end
  local weaponBreak = function(hintId)
    local hint = TableData.GetHintById(hintId)
    local titleHint = TableData.GetHintById(64)
    local confirmCallback = function()
      self:SendLevelUp()
    end
    local param = {
      title = titleHint,
      contentText = hint,
      customData = self.curCostWeaponCmdData,
      isDouble = true,
      confirmCallback = confirmCallback,
      dialogType = 1
    }
    UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
  end
  if not self.curCostWeaponCmdData:HasPowerUpWithoutLocked() and not self.curCostWeaponCmdData.IsLocked then
    self:SendLevelUp()
  elseif not self.curCostWeaponCmdData:HasPowerUpWithoutLocked() and self.curCostWeaponCmdData.IsLocked then
    weaponBreak(102282)
  elseif self.curCostWeaponCmdData:HasPowerUpWithoutLocked() and not self.curCostWeaponCmdData.IsLocked then
    weaponBreak(102283)
  elseif self.curCostWeaponCmdData:HasPowerUpWithoutLocked() and self.curCostWeaponCmdData.IsLocked then
    weaponBreak(102284)
  end
end
function UIChrWeaponBreakPanelV4:SendLevelUp()
  local lastBreakTimes = self.weaponCmdData.BreakTimes
  self:SetInputActive(false)
  NetCmdWeaponData:SendGunWeaponBreak(self.weaponCmdData.id, self.curCostWeaponCmdData.id, function(ret)
    self:SetInputActive(true)
    if ret == ErrorCodeSuc then
      NetCmdWeaponData:RemoveWeapon(self.curCostWeaponCmdData.id)
      local callback = function()
        self:SetWeaponData()
      end
      UIManager.OpenUIByParam(UIDef.UIChrWeaponPowerUpDialogV3, {
        weaponCmdData = self.weaponCmdData,
        lastBreakTimes = lastBreakTimes,
        callback = callback
      })
    end
  end)
end
