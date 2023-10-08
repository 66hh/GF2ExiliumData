require("UI.CommandCenterPanel.Item.CommanderBgItem")
UICommandCenterBgChangePanel = class("self", UIBasePanel)
UICommandCenterBgChangePanel.__index = UICommandCenterBgChangePanel
function UICommandCenterBgChangePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  self.csPanel = csPanel
  csPanel.HideSceneBackground = false
  csPanel.Is3DPanel = true
  self.bgItemList = {}
end
function UICommandCenterBgChangePanel:OnInit(root, data)
  self.super.SetRoot(self, root)
  self.mUIRoot = root
  self.panelType = 1
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitButtonGroup()
  self:InitUI()
  self.selectedId = 0
  self:OnSelectItem(NetCmdCommandCenterData.Background)
  function self.onBgTimelineLoadEnd(message)
    self.timelineLoading = false
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BgTimelineLoadEnd, self.onBgTimelineLoadEnd)
end
function UICommandCenterBgChangePanel:OnShowStart()
  self.timelineLoading = false
end
function UICommandCenterBgChangePanel.GetBgWeight(data)
  local bgData = TableData.listCommandBackgroundDatas:GetDataById(data.id)
  local unlockMul = 0
  if tonumber(bgData.args) ~= 0 then
    local unlock = tonumber(bgData.args)
    if not NetCmdAchieveData:CheckComplete(unlock) then
      unlockMul = 1
    end
  end
  return unlockMul * 100000 + data.type * 10000 + data.id
end
function UICommandCenterBgChangePanel:InitUI()
  self.ui.mText_List.text = TableData.GetHintById(113033)
  local dataList = TableData.listCommandBackgroundDatas:GetList()
  for _, item in pairs(self.bgItemList) do
    item:OnRelease()
  end
  self.bgItemList = {}
  local sortList = {}
  for i = 0, dataList.Count - 1 do
    table.insert(sortList, dataList[i])
  end
  table.sort(sortList, function(a, b)
    return self.GetBgWeight(a) < self.GetBgWeight(b)
  end)
  for _, data in pairs(sortList) do
    local item = CommanderBgItem.New()
    item:InitCtrl(self.ui.mTrans_Contemt)
    item:SetData(data, self)
    table.insert(self.bgItemList, item)
  end
end
function UICommandCenterBgChangePanel:InitButtonGroup()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    if self.timelineLoading then
      return
    end
    if self.selectedId ~= NetCmdCommandCenterData.Background then
      self.ui.mAnimator:SetTrigger("BlackMask")
      local bgData = TableData.listCommandBackgroundDatas:GetDataById(NetCmdCommandCenterData.Background)
      TimerSys:DelayCall(0.25, function()
        if bgData.type ~= 2 then
          SceneSys.currentScene:StopBackgroundVideo()
        else
          SceneSys.currentScene:PlayBackgroundVideo(bgData.bg)
        end
        self.Close()
      end)
    else
      self.Close()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickListControl()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ListControl.gameObject).onClick = function()
    self:OnClickListControl()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Change.gameObject).onClick = function()
    self:OnClickChange()
  end
end
function UICommandCenterBgChangePanel.Close()
  UIManager.CloseUI(UIDef.UICommandCenterBgChangePanel)
end
function UICommandCenterBgChangePanel:OnClose()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BgTimelineLoadEnd, self.onBgTimelineLoadEnd)
  self.ui = nil
  for _, item in pairs(self.bgItemList) do
    item:OnRelease()
  end
  self.bgItemList = {}
end
function UICommandCenterBgChangePanel:OnSelectItem(id)
  if self.timelineLoading or self.selectedId ~= 0 and self.selectedId == id then
    return
  end
  self.selectedId = id
  for _, item in pairs(self.bgItemList) do
    item:SetSelect(item.id == id)
  end
  local bgData = TableData.listCommandBackgroundDatas:GetDataById(id)
  if bgData.type == 3 then
    self.timelineLoading = true
  else
    self.timelineLoading = false
  end
  self.ui.mAnimator:SetTrigger("BlackMask")
  TimerSys:DelayCall(0.25, function()
    if bgData.type ~= 2 then
      SceneSys.currentScene:StopBackgroundVideo(id)
    else
      SceneSys.currentScene:PlayBackgroundVideo(bgData.bg)
    end
  end)
  local isUnlock = true
  if bgData.unlock ~= 0 then
    local unlock = tonumber(bgData.args)
    isUnlock = NetCmdAchieveData:CheckComplete(unlock)
    self.ui.mText_Locked.text = bgData.des.str
  end
  setactive(self.ui.mText_Locked.transform.parent.parent, id ~= NetCmdCommandCenterData.Background and not isUnlock)
  setactive(self.ui.mBtn_Change, id ~= NetCmdCommandCenterData.Background and isUnlock)
  setactive(self.ui.mTrans_Setted, id == NetCmdCommandCenterData.Background)
end
function UICommandCenterBgChangePanel:OnClickListControl()
  self.panelType = 3 - self.panelType
  if self.panelType == 1 then
    self.ui.mText_List.text = TableData.GetHintById(113033)
    self.ui.mAnimator:SetBool("Change", true)
  else
    self.ui.mText_List.text = TableData.GetHintById(113036)
    self.ui.mAnimator:SetBool("Change", false)
  end
end
function UICommandCenterBgChangePanel:OnClickChange()
  NetCmdCommandCenterData:ReqBackgroundChange(self.selectedId, function(ret)
    if ret == ErrorCodeSuc then
      local bgData = TableData.listCommandBackgroundDatas:GetDataById(self.selectedId)
      if bgData.type ~= 2 then
        SceneSys.currentScene:StopBackgroundVideo(self.selectedId)
      else
        SceneSys.currentScene:PlayBackgroundVideo(bgData.bg)
      end
      NetCmdCommandCenterData:SetBackground(self.selectedId)
      setactive(self.ui.mBtn_Change, false)
      setactive(self.ui.mTrans_Setted, true)
      for _, item in pairs(self.bgItemList) do
        item:UpdateData()
      end
      self.Close()
      TimerSys:DelayCall(1, function()
        UIUtils.PopupPositiveHintMessage(113039)
      end)
    end
  end)
end
function UICommandCenterBgChangePanel:OnCameraStart()
  return 0.01
end
function UICommandCenterBgChangePanel:OnCameraBack()
  return 0.01
end
