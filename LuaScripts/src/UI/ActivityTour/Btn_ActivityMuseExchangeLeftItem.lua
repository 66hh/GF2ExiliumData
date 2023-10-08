require("UI.UIBaseCtrl")
require("UI.Common.UICommonItem")
Btn_ActivityMuseExchangeLeftItem = class("Btn_ActivityMuseExchangeLeftItem", UIBaseCtrl)
Btn_ActivityMuseExchangeLeftItem.__index = Btn_ActivityMuseExchangeLeftItem
function Btn_ActivityMuseExchangeLeftItem:ctor()
end
function Btn_ActivityMuseExchangeLeftItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function Btn_ActivityMuseExchangeLeftItem:ShowItem(isShow)
  setactive(self.ui.mBtn_ActivityMuseExchangeLeftItem.gameObject, isShow)
end
function Btn_ActivityMuseExchangeLeftItem:UpdateItem(isShow)
  if isShow and self.data then
    if self.leftItem == nil then
      self.leftItem = UICommonItem.New()
      self.leftItem:InitCtrl(self.ui.mTrans_ImgItem)
    end
    setactive(self.leftItem.mUIRoot, true)
    self.leftItem:SetItemData(self.data.Offer, 1, nil, nil, nil, nil, nil, function()
      if self.data.Offer then
        UITipsPanel.Open(TableData.GetItemData(self.data.Offer))
      end
    end)
    if self.rightItem == nil then
      self.rightItem = UICommonItem.New()
      self.rightItem:InitCtrl(self.ui.mTrans_ImgItem1)
    end
    setactive(self.rightItem.mUIRoot, true)
    self.rightItem:SetItemData(self.data.Need, 1, nil, nil, nil, nil, nil, function()
      if self.data.Need then
        UITipsPanel.Open(TableData.GetItemData(self.data.Need))
      end
    end)
  else
    if self.leftItem then
      setactive(self.leftItem.mUIRoot, false)
    end
    if self.rightItem then
      setactive(self.rightItem.mUIRoot, false)
    end
  end
end
function Btn_ActivityMuseExchangeLeftItem:SetData(data, parent)
  self.data = data
  self.parent = parent
  self.ui.mBtn_ActivityMuseExchangeLeftItem.enabled = self.data == nil
  if self.data then
    if self.data.MatchUid and self.data.MatchUid > 0 then
      self.ui.mText_Info.text = TableData.GetHintById(270187)
      self.ui.mAnimator_ActivityMuseExchangeLeftItem:SetInteger("Switch", 2)
      setactive(self.ui.mBtn_Receive.gameObject, true)
    else
      self.ui.mAnimator_ActivityMuseExchangeLeftItem:SetInteger("Switch", 1)
      setactive(self.ui.mBtn_Receive.gameObject, false)
    end
    self:UpdateItem(true)
  else
    self.ui.mText_Info.text = TableData.GetHintById(270188)
    self.ui.mAnimator_ActivityMuseExchangeLeftItem:SetInteger("Switch", 0)
    self:UpdateItem(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Retreat.gameObject).onClick = function()
    if self.data == nil then
      return
    end
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.parent.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    NetCmdThemeData:SendCancelInspirationOrder(self.parent.themeId, self.data.Id, function(ret)
      if ret == ErrorCodeSuc then
        CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(270206))
        self.parent:CleanTimeIndex(self.data.Id)
        self.parent:UpdateMySubList()
        self.parent:UpdateRewardCount()
        self.parent:UpdateCollectRedPoint()
        self.parent:UpdateExchangeRedPoint()
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Receive.gameObject).onClick = function()
    if self.data == nil then
      return
    end
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.parent.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    NetCmdThemeData:SendExchangeInspiration(self.parent.themeId, self.data.Id, function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ActivityMuseExchangeLeftItem.gameObject).onClick = function()
    if self.data then
      return
    end
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.parent.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    if not NetCmdThemeData:IsCanReleaseOrder(self.parent.activityID) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(270205))
      return
    end
    UIManager.OpenUIByParam(UIDef.ActivityMuseAddDialog, {
      themeId = self.parent.themeId
    })
  end
end
