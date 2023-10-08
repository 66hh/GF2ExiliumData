require("UI.UIBasePanel")
require("UI.ArchivesPanel.Item.Btn_ArchivesCenterRecordItemV2")
ArchivesCenterRecordPanelV2 = class("ArchivesCenterRecordPanelV2", UIBasePanel)
ArchivesCenterRecordPanelV2.__index = ArchivesCenterRecordPanelV2
function ArchivesCenterRecordPanelV2:ctor(root)
  self.super.ctor(self, root)
  root.Type = UIBasePanelType.Panel
end
function ArchivesCenterRecordPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.storyUIList = {}
  self.currSelectData = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterRecordPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Item.gameObject).onClick = function()
    if self.itemId then
      local stcData = TableData.GetItemData(self.itemId)
      UITipsPanel.Open(stcData, nil, true)
    end
  end
end
function ArchivesCenterRecordPanelV2:OnInit(root, data)
  self.selectIndex = data[1]
  self.data = data[2]
  self:RefreshPlotDetail()
  self:RefreshData()
end
function ArchivesCenterRecordPanelV2:RefreshData()
  if self.selectIndex == 1 then
    setactive(self.ui.mTrans_Hard.gameObject, false)
    self:RefreshStory()
    setactive(self.ui.mTrans_Story.gameObject, true)
  else
    setactive(self.ui.mTrans_Story.gameObject, false)
    self:RefreshHard()
    setactive(self.ui.mTrans_Hard.gameObject, true)
  end
  local currPlotCount = NetCmdArchivesData:GetPlotCurrCount(self.data.id)
  local maxPlotCount = NetCmdArchivesData:GetPlotGroupCount(self.data.id)
  self.ui.mText_UnLockNum.text = string.format("%d/%d", currPlotCount, maxPlotCount)
  if currPlotCount >= maxPlotCount then
    TimerSys:DelayCall(0.2, function()
      self.ui.mAnimator_Item:SetBool("Bool", true)
    end)
  else
    self.ui.mAnimator_Item:SetBool("Bool", false)
  end
end
function ArchivesCenterRecordPanelV2:RefreshPlotDetail()
  if self.data == nil then
    return
  end
  self.ui.mText_Title.text = self.data.name.str
  local storyIDList = NetCmdArchivesData:GetGroupPlotListByGroup(self.data.id)
  for i = 0, storyIDList.Count - 1 do
    local syData = TableDataBase.listInformationDetailCsDatas:GetDataById(storyIDList[i])
    local index = i + 1
    if index > #self.storyUIList then
      local item = Btn_ArchivesCenterRecordItemV2.New()
      item:InitCtrl(self.ui.mTrans_Content)
      item:SetData(syData, self.selectIndex, i)
      table.insert(self.storyUIList, item)
    else
      self.storyUIList[index]:SetData(syData, self.selectIndex, i)
    end
    setactive(self.storyUIList[index].ui.mBtn_ArchivesCenterRecordItemV2, true)
    if i == 0 then
      self.currSelectData = syData
    end
  end
  for i = storyIDList.Count + 1, #self.storyUIList do
    setactive(self.storyUIList[i].ui.mBtn_ArchivesCenterRecordItemV2, false)
  end
end
function ArchivesCenterRecordPanelV2:RefreshStory()
  self.ui.mText_Code.text = self.data.code.str
  self.ui.mImg_StoryBg.sprite = IconUtils.GetArchivesIcon(self.data.listicon)
  if self.currSelectData then
    for k, v in pairs(self.currSelectData.unlock_item) do
      local itemData = TableData.GetItemData(k)
      if itemData then
        self.ui.mText_Name.text = itemData.name.str
        self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(itemData.id)
        self.ui.mText_Num.text = NetCmdItemData:GetItemCountById(itemData.id)
        self.itemId = itemData.id
        break
      end
    end
  end
end
function ArchivesCenterRecordPanelV2:RefreshHard()
  self.ui.mText_HardNum.text = self.data.code.str
  self.ui.mImg_HardBg.sprite = IconUtils.GetArchivesIcon(self.data.listicon)
  local itemData = TableDataBase.listItemDatas:GetDataById(self.data.item_id)
  if itemData then
    self.ui.mImg_HardIcon.sprite = IconUtils.GetItemIconSprite(itemData.id)
  end
end
function ArchivesCenterRecordPanelV2:OnShowStart()
end
function ArchivesCenterRecordPanelV2:OnShowFinish()
end
function ArchivesCenterRecordPanelV2:OnTop()
  self:RefreshPlotDetail()
  self:RefreshData()
end
function ArchivesCenterRecordPanelV2:OnBackFrom()
  self:RefreshPlotDetail()
  self:RefreshData()
end
function ArchivesCenterRecordPanelV2:OnClose()
end
function ArchivesCenterRecordPanelV2:OnHide()
end
function ArchivesCenterRecordPanelV2:OnHideFinish()
end
function ArchivesCenterRecordPanelV2:OnRelease()
end
