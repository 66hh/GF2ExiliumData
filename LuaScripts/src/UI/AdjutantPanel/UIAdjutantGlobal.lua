UIAdjutantGlobal = {}
UIAdjutantGlobal.AssistantCount = 3
UIAdjutantGlobal.BackgGroundCount = 2
UIAdjutantGlobal.CurInDoorId = 0
UIAdjutantGlobal.CurOutDoorId = 0
UIAdjutantGlobal.CommandBackGroundType = {In = 1, Out = 2}
UIAdjutantGlobal.CommandAdjutantType = {Adjutant = 1, Skin = 2}
UIAdjutantGlobal.CommandCenterCameraValue = {
  Normal = {},
  Model = {},
  BackgGround = {}
}
UIAdjutantGlobal.CommandCenterCameraDuration = 0.8
UIAdjutantGlobal.CameraPosTweener = nil
UIAdjutantGlobal.CameraFOVTweener = nil
UIAdjutantGlobal.AdjutantCameraAC = nil
UIAdjutantGlobal.AdjutantACName = "Adjutant/Ani_AdjutantFunctionSelectPanel_Camera"
UIAdjutantGlobal.AdjutantACTriggerName = {
  ChrFadeIn = "AdjutantChrChangeDialog_FadeIn",
  ChrFadeOut = "AdjutantChrChangeDialog_FadeOut",
  AssistantFadeIn = "AdjutantAssistantChangeDialog_FadeIn",
  Assistant01 = "AdjutantAssistantChangeDialog_01",
  Assistant02 = "AdjutantAssistantChangeDialog_02",
  Assistant03 = "AdjutantAssistantChangeDialog_03",
  AssistantFadeOut = "AdjutantAssistantChangeDialog_FadeOut",
  IndoorFadeIn = "AdjutantIndoorChangeDialog_FadeIn",
  IndoorFadeOut = "AdjutantIndoorChangeDialog_FadeOut",
  OutdoorFadeIn = "AdjutantOutdoorChangeDialog_FadeIn",
  OutdoorFadeOut = "AdjutantOutdoorChangeDialog_FadeOut"
}
function UIAdjutantGlobal.GetAdjutantRoomPic(picName)
  local tmpPicName = "Img_Adjutant_" .. picName
  return IconUtils.GetAdjutantRoomPic(tmpPicName)
end
function UIAdjutantGlobal.GetAdjutantRoomPrefab(prefabPath)
  return ResSys:GetCommandCenter(prefabPath)
end
function UIAdjutantGlobal.InitAdjutantCameraAC()
  UIAdjutantGlobal.AdjutantCameraAC = CS.CameraUtils.mainCamera:GetComponent("Animator")
  if UIAdjutantGlobal.AdjutantCameraAC ~= nil then
    UIAdjutantGlobal.AdjutantCameraAC.enabled = true
    local controller = ResSys:GetUIAnimController(UIAdjutantGlobal.AdjutantACName)
    UIAdjutantGlobal.AdjutantCameraAC.runtimeAnimatorController = controller
  end
end
function UIAdjutantGlobal.ResetAdjutantCameraAC()
  if UIAdjutantGlobal.AdjutantCameraAC ~= nil then
    UIAdjutantGlobal.AdjutantCameraAC.runtimeAnimatorController = nil
    UIAdjutantGlobal.AdjutantCameraAC = nil
  end
end
function UIAdjutantGlobal.PlayAdjutantCamera(triggerName)
  if UIAdjutantGlobal.AdjutantCameraAC ~= nil then
    UIAdjutantGlobal.AdjutantCameraAC:SetTrigger(triggerName)
  end
end
function UIAdjutantGlobal.InitCurBackground()
  UIAdjutantGlobal.CurInDoorId = NetCmdCommandCenterAdjutantData:GetCurBackgroundByType(UIAdjutantGlobal.CommandBackGroundType.In).CommandBackgroundData.Id
  UIAdjutantGlobal.CurOutDoorId = NetCmdCommandCenterAdjutantData:GetCurBackgroundByType(UIAdjutantGlobal.CommandBackGroundType.Out).CommandBackgroundData.Id
end
