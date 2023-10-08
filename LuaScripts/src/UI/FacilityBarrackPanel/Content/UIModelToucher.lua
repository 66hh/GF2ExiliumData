UIModelToucher = {}
UIModelToucher.weaponToucher = nil
UIModelToucher.startEuler = nil
UIModelToucher.startScale = nil
UIModelToucher.weaponToucherEventEnd = nil
UIModelToucher.weaponToucherEventBegin = nil
UIModelToucher.weaponModel = nil
UIModelToucher.characterToucher = nil
UIModelToucher.lastTweener = nil
UIModelToucher.resetEuler = nil
UIModelToucher.weaponCmd = nil
UIModelToucher.lastCreatedTweener = nil
function UIModelToucher.CreateWeapon(weaponCmd, gunId)
  local res = UIWeaponGlobal:GetWeaponModelShow(weaponCmd, gunId)
  UIModelToucher.weaponModel = CS.ResSys.Instance:GetBarrackWeaponInstance(res)
  if UIModelToucher.startEuler ~= nil then
    UIModelToucher.weaponModel.transform.localEulerAngles = UIModelToucher.startEuler
  end
  return UIModelToucher.weaponModel
end
function UIModelToucher.SetWeaponTransformValue(weaponCmd, enableRotation, enableToucher)
  if CS.LuaUtils.IsNullOrDestroyed(UIModelToucher.weaponModel) then
    return
  end
  UIModelToucher.weaponModel.transform.position = UIUtils.SplitStrToVector(weaponCmd.Position)
  UIModelToucher.weaponModel.transform.localScale = UIUtils.SplitStrToVector(weaponCmd.Scale)
  GFUtils.MoveToLayer(UIModelToucher.weaponModel.transform, CS.UnityEngine.LayerMask.NameToLayer("Friend"))
  local toRotation = UIUtils.SplitStrToVector(weaponCmd.Rotation)
  UIModelToucher.resetEuler = toRotation
  if enableToucher == nil or enableToucher then
    UIModelToucher.SwitchToucher(2)
    UIModelToucher.AttachWeaponTransToTouch(UIModelToucher.weaponModel)
  else
    UIModelToucher.ReleaseWeaponToucher()
  end
  if enableRotation ~= nil and enableRotation == false then
    if UIModelToucher.startEuler ~= nil then
      UIModelToucher.weaponModel.transform.localEulerAngles = UIModelToucher.startEuler
    end
    return
  end
  if UIModelToucher.startEuler == nil then
    UIModelToucher.SetStartEulerDirect(UIModelToucher.weaponModel.transform.localEulerAngles)
  end
  UIModelToucher.lastCreatedTweener = CS.UITweenManager.PlayRotationTween(UIModelToucher.weaponModel.transform, UIModelToucher.startEuler, toRotation, 1.2, 0, nil, CS.DG.Tweening.Ease.OutQuint, CS.DG.Tweening.RotateMode.FastBeyond360)
  UIModelToucher.SetStartEulerDirect(toRotation)
  UIModelToucher.startScale = UIModelToucher.weaponModel.transform.localScale
end
function UIModelToucher.OnWeaponTouchEnd(v2)
  local toEuler = UIModelToucher.startEuler
  if toEuler == nil then
    toEuler = Vector3.zero
  end
  if not CS.LuaUtils.IsNullOrDestroyed(UIModelToucher.weaponModel) then
    UIModelToucher.lastTweener = CS.UITweenManager.PlayRotationTween(UIModelToucher.weaponModel.transform, UIModelToucher.weaponModel.transform.localEulerAngles, toEuler, 1.2, 0, nil, CS.DG.Tweening.Ease.OutQuint, CS.DG.Tweening.RotateMode.FastBeyond360)
  end
end
function UIModelToucher.OnWeaponTouchBegin(v2)
  if UIModelToucher.lastTweener ~= nil then
    CS.UITweenManager.TweenKill(UIModelToucher.lastTweener)
  end
end
function UIModelToucher.ReleaseWeaponToucher()
  UIModelToucher.DetachAllWeaponEvents()
  UIModelToucher.weaponToucher = nil
  UIModelToucher.weaponToucherEventBegin = nil
  UIModelToucher.weaponToucherEventEnd = nil
  UIModelToucher.SetStartEulerDirect(nil)
end
function UIModelToucher.DetachAllWeaponEvents()
  if not CS.LuaUtils.IsNullOrDestroyed(UIModelToucher.weaponToucher) then
    if UIModelToucher.weaponToucherEventEnd ~= nil then
      UIModelToucher.weaponToucher:DetachOneFingerDraggingEndHandle(UIModelToucher.weaponToucherEventEnd)
      UIModelToucher.weaponToucher:DetachTwoFingerDraggingEndHandle(UIModelToucher.weaponToucherEventEnd)
      UIModelToucher.weaponToucherEventEnd = nil
    end
    if UIModelToucher.weaponToucherEventBegin ~= nil then
      UIModelToucher.weaponToucher:DetachOneFingerDraggingBeingHandle(UIModelToucher.weaponToucherEventBegin)
      UIModelToucher.weaponToucher:DetachTwoFingerDraggingBeingHandle(UIModelToucher.weaponToucherEventBegin)
      UIModelToucher.weaponToucherEventBegin = nil
    end
  end
