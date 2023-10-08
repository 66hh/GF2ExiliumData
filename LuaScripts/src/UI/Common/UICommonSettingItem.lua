require("UI.Common.UICommonSettingDropDownItem")
require("UI.UIBaseCtrl")
UICommonSettingItem = class("UICommonSettingItem", UIBaseCtrl)
UICommonSettingItem.__index = UICommonSettingItem
function UICommonSettingItem:ctor()
  self.itemId = 0
  self.itemNum = 0
  self.isItemEnough = false
  self.relateId = nil
end
function UICommonSettingItem:__InitCtrl()
end
function UICommonSettingItem:InitCtrl(parent, callback, setToFirst)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComSettingItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
    if setToFirst then
      obj.transform:SetSiblingIndex(0)
    end
  end
  self.ui = {}
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  self.btnList = {}
  self.dropDownItemList = {}
  self.mKeyBoardTextList = {}
  self.mKeyBoardAddImgList = {}
  self.mKeyBoardMouseImgList = {}
  self.isSortDropDownActive = false
  UIUtils.GetButtonListener(self.ui.mBtn_Screen.gameObject).onClick = function()
    if callback ~= nil then
      callback()
    end
  end
end
function UICommonSettingItem:OnDropDown()
  self:ShowDropDown(not self.isSortDropDownActive)
  self.parent.settingPanel.ui.mScrollRect_Picture.enabled = not self.isSortDropDownActive
  if self.isSortDropDownActive then
    self:RefreshPos()
  end
end
function UICommonSettingItem:SetData(data, parent)
  self.parent = parent
  self.ui.mText_Name.text = data.name
  if data.type == nil then
    self.type = 1
  end
  self.type = data.type
  setactive(self.ui.mTrans_Slider, self.type == 1)
  setactive(self.ui.mTrans_Screen, self.type == 2)
  setactive(self.ui.mTrans_Voice, self.type == 3)
  setactive(self.ui.mTrans_KeyPreview, self.type == 4)
  if data.type == 1 then
    self:SetValue(data.value)
    self.ui.mSlider.onValueChanged:AddListener(data.listener)
  elseif data.type == 2 then
    self:InitScreen(data)
  elseif data.type == 3 then
    self.mData = data
    self:RefreshVoice()
    UIUtils.GetButtonListener(self.ui.mBtn_Download.gameObject).onClick = function()
      CS.ResUpdateSys.Instance:DownloadVoicePack(data.id, function()
        self:RefreshVoice()
      end)
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Delete.gameObject).onClick = function()
      CS.ResUpdateSys.Instance:DeleteVoicePack(data.id, function()
        self:RefreshVoice()
      end)
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Use.gameObject).onClick = function()
      data.listener(data.id)
    end
  elseif data.type == 4 then
    self:SetKeyBoardBtn(data.value)
  end
end
function UICommonSettingItem:RefreshScreenPos()
  if self.mData.id == UISettingSubPanel.GraphicSettings.Resolution then
    self.ui.mList_Screen.transform.offsetMax = Vector2(0, -55)
    self.ui.mList_Screen.transform.offsetMin = Vector2(0, -600)
  end
end
function UICommonSettingItem:RefreshPos()
  if self.mData.id ~= UISettingSubPanel.GraphicSettings.Resolution then
    local tmpScreen = self.ui.mList_Screen:GetComponent(typeof(CS.UnityEngine.RectTransform))
    ComScreenItemHelper:RefreshFilterTransPos(self.ui.mTrans_BtnScreen, tmpScreen)
  end
end
function UICommonSettingItem:InitScreen(data)
  self.list = data.list
  self.mData = data
  if data.id == UISettingSubPanel.GraphicSettings.Resolution then
    self.ui.mList_Screen = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComSettingViewModeDropDownListItemV2.prefab", self))
  else
    self.ui.mList_Screen = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComSettingDropDownListItemV2.prefab", self))
  end
  CS.LuaUIUtils.SetParent(self.ui.mList_Screen.gameObject, self.ui.mTrans_BtnScreen.gameObject, true)
  self:LuaUIBindTable(self.ui.mList_Screen, self.ui)
  self.blockHelper = UIUtils.GetUIBlockHelper(self.parent.ui.mUIRoot, self.ui.mList_Screen.transform, function()
    self.blockHelper:DestroyButton()
    self.ui.mList_Screen.transform.parent = self.ui.mTrans_Screen
    self:OnDropDown()
    self.ui.mAnimator:SetTrigger("Normal")
  end)
  self:ShowDropDown(false)
  for i = 1, #data.list do
    local item = UICommonSettingDropDownItem.New()
    item:InitCtrl(self.ui.mContent_Screen.transform)
    item:SetData({
      id = i,
      name = data.list[i]
    })
    UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
      if data.id == UISettingSubPanel.GraphicSettings.FPS and data.list[i] >= 60 and CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.Mobile then
        MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(104050), nil, function()
          self:OnClickDropDown(item.id)
          data.listener(item.id - 1)
        end, function()
          self:OnDropDown()
        end, 0, 100)
      elseif data.id == UISettingSubPanel.GraphicSettings.RenderScale and tonumber(data.list[i]) >= 1.3 then
        MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(104050), nil, function()
          self:OnClickDropDown(item.id)
          data.listener(item.id - 1)
        end, function()
          self:OnDropDown()
        end, 0, 100)
      else
        self:OnClickDropDown(item.id, data)
        data.listener(item.id - 1)
      end
    end
    self.dropDownItemList[i] = item
    item:SetSelected(i == data.value + 1)
  end
  self:SetDropDownValue(data.value)
