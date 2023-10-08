UIUpgradeContent = class("UIUpgradeContent", UIBasePanel)
UIUpgradeContent.__index = UIUpgradeContent
UIUpgradeContent.PrefabPath = "Character/ChrStageUpPanel.prefab"
local self = UIUpgradeContent
function UIUpgradeContent:ctor(obj)
  UIUpgradeContent.super.ctor(self, obj)
end
function UIUpgradeContent:OnInit(root, data)
  self:SetRoot(root)
  self.rankList = {}
  self.curRank = nil
  self.canUpgrade = false
  self.isItemEnough = false
  self.costItem = nil
  self.extraDescriptionList = {}
  self.skilldata = nil
  self.mData = data
  self.mParent = FacilityBarrackGlobal.GetCharacterDetailPanel()
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIUpgradeContent:__InitCtrl()
  self.mTrans_Activate = self.ui.mTrans_Activate
  self.mTrans_UpgradeLock = self.ui.mTrans_UpgradeLock
  self.mText_Hint = self.ui.mText_Name2
  self.animator = UIUtils.GetAnimator(self.mUIRoot, "Root")
  for i = 1, TableData.GlobalSystemData.GunMaxGrade do
    local line
    local obj = self:GetRectTransform("Root/GrpStage/Viewport/Content/GrpStageUp/StageUp" .. i)
    if i < TableData.GlobalSystemData.GunMaxGrade then
      line = self:GetRectTransform("Root/GrpStage/Viewport/Content/GrpLine/Line" .. i)
    end
    local rank = self:InitRank(obj, line, i)
    table.insert(self.rankList, rank)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OK.gameObject).onClick = function()
    self:OnUpgradeClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Skill.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIChrSkillInfoDialog, {
      skillData = self.skilldata,
      gunCmdData = self.mParent.mData,
      isGunLock = self.mParent.isGunLock,
      showBottomBtn = false,
      showTag = 2
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUpgradeContent)
  end
  UIUtils.AddBtnClickListener(self.ui.mBtn_Home.gameObject, function()
    self:OnClickHome()
  end)
  self:InitCostItem()
end
function UIUpgradeContent:OnShowFinish()
  self:__InitCtrl()
  self:SetData()
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
end
function UIUpgradeContent:InitRank(obj, line, index)
  local rank = {}
  if obj then
    rank.index = index
    rank.obj = obj
    rank.btnUpgrade = UIUtils.GetButton(obj, "ComBarrackStageUp/Btn_GrpState")
    rank.transCanUnlock = UIUtils.GetRectTransform(obj, "ComBarrackStageUp/Btn_GrpState/GrpContent/GrpNor/GrpBg/Trans_ImgCanUnlock")
    rank.transUnlock = UIUtils.GetRectTransform(obj, "ComBarrackStageUp/Btn_GrpState/GrpContent/GrpNor/GrpBg/Trans_ImgUnlock")
    rank.transLock = UIUtils.GetRectTransform(obj, "ComBarrackStageUp/Btn_GrpState/GrpContent/GrpNor/GrpBg/Trans_ImgLocked")
    rank.transSelect = UIUtils.GetRectTransform(obj, "ComBarrackStageUp/Btn_GrpState/GrpContent/GrpSel")
    rank.transEffect = UIUtils.GetRectTransform(obj, "ChrStageUpPanelV2_Effect01")
    rank.transRedPoint = UIUtils.GetRectTransform(obj, "ComBarrackStageUp/Btn_GrpState/GrpContent/Trans_RedPoint")
  end
  if line then
    rank.tranLine = line
    rank.transLineLock = UIUtils.GetRectTransform(line, "Trans_GrpLocked")
    rank.transLineUnlock = UIUtils.GetRectTransform(line, "Trans_GrpUnlocked")
  end
  setactive(rank.transSelect, false)
  return rank
end
function UIUpgradeContent:InitCostItem()
  if self.costItem == nil then
    self.costItem = UICommonItem.New()
    self.costItem:InitCtrl(self.ui.mTrans_GrpItem)
  end
end
function UIUpgradeContent:OnCameraStart()
  return 3
end
function UIUpgradeContent:OnCameraBack()
  return 4
end
function UIUpgradeContent:SetData()
  if self.curRank then
    self.curRank.btnUpgrade.interactable = true
    setactive(self.curRank.transSelect, false)
  end
  self.isMaxUpgrade = self.mData.maxUpgrade == self.mData.upgrade
  self.curRank = nil
  self.animator:Play("Ani_ChrStageUp_fx_01", 3, 1)
  self:OnEnable(true)
  self:UpdateContent()
end
function UIUpgradeContent:OnHide()
  self:ReleaseTimers()
end
function UIUpgradeContent:OnEnable(enable)
  if not enable then
    self:ReleaseTimers()
  end
end
function UIUpgradeContent:UpdateContent()
  for i, rank in ipairs(self.rankList) do
    if i <= self.mData.maxUpgrade + 1 then
      self:UpdateRank(rank)
      if self.isMaxUpgrade then
        if rank.index == self.mData.maxUpgrade then
          self:OnClickRank(rank)
        end
      elseif rank.index == self.mData.upgrade + 1 then
        self:OnClickRank(rank)
        setactive(rank.transRedPoint, self.isItemEnough)
      end
    end
  end
