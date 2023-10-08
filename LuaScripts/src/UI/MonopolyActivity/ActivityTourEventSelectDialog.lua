require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.MonopolyActivity.Command.Btn_ActivityTourEventSelectItem")
ActivityTourEventSelectDialog = class("ActivityTourEventSelectDialog", UIBasePanel)
ActivityTourEventSelectDialog.__index = ActivityTourEventSelectDialog
function ActivityTourEventSelectDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourEventSelectDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self.listItem = {}
end
function ActivityTourEventSelectDialog:OnInit(root, data)
  self.selIdx = 1
  self.mDialogType = data.dialogType
  self.successCallBack = data.successCallBack
  self.failCallBack = data.failCallBack
  self.param = data.param
  self.listReward = data.rewards
  if self.listReward.Count == 0 then
    print_error("没有收到RewardList协议")
    return
  end
  setactive(self.ui.mBtn_Select.gameObject, false)
end
function ActivityTourEventSelectDialog:OnShowStart()
  if self.mDialogType == CS.GF2.Monopoly.TaskType.Func then
    self:RefreshRandomPoint()
  else
    self:RefreshGeneRandomEvent()
  end
  self:RefreshList()
end
function ActivityTourEventSelectDialog:OnClose()
  self:CloseCallBack()
end
function ActivityTourEventSelectDialog:OnRelease()
  self.ui = nil
  self.listReward = nil
  self:ReleaseCtrlTable(self.listItem, true)
end
function ActivityTourEventSelectDialog:RefreshList()
  for i = 1, self.listReward.Count do
    local item = self.listItem[i]
    if not item then
      item = Btn_ActivityTourEventSelectItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content.childItem, self.ui.mScrollListChild_Content.transform)
      self.listItem[i] = item
    end
    setactive(item.mUIRoot, true)
    item:SetSelectCallBack(i, self.RefreshSelect)
    self:RefreshItem(item, i - 1)
  end
  for i = self.listReward.Count + 1, #self.listItem do
    setactive(self.listItem[i].mUIRoot, false)
  end
end
function ActivityTourEventSelectDialog.RefreshSelect(selIdx)
  self = ActivityTourEventSelectDialog
  setactive(self.ui.mBtn_Select.gameObject, true)
  for i = 1, self.listReward.Count do
    local item = self.listItem[i]
    if item then
      self.selIdx = selIdx
      item:RefreshSelect(selIdx)
      self:SelectItem()
    end
  end
end
function ActivityTourEventSelectDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    self:OnBtnSelect()
  end
end
function ActivityTourEventSelectDialog:ResetListReward()
  self.listReward:Clear()
  self.listReward = nil
  self.successCallBack = nil
  self.failCallBack = nil
  self.ret = nil
  self.rewardData = nil
end
function ActivityTourEventSelectDialog:OnBtnSelect()
  self.rewardData = self.listReward[self.selIdx - 1]
  if MonopolyWorld.IsGmMode then
    if self.successCallBack then
      self.successCallBack(rewardData)
    end
    self:ResetListReward()
    UIManager.CloseUI(UIDef.ActivityTourEventSelectDialog)
    return
  end
  NetCmdMonopolyData:SendGetRandomReward(self.selIdx - 1, function(ret)
    self.ret = ret
    UIManager.CloseUI(UIDef.ActivityTourEventSelectDialog)
  end)
end
function ActivityTourEventSelectDialog:CloseCallBack()
  if not self.ret then
    return
  end
  if self.ret == ErrorCodeSuc then
    if self.successCallBack then
      self.successCallBack(self.rewardData)
    end
  elseif self.ret == ActivityTourGlobal.ErrorCodeActivityNotOpenOrClosed then
    print_debug("活动已结束")
    return
  elseif self.failCallBack then
    self.failCallBack(self.rewardData)
  end
  self:ResetListReward()
end
function ActivityTourEventSelectDialog:RefreshItem(itemCtrl, index)
  self:RefreshRandomPointItem(itemCtrl, index)
end
function ActivityTourEventSelectDialog:SelectItem()
  self:SelectRandomReward()
end
function ActivityTourEventSelectDialog:RefreshRandomPoint()
  if self.param and self.param == CS.LuaUtils.EnumToInt(ActivityTourGlobal.MonopolyFunctionType.RandomPoint) then
    self.ui.mText_Title.text = TableData.GetHintById(270225)
  else
    self.ui.mText_Title.text = TableData.GetHintById(270310)
  end
  self.ui.mText_Tips.text = TableData.GetHintById(270226)
end
function ActivityTourEventSelectDialog:RefreshGeneRandomEvent()
  self.ui.mText_Title.text = TableData.GetHintById(270283)
  self.ui.mText_Tips.text = TableData.GetHintById(270284)
end
function ActivityTourEventSelectDialog:RefreshRandomPointItem(itemCtrl, index)
  if not self.listReward or self.listReward.Count <= 0 then
    print_error("ActivityTourEventSelectDialog:随机事件奖励为空!")
    return
  end
  if itemCtrl == nil then
    print_error("ActivityTourEventSelectDialog:itemCtrl is null!")
    return
  end
  if self.listReward[index].Type == ActivityTourGlobal.RandomRewardType.Points then
    itemCtrl:SetPointData(self.listReward[index].Num)
  elseif self.listReward[index].Type == ActivityTourGlobal.RandomRewardType.Item then
    itemCtrl:SetInspirationData(self.listReward[index].Id, self.listReward[index].Num)
  elseif self.listReward[index].Type == ActivityTourGlobal.RandomRewardType.Buff then
    itemCtrl:SetBuffData(self.listReward[index].Id)
  else
    itemCtrl:SetCommandData(self.listReward[index].Id)
  end
end
function ActivityTourEventSelectDialog:SelectRandomReward()
end
