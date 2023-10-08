UIRecentActivityTab = class("UIRecentActivityTab", UIBaseCtrl)
function UIRecentActivityTab:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_RecentActivitieItem.gameObject, function()
    self:onClickSelf()
  end)
  self.ui.mCountdown:AddFinishCallback(function(succ)
    self:onTimerEmd(succ)
  end)
  self.ui.mAnimator.keepAnimatorControllerStateOnDisable = true
end
function UIRecentActivityTab:SetData(activityEntranceData, index, onClickCallback)
  self.activityEntranceData = activityEntranceData
  self.planActivityData = TableDataBase.listPlanDatas:GetDataById(activityEntranceData.plan_id)
  self.index = index
  self.onClickCallback = onClickCallback
  if not self.activityEntranceData then
    return
  end
  self.activityConfigData = NetCmdThemeData:GetActivityDataByEntranceId(self.activityEntranceData.id)
  self.activityModuleData = TableData.listActivityModuleDatas:GetDataById(self.activityEntranceData.module_id)
  self.isUnlock = self:IsUnlock()
  self:RefreshTimer()
end
function UIRecentActivityTab:Refresh()
  if not self.activityEntranceData then
    self.ui.mAnimator:SetBool("Unlock", false)
    return
  end
  setactivewithcheck(self.ui.mCountdown, false)
  self.ui.mText_Title.text = self.activityEntranceData.name.str
  if self.activityModuleData and self.activityModuleData.stage_type == 1 then
    self.ui.mText_Tag.text = "预热"
    setactive(self.ui.mTrans_Preheat.gameObject, true)
    NetCmdThemeData:SendThemeActivityInfo(self.activityEntranceData.id, function(ret)
      if ret == ErrorCodeSuc then
        setactive(self.ui.mObj_RedPoint, NetCmdThemeData:ThemeHaveRedPoint(1))
      end
    end)
  else
    self.ui.mText_Tag.text = ""
    setactive(self.ui.mTrans_Preheat.gameObject, false)
    setactive(self.ui.mObj_RedPoint, NetCmdThemeData:ThemeHaveRedPoint(2))
  end
  local isOpenTime = CGameTime:GetTimestamp() >= self.planActivityData.open_time and CGameTime:GetTimestamp() < self.planActivityData.close_time
  local canEnter = isOpenTime and self.isUnlock
  self.ui.mAnimator:SetBool("Unlock", canEnter)
  TimerSys:DelayFrameCall(1, function()
    self.ui.mAnimator:SetBool("Unlock", canEnter)
  end)
  self.ui.mImage_Bg.sprite = IconUtils.GetAtlasSprite("RecentActivitie/" .. self.activityEntranceData.banner_resource)
  self:RefreshTimer()
end
function UIRecentActivityTab:Update()
end
function UIRecentActivityTab:OnRelease(isDestroy)
  self.activityEntranceData = nil
  self.activityConfigData = nil
  self.index = nil
  self.onClickCallback = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UIRecentActivityTab:AddActivityEndCallback(callback)
  self.activityEndCallback = callback
end
function UIRecentActivityTab:GetIndex()
  return self.index
end
function UIRecentActivityTab:GetActivityEntranceData()
  return self.activityEntranceData
end
function UIRecentActivityTab:GetActivityConfigData()
  return self.activityConfigData
end
function UIRecentActivityTab:GetActivityModuleData()
  return self.activityModuleData
end
function UIRecentActivityTab:IsFirstOpen()
  return NetCmdThemeData:GetThemeMessageBoxState(self.activityEntranceData.id) < 1
end
function UIRecentActivityTab:IsUnlock()
  return AccountNetCmdHandler:CheckSystemIsUnLock(self.activityConfigData.unlock_id)
end
function UIRecentActivityTab:RefreshTimer()
  if not self.planActivityData then
    return
  end
  if self.activityModuleData.stage_type == 3 then
    self.ui.mText_Time.text = "已结束"
    setactivewithcheck(self.ui.mCountdown, true)
    return
  end
  self.ui.mCountdown:StartCountdown(self.planActivityData.close_time + 1)
  setactivewithcheck(self.ui.mCountdown, true)
end
function UIRecentActivityTab:onTimerEmd(succ)
  if not succ then
    return
  end
  self:SetVisible(false)
  if self.activityEndCallback then
    self.activityEndCallback(self.index)
  end
end
function UIRecentActivityTab:onClickSelf()
  if not self.isUnlock then
    local lockInfo = TableData.listUnlockDatas:GetDataById(self.activityConfigData.unlock_id)
    if lockInfo then
      local str = UIUtils.CheckUnlockPopupStr(lockInfo)
      PopupMessageManager.PopupString(str)
    end
    return
  end
  local isOpenTime = CGameTime:GetTimestamp() >= self.planActivityData.open_time and CGameTime:GetTimestamp() < self.planActivityData.close_time
  if not isOpenTime then
    local str = TableData.GetHintById(200003)
    CS.PopupMessageManager.PopupString(str)
    return
  end
  if self.onClickCallback then
    self.onClickCallback(self.index)
  end
end
