require("UI.UIBasePanel")
UISimCombatTeachingRewardPanel = class("UISimCombatTeachingRewardPanel", UIBasePanel)
UISimCombatTeachingRewardPanel.__index = UISimCombatTeachingRewardPanel
UISimCombatTeachingRewardPanel.chapterId = 0
UISimCombatTeachingRewardPanel.labelList = {}
function UISimCombatTeachingRewardPanel:ctor(csPanel)
  UISimCombatTeachingRewardPanel.super.ctor(self)
  csPanel.Type = UIBasePanelType.Dialog
end
function UISimCombatTeachingRewardPanel:CloseUISimCombatTeachingRewardPanel()
  UIManager.CloseUI(UIDef.UISimCombatTeachingRewardPanel)
  self:OnReleaseUISimCombatTeachingRewardPanel()
end
function UISimCombatTeachingRewardPanel:OnReleaseUISimCombatTeachingRewardPanel()
  self.labelList = {}
end
function UISimCombatTeachingRewardPanel:OnInit(root, data)
  self.mIsPop = true
  self.chapterId = data
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  UISimCombatTeachingRewardPanel.super.SetRoot(UISimCombatTeachingRewardPanel, root)
  UISimCombatTeachingRewardPanel.mView = UISimCombatTeachingRewardPanelView.New()
  UISimCombatTeachingRewardPanel.mView:InitCtrl(root)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:CloseUISimCombatTeachingRewardPanel()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CloseBg.gameObject).onClick = function()
    self:CloseUISimCombatTeachingRewardPanel()
  end
  self:UpdatePanel()
end
function UISimCombatTeachingRewardPanel:UpdatePanel()
  local prefab = UIUtils.GetGizmosPrefab("SimCombat/SimCombatTeachingRewardItemV2.prefab", self)
  local list = NetCmdSimulateBattleData:GetSimBattleTeachingChapterList()
  for i = 0, self.mView.mTrans_Content.childCount - 1 do
    gfdestroy(self.mView.mTrans_Content:GetChild(i))
  end
  for i = 0, list.Count - 1 do
    do
      local data = list[i]
      local item
      local obj = instantiate(prefab)
      item = UISimCombatTeachingRewardItemV2.New()
      UIUtils.AddListItem(obj, self.mView.mTrans_Content.transform)
      item:InitCtrl(obj.transform)
      UIUtils.GetButtonListener(item.mBtn_Receive.gameObject).onClick = function(gObj)
        self:OnReceiveItem(item)
      end
      item:SetData(data)
    end
  end
end
function UISimCombatTeachingRewardPanel:OnReceiveItem(item)
  for itemId, num in pairs(item.mData.StcData.chapter_reward) do
    if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
      return
    end
  end
  NetCmdSimulateBattleData:ReqSimCombatTutorialTakeChapterReward(item.mData.StcData.id, function()
    self:TakeQuestRewardCallBack()
  end)
end
function UISimCombatTeachingRewardPanel:TakeQuestRewardCallBack()
  self:UpdatePanel()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.RefreshChapterInfo, nil)
  self:UpdateRedPoint()
  UISimCombatTeachingPanel:UpdateRewardRedPoint()
  UIBattleIndexPanel:UpdateRedPoint()
end
