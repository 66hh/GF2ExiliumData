require("UI.WeaponPanel.UIWeaponGlobal")
UIChrWeaponPowerUpPanelV3 = class("UIChrWeaponPowerUpPanelV3", UIBasePanel)
UIChrWeaponPowerUpPanelV3.__index = UIChrWeaponPowerUpPanelV3
function UIChrWeaponPowerUpPanelV3:ctor(csPanel)
  UIChrWeaponPowerUpPanelV3.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  self.weaponCmdData = nil
  self.itemData = nil
  self.maxBreakTimes = 0
  self.MaxWeaponBreakTimes = 0
  self.targetBreakTimes = 0
  self.breakTimesItems = {}
  self.isWeaponEnough = false
  self.costWeaponNum = 0
  self.isItemEnough = false
  self.skillItems = {}
  self.ringObj = nil
  self.bgObj = nil
  self.bgObjAnimator = nil
end
function UIChrWeaponPowerUpPanelV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponPowerUpPanelV3:OnInit(root, data)
  self.weaponCmdData = NetCmdWeaponData:GetWeaponById(data)
  self.MaxWeaponBreakTimes = self.weaponCmdData.StcData.MaxBreak
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponPowerUpPanelV3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpBtnReduce.gameObject).onClick = function()
    self:UpdateBreakTime(-1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpBtnIncrease.gameObject).onClick = function()
    self:UpdateBreakTime(1)
  end
  self:InitBreakeTimesItem()
  self:InitSkill()
end
function UIChrWeaponPowerUpPanelV3:OnShowStart()
  self:SetWeaponData()
end
function UIChrWeaponPowerUpPanelV3:OnRecover()
end
function UIChrWeaponPowerUpPanelV3:OnBackFrom()
  self:SetWeaponData()
end
function UIChrWeaponPowerUpPanelV3:OnTop()
end
function UIChrWeaponPowerUpPanelV3:OnShowFinish()
end
function UIChrWeaponPowerUpPanelV3:OnCameraStart()
  return 0.01
end
function UIChrWeaponPowerUpPanelV3:OnCameraBack()
end
function UIChrWeaponPowerUpPanelV3:OnHide()
  if self.bgObjAnimator ~= nil then
    self.bgObjAnimator:SetTrigger("FadeOut")
  end
end
function UIChrWeaponPowerUpPanelV3:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIModelToucher.ReleaseWeaponToucher()
    UIWeaponGlobal:ReleaseWeaponModel()
  end
  setactive(self.ringObj, true)
  setactive(self.bgObj, false)
end
function UIChrWeaponPowerUpPanelV3:OnClose()
end
function UIChrWeaponPowerUpPanelV3:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPowerUpPanelV3:InitBreakeTimesItem()
  self.breakTimesItems = {}
  local tmpBreakTimesParent = self.ui.mTrans_Bar.transform
  local item
  for i = 1, self.MaxWeaponBreakTimes do
    if i > tmpBreakTimesParent.childCount - 1 then
      item = instantiate(self.ui.mTrans_BreakTimesItem.gameObject, tmpBreakTimesParent)
    else
      item = tmpBreakTimesParent:GetChild(i)
    end
    local breakTimesItem = {}
    self:LuaUIBindTable(item, breakTimesItem)
    table.insert(self.breakTimesItems, breakTimesItem)
  end
end
function UIChrWeaponPowerUpPanelV3:InitSkill()
  self.skillItems = {}
  local tmpSkillParent = self.ui.mTrans_Skill.transform
  local item
  for i = 1, 5 do
    if i > tmpSkillParent.childCount then
      item = instantiate(self.ui.mTextFit_Skill1.gameObject, tmpSkillParent)
    else
      item = tmpSkillParent:GetChild(i - 1)
    end
    table.insert(self.skillItems, item)
  end
