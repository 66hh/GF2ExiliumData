require("UI.UIBasePanel")
UIDarkzoneReliabilityDetailDialog = class("UIDarkzoneReliabilityDetailDialog", UIBasePanel)
UIDarkzoneReliabilityDetailDialog.__index = UIDarkzoneReliabilityDetailDialog
function UIDarkzoneReliabilityDetailDialog:ctor(csPanel)
  UIDarkzoneReliabilityDetailDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkzoneReliabilityDetailDialog:OnInit(root, data)
  UIDarkzoneReliabilityDetailDialog.super.SetRoot(UIDarkzoneReliabilityDetailDialog, root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self.mData = data
  self:AddBtnListen()
end
function UIDarkzoneReliabilityDetailDialog:OnShowFinish()
  self:UpdateLeftList()
  self:InstTabBtn()
  self:OnEnterSetInfo()
end
function UIDarkzoneReliabilityDetailDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkzoneReliabilityDetailDialog)
end
function UIDarkzoneReliabilityDetailDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.mData = nil
  self:ReleaseCtrlTable(self.storyItemList, true)
  self.storyItemList = nil
  self:ReleaseCtrlTable(self.FuncItemList)
  self.FuncItemList = nil
  self.IsPanelOpen = nil
  self.ChooseNpc = nil
  self.ChooseTab = nil
  self.ChooseNpcFavorLevel = nil
  self.LastLeftTabItem = nil
  self.LastTabItem = nil
  self:ReleaseCtrlTable(self.LeftTabItemList, true)
  self.LeftTabItemList = nil
  self:ReleaseCtrlTable(self.TabItemList, true)
  self.TabItemList = nil
end
function UIDarkzoneReliabilityDetailDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkzoneReliabilityDetailDialog:InitBaseData()
  self.mview = UIDarkzoneReliabilityDetailDialogView.New()
  self.ui = {}
  self.storyItemList = {}
  self.FuncItemList = {}
  self.IsPanelOpen = false
  self.ChooseNpc = DZStoreUtils.curNpcId
  self.ChooseTab = 1
  self.ChooseNpcFavorLevel = 0
  self.LastLeftTabItem = nil
  self.LastTabItem = nil
  self.LeftTabItemList = {}
  self.TabItemList = {}
end
function UIDarkzoneReliabilityDetailDialog:AddBtnListen()
  if self.hasCache ~= true then
    UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
      self:CloseFunction()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self:CloseFunction()
    end
    self.hasCache = true
  end
end
function UIDarkzoneReliabilityDetailDialog:UpdateLeftList()
  local list = self.mData[1]
  for i = 1, #list do
    local item = DarkzoneReliabilityDetailLeftTabItem.New()
    item:InitCtrl(self.ui.mTrans_LeftContent)
    item:SetTable(self)
    item:SetData(list[i])
    self.LeftTabItemList[list[i].id] = item
  end
end
function UIDarkzoneReliabilityDetailDialog:InstTabBtn()
  for i = 1, 2 do
    do
      local item = DarkzoneReliabilityDetailFuncTabItem.New()
      item:InitCtrl(self.ui.mTrans_TabBtn)
      if i == 1 then
        item.ui.mText_Name.text = TableData.GetHintById(903256)
        UIUtils.GetButtonListener(item.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
          if self.LastTabItem ~= nil then
            self.LastTabItem.interactable = true
          end
          item.ui.mBtn_ComTab1ItemV2.interactable = false
          self.LastTabItem = item.ui.mBtn_ComTab1ItemV2
          self.ChooseTab = 1
          self:UpdateFuncData()
        end
      elseif i == 2 then
        item.ui.mText_Name.text = TableData.GetHintById(903257)
        UIUtils.GetButtonListener(item.ui.mBtn_ComTab1ItemV2.gameObject).onClick = function()
          if self.LastTabItem ~= nil then
            self.LastTabItem.interactable = true
          end
          item.ui.mBtn_ComTab1ItemV2.interactable = false
          self.LastTabItem = item.ui.mBtn_ComTab1ItemV2
          self.ChooseTab = 2
          self:UpdateStoryData()
        end
      end
      self.TabItemList[i] = item
    end
  end
end
function UIDarkzoneReliabilityDetailDialog:OnEnterSetInfo()
  local leftTabItem = self.LeftTabItemList[DZStoreUtils.curNpcId]
  leftTabItem.ui.mBtn_Self.interactable = false
  self.LastLeftTabItem = leftTabItem.ui.mBtn_Self
  self.ChooseNpcFavorLevel = self.mData[2]
  self:UpdateData()
  local TabItem = self.TabItemList[self.ChooseTab]
  TabItem.ui.mBtn_ComTab1ItemV2.interactable = false
  self.LastTabItem = TabItem.ui.mBtn_ComTab1ItemV2
end
function UIDarkzoneReliabilityDetailDialog:UpdateData()
  if self.ChooseTab == 1 then
    self:UpdateFuncData()
  elseif self.ChooseTab == 2 then
    self:UpdateStoryData()
  end
end
function UIDarkzoneReliabilityDetailDialog:UpdateFuncData()
  setactive(self.ui.mTrans_Story, false)
  setactive(self.ui.mTrans_Function, true)
  local StcData = TableData.listDarkzoneNpcParameterDatas
  local favorMax = TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel
  self.FuncItemList = {}
  for i = 0, self.ui.mTrans_FuncListContent.childCount - 1 do
    gfdestroy(self.ui.mTrans_FuncListContent:GetChild(i))
  end
  for i = 1, favorMax do
    local data = StcData:GetDataById((self.ChooseNpc - 400) * 1000 + i)
    local item = DarkzoneReliabilityDetailFuncItem.New()
    item:InitCtrl(self.ui.mTrans_FuncListContent)
    item:SetData(data, self.ChooseNpcFavorLevel)
    table.insert(self.FuncItemList, item)
  end
end
function UIDarkzoneReliabilityDetailDialog:UpdateStoryData()
  setactive(self.ui.mTrans_Story, true)
  setactive(self.ui.mTrans_Function, false)
  local StcData = TableData.listDarkzoneNpcParameterDatas
  local favorMax = TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel
  for i = 0, self.ui.mTrans_StoryListContent.childCount - 1 do
    gfdestroy(self.ui.mTrans_StoryListContent:GetChild(i))
  end
  for i = 1, favorMax do
    local data = StcData:GetDataById((self.ChooseNpc - 400) * 1000 + i)
    if data.npc_story.str ~= "" then
      local item = DarkzoneReliabilityDetailStoryItem.New()
      item:InitCtrl(self.ui.mTrans_StoryListContent)
      item:SetData(data, self.ChooseNpcFavorLevel)
      table.insert(self.storyItemList, item)
    end
  end
end
