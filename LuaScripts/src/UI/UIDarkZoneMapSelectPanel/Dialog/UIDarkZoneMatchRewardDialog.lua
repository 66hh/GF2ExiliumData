require("UI.UIDarkZoneMapSelectPanel.Dialog.UIDarkZoneMatchRewardDialogView")
require("UI.UIBasePanel")
UIDarkZoneMatchRewardDialog = class("UIDarkZoneMatchRewardDialog", UIBasePanel)
UIDarkZoneMatchRewardDialog.__index = UIDarkZoneMatchRewardDialog
local self = UIDarkZoneMatchRewardDialog
function UIDarkZoneMatchRewardDialog:ctor(csPanel)
  UIDarkZoneMatchRewardDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneMatchRewardDialog:OnInit(root, data)
  UIDarkZoneMatchRewardDialog.super.SetRoot(UIDarkZoneMatchRewardDialog, root)
  self.mData = data
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIDarkZoneMatchRewardDialog:OnShowFinish()
  self:GetRewardItemDic(self.mData)
  self:UpdateItemList()
  self.IsPanelOpen = true
end
function UIDarkZoneMatchRewardDialog:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneMatchRewardDialog:OnUpdate(deltatime)
end
function UIDarkZoneMatchRewardDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneMatchRewardDialog)
end
function UIDarkZoneMatchRewardDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.mData = nil
  self.RewardItemDic = nil
  self:ReleaseCtrlTable(self.rewardListItems, true)
  self.rewardListItems = nil
end
function UIDarkZoneMatchRewardDialog:InitBaseData()
  self.mview = UIDarkZoneMatchRewardDialogView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.RewardItemDic = {}
  self.rewardListItems = {}
end
function UIDarkZoneMatchRewardDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:CloseFunction()
  end
end
function UIDarkZoneMatchRewardDialog:UpdateItemList()
  local needSortItem
  for k, v in pairs(self.RewardItemDic) do
    local item = RewardListItem.New()
    item:InitCtrl(self.ui.mTrans_Content, self.ui.Prefab)
    item:SetData(k, v)
    if k == 3 then
      needSortItem = item
    end
    table.insert(self.rewardListItems, item)
  end
  if needSortItem then
    needSortItem.mUIRoot:SetAsLastSibling()
  end
end
function UIDarkZoneMatchRewardDialog:GetRewardItemDic(list)
  for i = 0, list.Count - 1 do
    if 0 < list[i] then
      local data = TableData.listItemDatas:GetDataById(list[i])
      if data ~= nil then
        if self.RewardItemDic[data.type] == nil then
          self.RewardItemDic[data.type] = {}
        end
        table.insert(self.RewardItemDic[data.type], list[i])
      else
        gfdebug("ID" .. list[i] .. "在Item表中找不到")
      end
    end
  end
end
