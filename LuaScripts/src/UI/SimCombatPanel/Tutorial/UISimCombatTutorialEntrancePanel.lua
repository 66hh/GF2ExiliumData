require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatTutorialEntrancePanelView")
UISimCombatTutorialEntrancePanel = class("UISimCombatTutorialEntrancePanel", UIBasePanel)
UISimCombatTutorialEntrancePanel.__index = UISimCombatTutorialEntrancePanel
UISimCombatTutorialEntrancePanel.mView = nil
function UISimCombatTutorialEntrancePanel:ctor()
  UISimCombatTutorialEntrancePanel.super.ctor(self)
end
function UISimCombatTutorialEntrancePanel.Open()
end
function UISimCombatTutorialEntrancePanel.Close()
  UIManager.CloseUI(UIDef.UISimCombatTutorialEntrancePanel)
end
function UISimCombatTutorialEntrancePanel:OnHide()
end
function UISimCombatTutorialEntrancePanel:OnInit(root, data)
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  UISimCombatTutorialEntrancePanel.super.SetRoot(UISimCombatTutorialEntrancePanel, root)
  UISimCombatTutorialEntrancePanel.mData = data
  UISimCombatTutorialEntrancePanel.mView = UISimCombatTutorialEntrancePanelView
  self.ui = {}
  UISimCombatTutorialEntrancePanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function(gObj)
    UISimCombatTutorialEntrancePanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  local sectionTutorialData = TableData.listSimCombatTutorialSectionDatas:GetDataById(1)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    if not AccountNetCmdHandler:CheckSystemIsUnLock(sectionTutorialData.section_unlock) then
      PopupMessageManager.PopupString(sectionTutorialData.unlcok_tips.str)
      return
    end
    UIManager.OpenUI(UIDef.UISimCombatTutorialPanel)
  end
  local sectionRiddleData = TableData.listSimCombatTutorialSectionDatas:GetDataById(2)
  UIUtils.GetButtonListener(self.ui.mBtn_Root1.gameObject).onClick = function()
    if not AccountNetCmdHandler:CheckSystemIsUnLock(sectionRiddleData.section_unlock) then
      PopupMessageManager.PopupString(sectionRiddleData.unlcok_tips.str)
      return
    end
    UIManager.OpenUI(UIDef.UISimCombatRiddlePanel)
  end
  self.ui.mText_Name.text = sectionTutorialData.section_name.str
  self.ui.mText_Name1.text = sectionRiddleData.section_name.str
  self.sectionData = TableData.listSimCombatTutorialSectionDatas:GetList()
end
function UISimCombatTutorialEntrancePanel:OnShowStart()
  for i = 0, self.sectionData.Count - 1 do
    local redPoint = NetCmdSimulateBattleData:CheckTeachingRewardRedPoint(self.sectionData[i].id) or NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint(self.sectionData[i].id)
    if i == 0 then
      redPoint = redPoint or NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint()
      setactive(self.ui.mTrans_RedPoint, redPoint)
      self.ui.mAnimator_Root:SetBool("UnLock", AccountNetCmdHandler:CheckSystemIsUnLock(self.sectionData[i].section_unlock))
    else
      setactive(self.ui["mTrans_RedPoint" .. i], redPoint)
      self.ui["mAnimator_Root" .. i]:SetBool("UnLock", AccountNetCmdHandler:CheckSystemIsUnLock(self.sectionData[i].section_unlock))
    end
  end
end
function UISimCombatTutorialEntrancePanel:OnClose()
end
function UISimCombatTutorialEntrancePanel:OnBackFrom()
  self:OnShowStart()
end
function UISimCombatTutorialEntrancePanel:UpdateRewardRedPoint()
  setactive(self.ui.mTrans_RedPoint, NetCmdSimulateBattleData:CheckTeachingRewardRedPoint())
end
