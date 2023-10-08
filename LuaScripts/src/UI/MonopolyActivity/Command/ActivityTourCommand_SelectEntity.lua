require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.Command.ActivityTourCommand_CtrlBase")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourCommandSelectEntity = class("ActivityTourCommandSelectEntity", ActivityTourCommandCtrlBase)
ActivityTourCommandSelectEntity.__index = ActivityTourCommandSelectEntity
function ActivityTourCommandSelectEntity:ctor()
  self.super.ctor(self)
end
function ActivityTourCommandSelectEntity:InitCtrl(commandCtrl, parentUI)
  self.mCommandCtrl = commandCtrl
  self.ui = parentUI
  self.mSelectRoot = self.ui.mTrans_SelectEntity.gameObject
  function self.OnSelectChange()
    self:OnSelectChangeRefreshInfo()
  end
end
function ActivityTourCommandSelectEntity:Hide()
  setactive(self.ui.mTrans_SelectEntity, false)
  setactive(self.ui.mTrans_SelectRoot, false)
  MessageSys:RemoveListener(CS.GF2.Message.MonopolyEvent.OnSelectChange, self.OnSelectChange)
  MonopolySelectManager:CancelAllSelect(true)
  MonopolySelectManager:EnableMultiSelect(false)
end
function ActivityTourCommandSelectEntity:SetData(data, slotIndex)
  self:RegisterEvent()
  MessageSys:AddListener(CS.GF2.Message.MonopolyEvent.OnSelectChange, self.OnSelectChange)
  self.mData = data
  self.mSlotIndex = slotIndex
  self:InitParam()
  self:ShowOrderInfo(self.mData)
  self:InitSelectInfo()
end
function ActivityTourCommandSelectEntity:InitParam()
  local params = string.split(self.mData.target_type, ":")
  self.mTargetType = tonumber(params[1])
  if params[2] then
    self.mTargetTypeParam = string.split(params[2], ",")
    for i = 1, #self.mTargetTypeParam do
      self.mTargetTypeParam[i] = tonumber(self.mTargetTypeParam[i])
    end
  else
    self.mTargetTypeParam = nil
  end
  if self.mData.target_param == nil or 2 > self.mData.target_param.Count then
    self.mMinSelect = 0
    self.mMaxSelect = 0
  else
    self.mMinSelect = self.mData.target_param[0]
    self.mMaxSelect = self.mData.target_param[1]
  end
end
function ActivityTourCommandSelectEntity:RegisterEvent()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Confirm, function()
    MonopolyWorld.MpData:UseCommand(self.mSlotIndex, 0, MonopolySelectManager:GetAllSelectTargets(), function(ret)
      if ret == ErrorCodeSuc then
        self.mCommandCtrl:HideCommandInfo()
        self.mCommandCtrl:RefreshAllCommand(false)
      end
    end)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Delete, function()
    self.mCommandCtrl:DeleteCommand(self.mData, self.mSlotIndex)
  end)
end
function ActivityTourCommandSelectEntity:InitSelectInfo()
  self.mShowSelect = self.mTargetType ~= ActivityTourGlobal.OrderSelectType_SelfActor and self.mMaxSelect ~= 0
  setactive(self.ui.mTrans_SelectRoot, self.mShowSelect)
  self:EnableConfirmBtn(not self.mShowSelect)
  MonopolySelectManager:CancelAllSelect(true)
  if not self.mShowSelect then
    return
  end
  MonopolySelectManager:EnableMultiSelect(true, self.mMaxSelect)
  local count = MonopolySelectManager:SetOnlyCanSelectWithOrder(self.mData)
  if self.mMaxSelect == -1 then
    self.mMaxSelect = count
  end
  if self.mMinSelect == -1 then
    self.mMinSelect = count
  end
  self:RefreshSelectCount()
end
function ActivityTourCommandSelectEntity:RefreshSelectCount()
  if not self.mShowSelect then
    return
  end
  local selectCount = MonopolySelectManager:GetTotalSelectCount()
  local canConfirm = selectCount >= self.mMinSelect
  local selectAll = selectCount >= self.mMaxSelect
  self.ui.mText_SelectInfo.text = UIUtils.StringFormatWithHintId(270169 + self.mTargetType - 1, selectCount, self.mMaxSelect)
  setactive(self.ui.mTrans_SelectUnComplete, not selectAll)
  setactive(self.ui.mTrans_SelectComplete, selectAll)
  self:EnableConfirmBtn(canConfirm)
end
function ActivityTourCommandSelectEntity:OnSelectChangeRefreshInfo()
  if not self.mSelectRoot.activeInHierarchy then
    return
  end
  self:RefreshSelectCount()
end
function ActivityTourCommandSelectEntity:OnRelease()
  MessageSys:RemoveListener(CS.GF2.Message.MonopolyEvent.OnSelectChange, self.OnSelectChange)
  self.mSelectRoot = nil
  self.super.OnRelease(self, true)
end
