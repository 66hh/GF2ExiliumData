require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.Command.ActivityTourCommand_Move_PointItem")
require("UI.MonopolyActivity.Command.ActivityTourCommand_CtrlBase")
ActivityTourCommandMove = class("ActivityTourCommandMove", ActivityTourCommandCtrlBase)
ActivityTourCommandMove.__index = ActivityTourCommandMove
local MaxShowNumCount = 6
function ActivityTourCommandMove:ctor()
  self.super.ctor(self)
end
function ActivityTourCommandMove:InitCtrl(commandCtrl, parentUI)
  self.mCommandCtrl = commandCtrl
  self.mSelectNums = {}
  self.ui = parentUI
end
function ActivityTourCommandMove:Hide()
  setactive(self.ui.mTrans_SelectMove, false)
end
function ActivityTourCommandMove:SetData(data, slotIndex)
  self.mData = data
  self.mSlotIndex = slotIndex
  self.mSelectNum = nil
  self.mShowSelectNum = false
  self:RegisterEvent()
  self:ShowOrderInfo(self.mData)
  self:EnableConfirmBtn(true)
  setactive(self.ui.mBtn_Delete, true)
end
function ActivityTourCommandMove:ShowSelectNum()
  self.mShowSelectNum = true
  setactive(self.ui.mBtn_Delete, false)
  setactive(self.ui.mTrans_SelectEntity, false)
  setactive(self.ui.mTrans_SelectMove, true)
  local totalShowCount = self.mData.section.Count
  if totalShowCount < 2 then
    print_error("移动点数不能少于两个")
    return
  end
  local minNum = self.mData.section[0]
  local maxNum = self.mData.section[1]
  for i = 1, MaxShowNumCount do
    local pointItem = self.mSelectNums[i]
    if not pointItem then
      pointItem = ActivityTourCommandPointItem.New()
      pointItem:InitCtrl(self.ui.mSCL_CommandSelectNum.childItem, self.ui.mSCL_CommandSelectNum.transform, function()
        self:OnClickCommand(i)
      end)
      self.mSelectNums[i] = pointItem
    end
    local num = minNum + (i - 1)
    if maxNum < num then
      num = nil
    end
    pointItem:SetData(num, function()
      self:OnClickNum(i)
    end)
    pointItem.mUIRoot:SetAsLastSibling()
  end
end
function ActivityTourCommandMove:OnClickNum(index)
  for i = 1, #self.mSelectNums do
    local numItem = self.mSelectNums[i]
    local isSelect = i == index
    if isSelect then
      self.mSelectNum = numItem.num
    end
    numItem:EnableBtn(not isSelect)
  end
end
function ActivityTourCommandMove:RegisterEvent()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Confirm, function()
    if not self.mShowSelectNum then
      self:ShowSelectNum()
    else
      self:UseCommand()
    end
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Delete, function()
    self.mCommandCtrl:DeleteCommand(self.mData, self.mSlotIndex)
  end)
end
function ActivityTourCommandMove:UseCommand()
  if not self.mSelectNum then
    UIUtils.PopupErrorWithHint(270166)
    return
  end
  MonopolyWorld.MpData:UseCommand(self.mSlotIndex, self.mSelectNum, {}, function(ret)
    if ret == ErrorCodeSuc then
      self.mCommandCtrl:HideCommandInfo()
      self.mCommandCtrl:RefreshAllCommand(false)
    end
  end)
end
function ActivityTourCommandMove:OnRelease()
  self:ReleaseCtrlTable(self.mSelectNums, true)
  self.mSelectNums = nil
  self.mShowSelectNum = false
  self.super.OnRelease(self, true)
end
