require("UI.Common.UICommonItem")
UIActivitySevenQuestTaskItem = class("UIActivitySevenQuestTaskItem", UIBaseCtrl)
UIActivitySevenQuestTaskItem.ItemState = {
  Common = 1,
  CanReceive = 2,
  Complete = 3
}
function UIActivitySevenQuestTaskItem:ctor()
end
function UIActivitySevenQuestTaskItem:InitCtrl(root, data)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("Activity/SevenQuest/Btn_SevenQuestItemV2.prefab", self))
  self.data = data
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  UIUtils.AddListItem(instObj.gameObject, root)
  self:SetRoot(instObj.transform)
  self:UpdateTaskInfo()
  UIUtils.GetButtonListener(self.ui.mTrans_Go.gameObject).onClick = function()
    if self.data.taskData.link ~= "" then
      SceneSwitch:SwitchByID(tonumber(self.data.taskData.link))
    end
  end
  UIUtils.GetButtonListener(self.ui.mTrans_Can.gameObject).onClick = function()
    NetCmdActivitySevenQuestData:SendGetSevenQuestReward(self.data.taskData.id)
  end
end
function UIActivitySevenQuestTaskItem:UpdateTaskInfo()
  self.ui.mText_Content.text = self.data.taskData.name
  self.item = UICommonItem.New()
  self.item:InitCtrl(self.ui.mTrans_Item)
  for k, v in pairs(self.data.taskData.reward) do
    self.item:SetItemData(k, v)
  end
end
function UIActivitySevenQuestTaskItem:UpdateTaskState()
  local state = NetCmdActivitySevenQuestData:GetTaskState(self.data.taskData.id)
  if state == 0 then
    self.itemState = UIActivitySevenQuestTaskItem.ItemState.Common
  elseif state == 1 then
    self.itemState = UIActivitySevenQuestTaskItem.ItemState.CanReceive
  elseif state == 2 then
    self.itemState = UIActivitySevenQuestTaskItem.ItemState.Complete
  end
  setactive(self.ui.mTrans_Go, self.itemState == UIActivitySevenQuestTaskItem.ItemState.Common)
  setactive(self.ui.mTrans_Can, self.itemState == UIActivitySevenQuestTaskItem.ItemState.CanReceive)
  setactive(self.ui.mTrans_Complete, self.itemState == UIActivitySevenQuestTaskItem.ItemState.Complete)
  self.item:SetReceivedIcon(self.itemState == UIActivitySevenQuestTaskItem.ItemState.Complete)
end
function UIActivitySevenQuestTaskItem:OnRelease()
  gfdestroy(self.item:GetRoot())
  gfdestroy(self.mUIRoot)
  self.ui = nil
end
function UIActivitySevenQuestTaskItem:OnAwake(root, data)
  gfwarning("UIActivitySevenQuestTaskItem:OnAwake")
end