end
function UICommonSettingItem:SetDropDownValue(value)
  self.selected = value + 1
  self.ui.mText_Screen.text = self.list[self.selected]
  for i = 1, #self.list do
    if self.selected == i then
      self.dropDownItemList[i]:SetSelected(true)
    else
      self.dropDownItemList[i]:SetSelected(false)
    end
  end
end
function UICommonSettingItem:OnClickDropDown(index)
  self.selected = index
  self.ui.mText_Screen.text = self.list[index]
  for i = 1, #self.list do
    if index == i then
      self.dropDownItemList[i]:SetSelected(true)
    else
      self.dropDownItemList[i]:SetSelected(false)
    end
  end
  self:OnDropDown()
end
function UICommonSettingItem:ShowDropDown(show)
  setactive(self.ui.mList_Screen.transform, show)
  if show then
    AudioUtils.PlayByID(1020030)
  end
  self.isSortDropDownActive = show
end
function UICommonSettingItem:SetValue(value)
  self.ui.mSlider.value = value
  self.ui.mText_Num.text = FormatNum(math.min(100, math.floor(value * 100)))
end
function UICommonSettingItem:RefreshVoice()
  local hasDownLoad = CS.ResUpdateSys.Instance:CurrentVoicePackIsAvailable(self.mData.id)
  setactive(self.ui.mText_VoiceName.gameObject, AccountNetCmdHandler.AvgVoice == self.mData.id)
  setactive(self.ui.mTrans_Delete.gameObject, false)
  setactive(self.ui.mTrans_Download.gameObject, AccountNetCmdHandler.AvgVoice ~= self.mData.id and not hasDownLoad)
  setactive(self.ui.mTrans_Use.gameObject, AccountNetCmdHandler.AvgVoice ~= self.mData.id and hasDownLoad)
end
function UICommonSettingItem:InitButtons(data)
  self.list = data.list
  local button = UIUtils.GetGizmosPrefab("CommanderInfo/CommanderInfoBtnItemV2.prefab", self)
  for i = 1, #data.list do
    do
      local item = UICommonSettingButtonItem.New()
      local obj = instantiate(button, self.ui.mTrans_GrpBtn)
      item:InitCtrl(obj.transform)
      item:SetData({
        id = i,
        name = data.list[i]
      })
      UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
        self:OnClickButton(item)
        data.listener(item.id - 1)
      end
      self.btnList[i] = item
    end
  end
  self:SetButtonGroupValue(data.value)
end
function UICommonSettingItem:SetKeyBoardBtn(data)
  local textIndex, mouseImgIndex = 0, 0
  local parent = self.ui.mTrans_KeyPreview
  local valueCount = data.value.Count
  for i = 0, valueCount - 1 do
    local v = data.value[i]
    if 0 < i then
      local index = i
      if self.mKeyBoardAddImgList[index] == nil then
        local obj = instantiate(self.ui.mTrans_KeyAdd.gameObject, parent)
        self.mKeyBoardAddImgList[index] = obj
      end
      setactive(self.mKeyBoardAddImgList[index], true)
    end
    local num = string.match(v, "Mouse")
    if num then
      mouseImgIndex = mouseImgIndex + 1
      if self.mKeyBoardMouseImgList[mouseImgIndex] == nil then
        local obj = instantiate(self.ui.mImg_KeyIcon.gameObject, parent)
        self.mKeyBoardMouseImgList[mouseImgIndex] = obj:GetComponent(typeof(CS.UnityEngine.UI.Image))
      end
      local img = self.mKeyBoardMouseImgList[mouseImgIndex]
      img.sprite = IconUtils.GetIconV2("KeyIcon", "Icon_KeyPC_" .. v)
      setactive(img, true)
    else
      textIndex = textIndex + 1
      if self.mKeyBoardTextList[textIndex] == nil then
        local obj = instantiate(self.ui.mTrans_KeyBoard.gameObject, parent)
        local uiTable = {}
        uiTable.mUIRoot = obj
        uiTable.mKeyBoardText = obj.transform:Find("Text"):GetComponent(typeof(CS.UnityEngine.UI.Text))
        self.mKeyBoardTextList[textIndex] = uiTable
      end
      local uiTable = self.mKeyBoardTextList[textIndex]
      uiTable.mKeyBoardText.text = v
      setactive(uiTable.mUIRoot, true)
    end
  end
end
function UICommonSettingItem:SetButtonGroupValue(value)
  self:OnClickButton(self.btnList[value + 1])
end
function UICommonSettingItem:OnClickButton(item)
  for i = 1, #self.btnList do
    if item ~= self.btnList[i] then
      self.btnList[i].mBtn_Select.interactable = true
    else
      self.btnList[i].mBtn_Select.interactable = false
    end
  end
end
