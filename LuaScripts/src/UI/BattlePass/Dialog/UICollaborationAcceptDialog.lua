require("UI.BattlePass.UIBattlePassGlobal")
require("UI.Common.UICommonItem")
UICollaborationAcceptDialog = class("UICollaborationAcceptDialog", UIBasePanel)
UICollaborationAcceptDialog.__index = UICollaborationAcceptDialog
function UICollaborationAcceptDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICollaborationAcceptDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UICollaborationAcceptDialog:OnInit(root, data)
  self:AddBtnListen()
  self.mBpMessage = data.bpMessage
  self.mRewardItem = {}
  self:ShowInfo()
end
function UICollaborationAcceptDialog:OnShowStart()
end
function UICollaborationAcceptDialog:OnShowFinish()
end
function UICollaborationAcceptDialog:ShowInfo()
  local bpTaskData = TableData.listBpTaskDatas:GetDataById(self.mBpMessage.StcId)
  if bpTaskData == nil then
    return
  end
  self.ui.mText_TaskTarget.text = bpTaskData.Des
  self.ui.mText_Title.text = string_format(TableData.GetHintById(192083), bpTaskData.Name)
  local index = 1
  for k, v in pairs(bpTaskData.RewardList) do
    local item = self.mRewardItem[index]
    if self.mRewardItem[index] == nil then
      item = UICommonItem.New()
      table.insert(self.mRewardItem, item)
    end
    item:InitCtrl(self.ui.mSListChild_GrpItemList.transform)
    item:SetItemData(k, v)
    index = index + 1
  end
  for i = 0, NetCmdBattlePassData.TaskDetailUsersList.Count - 1 do
    local userData = NetCmdBattlePassData.TaskDetailUsersList[i]
    if userData.Uid == NetCmdBattlePassData.TaskDetail.Task.Owner then
      self.ui.mText_Tip.text = string_format(TableData.GetHintById(192060), userData.Name, bpTaskData.Name)
    end
  end
end
function UICollaborationAcceptDialog:OnAcceptTask(msg)
  local state = msg.Sender
  if CS.ProtoObject.BpShareTaskState.None == state then
    local hint = TableData.GetHintById(192057)
    CS.PopupMessageManager.PopupPositiveString(hint)
    UIManager.CloseUI(UIDef.UICollaborationAcceptDialog)
  elseif CS.ProtoObject.BpShareTaskState.Full == state then
    local hint = TableData.GetHintById(192058)
    CS.PopupMessageManager.PopupString(hint)
  elseif CS.ProtoObject.BpShareTaskState.Expire == state then
    local hint = TableData.GetHintById(192059)
    CS.PopupMessageManager.PopupString(hint)
  end
end
function UICollaborationAcceptDialog:OnClose()
  for _, item in pairs(self.mRewardItem) do
    gfdestroy(item:GetRoot())
  end
  MessageSys:RemoveListener(UIEvent.BpTaskAccept, self.AcceptTask)
end
function UICollaborationAcceptDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UICollaborationAcceptDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.transform).onClick = function()
    UIManager.CloseUI(UIDef.UICollaborationAcceptDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.transform).onClick = function()
    UIManager.CloseUI(UIDef.UICollaborationAcceptDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = function()
    UIManager.CloseUI(UIDef.UICollaborationAcceptDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.transform).onClick = function()
    if NetCmdBattlePassData.AcceptTaskNum >= TableData.GlobalSystemData.BattlepassTaskShareToplimit2 then
      local hint = TableData.GetHintById(192048)
      CS.PopupMessageManager.PopupString(hint)
      return
    end
    NetCmdBattlePassData:SendBattlepassAcceptTask(self.mBpMessage.TaskId)
  end
  function self.AcceptTask(msg)
    self:OnAcceptTask(msg)
  end
  MessageSys:AddListener(UIEvent.BpTaskAccept, self.AcceptTask)
end
