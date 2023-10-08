require("UI.SimCombatPanel.Tutorial.Item.UISimCombatRiddleItem")
require("UI.UIBasePanel")
require("UI.SimCombatPanel.Tutorial.UISimCombatRiddlePanelView")
UISimCombatRiddlePanel = class("UISimCombatRiddlePanel", UIBasePanel)
UISimCombatRiddlePanel.__index = UISimCombatRiddlePanel
UISimCombatRiddlePanel.mView = nil
UISimCombatRiddlePanel.chapterList = {}
function UISimCombatRiddlePanel:ctor()
  UISimCombatRiddlePanel.super.ctor(self)
end
function UISimCombatRiddlePanel.Open()
end
function UISimCombatRiddlePanel.Close()
  UIManager.CloseUI(UIDef.UISimCombatRiddlePanel)
end
function UISimCombatRiddlePanel.Hide()
end
function UISimCombatRiddlePanel:OnInit(root, data)
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  UISimCombatRiddlePanel.super.SetRoot(UISimCombatRiddlePanel, root)
  UISimCombatRiddlePanel.mData = data
  UISimCombatRiddlePanel.mView = UISimCombatRiddlePanelView
  self.ui = {}
  UISimCombatRiddlePanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function(gObj)
    UISimCombatRiddlePanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  local chapterDataList = NetCmdSimulateBattleData:GetSimBattleTeachingChapterList(2)
  for i = 0, chapterDataList.Count - 1 do
    local chapterData = chapterDataList[i]
    local item
    if self.chapterList[i + 1] == nil then
      item = UISimCombatRiddleItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      table.insert(self.chapterList, item)
      UIUtils.GetButtonListener(item.ui.mBtn_Root.gameObject).onClick = function()
        if not chapterData.IsUnlocked or not chapterData.IsPrevCompleted then
          CS.PopupMessageManager.PopupString(chapterData.StcData.unlcok_tips.str)
          return
        end
        if chapterData:CheckRedPoint() then
          chapterData:RemoveRedPoint()
        end
        UIManager.OpenUIByParam(UIDef.UISimCombatRiddleChapterPanel, chapterData)
      end
    end
  end
  function self.OnItemShow(index)
    self.chapterList[index + 1]:SetData(chapterDataList[index])
  end
  self.ui.mFade_Content:onShow("+", self.OnItemShow)
end
function UISimCombatRiddlePanel:OnRecover()
  self:OnShowStart()
end
function UISimCombatRiddlePanel:OnBackFrom()
  self:OnShowStart()
end
function UISimCombatRiddlePanel:OnShowStart()
  self.ui.mFade_Content:InitFade()
  self:UpdateRewardRedPoint()
end
function UISimCombatRiddlePanel:OnRelease()
  self.chapterList = {}
end
function UISimCombatRiddlePanel:OnSave()
  self.chapterList = {}
end
function UISimCombatRiddlePanel:OnClose()
  self.ui.mFade_Content:onShow("-", self.OnItemShow)
end
function UISimCombatRiddlePanel:UpdateRewardRedPoint()
end
