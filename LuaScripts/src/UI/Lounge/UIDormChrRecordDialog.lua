require("UI.UIBasePanel")
UIDormChrRecordDialog = class("UIDormChrRecordDialog", UIBasePanel)
UIDormChrRecordDialog.__index = UIDormChrRecordDialog
function UIDormChrRecordDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIDormChrRecordDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
end
function UIDormChrRecordDialog:OnInit(root, data)
  self.mData = data[2]
  self.Callback = data[1]
  self:InitInfoData()
end
function UIDormChrRecordDialog:OnShowStart()
  self.canClose = self.mData.voice == 0
  if self.mData.voice > 0 then
    self:DelayCall(0.5, function()
      self.isPlayAudio = true
      AudioUtils.PlayByID(self.mData.voice)
      self.ui.mUIEffectNoiseSpectrum_Effect:SetSignalIntensityByComplete(1)
    end)
    local delayTime = self.ui.mTweenText_Details.duration
    self:DelayCall(delayTime, function()
      self.canClose = true
    end)
    self.ui.mTweenText_Details:Play()
  end
end
function UIDormChrRecordDialog:OnShowFinish()
  LoungeHelper.CameraCtrl.isDebug = false
end
function UIDormChrRecordDialog:OnHide()
end
function UIDormChrRecordDialog:OnClickClose()
  if self.canClose == true then
    UIManager.CloseUI(UIDef.UIDormChrRecordDialog)
    if self.Callback then
      self.Callback()
    end
  else
    self.ui.mTweenText_Details:KillByComplete()
    self.canClose = true
  end
end
function UIDormChrRecordDialog:OnClose()
  if self.isPlayAudio == true then
    AudioUtils.StopAudioByID(self.mData.voice)
  end
  self.isPlayAudio = nil
  self.mData = nil
  self.canClose = nil
  self.super.OnClose(self)
end
function UIDormChrRecordDialog:OnRelease()
end
function UIDormChrRecordDialog:InitInfoData()
  local content = self.mData.text.str
  local strLength = string.len(content)
  self.ui.mTrans_Content.anchoredPosition = vector2zero
  self.ui.mText_Name.text = self.mData.title.str
  self.ui.mText_Detail.text = content
  self.ui.mText_Num.text = string.format("-", self.mData.sort)
  self.ui.mTweenText_Details.duration = strLength / 20
  setactive(self.ui.mTrans_Audio, self.mData.voice > 0)
  setactive(self.ui.mTrans_ImgLine, not (self.mData.voice > 0))
  self.ui.mTweenText_Details:Kill()
end
function UIDormChrRecordDialog:AddBtnListen()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:OnClickClose()
  end)
  self.ui.mBtn_BGClose.onClick:AddListener(function()
    if self.canClose == false then
      self.ui.mTweenText_Details:KillByComplete()
      self.canClose = true
    end
  end)
end
function UIDormChrRecordDialog:OnCameraStart()
  return 0.01
end
function UIDormChrRecordDialog:OnCameraBack()
  return 0.01
end
