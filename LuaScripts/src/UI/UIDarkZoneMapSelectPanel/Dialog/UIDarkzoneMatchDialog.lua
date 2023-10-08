require("UI.UIDarkZoneMapSelectPanel.Dialog.UIDarkzoneMatchDialogView")
require("UI.UIBasePanel")
UIDarkzoneMatchDialog = class("UIDarkzoneMatchDialog", UIBasePanel)
UIDarkzoneMatchDialog.__index = UIDarkzoneMatchDialog
local self = UIDarkzoneMatchDialog
function UIDarkzoneMatchDialog:ctor(csPanel)
  UIDarkzoneMatchDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkzoneMatchDialog:OnInit(root, data)
  UIDarkzoneMatchDialog.super.SetRoot(UIDarkzoneMatchDialog, root)
  self:InitBaseData()
  self.isClosed = false
  self.mData = data
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIDarkzoneMatchDialog:OnShowFinish()
  if DarkNetCmdMatchData.IsMatchSuccess == true then
    self.ui.mBtn_Cancel.interactable = false
    self.ui.mText_Time.text = DarkNetCmdMatchData.MatchCount
    setactive(self.ui.mTrans_Progress, false)
    setactive(self.ui.mTrans_Succeed, true)
    self.ui.mAnim_Root:SetTrigger("Succeed")
    self.CountDown = false
    setactive(self.ui.mBtn_Cancel.gameObject, false)
  else
    setactive(self.ui.mTrans_Progress, true)
  end
end
function UIDarkzoneMatchDialog:OnHide()
end
function UIDarkzoneMatchDialog:OnUpdate(deltatime)
  if self.Time == nil then
    self.Time = 0
  end
  if DarkNetCmdMatchData.IsMatchSuccess == true and self.MatchSuccess == false then
    self.ui.mBtn_Cancel.interactable = false
    self.ui.mText_Time.text = DarkNetCmdMatchData.MatchCount
    setactive(self.ui.mTrans_Progress, false)
    setactive(self.ui.mTrans_Succeed, true)
    self.ui.mAnim_Root:ResetTrigger("Succeed")
    self.ui.mAnim_Root:SetTrigger("Succeed")
    self.MatchSuccess = true
    self.CountDown = false
    setactive(self.ui.mBtn_Cancel.gameObject, false)
  elseif self.CountDown ~= false then
    self.Time = self.Time + deltatime
    self.ui.mText_Time.text = DarkNetCmdMatchData:sec_to_hms(math.ceil(self.Time + deltatime))
  end
end
function UIDarkzoneMatchDialog:CloseFunction()
  if self.isClosed == true then
    return
  end
  if DarkNetCmdMatchData.IsMatchSuccess == false then
  end
end
function UIDarkzoneMatchDialog:OnClose()
  self.ui = nil
  self.mview = nil
  self.MatchSuccess = nil
  self.Time = nil
  self.CountDown = nil
  self.isClosed = nil
  DarkNetCmdMatchData.IsMatchSuccess = false
end
function UIDarkzoneMatchDialog:InitBaseData()
  self.mview = UIDarkzoneMatchDialogView.New()
  self.ui = {}
  self.MatchSuccess = false
  self.Time = 0
end
function UIDarkzoneMatchDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:CloseFunction()
  end
end
