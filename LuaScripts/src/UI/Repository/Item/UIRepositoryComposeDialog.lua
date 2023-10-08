require("UI.UIBasePanel")
require("UI.Repository.Item.UIRepositoryComposeDialogView")
require("UI.Common.UICommonItem")
require("UI.Tips.UIRepositoryComposeItem")
require("UI.Common.UICommonReceivePanel")
UIRepositoryComposeDialog = class("UIRepositoryComposeDialog", UIBasePanel)
UIRepositoryComposeDialog.__index = UIRepositoryComposeDialog
UIRepositoryComposeDialog.composeItemList = {}
UIRepositoryComposeDialog.dataList = {}
function UIRepositoryComposeDialog:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.mCSPanel = csPanel
end
function UIRepositoryComposeDialog:OnInit(root, data)
  UIRepositoryComposeDialog.super.SetRoot(UIRepositoryComposeDialog, root)
  self.ui = {}
  self.mData = data
  self.itemData = data.itemData
  self.mView = UIRepositoryComposeDialogView.New()
  self.mView:InitCtrl(root, self.ui)
  self:InitData()
  self:AddBtnListen()
end
function UIRepositoryComposeDialog:OnClose()
  self.ui = nil
  self.mView = nil
  for i, v in pairs(self.composeItemList) do
    v:OnRelease(true)
  end
  if self.targetItem then
    self.targetItem:OnRelease(true)
  end
  self.composeItemList = {}
  self.dataList = {}
end
function UIRepositoryComposeDialog:OnRelease()
end
function UIRepositoryComposeDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIRepositoryComposeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIRepositoryComposeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIRepositoryComposeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickCompose()
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
function UIRepositoryComposeDialog:InitData()
  self.selectIndex = 0
  self.targetItem = UICommonItem.New()
  self.targetItem:InitCtrl(self.ui.mTrans_ItemContent)
  self.targetItem:SetItemData(self.itemData.id, 0, nil, true, nil, nil, nil, nil, nil, nil, nil, nil, true)
  self.dataList = {}
  for itemId, count in pairs(self.itemData.compose) do
    table.insert(self.dataList, {itemId = itemId, count = count})
  end
  table.sort(self.dataList, function(a, b)
    local tableA = TableData.GetItemData(a.itemId)
    local tableB = TableData.GetItemData(b.itemId)
    return tableA.rank < tableB.rank
  end)
  for index, data in pairs(self.dataList) do
    local item = UIRepositoryComposeItem.New()
    item:InitCtrl(self.ui.mTrans_ComposeContent)
    item:SetData(data, index, self)
    table.insert(self.composeItemList, item)
  end
  local uiTemplateMax = self.ui.mBtn_Max.transform:GetComponent(typeof(CS.UITemplate))
  local uiTemplateMin = self.ui.mBtn_Min.transform:GetComponent(typeof(CS.UITemplate))
  uiTemplateMax.Texts[0].text = TableData.GetHintById(1078)
  uiTemplateMin.Texts[0].text = TableData.GetHintById(1079)
  local imgBg = self.ui.mTrans_GrpBg:GetChild(0):Find("GrpBg/ImgBg3")
  setactive(imgBg, false)
  self:SelectDefaultIndex()
end
function UIRepositoryComposeDialog:SelectDefaultIndex()
  local ret = 1
  for index, data in pairs(self.dataList) do
    local itemNum = NetCmdItemData:GetItemCount(data.itemId)
    if itemNum >= data.count then
      ret = index
      break
    end
  end
  local count = #self.dataList
  local maskHeight = self.ui.mTrans_ComposeContent.parent.rect.height
  local spacing = self.ui.mVerticalLayoutGroup_Item.spacing
  local itemHeight = self.ui.mTrans_ComposeContent:GetChild(0):GetComponent("LayoutElement").minHeight
  local contentHeight = itemHeight * count + spacing * (count + 1)
  self.ui.mScrollRect_Item.inertia = false
  if maskHeight < contentHeight then
    local moveY
    if ret < 3 then
      moveY = 0
    elseif ret == count then
      moveY = contentHeight - maskHeight
    else
      moveY = (ret - 2) * (spacing + itemHeight)
    end
    LuaDOTweenUtils.DOAnchorPosY(self.ui.mTrans_ComposeContent, moveY, 0.1)
  end
  TimerSys:DelayCall(0.1, function()
    self.ui.mScrollRect_Item.inertia = true
  end)
  self:OnSelectItem(ret)