end
function UIChrWeaponPowerUpPanelV3:SetWeaponData()
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  self.ringObj = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("UI_ChrWeapon_Bg_Ring")
  self.bgObj = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("GrpBg")
  self.bgObjAnimator = self.bgObj:GetComponent(typeof(CS.UnityEngine.Animator))
  setactive(self.ringObj, false)
  setactive(self.bgObj, true)
  self.MaxWeaponBreakTimes = self.weaponCmdData.StcData.MaxBreak
  self.ui.mText_WeaponName.text = self.weaponCmdData.Name
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(self.weaponCmdData.Type)
  self.ui.mText_WeaponType.text = weaponTypeData.Name.str
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_QualityLine.color.a)
  self.ui.mImg_WeaponQualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_WeaponQualityLine.color.a)
  UIUtils.GetButtonListener(self.ui.mBtn_GrpWeaponConsume.gameObject).onClick = function()
    local itemData = TableData.GetItemData(self.weaponCmdData.stc_id)
    UITipsPanel.Open(itemData, 0, true)
  end
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mText_Name.text = self.weaponCmdData.Name
  local breakParam = TableData.GlobalSystemData["WeaponRank" .. self.weaponCmdData.Rank .. "BreakItem"]
  self.breakParam = {}
  for i, v in pairs(breakParam) do
    table.insert(self.breakParam, {id = i, costNum = v})
  end
  if #self.breakParam == 0 then
    gferror("武器突破道具数量错误")
  end
  self.itemData = TableData.listItemDatas:GetDataById(self.breakParam[1].id)
  self.ui.mText_Name1.text = self.itemData.Name.str
  self.ui.mImg_Icon1.sprite = IconUtils.GetItemIconSprite(self.itemData.id)
  UIUtils.GetButtonListener(self.ui.mBtn_GrpItemConsume.gameObject).onClick = function()
    UITipsPanel.Open(self.itemData, 0, true)
  end
  self.ui.mImg_QualityLine1.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.rank, self.ui.mImg_QualityLine1.color.a)
  self:UpdateBreakTime(1)
  if self.isWeaponEnough == true then
    UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
      self:OnClickLevelUp()
    end
  else
    local itemData = TableData.GetItemData(self.weaponCmdData.stc_id)
    TipsManager.Add(self.ui.mBtn_BtnBreak.gameObject, itemData)
  end
end
function UIChrWeaponPowerUpPanelV3:UpdateBreakTime(addValue)
  addValue = addValue == nil and 0 or addValue
  local curBreakTimes = self.weaponCmdData.BreakTimes
  self.maxBreakTimes = 0
  if self.weaponCmdData.WeaponduplicateNum >= self.MaxWeaponBreakTimes - curBreakTimes then
    self.maxBreakTimes = self.MaxWeaponBreakTimes
  else
    local itemOwn = NetCmdItemData:GetItemCountById(self.itemData.id)
    itemOwn = 0
    local itemCost = self.breakParam[1].costNum
    local canBreakTimes = math.floor(itemOwn / itemCost)
    self.maxBreakTimes = self.weaponCmdData.BreakTimes + self.weaponCmdData.WeaponduplicateNum + canBreakTimes
    if self.maxBreakTimes > self.MaxWeaponBreakTimes then
      self.maxBreakTimes = self.MaxWeaponBreakTimes
    end
  end
  self.targetBreakTimes = self.maxBreakTimes
  if self.targetBreakTimes == curBreakTimes then
    self.targetBreakTimes = curBreakTimes + addValue
  end
  if self.targetBreakTimes > self.MaxWeaponBreakTimes or curBreakTimes > self.targetBreakTimes then
    return
  end
  self.ui.mImg_Num.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.targetBreakTimes .. "_S")
  self:UpdateTargetBreakTimes()
end
function UIChrWeaponPowerUpPanelV3:UpdateTargetBreakTimes()
  local curBreakTimes = self.weaponCmdData.BreakTimes
  local targetBreakTimes = self.targetBreakTimes
  for i = 1, #self.breakTimesItems do
    setactive(self.breakTimesItems[i].mTrans_Arrow.gameObject, i == targetBreakTimes)
    setactive(self.breakTimesItems[i].mTrans_ProgressBarBefore.gameObject, i <= curBreakTimes)
    setactive(self.breakTimesItems[i].mTrans_ProgressBarAfter.gameObject, i > curBreakTimes and i <= targetBreakTimes)
  end
  self:UpdateWeaponConsume()
  self:UpdateItemConsume()
  self:UpdateSkill()
end
function UIChrWeaponPowerUpPanelV3:UpdateWeaponConsume()
  local weaponduplicateNum = self.weaponCmdData.WeaponduplicateNum
  local costWeaponNum = self.targetBreakTimes - self.weaponCmdData.BreakTimes
  local canNotSel = weaponduplicateNum == 0
  self.isWeaponEnough = weaponduplicateNum >= costWeaponNum
  if canNotSel then
    self.ui.mText_Num.text = "<color=red>0</color>/1"
  elseif self.isWeaponEnough then
    self.ui.mText_Num.text = weaponduplicateNum .. "/" .. costWeaponNum
    self.costWeaponNum = costWeaponNum
  else
    self.ui.mText_Num.text = weaponduplicateNum .. "/" .. weaponduplicateNum
    self.costWeaponNum = weaponduplicateNum
  end
  setactive(self.ui.mTrans_ImgLockedMask.gameObject, canNotSel)
  setactive(self.ui.mTrans_Sel.gameObject, not canNotSel)