end
function UIUpgradeContent:UpdateRank(item)
  if item then
    item.isActivate = item.index <= self.mData.upgrade
    item.isLock = item.index > self.mData.upgrade + 1
    item.isCanUpgrade = item.index == self.mData.upgrade + 1
    setactive(item.transUnlock, item.isActivate)
    setactive(item.transCanUnlock, item.isCanUpgrade)
    setactive(item.transLock, item.isLock)
    setactive(item.transEffect, false)
    setactive(item.transRedPoint, false)
    if item.tranLine then
      setactive(item.transLineLock, not item.isActivate)
      setactive(item.transLineUnlock, item.isActivate)
    end
    UIUtils.GetButtonListener(item.btnUpgrade.gameObject).onClick = function()
      self:OnClickRank(item)
    end
  end
end
function UIUpgradeContent:OnClickRank(item)
  if self.curRank then
    if self.curRank.index == item.index then
      return
    else
      self.curRank.btnUpgrade.interactable = true
    end
    setactive(self.curRank.transSelect, false)
  end
  setactive(item.transSelect, true)
  self.curRank = item
  self.curRank.btnUpgrade.interactable = false
  self:UpdateRankInfo(item)
end
function UIUpgradeContent:UpdateRankInfo(item)
  if item then
    local gun_grade_id = self.mData.grade * 100 + item.index + 1
    local gunGradeData = TableData.listGunGradeDatas:GetDataById(gun_grade_id)
    if item.index > 0 then
      self.costItem:SetItemData(self.mData.TabGunData.core_item_id, gunGradeData.CostPiece, true, true)
    end
    self.ui.mText_Num.text = item.index
    self.ui.mText_GradeName.text = gunGradeData.name.str
    local skilldata = TableData.listBattleSkillDatas:GetDataById(gunGradeData.abbr[0])
    self.skilldata = skilldata
    self.ui.mText_Name1.text = skilldata.name.str
    self.ui.mText_Lv.text = "Lv." .. skilldata.level
    self.ui.mTrans_Description.text = skilldata.upgrade_description.str
    self.ui.mTrans_Icon.sprite = IconUtils.GetSkillIconByAttr(skilldata.icon, skilldata.icon_attr_type)
    setactive(self.ui.mTrans_ExtraDescription.gameObject, false)
    if item.index > self.mData.upgrade then
      self.mText_Hint.text = string_format(TableData.GetHintById(102106), item.index - 1)
    end
    self.isItemEnough = self.costItem:IsItemEnough()
    setactive(self.mTrans_Activate, item.isActivate)
    setactive(self.mTrans_UpgradeLock, item.isLock)
    setactive(self.ui.mBtn_OK.gameObject, item.isCanUpgrade)
    setactive(self.ui.mTrans_GrpItem, item.index > 0)
    setactive(self.ui.mTrans_GrpConsume, item.index > self.mData.mGun.Grade or item.index == 1 and self.mData.mGun.Grade == 0)
    self.canUpgrade = self.isItemEnough and item.isCanUpgrade and not self.isMaxUpgrade
  end
end
function UIUpgradeContent:OnUpgradeClick()
  if self.curRank then
    if self.canUpgrade then
      setactive(self.ui.mTrans_Mask, true)
      NetCmdTrainGunData:SendCmdUpgradeGun(self.mData.id, function()
        self:UpgradeCallback()
      end)
    elseif not self.isItemEnough then
      UIUtils.PopupHintMessage(40005)
    end
  end
end
function UIUpgradeContent:UpgradeCallback()
  if self.curRank then
    self.curRank.btnUpgrade.interactable = true
    setactive(self.curRank.transSelect, false)
  end
  local curRank = self.curRank
  self.isMaxUpgrade = self.mData.maxUpgrade == self.mData.upgrade
  self.animator:Play("Ani_ChrStageUp_fx_01", 3, 0)
  setactive(curRank.transEffect, true)
  self:DelayCall(3, function()
    UIManager.OpenUIByParam(UIDef.UIChrStageUpDialog, self.mData)
    if self.curRank then
      self:SetData()
      CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.FacilityBarrackEvent.RefreshGun, nil)
      self.mParent.isModelLoading = false
      setactive(curRank.transEffect, false)
      setactive(self.ui.mTrans_Mask, false)
    end
  end)
end
function UIUpgradeContent:GetCostNumByUpgrade(upgrade)
  if upgrade < 0 then
    return 0
  end
  return TableData.GlobalSystemData.CharacterUpgradeCost[upgrade - 1]
end
function UIUpgradeContent:GetRectTransform(path)
  local child = self.mUIRoot.transform:Find(path)
  return CS.LuaUIUtils.GetRectTransform(child)
end
function UIUpgradeContent:OnRelease()
  UISystem.BarrackCharacterCameraCtrl:AttachChrTouchCtrlEvents()
  self:ReleaseTimers()
end
function UIUpgradeContent:OnClickHome()
  UIManager.JumpToMainPanel()
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
end
