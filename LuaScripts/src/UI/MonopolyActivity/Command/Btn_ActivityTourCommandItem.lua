require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
Btn_ActivityTourCommandItem = class("Btn_ActivityTourCommandItem", UIBaseCtrl)
Btn_ActivityTourCommandItem.__index = Btn_ActivityTourCommandItem
function Btn_ActivityTourCommandItem:ctor()
  self.super.ctor(self)
end
function Btn_ActivityTourCommandItem:InitCtrl(itemPrefab, parent, onClick)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.isEmpty = true
  self.mCommandID = nil
  self.ui.mAnim_Root.keepAnimatorControllerStateOnDisable = true
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    if onClick then
      onClick()
    end
  end
  function self.ui.mAKE_Root.onAnimationEvent()
    self:RefreshCommand()
  end
end
function Btn_ActivityTourCommandItem:EnableBtn(enable)
  self.ui.mBtn_Root.interactable = enable
end
function Btn_ActivityTourCommandItem:CommandFadeInOut(isFadeIn)
  UIUtils.AnimatorFadeInOut(self.ui.mAnim_Root, isFadeIn)
end
function Btn_ActivityTourCommandItem:ShowNone()
  local oldIsEmpty = self.isEmpty
  self.isEmpty = true
  self.ui.mCanvasGroup_Root.blocksRaycasts = false
  self.mCommandID = nil
  self:EnableBtn(true)
  setactive(self.ui.mTrans_Command, false)
  if oldIsEmpty == false then
    self.ui.mAnim_Root:ResetTrigger("Refresh")
    self:CommandFadeInOut(false)
  end
end
function Btn_ActivityTourCommandItem:SetData(commandID, isRefresh)
  self.mCommandID = commandID
  self.data = TableData.listMonopolyOrderDatas:GetDataById(commandID)
  setactive(self.ui.mTrans_Command, true)
  self.ui.mCanvasGroup_Root.blocksRaycasts = true
  self:EnableBtn(true)
  if self.isEmpty then
    self.isEmpty = false
    self:RefreshCommand()
    self:CommandFadeInOut(true)
    return
  end
  if isRefresh == nil then
    isRefresh = true
  end
  if isRefresh then
    self.ui.mAnim_Root:ResetTrigger("Refresh")
    self.ui.mAnim_Root:SetTrigger("Refresh")
  else
    self:RefreshCommand()
  end
end
function Btn_ActivityTourCommandItem:RefreshCommand()
  if self.data == nil then
    self:ShowNone()
    return
  end
  self.ui.mImage_Icon.sprite = ActivityTourGlobal.GetActivityTourSprite(self.data.order_icon)
  local qualityColor = ActivityTourGlobal.GetCommandItemQualityColor(self.data.level)
  self.ui.mImage_Quality.color = qualityColor
  self.ui.mImage_Quality2.color = qualityColor
  if self.data.section.Count == 1 then
    self.ui.mText_Step.text = tostring(self.data.section.Count)
  else
    self.ui.mText_Step.text = UIUtils.StringFormatWithHintId(270164, self.data.section[0], self.data.section[1])
  end
end
