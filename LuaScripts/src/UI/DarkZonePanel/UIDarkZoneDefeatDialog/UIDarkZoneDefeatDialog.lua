require("UI.Common.UICommonItem")
require("UI.UIBasePanel")
UIDarkZoneDefeatDialog = class("UIDarkZoneDefeatDialog", UIBasePanel)
UIDarkZoneDefeatDialog.__index = UIDarkZoneDefeatDialog
function UIDarkZoneDefeatDialog:ctor(csPanel)
  UIDarkZoneDefeatDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneDefeatDialog:OnInit(root, data)
  UIDarkZoneDefeatDialog.super.SetRoot(UIDarkZoneDefeatDialog, root)
  self:InitBaseData()
  self.userData = data
  self.mItemTable = {}
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
  self:UpdateData()
end
function UIDarkZoneDefeatDialog:OnShowFinish()
end
function UIDarkZoneDefeatDialog:CloseFunction()
  CS.SysMgr.dzUIControlMgr:DarkEnd()
end
function UIDarkZoneDefeatDialog:OnClose()
  for _, item in pairs(self.mItemTable) do
    gfdestroy(item:GetRoot())
  end
  self.ui = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.GunInfoDialog = nil
  self.clickTime = nil
  self.canClose = false
end
function UIDarkZoneDefeatDialog:InitBaseData()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.clickTime = 1
  self.hasCache = false
  self.isRewardBlank = true
  self.isDiscoverBlank = true
  self.canClose = false
  TimerSys:DelayCall(2, function()
    self.canClose = true
  end)
end
function UIDarkZoneDefeatDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneDefeatDialog:AddBtnListen()
  if self.hasCache ~= true then
    UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
      if self.canClose then
        self:CloseFunction()
      end
    end
    self.hasCache = true
  end
end
function UIDarkZoneDefeatDialog:UpdateData()
  local reason = ""
  local flag = self.userData.value__
  if flag == 0 then
    reason = TableData.GetHintById(903380) .. " " .. TableData.GetHintById(240046)
  elseif flag == 1 then
    reason = TableData.GetHintById(903380) .. " " .. TableData.GetHintById(903383)
  elseif flag == 2 then
    reason = TableData.GetHintById(903380) .. " " .. TableData.GetHintById(903381)
  elseif flag == 3 then
    reason = TableData.GetHintById(903380) .. " " .. TableData.GetHintById(903382)
  elseif flag == 4 then
    reason = TableData.GetHintById(903380) .. " " .. TableData.GetHintById(240047)
  elseif flag == 5 then
    reason = TableData.GetHintById(903380) .. " " .. TableData.GetHintById(240065)
  else
    gfwarning("未知的失败原因")
  end
  self.ui.mText_FailReason.text = reason
  self.ui.mText_Name.text = AccountNetCmdHandler:GetName()
  MessageSys:SendMessage(GuideEvent.OnDarkLose, CS.SysMgr.dzMatchGameMgr.darkZoneType)
  local questID = DarkNetCmdStoreData.currentTaskID
  if questID == 0 then
    questID = 10101
    gfdebug("questID 未设置，看看是不是没有走正常任务流程")
  end
  local equipLoss = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID).EquipLoss
  local enterDzEquipList = DarkZoneNetRepoCmdData.EnterDzEquipList
  local allBagGoods = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag:GetAllGoods()
  self.mAllBagGoods = {}
  for i = 0, allBagGoods.Count - 1 do
    table.insert(self.mAllBagGoods, allBagGoods[i])
  end
  table.sort(self.mAllBagGoods, function(a, b)
    local data1 = TableData.GetItemData(a.itemID)
    local data2 = TableData.GetItemData(b.itemID)
    if data1.rank == data2.rank then
      return a.itemID > b.itemID
    else
      return data1.rank > data2.rank
    end
  end)
  for i = 1, #self.mAllBagGoods do
    local itemShow = self.mAllBagGoods[i]:ShowInSettle()
    if itemShow then
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mSListChild_Content.transform)
      self.isDiscoverBlank = false
      if 1 >= self.mAllBagGoods[i].num then
        item:SetItemData(self.mAllBagGoods[i].itemID, 0, false, false, nil, self.mAllBagGoods[i].onlyID)
      else
        item:SetItemData(self.mAllBagGoods[i].itemID, self.mAllBagGoods[i].num, false, false, nil, self.mAllBagGoods[i].onlyID)
      end
      table.insert(self.mItemTable, item)
    end
  end
  setactive(self.ui.mTrans_ItemRoot, self.ui.mSListChild_Content.transform.childCount ~= 0)
  setactive(self.ui.mTrans_None, self.ui.mSListChild_Content.transform.childCount == 0)
end
function UIDarkZoneDefeatDialog:CloseInfo()
  if self.GunInfoDialog ~= nil then
    TransformUtils.PlayAniWithCallback(self.GunInfoDialog.transform, function()
      setactive(self.GunInfoDialog.gameObject, false)
    end)
  end
end
