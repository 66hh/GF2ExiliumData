require("UI.UIBasePanel")
UIChrStageUpDialog = class("UIChrStageUpDialog", UIBasePanel)
UIChrStageUpDialog.__index = UIChrStageUpDialog
local self = UIChrStageUpDialog
self.callback = nil
function UIChrStageUpDialog:ctor(obj)
  UIChrStageUpDialog.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UIChrStageUpDialog:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.gunCmdData = data.gunCmdData
  self.closeCallback = data.closeCallback
  self.nextBattleSkillData = nil
  local length = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Root, "FadeIn")
  self.fadeInTimer = TimerSys:DelayCall(length, function()
    self:AddBtnListen()
  end)
  local nextGradeId = self.gunCmdData.grade * 100 + self.gunCmdData.mGun.Grade + 1
  local gunGradeData = TableData.listGunGradeDatas:GetDataById(nextGradeId)
  local nextSkillId = gunGradeData.Abbr[0]
  for i = 0, self.gunCmdData.CurAbbr.Count - 1 do
    if math.ceil(self.gunCmdData.CurAbbr[i] / 100) == math.ceil(nextSkillId / 100) then
      self.nextBattleSkillData = TableData.listBattleSkillDatas:GetDataById(self.gunCmdData.CurAbbr[i])
      self:SetUIData()
      return
    end
  end
  self.ui.mBtn_Close.interactable = false
end
function UIChrStageUpDialog:SetUIData()
  if self.nextBattleSkillData == nil then
    return
  end
  local isGunLock = NetCmdTeamData:GetGunByID(self.gunCmdData.GunId) == nil
  self.ui.mText_Name.text = self.nextBattleSkillData.name.str
  self.ui.mLevelText_Now.text = self.nextBattleSkillData.level - 1
  self.ui.mLevelText_Soon.text = self.nextBattleSkillData.level
  self.ui.mSkill_Icon.sprite = IconUtils.GetSkillIconByAttr(self.nextBattleSkillData.icon, self.nextBattleSkillData.icon_attr_type)
end
function UIChrStageUpDialog:CloseUIChrStageUpDialog()
  UIManager.CloseUI(UIDef.UIChrStageUpDialog)
  if self.callback ~= nil then
    self.callback()
    self.callback = nil
  end
end
function UIChrStageUpDialog:AddBtnListen()
  self.ui.mBtn_Close.interactable = true
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseUIChrStageUpDialog()
  end
end
function UIChrStageUpDialog:RemoveBtnListen()
  self.ui.mBtn_Close.interactable = false
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
end
function UIChrStageUpDialog:OnClose()
  self:RemoveBtnListen()
  if self.enableTimer then
    self.enableTimer:Stop()
    self.enableTimer = nil
  end
end
function UIChrStageUpDialog:OnHideFinish()
  if self.closeCallback ~= nil then
    self.closeCallback()
  end
end