end
function UIRepositoryComposeDialog:OnAddSlider()
  if self.composeNum >= self.sliderMaxNum then
    return
  end
  self:OnSliderChange(self.composeNum + 1)
end
function UIRepositoryComposeDialog:OnReduceSlider()
  if self.composeNum <= 1 then
    return
  end
  self:OnSliderChange(self.composeNum - 1)
end
function UIRepositoryComposeDialog:OnMaxSlider()
  self:OnSliderChange(self.sliderMaxNum)
end
function UIRepositoryComposeDialog:OnMinSlider()
  self:OnSliderChange(1)
end
function UIRepositoryComposeDialog:OnClickCompose()
  if self.composeNum == 0 then
    UIUtils.PopupHintMessage(1105)
  else
    NetCmdItemData:SendCmdComposeItemsMsg(self.itemData.id, self.composeNum, self.dataList[self.selectIndex].itemId, function(ret)
      self:OnComposeSucc(ret)
    end)
  end
end
function UIRepositoryComposeDialog:OnComposeSucc(ret)
  if ret == ErrorCodeSuc then
    UICommonReceivePanel.OpenWithCheckPopupDownLeftTips()
    self:UpdateData()
    local targetItemNum = NetCmdItemData:GetItemCount(self.itemData.id)
    MessageSys:SendMessage(UIEvent.ItemCompose, self.itemData.id, targetItemNum)
    if self.composeNum == 0 then
      self:SelectDefaultIndex()
    end
  end
end
function UIRepositoryComposeDialog:UpdateData()
  local targetItemNum = NetCmdItemData:GetItemCount(self.itemData.id)
  self.ui.mText_ItemCount.text = string_format(TableData.GetHintById(808), targetItemNum)
  self.ui.mText_Rate.text = self.dataList[self.selectIndex].count .. ":1"
  for _, item in pairs(self.composeItemList) do
    item:UpdateCount()
    item:SetSelected(self.selectIndex)
  end
  local itemNum = NetCmdItemData:GetItemCount(self.dataList[self.selectIndex].itemId)
  local isActive = itemNum >= self.dataList[self.selectIndex].count
  if isActive then
    self.sliderMaxNum = math.floor(itemNum / self.dataList[self.selectIndex].count)
    self.sliderMaxNum = math.min(self.sliderMaxNum, TableData.GlobalSystemData.ItemComposeMax)
    self.ui.mText_Max.text = tostring(self.sliderMaxNum)
    self.ui.mSlider_Decompose.minValue = 1
    self.ui.mSlider_Decompose.maxValue = self.sliderMaxNum
    self.ui.mSlider_Decompose.onValueChanged:AddListener(function(value)
      self:OnSliderChange(value)
    end)
    self:RefreshSlider()
  else
    self.ui.mText_Max.text = "1"
    self.ui.mSlider_Decompose.minValue = 1
    self.ui.mSlider_Decompose.maxValue = 1
    self.sliderMaxNum = 1
    self.ui.mSlider_Decompose.value = 0
    self.composeNum = 0
    self:RefreshSlider()
  end
end
function UIRepositoryComposeDialog:OnSelectItem(index)
  if self.selectIndex == index then
    return
  end
  self.selectIndex = index
  self:OnSliderChange(1)
  self:UpdateData()
end
function UIRepositoryComposeDialog:OnSliderChange(value)
  self.composeNum = value
  self:RefreshSlider()
end
function UIRepositoryComposeDialog:RefreshSlider()
  self.ui.mBtn_Min.interactable = self.composeNum > 1
  self.ui.mBtn_SliderReduce.interactable = self.composeNum > 1
  self.ui.mBtn_Max.interactable = self.composeNum ~= self.sliderMaxNum and self.composeNum ~= 0
  self.ui.mBtn_SliderAdd.interactable = self.composeNum ~= self.sliderMaxNum and self.composeNum ~= 0
  self.ui.mSlider_Decompose.value = self.composeNum
  self.ui.mText_ComposeNum.text = math.floor(self.composeNum)
end
