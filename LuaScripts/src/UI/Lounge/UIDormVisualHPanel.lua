require("UI.UIBasePanel")
require("UI.Common.ComBtnInputKeyPC")
require("UI.Lounge.DormGlobal")
UIDormVisualHPanel = class("UIDormVisualHPanel", UIBasePanel)
UIDormVisualHPanel.__index = UIDormVisualHPanel
function UIDormVisualHPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIDormVisualHPanel:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self:InitContent()
  self:AddListener()
  self.mCSPanel.AutoShowNextPanel = true
  CS.UnityEngine.Screen.orientation = CS.UnityEngine.ScreenOrientation.AutoRotation
  CS.UnityEngine.Screen.autorotateToLandscapeRight = true
  CS.UnityEngine.Screen.autorotateToLandscapeLeft = true
  CS.UnityEngine.Screen.autorotateToPortrait = true
  CS.UnityEngine.Screen.autorotateToPortraitUpsideDown = true
  DormGlobal.IsResetOrientation = false
  self.isChanging = false
  UISystem.UIRootCanvasAdapter:CanvasResolutionChange()
  gfdebug("orientation2 " .. tostring(CS.UnityEngine.Screen.autorotateToLandscapeLeft))
  gfdebug("orientation3 " .. tostring(CS.UnityEngine.Screen.autorotateToLandscapeRight))
  gfdebug("orientation4 " .. tostring(CS.UnityEngine.Screen.autorotateToPortrait))
  gfdebug("orientation5 " .. tostring(CS.UnityEngine.Screen.autorotateToPortraitUpsideDown))
end
function UIDormVisualHPanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    DormGlobal.IsResetOrientation = true
    UIManager.CloseUI(UIDef.UIDormVisualHPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    if LoungeHelper.CameraCtrl ~= nil then
      LoungeHelper.CameraCtrl:SetCanSendMessage(false)
    end
    DormGlobal.IsResetOrientation = true
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Top.gameObject).onDown = function()
    self:MoveForward(DormGlobal.Direction.Forward)
    self:SetUIClick(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right.gameObject).onDown = function()
    self:MoveRight(DormGlobal.Direction.Right)
    self:SetUIClick(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Bottom.gameObject).onDown = function()
    self:MoveBack(DormGlobal.Direction.Back)
    self:SetUIClick(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onDown = function()
    self:MoveLeft(DormGlobal.Direction.Left)
    self:SetUIClick(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Top.gameObject).onUp = function()
    self:MoveForward(DormGlobal.Direction.None)
    self:SetUIClick(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right.gameObject).onUp = function()
    self:MoveRight(DormGlobal.Direction.None)
    self:SetUIClick(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Bottom.gameObject).onUp = function()
    self:MoveBack(DormGlobal.Direction.None)
    self:SetUIClick(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onUp = function()
    self:MoveLeft(DormGlobal.Direction.None)
    self:SetUIClick(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reset.gameObject).onClick = function()
    LoungeHelper.CameraCtrl.CameraPreObj:ResetCamera()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Hide.gameObject).onClick = function()
    self:OnHideClick()
  end
end
function UIDormVisualHPanel:AddListener()
  function self.updateOrient(message)
    self:UpdateOrient(message)
  end
  MessageSys:AddListener(CS.GF2.Message.LoungeEvent.CameraDirChange, self.updateOrient)
end
function UIDormVisualHPanel:RemoveListener()
  if self.updateOrient ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.LoungeEvent.CameraDirChange, self.updateOrient)
    self.updateOrient = nil
  end
end
function UIDormVisualHPanel:InitContent()
  self.isShow = not DormGlobal.IsShowUI
  self:OnHideClick()
  self.BtnResetKeyPC = ComBtnInputKeyPC.New()
  self.BtnResetKeyPC:InitCtrl(self.ui.mBtn_ResetPC, {
    self.ui.mTrans_RockInfo,
    self.ui.mTrans_Left
  }, self, KeyCode.Mouse2, "Mouse2")
  self.BtnInputKeyPC = ComBtnInputKeyPC.New()
  self.BtnInputKeyPC:InitCtrl(self.ui.mBtn_HidePC, {
    self.ui.mTrans_RockInfo,
    self.ui.mTrans_Left,
    self.BtnResetKeyPC:GetRoot()
  }, self, KeyCode.H, "H")
  self.topKeyUI = {}
  self.bottomKeyUI = {}
  self.leftKeyUI = {}
  self.rightKeyUI = {}
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    self:ShowKeyText(self.ui.mBtn_LeftPC.gameObject, self.leftKeyUI, "A")
    self:ShowKeyText(self.ui.mBtn_TopPC.gameObject, self.topKeyUI, "W")
    self:ShowKeyText(self.ui.mBtn_RightPC.gameObject, self.rightKeyUI, "D")
    self:ShowKeyText(self.ui.mBtn_BottomPC.gameObject, self.bottomKeyUI, "S")
  else
  end
