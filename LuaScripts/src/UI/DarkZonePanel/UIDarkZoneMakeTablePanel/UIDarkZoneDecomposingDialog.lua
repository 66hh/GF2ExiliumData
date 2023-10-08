require("UI.UIBasePanel")
UIDarkZoneDecomposingDialog = class("UIDarkZoneDecomposingDialog", UIBasePanel)
UIDarkZoneDecomposingDialog.__index = UIDarkZoneDecomposingDialog
function UIDarkZoneDecomposingDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneDecomposingDialog:OnAwake(root, callBack)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.callBack = callBack
end
function UIDarkZoneDecomposingDialog:OnInit(root, data)
end
function UIDarkZoneDecomposingDialog:OnShowStart()
  self.ui.mAnimation:Play()
  TimerSys:DelayCall(self.ui.mAnimation.clip.length, function()
    UIManager.CloseUI(UIDef.UIDarkZoneDecomposingDialog)
    if DarkNetCmdMakeTableData.FullDecompose then
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        nil,
        function()
          self.callBack()
        end
      })
    end
  end)
end
function UIDarkZoneDecomposingDialog:OnShowFinish()
end
function UIDarkZoneDecomposingDialog:OnBackFrom()
end
function UIDarkZoneDecomposingDialog:OnClose()
end
function UIDarkZoneDecomposingDialog:OnHide()
end
function UIDarkZoneDecomposingDialog:OnHideFinish()
end
function UIDarkZoneDecomposingDialog:OnRelease()
  self.ui = nil
  self.callBack = nil
end
function UIDarkZoneDecomposingDialog:OnRecover()
end
function UIDarkZoneDecomposingDialog:OnSave()
end
