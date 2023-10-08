require("UI.UIBasePanel")
UIAdjutantFunctionSelectPanel = class("UIAdjutantFunctionSelectPanel", UIBasePanel)
UIAdjutantFunctionSelectPanel.__index = UIAdjutantFunctionSelectPanel
local self = UIAdjutantFunctionSelectPanel
function UIAdjutantFunctionSelectPanel:ctor(obj)
  UIAdjutantFunctionSelectPanel.super.ctor(self)
  obj.HideSceneBackground = false
end
function UIAdjutantFunctionSelectPanel:OnInit(root)
  self.super.SetRoot(UIAdjutantFunctionSelectPanel, root)
  self.RedPointType = {
    RedPointConst.CommandCenterIndoor,
    RedPointConst.CommandCenterOutDoor
  }
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIAdjutantGlobal.ResetAdjutantCameraAC()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIAdjutantGlobal.ResetAdjutantCameraAC()
    UIManager.CloseUI(UIDef.UIAdjutantFunctionSelectPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_IndoorChange.gameObject).onClick = function()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_OutdoorChange.gameObject).onClick = function()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_AssistantChange.gameObject).onClick = function()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChrChange.gameObject).onClick = function()
    self:AdjutantChrChange()
  end
  NetCmdCommandCenterAdjutantData:GetAllAdjutant()
  UIAdjutantGlobal.InitAdjutantCameraAC()
  UIAdjutantGlobal.InitCurBackground()
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.CommandCenterIndoor, UIUtils.GetRectTransform(self.ui.mBtn_IndoorChange, "Root/Trans_RedPoint"))
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.CommandCenterOutDoor, UIUtils.GetRectTransform(self.ui.mBtn_OutdoorChange, "Root/Trans_RedPoint"))
end
function UIAdjutantFunctionSelectPanel:AdjutantIndoorChange()
  UIManager.OpenUI(UIDef.UIAdjutantIndoorChangeDialog)
end
function UIAdjutantFunctionSelectPanel:AdjutantOutdoorChange()
  UIManager.OpenUI(UIDef.UIAdjutantOutdoorChangeDialog)
end
function UIAdjutantFunctionSelectPanel:AdjutantAssistantChange()
  SceneSys.currentScene:EnableAssistants(false, 0)
  UIManager.OpenUI(UIDef.UIAdjutantAssistantChangeDialog)
end
function UIAdjutantFunctionSelectPanel:AdjutantChrChange()
  UIManager.OpenUI(UIDef.UIAdjutantChrChangeDialog)
end
function UIAdjutantFunctionSelectPanel:OnShowStart()
  self:UpdateRedPoint()
end
function UIAdjutantFunctionSelectPanel:OnHide()
  self.ui.mAnimator_Root:SetTrigger("FadeOut")
  self.isHide = true
end
function UIAdjutantFunctionSelectPanel:OnClose()
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.CommandCenterIndoor)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.CommandCenterOutDoor)
end
