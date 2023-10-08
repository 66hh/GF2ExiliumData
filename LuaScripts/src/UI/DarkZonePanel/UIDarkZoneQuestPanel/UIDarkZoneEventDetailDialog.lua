require("UI.DarkZonePanel.UIDarkZoneQuestPanel.UIDarkZoneEventDetailDialogView")
require("UI.DarkZonePanel.UIDarkZoneQuestPanel.item.UIDarkZoneEventDetailDialogItem")
require("UI.DarkZonePanel.UIDarkZoneQuestPanel.item.UIDarkZoneEventTopTabItem")
require("UI.UIBasePanel")
UIDarkZoneEventDetailDialog = class("UIDarkZoneEventDetailDialog", UIBasePanel)
UIDarkZoneEventDetailDialog.__index = UIDarkZoneEventDetailDialog
function UIDarkZoneEventDetailDialog:ctor(csPanel)
  UIDarkZoneEventDetailDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneEventDetailDialog:OnInit(root, data)
  UIDarkZoneEventDetailDialog.super.SetRoot(UIDarkZoneEventDetailDialog, root)
  self:InitBaseData()
  self.mData = data
  self.showEvent = DarkZoneGlobal.EventType.Start
  if data[2] then
    self.showEvent = data[2]
  end
  self.topTabList = {}
  self.PosCache = {}
  for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
    self.PosCache[i] = 0
  end
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:RefreshDialog()
end
function UIDarkZoneEventDetailDialog:OnClose()
  self.ui = nil
  self.mView = nil
  self:ReleaseCtrlTable(self.eventItemList, true)
  self:ReleaseCtrlTable(self.topTabList, true)
  self.eventItemList = nil
end
function UIDarkZoneEventDetailDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneEventDetailDialog:InitBaseData()
  self.mView = UIDarkZoneEventDetailDialogView.New()
  self.ui = {}
  self.eventItemList = {}
end
function UIDarkZoneEventDetailDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseSelf()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:CloseSelf()
  end
end
function UIDarkZoneEventDetailDialog:RefreshDialog()
  local hintID, eventHintID, eventData
  hintID = 240028
  eventData = self.mData[1]
  self.ui.mText_Title.text = TableData.GetHintById(hintID)
  for i = 1, #eventData do
    local eventTable = eventData[i]
    if self.eventItemList[i] == nil then
      local item = UIDarkZoneEventDetailDialogItem.New()
      item:InitCtrl(self.ui.mScrollChild_EventContent.transform, self.ui.mScrollChild_EventContent.childItem)
      self.eventItemList[i] = item
    end
    local item = self.eventItemList[i]
    item:SetData(eventTable)
  end
end
function UIDarkZoneEventDetailDialog:CreateTopTab()
  for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
    do
      local toptab = self.topTabList[i]
      if not toptab then
        toptab = UIDarkZoneEventTopTabItem.New()
        toptab:InitCtrl(self.ui.mScrollChild_Tab.childItem, self.ui.mScrollChild_Tab.transform)
        table.insert(self.topTabList, toptab)
      end
      toptab:SetData(i, function()
        for j = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
          self.topTabList[j].ui.mBtn_Self.interactable = true
        end
        toptab.ui.mBtn_Self.interactable = false
        self:FilterEventItem(i)
      end)
      if self.PosCache[i] == 0 then
        setactive(self.topTabList[i]:GetRoot(), false)
      else
        setactive(self.topTabList[i]:GetRoot(), true)
      end
    end
  end
end
function UIDarkZoneEventDetailDialog:SetAnchorPos(pos)
  LuaDOTweenUtils.SetTransformSlide(self.ui.mTrans_Content, pos)
end
function UIDarkZoneEventDetailDialog:FilterEventItem(eventType)
  for i = 1, #self.eventItemList do
    if self.eventItemList[i].mData.type == eventType then
      setactive(self.eventItemList[i]:GetRoot(), true)
    else
      setactive(self.eventItemList[i]:GetRoot(), false)
    end
  end
end
function UIDarkZoneEventDetailDialog:OnShowFinish()
  UIUtils.ForceRebuildLayout(self.ui.mTrans_Content)
  self:GetPosCache()
  self:CreateTopTab()
  if self.PosCache[self.showEvent] == 0 then
    for i = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
      if self.PosCache[i] ~= 0 then
        self.showEvent = i
      end
    end
  end
  self.topTabList[self.showEvent]:callBack()
end
function UIDarkZoneEventDetailDialog:GetPosCache()
  local cntPos = 0
  for i = 1, #self.eventItemList do
    for j = DarkZoneGlobal.EventType.Start, DarkZoneGlobal.EventType.End do
      if self.eventItemList[i].mData.type == j and self.PosCache[j] == 0 then
        self.PosCache[j] = CS.UnityEngine.Vector2(self.ui.mTrans_Content.anchoredPosition.x, self.ui.mLayout_Content.spacing * (i - 1) + cntPos)
        break
      end
    end
    cntPos = cntPos + self.eventItemList[i]:SetPos()
  end
end
function UIDarkZoneEventDetailDialog:CloseSelf()
  UIManager.CloseUI(UIDef.UIDarkZoneEventDetailDialog)
end