end
function UIDormVisualHPanel:ShowKeyText(obj, table, str)
  local pcKey = obj.transform:Find("PCKey_Content")
  self:LuaUIBindTable(pcKey, table)
  table.mText_InputKey.text = str
end
function UIDormVisualHPanel:OnShowFinish()
  LoungeHelper.CameraCtrl.isDebug = true
  LoungeHelper.PhysicSimulate(true)
  local orientation = CS.UnityEngine.Screen.orientation
  local platform = CS.UnityEngine.Application.platform
  if platform == CS.UnityEngine.RuntimePlatform.WindowsEditor or platform == CS.UnityEngine.RuntimePlatform.WindowsPlayer then
    return
  end
  if (orientation == CS.UnityEngine.ScreenOrientation.Portrait or orientation == CS.UnityEngine.ScreenOrientation.PortraitUpsideDown) and self.isChanging == false then
    self.ui.mBtn_AniTime.m_FadeOutTime = 0
    self.mCSPanel.AutoShowNextPanel = false
    self.isChanging = true
    DormGlobal.IsShowUI = true
    UIManager.CloseUI(UIDef.UIDormVisualHPanel)
    UIManager.OpenUI(UIDef.UIDormVisualVPanel)
  end
end
function UIDormVisualHPanel:SetUIClick(bool)
  CS.LoungeCameraPreObj.isUIClick = bool
end
function UIDormVisualHPanel:MoveLeft(Direction)
  CS.LoungeCameraPreObj.eNowDirection = Direction
end
function UIDormVisualHPanel:MoveRight(Direction)
  CS.LoungeCameraPreObj.eNowDirection = Direction
end
function UIDormVisualHPanel:MoveForward(Direction)
  CS.LoungeCameraPreObj.eNowDirection = Direction
end
function UIDormVisualHPanel:MoveBack(Direction)
  CS.LoungeCameraPreObj.eNowDirection = Direction
end
function UIDormVisualHPanel:OnHideFinish()
  if DormGlobal.IsResetOrientation then
    gfdebug("UIDormVisualHPanel " .. tostring(CS.UnityEngine.Screen.orientation))
    CS.UnityEngine.Screen.orientation = CS.UnityEngine.ScreenOrientation.LandscapeLeft
    CS.UnityEngine.Screen.autorotateToLandscapeRight = false
    CS.UnityEngine.Screen.autorotateToLandscapeLeft = false
    CS.UnityEngine.Screen.autorotateToPortrait = false
    CS.UnityEngine.Screen.autorotateToPortraitUpsideDown = false
    self.ui.mBtn_AniTime.m_FadeOutTime = 0.33
    UISystem.UIRootCanvasAdapter:CanvasResolutionChange()
  end
end
function UIDormVisualHPanel:OnClose()
  LoungeHelper.PhysicSimulate(false)
  LoungeHelper.CameraCtrl.isDebug = false
  self:RemoveListener()
end
function UIDormVisualHPanel:OnHideClick()
  self.isShow = not self.isShow
  setactivewithcheck(self.ui.mTrans_Action, self.isShow)
  setactivewithcheck(self.ui.mTrans_Icon1, self.isShow)
  setactivewithcheck(self.ui.mTrans_Left, self.isShow)
  setactivewithcheck(self.ui.mTrans_Reset, self.isShow)
  setactivewithcheck(self.ui.mTrans_Icon2, not self.isShow)
  DormGlobal.IsShowUI = self.isShow
end
function UIDormVisualHPanel:UpdateOrient(message)
  local orientation = message.Sender
  gfdebug("UIDormVisualHPanel orientation " .. tostring(orientation))
  if (orientation == CS.UnityEngine.ScreenOrientation.Portrait or orientation == CS.UnityEngine.ScreenOrientation.PortraitUpsideDown) and self.isChanging == false then
    self.ui.mBtn_AniTime.m_FadeOutTime = 0
    self.mCSPanel.AutoShowNextPanel = false
    DormGlobal.IsShowUI = true
    self.isChanging = true
    UIManager.CloseUI(UIDef.UIDormVisualHPanel)
    UIManager.OpenUI(UIDef.UIDormVisualVPanel)
  end
end
function UIDormVisualHPanel:OnCameraStart()
  return 0.01
end
function UIDormVisualHPanel:OnCameraBack()
  return 0.01
end
