require("UI.UIBasePanel")
require("UI.DailyCheckInPanel.UIDailyCheckInPanelView")
require("UI.DailyCheckInPanel.Item.UICheckInItem")
UIDailyCheckInPanel = class("UIDailyCheckInPanel", UIBasePanel)
UIDailyCheckInPanel.__index = UIDailyCheckInPanel
UIDailyCheckInPanel.mView = nil
UIDailyCheckInPanel.mData = nil
UIDailyCheckInPanel.mCurCheckInDays = 0
UIDailyCheckInPanel.mCurCheckInId = 0
UIDailyCheckInPanel.mCheckInItemList = nil
UIDailyCheckInPanel.mCurCheckInItem = nil
UIDailyCheckInPanel.callback = nil
UIDailyCheckInPanel.IsPlayed = false
UIDailyCheckInPanel.mCheckInMonth = nil
UIDailyCheckInPanel.mTimeToRefresh = nil
UIDailyCheckInPanel.refresh_timedata = nil
UIDailyCheckInPanel.refresh_gametime = nil
UIDailyCheckInPanel.mCheckInMark = nil
UIDailyCheckInPanel.ui = {}
UIDailyCheckInPanel.mTimer = nil
UIDailyCheckInPanel.CanClose = true
function UIDailyCheckInPanel:ctor(csPanel)
  UIDailyCheckInPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDailyCheckInPanel:OnInit(root, callback)
  self.callback = callback
  self:SetRoot(root)
  self.IsPlayed = false
  self.CanClose = true
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  if UISystem:GetTopPanelUI().UIDefine.UIType ~= UIDef.UICommandCenterPanel and UISystem:GetTopPanelUI().UIDefine.UIType ~= UIDef.UICommandCenterHudPanel then
    setactive(self.ui.mTrans_Root, false)
  else
    setactive(self.ui.mTrans_Root, true)
    self.mCheckInItemList = List:New()
    UIUtils.GetButtonListener(self.ui.mBtn_DailyCheckIn_Confirm.gameObject).onClick = function()
      self:OnReturnClicked()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_DailyCheckInClose.gameObject).onClick = function()
      self:OnReturnClicked()
    end
    self:SetCheckInMonth()
    self.checkInSuccess = false
    self:InitCheckInData()
  end
end
function UIDailyCheckInPanel:OnShowStart()
  if UISystem:GetTopPanelUI().UIDefine.UIType ~= UIDef.UICommandCenterPanel and UISystem:GetTopPanelUI().UIDefine.UIType ~= UIDef.UICommandCenterHudPanel then
    UIManager.CloseUI(UIDef.UIDailyCheckInPanel)
    NetCmdCheckInData:ResetCheckIn()
  end
end
function UIDailyCheckInPanel:OnUpdate()
  self:TimeToRefresh()
end
function UIDailyCheckInPanel:OnHide()
end
function UIDailyCheckInPanel:OnClose()
  if self.mTimer ~= nil then
    self.mTimer:Stop()
    self.mTimer = nil
  end
  self.IsPlayed = false
  if self.mCheckInItemList ~= nil then
    for _, item in ipairs(self.mCheckInItemList) do
      gfdestroy(item:GetRoot())
    end
    self.mCheckInItemList = {}
  end
end
function UIDailyCheckInPanel:OnRelease()
end
function UIDailyCheckInPanel:TimeToRefresh()
  self.refresh_timedata = CGameTime:GetDateTime()
  self.refresh_gametime = CGameTime:GetTimestamp()
  CGameTime:timeGetTimeData(self.refresh_timedata, self.refresh_gametime)
  local dataTable = TableDataBase.listTimerDatas:GetDataById(11, true)
  local refreshTime = dataTable.args1
  local refreshHour = string.byte(refreshTime, 1) - 48
  local refreshMin = string.byte(refreshTime, 3) - 48
  local hour = 23 + refreshHour - self.refresh_timedata.tm_hour
  if 24 <= hour then
    hour = hour - 24
  end
  local min = 59 + refreshMin - self.refresh_timedata.tm_min
  if 60 <= min then
    min = min - 60
    hour = hour + 1
  end
  local sec = 60 - self.refresh_timedata.tm_sec
  if sec == 60 then
    sec = 0
    min = min + 1
    if min == 60 then
      min = 0
      hour = hour + 1
    end
  end
  local time = string.format("-", hour) .. ":" .. string.format("-", min) .. ":" .. string.format("-", sec) .. " "
  self.ui.mTimeToRefresh.text = TableData.GetHintReplaceById(60074, time)