end
function UIChrWeaponPowerUpPanelV3:UpdateItemConsume()
  local costItemNum = self.targetBreakTimes - self.weaponCmdData.BreakTimes - self.weaponCmdData.WeaponduplicateNum
  local itemCost = costItemNum * self.breakParam[1].costNum
  local itemOwn = NetCmdItemData:GetItemCountById(self.itemData.id)
  itemOwn = 0
  if self.isWeaponEnough then
    self.isItemEnough = true
    setactive(self.ui.mTrans_ImgLockedMask1.gameObject, true)
    setactive(self.ui.mTrans_Sel1.gameObject, false)
    self.ui.mText_Num1.text = itemOwn .. "/" .. 0
    return
  end
  self.isItemEnough = itemCost <= itemOwn
  if self.isItemEnough then
    self.ui.mText_Num1.text = itemOwn .. "/" .. itemCost
  else
    self.ui.mText_Num1.text = "<color=red>" .. itemOwn .. "</color>/" .. itemCost
  end
  setactive(self.ui.mTrans_ImgLockedMask1.gameObject, not self.isItemEnough)
  setactive(self.ui.mTrans_Sel1.gameObject, self.isItemEnough)
end
function UIChrWeaponPowerUpPanelV3:UpdateSkill()
  local SkillId = self.weaponCmdData.SkillId
  if SkillId == 0 then
    setactive(self.ui.mTrans_SkillTitle.gameObject, false)
    setactive(self.ui.mTrans_SkillList.gameObject, false)
    return
  end
  setactive(self.ui.mTrans_SkillTitle.gameObject, true)
  setactive(self.ui.mTrans_SkillList.gameObject, true)
  local data = self.weaponCmdData.Skill
  if data then
    self.ui.mText_SkillName.text = data.name.str
    self.ui.mTextFit_SkillDescribe.text = data.description.str
  end
  local curBreakTimes = self.weaponCmdData.BreakTimes
  local targetBreakTimes = self.targetBreakTimes
  local textImgColorList = self.ui.mTextImgColorList_Skill1
  for i = 1, #self.skillItems do
    local breakData = TableData.listWeaponBreakDatas:GetDataById(self.weaponCmdData.stc_id * 10 + i + 1)
    local skillData = TableData.GetSkillData(breakData.skill)
    local text = self.skillItems[i]:GetComponent("Text")
    local strLv = TableData.GetHintById(40115)
    local levelText = string_format(strLv, skillData.Level)
    text.text = levelText .. skillData.upgrade_description.str
    if curBreakTimes >= i + 1 then
      text.color = textImgColorList.TextColor[0]
    elseif curBreakTimes < i + 1 and targetBreakTimes >= i + 1 then
      text.color = textImgColorList.TextColor[1]
    else
      text.color = textImgColorList.TextColor[2]
    end
  end
end
function UIChrWeaponPowerUpPanelV3:OnClickLevelUp()
  if self.isWeaponEnough or self.isItemEnough then
    local SendLevelUp = function()
      local lastBreakTimes = self.weaponCmdData.BreakTimes
      local duplicateCost = self.targetBreakTimes - lastBreakTimes
      if not self.isWeaponEnough then
        duplicateCost = self.weaponCmdData.WeaponduplicateNum
      end
      NetCmdWeaponData:SendGunWeaponBreak(self.weaponCmdData.stc_id, duplicateCost, self.targetBreakTimes, function(ret)
        if ret == ErrorCodeSuc then
          self.weaponCmdData.WeaponduplicateNum = self.weaponCmdData.WeaponduplicateNum - duplicateCost
          self:SetWeaponData()
          UIManager.OpenUIByParam(UIDef.UIChrWeaponPowerUpDialogV3, {
            weaponStcId = self.weaponCmdData.stc_id,
            lastBreakTimes = lastBreakTimes
          })
        end
      end)
    end
    local hint = TableData.GetHintById(40113)
    hint = string_format(hint, self.weaponCmdData.StcData.Name.str)
    local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn, function()
      SendLevelUp()
    end)
    MessageBoxPanel.Show(content)
  else
    UIUtils.PopupHintMessage(40018)
  end
end
