UIBattlePassGlobal = {}
UIBattlePassGlobal.ButtonType = {
  MainPanel = 1,
  Mission = 2,
  Collection = 3,
  Shop = 4
}
UIBattlePassGlobal.ButtonTypeHintText = {
  [1] = 192000,
  [2] = 192001,
  [3] = 192002,
  [4] = 192003
}
UIBattlePassGlobal.BpUnlockType = {Normal = 1, Plus = 2}
UIBattlePassGlobal.BpCollectionTabId = {Gun = 1, Weapon = 2}
UIBattlePassGlobal.BpTaskTypeShow = {
  Daily = 1,
  Weekly = 2,
  TaskNew = 3,
  TaskCooperation = 4
}
UIBattlePassGlobal.BpTaskDialogType = {
  RefreshDaily = 1,
  AddDaily = 2,
  AddShare = 3,
  RefreshWeek = 4
}
UIBattlePassGlobal.BpTaskGetType = {Extra = 1, Share = 2}
UIBattlePassGlobal.ShowModel = nil
UIBattlePassGlobal.BpShowSource = {MainPanel = 1, UnlockPanel = 2}
UIBattlePassGlobal.BpMainpanelRefreshType = {
  None = 0,
  FristShow = 1,
  ClickTab = 2,
  OnTop = 3,
  LevelUp = 4
}
UIBattlePassGlobal.BpBuyPromote2 = false
UIBattlePassGlobal.CurMaxItemIndex = 0
UIBattlePassGlobal.CurBpMainpanelRefreshType = UIBattlePassGlobal.BpMainpanelRefreshType.FristShow
UIBattlePassGlobal.BpShowSourceType = UIBattlePassGlobal.BpShowSource.MainPanel
UIBattlePassGlobal.BpOutSideType = {bp = 1, bpOutSide = 2}
UIBattlePassGlobal.IsBpOutSide = UIBattlePassGlobal.BpOutSideType.bp
UIBattlePassGlobal.UnlockPanelBlackTime = 0.1
UIBattlePassGlobal.BpMainPanelBlackTime = 0
UIBattlePassGlobal.ModelList = {}
UIBattlePassGlobal.TabIndx = 0
UIBattlePassGlobal.IsVideoPlay = false
UIBattlePassGlobal.RefreshKey = "BPRefreshTime"
function UIBattlePassGlobal.InitEffectNum(fun)
  local effectNumObjName = "ChrPowerUpPanelV3_Visual_Mesh"
  local modelCachePoolObj = UIBattlePassGlobal.ShowModel
  if modelCachePoolObj ~= nil then
    UIBattlePassGlobal.EffectNumObj = ResSys:GetUICharacter(effectNumObjName)
    UIBattlePassGlobal.EffectNumObj.transform:SetParent(modelCachePoolObj.transform)
    UIBattlePassGlobal.MoveAssetObj = ResSys:GetBpEffect("P_BattlePassTargetMover")
    UIBattlePassGlobal.MoveAssetObj.transform:SetParent(modelCachePoolObj.transform)
    UIBattlePassGlobal.EffectNumObjRoot = UIBattlePassGlobal.EffectNumObj.transform:Find("GrpEffectNum/Root").gameObject
    UIBattlePassGlobal.EffectNumAnimator = UIBattlePassGlobal.EffectNumObjRoot:GetComponent(typeof(CS.UnityEngine.Animator))
    UIBattlePassGlobal.EffectNumCollider = UIBattlePassGlobal.EffectNumObjRoot:GetComponent(typeof(CS.UnityEngine.Collider))
    UIBattlePassGlobal.EffectNumGFButton = UIBattlePassGlobal.EffectNumObjRoot:GetComponent(typeof(CS.UnityEngine.UI.GFButton))
    setrotation(UIBattlePassGlobal.EffectNumObj.transform, CS.UnityEngine.Quaternion.Euler(0, -180, 0))
    setactive(UIBattlePassGlobal.EffectNumObjRoot, not UIBattlePassGlobal.IsVideoPlay)
    setactive(UIBattlePassGlobal.EffectNumObj, true)
    UIUtils.GetButtonListener(UIBattlePassGlobal.EffectNumGFButton.gameObject).onClick = fun
  end
end
