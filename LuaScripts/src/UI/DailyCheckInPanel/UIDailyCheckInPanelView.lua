require("UI.UIBaseView")
UIDailyCheckInPanelView = class("UIDailyCheckInPanelView", UIBaseView)
UIDailyCheckInPanelView.__index = UIDailyCheckInPanelView
UIDailyCheckInPanelView.mBtn_DailyCheckIn_Confirm = nil
UIDailyCheckInPanelView.mText_DailyCheckIn_CharacterInfo_Message = nil
UIDailyCheckInPanelView.mText_DailyCheckIn_CharacterInfo_InfoText02 = nil
UIDailyCheckInPanelView.mText_DailyCheckIn_CharacterInfo_InfoText03 = nil
UIDailyCheckInPanelView.mLayout_DailyCheckIn_CheckInItemList = nil
UIDailyCheckInPanelView.mTrans_DailyCheckIn_CharacterInfo_MessageBGImage = nil
function UIDailyCheckInPanelView:__InitCtrl()
end
function UIDailyCheckInPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
