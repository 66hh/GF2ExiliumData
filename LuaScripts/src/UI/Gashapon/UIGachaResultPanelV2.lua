require("UI.Gashapon.UIGachaMainPanelV2")
require("UI.UIBasePanel")
require("UI.UITweenCamera")
require("UI.Gashapon.UIGachaResultPanelV2View")
require("UI.Gashapon.UIFrontLayerCanvasView")
require("UI.Gashapon.Item.UIGashaponCardDisplayItemV2")
UIGachaResultPanelV2 = class("UIGachaResultPanelV2", UIBasePanel)
UIGachaResultPanelV2.__index = UIGachaResultPanelV2
UIGachaResultPanelV2.mPath_GashaponItem = "Gashapon/GashaponCardDisplayItem.prefab"
UIGachaResultPanelV2.mView = nil
UIGachaResultPanelV2.mCanvas = nil
UIGachaResultPanelV2.Trans_FronLayerLayout = nil
UIGachaResultPanelV2.mGashaItemList = nil
UIGachaResultPanelV2.mData = nil
UIGachaResultPanelV2.mCurActivityId = 0
UIGachaResultPanelV2.mIsPlayingAnim = false
function UIGachaResultPanelV2:ctor(csPanel)
  UIGachaResultPanelV2.super.ctor(UIGachaResultPanelV2, csPanel)
end
function UIGachaResultPanelV2.Open()
  UIManager.OpenUI(UIDef.UIGachaResultPanel)
end
function UIGachaResultPanelV2.Close()
  UIManager.CloseUI(UIDef.UIGachaResultPanel)
end
function UIGachaResultPanelV2:OnInit(root, data)
  UIGachaResultPanelV2.super.SetRoot(UIGachaResultPanelV2, root)
  self.mData = data
  self:SetRoot(root)
  self.mView = UIGachaResultPanelV2View.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(self.mUIRoot)
  if type(data) == "table" then
    self.mData = data[1]
    self.closeCallback = data[2]
  else
    self.mData = data
    self.closeCallback = nil
  end
  self.mGashaItemList = List:New(UIGashaponCardDisplayItemV2)
  if self.mGashaItemList:Count() == 0 then
    self:OnGetGashapon(self.mData)
  end
  function self.OnItemShow(index)
    self.mGashaItemList[index + 1]:SetColor(TableData.GetItemData(self.resultList[index + 1].ItemId).rank)
  end
  self.ui.mFade_Content:onShow("+", self.OnItemShow)
  self.mCurActivityId = UIGachaMainPanelV2.mCurActivityId
  self.mAnimsQueue = List:New(CS.System.Int32)
  local ticketItem = TableData.GetItemData(16)
  local itemCount = 0
  for i = 0, NetCmdItemData:GetUserDropCache().Count - 1 do
    local item = NetCmdItemData:GetUserDropCache()[i]
    if item.ItemId == 16 then
      itemCount = itemCount + item.ItemNum
    end
  end
  setactive(self.ui.mImg_Icon, ticketItem ~= nil)
  if ticketItem ~= nil then
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(ticketItem.id)
  end
  if itemCount == 0 then
    itemCount = self.mGashaItemList:Count()
  end
  self.ui.mText_Name.text = ticketItem.name.str
  self.ui.mText_Num.text = itemCount
  setactive(self.ui.mText_Next, false)
end
function UIGachaResultPanelV2:OnGetGashapon(msg)
  self.resultList = {}
  local gachainfos = msg.Content
  local count = gachainfos.Length
  for i = 0, count - 1 do
    table.insert(self.resultList, gachainfos[i])
  end
  local isOneTime = false
  if count == 1 then
    isOneTime = true
  end
  for i = 1, count do
    local info = self.resultList[i]
    local item = UIGashaponCardDisplayItemV2.New()
    item:InitCtrl(self.ui.mContent_Card.transform, i)
    if isOneTime == false then
      item:SetIndex(i + 1)
    else
      item:SetIndex(0)
    end
    item:InitData(info)
    local itemBtn = UIUtils.GetListener(item.mUIRoot.gameObject)
    itemBtn.param = item
    itemBtn.paramData = nil
    self.mGashaItemList:Add(item)
  end
  self.mIsPlayingAnim = true
  self.ui.mFade_Content.enabled = false
  self.ui.mFade_Content.enabled = true
  local t = 0
  if isOneTime == false then
    t = 2.5
  else
    t = 1.0
  end
  TimerSys:DelayCall(t + 0.1, function()
    self:OnMoveInAnimEnd()
  end, nil)
end
function UIGachaResultPanelV2:OnMoveInAnimEnd()
  self.mIsPlayingAnim = false
end
function UIGachaResultPanelV2:OnConfirmItem(gameObj)
  self:ClearGashaponItems()
  if self.closeCallback == nil then
    UIGachaResultPanelV2.Close()
  else
    self.closeCallback()
  end
end
function UIGachaResultPanelV2:ClearGashaponItems()
  for i = 1, self.mGashaItemList:Count() do
    self.mGashaItemList[i]:StopTimer()
    self.mGashaItemList[i]:DestroySelf()
  end
  self.mGashaItemList:Clear()
end
function UIGachaResultPanelV2:HidePanel()
  setactive(self.mUIRoot.gameObject, false)
  setactive(UIGachaResultPanelV2.Trans_FronLayerLayout.gameObject, false)
end
function UIGachaResultPanelV2:ShowPanel()
  setactive(self.mUIRoot.gameObject, true)
  setactive(UIGachaResultPanelV2.Trans_FronLayerLayout.gameObject, true)
end
function UIGachaResultPanelV2:OnClose()
  self:UnRegistrationAllKeyboard()
  UIGachaResultPanelV2.mView = nil
  self.ui.mFade_Content:onShow("-", self.OnItemShow)
end
function UIGachaResultPanelV2:OnShowStart()
  NetCmdItemData:SetWaitingBlock(false)
  self.ui.mCanvasGroup_Root.blocksRaycasts = false
  TimerSys:DelayCall(2, function()
    self.ui.mCanvasGroup_Root.blocksRaycasts = true
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_GrpClose)
  end)
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    NetCmdItemData:ClearUserDropCache()
    self:OnConfirmItem()
  end
end
