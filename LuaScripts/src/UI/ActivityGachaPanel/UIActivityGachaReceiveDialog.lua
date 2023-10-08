require("UI.UIBasePanel")
UIActivityGachaReceiveDialog = class("UIActivityGachaReceiveDialog", UIBasePanel)
UIActivityGachaReceiveDialog.__index = UIActivityGachaReceiveDialog
function UIActivityGachaReceiveDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIActivityGachaReceiveDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self.listTargetItem = {}
  self.listNormalItem = {}
end
function UIActivityGachaReceiveDialog:OnInit(root, data)
  self.reward = data[1]
  self.gachaId = data[2]
  self.noTargetReward = data[3]
  self.callback = data[4]
  self.isMaxRound = data[5]
  self.curGroup = data[6]
end
function UIActivityGachaReceiveDialog:OnShowStart()
  self:Refresh()
end
function UIActivityGachaReceiveDialog:OnShowFinish()
end
function UIActivityGachaReceiveDialog:OnBackFrom()
end
function UIActivityGachaReceiveDialog:OnClose()
  if self.callback then
    self.callback()
  end
end
function UIActivityGachaReceiveDialog:OnHide()
end
function UIActivityGachaReceiveDialog:OnHideFinish()
end
function UIActivityGachaReceiveDialog:OnRelease()
  self.ui = nil
  self:ReleaseCtrlTable(self.listTargetItem, true)
  self.listTargetItem = nil
  self:ReleaseCtrlTable(self.listNormalItem, true)
  self.listNormalItem = nil
  self.callback = nil
end
function UIActivityGachaReceiveDialog:OnRecover()
end
function UIActivityGachaReceiveDialog:OnSave()
end
function UIActivityGachaReceiveDialog:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIActivityGachaReceiveDialog)
  end
end
function UIActivityGachaReceiveDialog:Refresh()
  local targetData = {}
  local normalData = {}
  local groupData = NetCmdActivityGachaData:GetGroupConfig(self.gachaId, self.curGroup)
  local lstId = TableDataBase.listActivityGachaRewardByGachaGroupDatas:GetDataById(groupData.gacha_group).Id
  for p, q in pairs(self.reward) do
    for i = 0, lstId.Count - 1 do
      local rewardData = TableData.listActivityGachaRewardDatas:GetDataById(lstId[i])
      if rewardData.id == p then
        local showData = UIUtils.GetKVSortItemTable(rewardData.reward_item)
        for _, data in pairs(showData) do
          local itemData = TableData.GetItemData(data.id)
          if itemData then
            if rewardData.type == ActivityGachaGlobal.TargteType then
              UIUtils.AddDrop(targetData, {
                itemId = data.id,
                itemNum = data.num * q
              })
              break
            end
            UIUtils.AddDrop(normalData, {
              itemId = data.id,
              itemNum = data.num * q
            })
          end
          break
        end
        break
      end
    end
  end
  UIUtils.SortItemTable(targetData)
  UIUtils.SortItemTable(normalData)
  setactive(self.ui.mText_NoRewardTip.gameObject, self.noTargetReward and #targetData <= 0)
  setactive(self.ui.mTrans_TargetReward, groupData.type == 1 and (self.noTargetReward or 0 < #targetData))
  setactive(self.ui.mTrans_NormalReward, 0 < #normalData)
  setactive(self.ui.mTrans_TargetTip, #targetData <= 0)
  self:RefreshList(targetData, self.listTargetItem, self.ui.mScrollListChild_TargetContent)
  self:RefreshList(normalData, self.listNormalItem, self.ui.mScrollListChild_NormalContent)
end
function UIActivityGachaReceiveDialog:RefreshList(rewardData, listItem, parent)
  local index = 1
  for _, v in pairs(rewardData) do
    local item = listItem[index]
    if not item then
      local commonItem = UICommonItem.New()
      commonItem:InitCtrl(parent)
      commonItem:SetItemData(v.itemId, v.itemNum)
      listItem[index] = commonItem
    else
      item:SetItemData(v.itemId, v.itemNum)
      setactive(item:GetRoot(), true)
    end
    index = index + 1
  end
  for i = index, #listItem do
    setactive(listItem[i]:GetRoot(), false)
  end
end
