require("UI.DarkZonePanel.UIDarkZoneNPCSelectPanel.UIDarkZoneStorePanel.Dialog.UIDarkZoneFavorUpDownDialogView")
require("UI.UIBasePanel")
UIDarkZoneFavorUpDownDialog = class("UIDarkZoneFavorUpDownDialog", UIBasePanel)
UIDarkZoneFavorUpDownDialog.__index = UIDarkZoneFavorUpDownDialog
function UIDarkZoneFavorUpDownDialog:ctor(csPanel)
  UIDarkZoneFavorUpDownDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneFavorUpDownDialog:OnInit(root, data)
  UIDarkZoneFavorUpDownDialog.super.SetRoot(UIDarkZoneFavorUpDownDialog, root)
  self:InitBaseData()
  self.mData = data
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:InitInfoData()
end
function UIDarkZoneFavorUpDownDialog:OnShowFinish()
  self.IsPanelOpen = true
  if self.mData.From < self.mData.To then
    self.ui.mAnim_Root:SetInteger("Color", 0)
    self.ui.mText_Tittle.text = TableData.GetHintById(903223)
  else
    self.ui.mAnim_Root:SetInteger("Color", 1)
  end
end
function UIDarkZoneFavorUpDownDialog:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneFavorUpDownDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneFavorUpDownDialog)
  UIManager.OpenUI(UIDef.UICommonReceivePanel)
end
function UIDarkZoneFavorUpDownDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self:ReleaseCtrlTable(self.storeAttributeItem, true)
  self.storeAttributeItem = nil
end
function UIDarkZoneFavorUpDownDialog:InitBaseData()
  self.mview = UIDarkZoneFavorUpDownDialogView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.storeAttributeItem = {}
  self.IsPanelOpen = false
end
function UIDarkZoneFavorUpDownDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
end
function UIDarkZoneFavorUpDownDialog:InitInfoData()
  self:InitNewStoreData()
end
function UIDarkZoneFavorUpDownDialog:InitNewStoreData()
  self.ui.mText_From.text = self.mData.From
  self.ui.mText_To.text = self.mData.To
  local NpcFavor = DarkNetCmdStoreData:GetNpcDataById(DZStoreUtils.curNpcId).Favor
  local NpcStoreList = DZStoreUtils.NpcStoreStateDic[DZStoreUtils.curNpcId]
  local BeforeCount = #NpcStoreList.UnlockList
  local NowCount = 0
  local TempNewStoreList = {}
  if self.mData.From < self.mData.To then
    for k, v in pairs(NpcStoreList.LockList) do
      local unlockNum = tonumber(v.spec_args) or 0
      if NpcFavor >= unlockNum then
        table.insert(NpcStoreList.UnlockList, v)
        table.insert(TempNewStoreList, v)
      end
    end
  end
  NowCount = #NpcStoreList.UnlockList
  if BeforeCount ~= NowCount then
    local item = DZNewStoreAttributeItem.New()
    item:InitCtrl(self.ui.mTrans_Content, self.ui.mPrefab)
    item:SetData(TableData.GetHintById(903213))
    for i = 1, #TempNewStoreList do
      item = DZNewStoreAttributeItem.New()
      item:InitCtrl(self.ui.mTrans_Content, self.ui.mPrefab)
      item:SetData(TempNewStoreList[i].name.str)
      self.storeAttributeItem[i] = item
    end
  end
end