end
function UIModelToucher.ReleaseCharacterToucher()
  UIModelToucher.characterToucher = nil
end
function UIModelToucher.AttachStoreTransToTouch(gameObject)
  local camera = UISystem.StoreCamera
end
function UIModelToucher.AttachCharacterTransToTouch(gameObject)
  local camera = UISystem.CharacterCamera
  UIModelToucher.characterToucher = CS.BarrackCharacterTouchController.Get(camera.gameObject)
  UIModelToucher.characterToucher:SetModel(gameObject)
end
function UIModelToucher.UpdateStageUpVirtualCameraTargetPosition(position)
  local camera = BarrackHelper.CameraMgr.CharacterCamera
  UIModelToucher.characterToucher = CS.BarrackCharacterTouchController.Get(camera.gameObject)
  UIModelToucher.characterToucher:UpdateStageUpVirtualCameraTargetPosition(position)
end
function UIModelToucher.SetStageUpVirtualCameraPosition(position)
  local camera = BarrackHelper.CameraMgr.CharacterCamera
  UIModelToucher.characterToucher = CS.BarrackCharacterTouchController.Get(camera.gameObject)
  UIModelToucher.characterToucher:SetStageUpVirtualCameraPosition(position)
end
function UIModelToucher.AttachLoungeCharacterTransToTouch(gameObject)
  local camera = UISystem.CharacterCamera
  UIModelToucher.characterToucher = CS.CharacterCameraScaleController.Get(camera.gameObject)
  UIModelToucher.characterToucher:SetLoungeModel(gameObject)
end
function UIModelToucher.AttachWeaponTransToTouch(gameObject)
  local camera = UISystem.CharacterCamera
  UIModelToucher.weaponToucher = CS.WeaponTouchController.Get(camera.gameObject)
  UIModelToucher.weaponToucher:SetModel(gameObject)
end
function UIModelToucher.SetStartEuler(euler)
  UIModelToucher.SetStartEulerDirect(euler)
  UIModelToucher.OnWeaponTouchEnd()
end
function UIModelToucher.SetStartEulerDirect(euler)
  UIModelToucher.startEuler = euler
end
function UIModelToucher.ResetStartEuler()
  UIModelToucher.SetStartEulerDirect(UIModelToucher.resetEuler)
  UIModelToucher.OnWeaponTouchEnd()
end
function UIModelToucher.SwitchToucher(type)
  local camera = UISystem.CharacterCamera
  UIModelToucher.characterToucher = CS.BarrackCharacterTouchController.Get(camera.gameObject)
  if UIModelToucher.characterToucher == nil then
    return
  end
  UIModelToucher.weaponToucher = CS.WeaponTouchController.Get(camera.gameObject)
  if UIModelToucher.weaponToucher == nil then
    return
  end
  UIModelToucher.weaponToucher:DetachEvents()
  UIModelToucher.characterToucher:DetachEvents()
  UIModelToucher.DetachAllWeaponEvents()
  if type == 1 then
    UIModelToucher.characterToucher.enabled = true
    UIModelToucher.weaponToucher.enabled = false
    UIModelToucher.characterToucher:AttachEvents()
  elseif type == 2 then
    UIModelToucher.characterToucher.enabled = false
    UIModelToucher.characterToucher:ResetCameraTweener()
    UIModelToucher.weaponToucher.enabled = true
    UIModelToucher.weaponToucher:AttachEvents(UIModelToucher.OnOneFingerCancel)
    UIModelToucher.AttachWeaponTouchEvents()
  end
end
function UIModelToucher.OnOneFingerCancel()
  UIModelToucher.OnWeaponTouchEnd(nil)
end
function UIModelToucher.AttachWeaponTouchEvents()
  if UIModelToucher.weaponToucher == nil then
    return
  end
  if UIModelToucher.weaponToucherEventEnd == nil then
    function UIModelToucher.weaponToucherEventEnd(v2)
      UIModelToucher.OnWeaponTouchEnd(v2)
    end
  end
  UIModelToucher.weaponToucher:AttachOneFingerDraggingEndHandle(UIModelToucher.weaponToucherEventEnd)
  UIModelToucher.weaponToucher:AttachTwoFingerDraggingEndHandle(UIModelToucher.weaponToucherEventEnd)
  if UIModelToucher.weaponToucherEventBegin == nil then
    function UIModelToucher.weaponToucherEventBegin(v2)
      UIModelToucher.OnWeaponTouchBegin(v2)
    end
  end
  UIModelToucher.weaponToucher:AttachOneFingerDraggingBeingHandle(UIModelToucher.weaponToucherEventBegin)
  UIModelToucher.weaponToucher:AttachTwoFingerDraggingBeingHandle(UIModelToucher.weaponToucherEventBegin)
end
function UIModelToucher.ResetWeaponModelToucher()
  local enableToucher = FacilityBarrackGlobal.GetCurCameraStand() == FacilityBarrackGlobal.CameraType.WeaponToucher
  if enableToucher then
    UIModelToucher.SwitchToucher(2)
    UIModelToucher.AttachWeaponTransToTouch(UIModelToucher.weaponModel)
  else
    UIModelToucher.ReleaseWeaponToucher()
  end
end
