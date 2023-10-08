require("UI.Repository.Item.UIRepositoryBoxDialogView")
require("UI.Repository.Item.UIRepositoryBoxItem")
UIRepositoryBoxDialog = class("UIRepositoryBoxDialog", UIBasePanel)
UIRepositoryBoxDialog.__index = UIRepositoryBoxDialog
function UIRepositoryBoxDialog:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.mCSPanel = csPanel
end
function UIRepositoryBoxDialog:OnInit(root, data)
  UIRepositoryBoxDialog.super.SetRoot(UIRepositoryBoxDialog, root)
  self.ui = {}
  self.mData = data
  self.mview = UIRepositoryBoxDialogView.New()
  self.mview:InitCtrl(root, self.ui)
  self:InitData()
  self:AddBtnListen()
  self:UpdateData()
end
function UIRepositoryBoxDialog:OnClose()
  if self.itemList then
    for i = 1, #self.itemList do
      gfdestroy(self.itemList[i].ui.mUIRoot)
    end
  end
  self.ui = nil
  self.mview = nil
end
function UIRepositoryBoxDialog:OnRelease()
end
function UIRepositoryBoxDialog:InitData()
  self.nowNum = 0
  self.itemList = {}
  self.ui.mText_Titile.text = self.mData.name.str
  self.ui.mText_NameSelf0.text = TableData.GetHintById(1078)
  self.ui.mText_NameSelf.text = TableData.GetHintById(1079)
  local splitData = string.split(self.mData.ArgsStr, ";")
  self.totalNum = tonumber(splitData[1])
  self.itemTableList = string.split(splitData[2], ",")
  self.ui.mText_SelectTip.text = TableData.GetHintById(1070)
  self.ui.mText_SelectNum.text = string_format(TableData.GetHintById(1071), 0, self.totalNum)
  for i = 1, #self.itemTableList do
    local splitItem = string.split(self.itemTableList[i], ":")
    local itemId = tonumber(splitItem[1])
    local itemNum = tonumber(splitItem[2])
    local itemTableData = TableData.GetItemData(itemId)
    local item = UIRepositoryBoxItem.New()
    item:InitCtrl(self.ui.mTrans_BoxContent:GetComponent(typeof(CS.ScrollListChild)).childItem, self.ui.mTrans_BoxContent)
    item:SetData(itemId, itemNum, itemTableData, self)
    table.insert(self.itemList, item)
  end
  self.itemList[1]:OnClick(self)
end
function UIRepositoryBoxDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIRepositoryBoxDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIRepositoryBoxDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close2.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIRepositoryBoxDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnConfirmClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SliderAdd.gameObject).onClick = function()
    self:OnAddSlider()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SliderReduce.gameObject).onClick = function()
    self:OnReduceSlider()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Max.gameObject).onClick = function()
    self:OnMaxSlider()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Min.gameObject).onClick = function()
    self:OnMinSlider()
  end
end
function UIRepositoryBoxDialog:OnConfirmClick()
  if self.nowNum < self.totalNum then
    CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(1072), self.totalNum))
    return
  end
  local select = {}
  local otherTable = {}
  for i = 1, #self.itemList do
    if self.itemList[i].isSelect then
      local itemId = self.itemList[i].itemId
      local itemNum = self.itemList[i].itemNum
      if otherTable[itemId] ~= nil then
        otherTable[itemId] = otherTable[itemId] + itemNum
      else
        otherTable[itemId] = itemNum
      end
      table.insert(select, tonumber(self.itemList[i].itemId))
    end
  end
  if TipsManager.CheckItemIsOverflowAndStopByList(otherTable) then
    return
  end
  NetCmdItemData:SendCS_UseGiftPick(self.mData.id, select, self.composeNum)
  UIManager.CloseUI(UIDef.UIRepositoryBoxDialog)
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
end
function UIRepositoryBoxDialog:UpdateData()
  local itemNum = NetCmdItemData:GetItemCount(self.mData.id)
  self.composeNum = 1
  self.sliderMaxNum = itemNum
  self.sliderMaxNum = math.min(self.sliderMaxNum, TableData.GlobalSystemData.ItemComposeMax)
  self.ui.mText_Max.text = tostring(self.sliderMaxNum)
  self.ui.mSlider_Decompose.minValue = 1
  self.ui.mSlider_Decompose.maxValue = self.sliderMaxNum
  self.ui.mSlider_Decompose.onValueChanged:AddListener(function(value)
    self:OnSliderChange(value)
  end)
  self:RefreshSlider()
end
function UIRepositoryBoxDialog:OnAddSlider()
  if self.composeNum >= self.sliderMaxNum then
    return
  end
  self:OnSliderChange(self.composeNum + 1)
end
function UIRepositoryBoxDialog:OnReduceSlider()
  if self.composeNum <= 1 then
    return
  end
  self:OnSliderChange(self.composeNum - 1)
end
function UIRepositoryBoxDialog:OnMaxSlider()
  self:OnSliderChange(self.sliderMaxNum)
end
function UIRepositoryBoxDialog:OnMinSlider()
  self:OnSliderChange(1)
end
function UIRepositoryBoxDialog:OnSliderChange(value)
  self.composeNum = value
  self:RefreshSlider()
end
function UIRepositoryBoxDialog:RefreshSlider()
  self.ui.mBtn_Min.interactable = self.composeNum > 1
  self.ui.mBtn_SliderReduce.interactable = self.composeNum > 1
  self.ui.mBtn_Max.interactable = self.composeNum ~= self.sliderMaxNum and self.composeNum ~= 0
  self.ui.mBtn_SliderAdd.interactable = self.composeNum ~= self.sliderMaxNum and self.composeNum ~= 0
  self.ui.mSlider_Decompose.value = self.composeNum
  self.ui.mText_ComposeNum.text = math.floor(self.composeNum)
end
