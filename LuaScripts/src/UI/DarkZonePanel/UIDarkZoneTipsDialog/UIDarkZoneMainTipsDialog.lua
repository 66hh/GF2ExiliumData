require("UI.DarkZonePanel.UIDarkZoneTipsDialog.UIDarkZoneMainTipsDialogView")
require("UI.UIBasePanel")
UIDarkZoneMainTipsDialog = class("UIDarkZoneMainTipsDialog", UIBasePanel)
UIDarkZoneMainTipsDialog.__index = UIDarkZoneMainTipsDialog
local MainTipsDialogType = {
  None = 0,
  GlobalEvent = 1,
  UnlockNew = 2,
  UnlockAll = 3,
  EnterNewRoom = 4,
  GlobalVigilantLevelChange = 5
}
function UIDarkZoneMainTipsDialog:ctor(csPanel)
  UIDarkZoneMainTipsDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.AutoCloseAbovePanel = false
  csPanel.AutoShowNextPanel = false
  csPanel.HandleHandleKeyboardByParent = true
end
function UIDarkZoneMainTipsDialog:OnInit(root, data)
  UIDarkZoneMainTipsDialog.super.SetRoot(UIDarkZoneMainTipsDialog, root)
  self.mview = UIDarkZoneMainTipsDialogView.New()
  self.ui = {}
  self.mview:InitCtrl(root, self.ui)
  self.ShowType = data[0]
  self.tipsShow = self.ShowType == MainTipsDialogType.UnlockAll or self.ShowType == MainTipsDialogType.EnterNewRoom
  self.generalShow = self.ShowType == MainTipsDialogType.UnlockNew or self.ShowType == MainTipsDialogType.GlobalVigilantLevelChange
  setactive(self.ui.mBind_Event.gameObject, self.ShowType == MainTipsDialogType.GlobalEvent)
  setactive(self.ui.mBind_ExploreCompletion.gameObject, self.tipsShow)
  setactive(self.ui.mBind_ExploreFind.gameObject, self.generalShow)
  if self.ShowType == MainTipsDialogType.GlobalEvent then
    self.GlobalEventUI = {}
    self:LuaUIBindTable(self.ui.mBind_Event.gameObject, self.GlobalEventUI)
    self.GlobalEventUI.events = data[1]
    local count = self.GlobalEventUI.events.Count
    self:InitGlobalEvent(self.GlobalEventUI.events[count - 1])
  elseif self.generalShow then
    self.UnlockNewUI = {}
    self:LuaUIBindTable(self.ui.mBind_ExploreFind.gameObject, self.UnlockNewUI)
    self:InitUnlockNew(data[1])
  elseif self.tipsShow then
    self.UnlockAllUI = {}
    self:LuaUIBindTable(self.ui.mBind_ExploreCompletion.gameObject, self.UnlockAllUI)
    self:InitUnlockAll(data[1])
  end
end
function UIDarkZoneMainTipsDialog:OnClose()
  if self.ShowType == MainTipsDialogType.GlobalEvent then
    setactive(self.ui.mBind_Event.gameObject, false)
    if self.GlobalEventUI.timer ~= nil then
      self.GlobalEventUI.timer:Stop()
    end
    self.GlobalEventUI = nil
  elseif self.generalShow then
    setactive(self.ui.mBind_ExploreFind.gameObject, false)
    if self.UnlockNewUI.timer ~= nil then
      self.UnlockNewUI.timer:Stop()
    end
    self.UnlockNewUI = nil
  elseif self.tipsShow then
    setactive(self.ui.mBind_ExploreCompletion.gameObject, false)
    if self.UnlockAllUI.timer ~= nil then
      self.UnlockAllUI.timer:Stop()
    end
    self.UnlockAllUI = nil
  end
  self.ui = nil
  self.mview = nil
end
function UIDarkZoneMainTipsDialog:InitGlobalEvent(data)
  self.GlobalEventUI.timer = nil
  self.GlobalEventUI.intervalTime = 2.18
  self.GlobalEventUI.mText_Tittle.text = TableData.GetHintById(903407)
  self.GlobalEventUI.mText_Name.text = data.name
end
function UIDarkZoneMainTipsDialog:InitUnlockNew(data)
  self.UnlockNewUI.mText_Title.text = TableData.GetHintById(data)
  self.UnlockNewUI.timer = nil
  self.UnlockNewUI.intervalTime = 2.18
end
function UIDarkZoneMainTipsDialog:InitUnlockAll(data)
  self.UnlockAllUI.mText_Title.text = TableData.GetHintById(data)
  self.UnlockAllUI.timer = nil
  self.UnlockAllUI.intervalTime = 2.18
  if self.ShowType == MainTipsDialogType.UnlockAll then
    self.UnlockAllUI.mImg_Title.sprite = IconUtils.GetDarkzoneEventIcon("Icon_DarkzoneTip_Exply")
  elseif self.ShowType == MainTipsDialogType.EnterNewRoom then
    self.UnlockAllUI.mImg_Title.sprite = IconUtils.GetDarkzoneEventIcon("Icon_DarkzoneTip_Home")
  end
end
function UIDarkZoneMainTipsDialog:OnShowStart()
  if self.ShowType == MainTipsDialogType.GlobalEvent then
    self.GlobalEventUI.mAni_EventOpen:SetTrigger("FadeInOut")
    self.GlobalEventUI.timer = TimerSys:DelayCall(self.GlobalEventUI.intervalTime, function()
      self.GlobalEventUI.timer = nil
      UIManager.CloseUI(UIDef.UIDarkZoneMainTipsDialog)
      MessageSys:SendMessage(CS.GF2.Message.DarkMsg.RefreshGlobalEvent, self.GlobalEventUI.events)
      self.GlobalEventUI.events = nil
    end)
  elseif self.generalShow then
    self.UnlockNewUI.timer = TimerSys:DelayCall(self.UnlockNewUI.intervalTime, function()
      self.UnlockNewUI.timer = nil
      UIManager.CloseUI(UIDef.UIDarkZoneMainTipsDialog)
    end)
  elseif self.ShowType == MainTipsDialogType.UnlockAll then
    self.UnlockAllUI.mAni_Root:SetInteger("Switch", 0)
    self.UnlockAllUI.mAni_Root:SetTrigger("FadeInOut")
    self.UnlockAllUI.timer = TimerSys:DelayCall(self.UnlockAllUI.intervalTime, function()
      self.UnlockAllUI.timer = nil
      UIManager.CloseUI(UIDef.UIDarkZoneMainTipsDialog)
    end)
  elseif self.ShowType == MainTipsDialogType.EnterNewRoom then
    self.UnlockAllUI.mAni_Root:SetInteger("Switch", 1)
    self.UnlockAllUI.mAni_Root:SetTrigger("FadeInOut")
    self.UnlockAllUI.timer = TimerSys:DelayCall(self.UnlockAllUI.intervalTime, function()
      self.UnlockAllUI.timer = nil
      UIManager.CloseUI(UIDef.UIDarkZoneMainTipsDialog)
    end)
  end
end
function UIDarkZoneMainTipsDialog:OnRelease()
end