end
function UIDailyCheckInPanel:SetCheckInMonth()
  local timedata = CGameTime:GetDateTime()
  local gametime = CGameTime:GetTimestamp()
  CGameTime:timeGetTimeData(timedata, gametime)
  self.ui.mCheckInMonth.text = string.format("M", timedata.tm_year) .. "." .. string.format("-", timedata.tm_mon)
end
function UIDailyCheckInPanel:InitCheckInData()
  self.mData = NetCmdCheckInData.CheckInData
  self.mCurCheckInDays = self.mData.CheckinDay + 1
  self.mCurCheckInId = self.mData.CheckinId
  self.ui.mBtn_DailyCheckIn_Confirm.enabled = false
  local data = NetCmdCheckInData:GetCheckInDataListById(self.mCurCheckInId)
  for i = 0, data.Count - 1 do
    local item = UICheckInItem.New()
    item:InitCtrl(self.ui.mLayout_DailyCheckIn_CheckInItemList.transform)
    item:InitData(data[i])
    if data[i].Day < self.mCurCheckInDays then
      item:SetMask()
    end
    if data[i].Day == self.mCurCheckInDays - 1 then
      item:SetTransparent()
    end
    self.mCheckInItemList:Add(item)
  end
  if self.mData.IsChecked == false then
    self.CanClose = false
    TimerSys:DelayCall(0.5, function()
      self:DelayCheckIn()
    end, nil)
  else
    self:UpdateBtnState(true)
    self.ui.mBtn_DailyCheckIn_Confirm.enabled = true
    self.IsPlayed = true
    self.CanClose = true
    self.checkInSuccess = false
  end
end
function UIDailyCheckInPanel:DelayCheckIn()
  for i = 1, #self.mCheckInItemList do
    local item = self.mCheckInItemList[i]
    if item.mData.Day == self.mCurCheckInDays then
      self.mCurCheckInItem = item
      break
    end
  end
  NetCmdCheckInData:SendDailyCheckInCmd(self.mCurCheckInDays - 1, function(ret)
    self:CheckInCallback(ret)
  end)
end
function UIDailyCheckInPanel:UpdateBtnState(isCanClick)
  for i = 1, #self.mCheckInItemList do
    local item = self.mCheckInItemList[i]
    item:UpdateBtnState(isCanClick)
  end
end
function UIDailyCheckInPanel:CheckInCallback(ret)
  setactive(self.ui.mCheckInMark.gameObject, false)
  self.CanClose = false
  if ret == ErrorCodeSuc then
    gfdebug("签到成功")
    self.mCurCheckInItem:SetChecked(function()
      TimerSys:DelayCall(1.3, function()
        NetCmdCheckInData:ShowCheckInReward()
        self:UpdateBtnState(true)
        self.IsPlayed = true
        self.checkInSuccess = true
      end, nil)
    end)
    setactive(self.ui.mCheckInMark.gameObject, true)
  else
    gfdebug("签到失败")
    self.IsPlayed = true
    self.checkInSuccess = false
  end
  self.ui.mBtn_DailyCheckIn_Confirm.enabled = true
end
function UIDailyCheckInPanel:OnReturnClicked(gameObject)
  if not self.IsPlayed then
    return
  end
  if self.CloseDelay ~= nil and not self.CloseDelay.HaveFinished then
    self.CloseDelay:Stop()
    self.CloseDelay = nil
  end
  UIManager.CloseUI(UIDef.UIDailyCheckInPanel)
  if self.callback then
    self.callback()
  end
end
function UIDailyCheckInPanel:OnTop()
  if self.checkInSuccess then
    TimerSys:DelayCall(0.5, function()
      self:OnReturnClicked()
    end, nil)
  end
end
