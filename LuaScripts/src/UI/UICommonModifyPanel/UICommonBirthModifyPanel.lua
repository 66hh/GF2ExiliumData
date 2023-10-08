require("UI.UIBasePanel")
require("UI.UICommonModifyPanel.UICommonBirthModifyPanelView")
UICommonBirthModifyPanel = class("UICommonBirthModifyPanel", UIBasePanel)
UICommonBirthModifyPanel.__index = UICommonBirthModifyPanel
UICommonBirthModifyPanel.DateType = {Month = 12, Day = 31}
UICommonBirthModifyPanel.monthList = {}
UICommonBirthModifyPanel.dayList = {}
UICommonBirthModifyPanel.curDate = {month = 1, day = 1}
UICommonBirthModifyPanel.confirmCb = nil
function UICommonBirthModifyPanel.OpenBirthDayPanel(curDate, callback, uiGroupType)
  UIManager.OpenUIByParam(UIDef.UICommonBirthModifyPanel, {callback, curDate}, uiGroupType)
end
function UICommonBirthModifyPanel:ctor(csPanel)
  UICommonBirthModifyPanel.super.ctor(UICommonBirthModifyPanel, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonBirthModifyPanel.Close()
  self = UICommonBirthModifyPanel
  UIManager.CloseUISelf(UICommonBirthModifyPanel)
end
function UICommonBirthModifyPanel:OnRelease()
  self.curDate = {month = 1, day = 1}
  self.confirmCb = nil
end
function UICommonBirthModifyPanel:OnInit(root, data)
  self.super.SetRoot(UICommonBirthModifyPanel, root)
  self.confirmCb = data[1]
  self:SetCruDate(data[2])
  self.dayItems = {}
  self.monthItems = {}
  self.mView = UICommonBirthModifyPanelView.New()
  self.mView:InitCtrl(root)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    UICommonBirthModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CloseBg.gameObject).onClick = function()
    UICommonBirthModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Confirm.gameObject).onClick = function()
    UICommonBirthModifyPanel:OnClickConfirm()
  end
  self:InitMonthTypeScrollList()
  self:InitDayTypeScrollList()
  self:UpdateDayList(self:GetMonthDay(self.curDate.month))
  TimerSys:DelayFrameCall(3, function()
    self:UpdateTextStyle(self.monthItems[self.curDate.month], true)
    self:UpdateTextStyle(self.dayItems[self.curDate.day], true)
  end)
end
function UICommonBirthModifyPanel:OnClickConfirm()
  if self.confirmCb then
    self:OnDateChange()
    local birth = self.curDate.month * 100 + self.curDate.day
    self.confirmCb(birth)
  end
  self.Close()
end
function UICommonBirthModifyPanel:InitMonthTypeScrollList()
  local itemPrefab = self.mView.mTrans_MonthContent:GetComponent(typeof(CS.ScrollListChild))
  self.monthItems = {}
  for i = 1, 12 do
    local item = {}
    item.gameObject = instantiate(itemPrefab.childItem)
    UIUtils.AddListItem(item.gameObject, self.mView.mTrans_MonthContent.gameObject)
    item.transform = item.gameObject.transform
    item.animator = CS.LuaUIUtils.GetAnimator(item.transform)
    item.text_b = CS.LuaUIUtils.GetText(item.transform:Find("Text_B"))
    item.text_b.text = tostring(i)
    item.text_w = CS.LuaUIUtils.GetText(item.transform:Find("Text_W"))
    item.text_w.text = tostring(i)
    item.gameObject.name = tostring(i)
    table.insert(self.monthItems, item)
  end
  self.mView.mMonthList.enabled = true
  self.mView.mMonthList:InitScroll(function(gameObject)
    self:OnMonthChange(gameObject)
  end, self.curDate.month)
end
function UICommonBirthModifyPanel:InitDayTypeScrollList()
  local itemPrefab = self.mView.mTrans_DayContent:GetComponent(typeof(CS.ScrollListChild))
  for i = 1, 31 do
    local item = {}
    item.gameObject = instantiate(itemPrefab.childItem)
    UIUtils.AddListItem(item.gameObject, self.mView.mTrans_DayContent.gameObject)
    item.transform = item.gameObject.transform
    item.animator = CS.LuaUIUtils.GetAnimator(item.transform)
    item.text_b = CS.LuaUIUtils.GetText(item.transform:Find("Text_B"))
    item.text_b.text = tostring(i)
    item.text_w = CS.LuaUIUtils.GetText(item.transform:Find("Text_W"))
    item.text_w.text = tostring(i)
    item.gameObject.name = tostring(i)
    table.insert(self.dayItems, item)
  end
  self.mView.mDayList.enabled = true
  self.mView.mDayList:InitScroll(function(gameObject)
    self:OnDayChange(gameObject)
  end, self.curDate.day)
end
function UICommonBirthModifyPanel:OnDateChange()
  local monthObj = self.mView.mMonthList:GetClosestGameObject()
  local dayObj = self.mView.mDayList:GetClosestGameObject()
  if monthObj and dayObj then
    local month = monthObj.name
    local day = dayObj.name
    local maxDay = self:GetMonthDay(month)
    self.curDate.month = tonumber(month)
    self.curDate.day = tonumber(day)
    self.curDate.day = maxDay < self.curDate.day and maxDay or self.curDate.day
  end
end
function UICommonBirthModifyPanel:OnMonthChange(gameObject)
  if gameObject then
    local index = gameObject.name
    if self.curDate.month ~= tonumber(index) then
      self:UpdateTextStyle(self.monthItems[self.curDate.month], false)
      self.curDate.month = tonumber(index)
      self:UpdateTextStyle(self.monthItems[self.curDate.month], true)
      self:UpdateDayList(self:GetMonthDay(self.curDate.month))
    end
  end
end
function UICommonBirthModifyPanel:OnDayChange(gameObject)
  if gameObject then
    local index = gameObject.name
    if self.curDate.day ~= tonumber(index) then
      self:UpdateTextStyle(self.dayItems[self.curDate.day], false)
      self.curDate.day = tonumber(index)
      self:UpdateTextStyle(self.dayItems[self.curDate.day], true)
    end
  end
end
function UICommonBirthModifyPanel:UpdateTextStyle(item, isSelect)
  if item then
    item.animator:SetBool("White", isSelect)
  end
end
function UICommonBirthModifyPanel:UpdateDayList(day)
  for i = 29, 31 do
    local item = self.dayItems[i]
    setactive(item.gameObject, i <= day)
  end
end
function UICommonBirthModifyPanel:GetMonthDay(month)
  local day = os.date("%d", os.time({
    year = 2020,
    month = month + 1,
    day = 0
  }))
  return tonumber(day)
end
function UICommonBirthModifyPanel:SetCruDate(birth)
  if 0 < birth then
    local month = luaRoundNum(birth / 100)
    local day = luaRoundNum(birth - month * 100)
    self.curDate.month = month
    self.curDate.day = day
  else
    self.curDate.month = 1
    self.curDate.day = 1
  end
end
function UICommonBirthModifyPanel:OnClose()
  for k, v in ipairs(self.dayItems) do
    gfdestroy(v.gameObject)
  end
  for k, v in ipairs(self.monthItems) do
    gfdestroy(v.gameObject)
  end
  self.mView.mMonthList:Reset()
  self.mView.mMonthList.enabled = false
  self.mView.mDayList.enabled = false
end
