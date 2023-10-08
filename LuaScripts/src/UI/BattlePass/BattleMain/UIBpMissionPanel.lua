require("UI.QuestPanel.UICommonTab")
require("UI.BattlePass.Item.BpMissionListItem")
require("UI.BattlePass.UIBattlePassGlobal")
UIBpMissionPanel = class("UIBpMissionPanel", UIBaseCtrl)
UIBpMissionPanel.__index = UIBpMissionPanel
function UIBpMissionPanel:ctor()
  self.itemList = {}
end
function UIBpMissionPanel:__InitCtrl()
end
function UIBpMissionPanel:InitCtrl(prefab, parent)
  self.obj = instantiate(prefab, parent)
  CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject)
  self:SetRoot(self.obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:__InitCtrl()
  self.mCurPlanOverTime = 0
  self.addSlot = nil
  self.addSlotui = {}
  self.addShareSlot = nil
  self.addShareSlotui = {}
  self.curSlotDataList = nil
  self.curTabIndex = nil
  self:InitBase()
  function self.RefreshFun(sender)
    self:Refresh(true)
    if sender and sender.Sender then
      TimerSys:DelayCall(1.1, function()
        CS.PopupMessageManager.PopupPositiveString(sender.Sender)
      end)
    end
  end
  function self.RefreshFun2()
    self:Refresh(true)
  end
  function self.BPRefreshShareOutTime()
    self:Refresh()
  end
  function self.RefreshOne(sender)
    self:refreshTabRedPoint()
    self.ui.mVirtualListEx:RefreshItem(sender.Sender)
  end
  function self.RefreshAddExp()
    self:Show(true)
  end
  function self.refreshTimeFun(sender)
    self.refreshTime = sender.Sender
  end
  self.refreshTime = NetCmdBattlePassData:GetDailyRefreshTime()
  MessageSys:AddListener(UIEvent.BPRefreshTime, self.refreshTimeFun)
  MessageSys:AddListener(UIEvent.BPRefreshShareOutTime, self.BPRefreshShareOutTime)
  MessageSys:AddListener(UIEvent.BpTaskFish, self.RefreshFun2)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BpGetNewTask, self.RefreshFun)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BpBuyAfterResfresh, self.RefreshFun2)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BpResfresh, self.RefreshAddExp)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BpExpRefreah, self.RefreshAddExp)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BpOnLookClick, self.RefreshOne)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BpTaskReceived, self.RefreshFun)
end
function UIBpMissionPanel:SetTopBtnRedPointFun(fun)
  self.topBtnFun = fun
end
function UIBpMissionPanel:InitBase()
  setactive(self.obj, true)
  self.curSlotDataList = {}
  self.tabTable = {}
  UIUtils.GetButtonListener(self.ui.mBtn_addExp.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UIBattlePassBoughtDialog)
  end
  function self.ui.mVirtualListEx.itemRenderer(index, renderData)
    self:itemRenderer(index, renderData)
  end
  function self.ui.mVirtualListEx.itemProvider()
    return self:itemProvider()
  end
end
function UIBpMissionPanel:SetData(data)
end
function UIBpMissionPanel:Show(expAdd)
  setactive(self.ui.mText_exp, true)
  local battlePassPlan = NetCmdSimulateBattleData:GetPlanByType(CS.GF2.Data.PlanType.PlanFunctionBattlepass)
  self.mCurPlanOverTime = battlePassPlan.CloseTime
  local seasonId = NetCmdBattlePassData.BattlePassId
  local seasonData = TableData.listBpSeasonDatas:GetDataById(seasonId)
  if seasonData == nil then
    return
  end
  if self.curTabIndex == nil then
    self.curTabIndex = UIBattlePassGlobal.BpTaskTypeShow.Daily
  end
  if expAdd then
    local oldExpPercent = NetCmdBattlePassData.BattlePassOldExp / seasonData.upgrade_exp
    local nowExpPercent = NetCmdBattlePassData.BattlePassOverflowExp / seasonData.upgrade_exp
    local oldLevel = NetCmdBattlePassData.BattlePassOldLevel
    local nowLevel = NetCmdBattlePassData.BattlePassLevel
    if NetCmdBattlePassData.BattlePassLevel > 0 then
      LuaDOTweenUtils.SetBattlePassLevelUp(self.ui.mImg_expBar, oldLevel, nowLevel, NetCmdBattlePassData.BattlePassOldExp, NetCmdBattlePassData.BattlePassOverflowExp, seasonData.upgrade_exp, self.ui.mText_lv, self.ui.mText_exp, 1.0, oldExpPercent, nowExpPercent, TableData.GetHintById(192088) .. "{0:D2}", function()
        if NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level then
          setactive(self.ui.mText_exp, false)
          self.ui.mImg_expBar.fillAmount = 1
        end
      end)
    else
      LuaDOTweenUtils.SetBattlePassLevelUp(self.ui.mImg_expBar, oldLevel, nowLevel, NetCmdBattlePassData.BattlePassOldExp, NetCmdBattlePassData.BattlePassOverflowExp, seasonData.upgrade_exp, self.ui.mText_lv, self.ui.mText_exp, 1.0, oldExpPercent, nowExpPercent, TableData.GetHintById(192088), function()
        if NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level then
          setactive(self.ui.mText_exp, false)
          self.ui.mImg_expBar.fillAmount = 1
        end
      end)
    end
  else
    if 0 < NetCmdBattlePassData.BattlePassLevel then
      self.ui.mText_lv.text = TableData.GetHintById(192088) .. string.format("-", tostring(NetCmdBattlePassData.BattlePassLevel))
    else
      self.ui.mText_lv.text = TableData.GetHintById(192088) .. NetCmdBattlePassData.BattlePassLevel
    end
    self.ui.mText_exp.text = NetCmdBattlePassData.BattlePassOverflowExp .. "/" .. seasonData.upgrade_exp
    self.ui.mImg_expBar.fillAmount = NetCmdBattlePassData.BattlePassOverflowExp / seasonData.upgrade_exp
  end
  if NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level then
    self.ui.mText_expFull.text = TableData.GetHintById(192097)
    setactive(self.ui.mText_exp, false)
    self.ui.mImg_expBar.fillAmount = 1
  else
    self.ui.mText_expFull.text = TableData.GetHintById(192087)
  end
  self.curSlotDataList = NetCmdBattlePassData:GetShowDailyQuestList(self.curTabIndex)
  local bpTaskTypeDataList = TableData.listBpTaskTypeClassDatas:GetList()
  for i = 1, 2 do
    if not self.tabTable[i] then
      self.tabTable[i] = UICommonTab.New(instantiate(self.ui.mTrans_leftTab.childItem, self.ui.mTrans_leftTab.transform))
    end
    self.tabTable[i]:InitByBpTaskTypeData(bpTaskTypeDataList[i - 1], i, function()
      self:onClickTab(i)
    end)
    local unlockid = 0
    if self.tabTable[i]:GetUnlockId() then
      unlockid = self.tabTable[i]:GetUnlockId()
    end
    local isUnlock = AccountNetCmdHandler:CheckSystemIsUnLock(unlockid)
    local redPointVisible = isUnlock and NetCmdBattlePassData:CheckIshaveGetReward(self.tabTable[i]:GetType())
    self.tabTable[i]:SetRedPointVisible(redPointVisible)
  end
  self:onClickTab(self.curTabIndex)
end
function UIBpMissionPanel:itemProvider()
  local slot = BpMissionListItem.New(instantiate(self.ui.mTrans_MissionList.childItem, self.ui.mTrans_MissionList.transform))
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = slot:GetRoot().gameObject
  renderDataItem.data = slot
  return renderDataItem
end
function UIBpMissionPanel:itemRenderer(index, renderData)
  local slotData = self.curSlotDataList[index]
  local slot = renderData.data
  slot:SetData(slotData, index + 1, function()
    self:onSlotReceived()
  end, function()
    self:OnDialogCofirm()
  end, self.refreshTime)
end
function UIBpMissionPanel:OnBackFrom()
  self:Show()
end
function UIBpMissionPanel:onClickTab(index)
  if index <= 0 or index > #self.tabTable then
    return
  end
  if self.tabTable[self.curTabIndex] then
    self.tabTable[self.curTabIndex]:Deselect()
  end
  if self.tabTable[index] then
    self.tabTable[index]:Select()
  end
  self:onTabChanged(self.curTabIndex, index)
  self.curTabIndex = index
  self:Refresh()
end
function UIBpMissionPanel:onTabChanged(preTabIndex, curTabIndex)
  if self.tabTable[preTabIndex] then
    self.tabTable[preTabIndex]:Deselect()
  end
  if self.tabTable[curTabIndex] then
    self.tabTable[curTabIndex]:Select()
  end
end
function UIBpMissionPanel:OnUpdate()
  if self.mCurPlanOverTime and self.ui and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mText_countDown) then
    local lastTime = NetCmdBattlePassData:GetWeeklyTime()
    self.ui.mText_countDown.text = lastTime
  end
end
function UIBpMissionPanel:Refresh(EnableFade)
  if not EnableFade then
    self.ui.mMonoScrollerFadeManager_Content.enabled = false
    self.ui.mMonoScrollerFadeManager_Content.enabled = true
    self.ui.mAnimator_Root:SetTrigger("Tab_FadeIn")
  end
  self.curSlotDataList = NetCmdBattlePassData:GetShowDailyQuestList(self.curTabIndex)
  self:refreshTabRedPoint()
  setactive(self.ui.mTrans_TopTip, self.curTabIndex == UIBattlePassGlobal.BpTaskTypeShow.Weekly)
  self.ui.mVirtualListEx.numItems = self.curSlotDataList.Count
  self.ui.mVirtualListEx:Refresh()
end
function UIBpMissionPanel:OnDialogCofirm()
  self.ui.mTrans_Content.anchoredPosition = Vector2(self.ui.mTrans_Content.anchoredPosition.x, 0)
end
function UIBpMissionPanel:OnRefresh()
  gfwarning("UIBpMissionPanel:OnRefresh()")
end
function UIBpMissionPanel:createStdSlot()
end
function UIBpMissionPanel:onClickAdd(bpGetType)
end
function UIBpMissionPanel:OnClickBuyLevel()
  if NetCmdBattlePassData.BattlePassLevel >= NetCmdBattlePassData.CurSeason.max_level then
    local storeGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassExperience)
    if storeGoodData ~= nil and storeGoodData.price_type > 0 then
      local stcData = TableData.GetItemData(storeGoodData.price_type)
      local costItemNum = NetCmdItemData:GetItemCountById(storeGoodData.price_type)
      local maxNum = costItemNum / storeGoodData.price
      if maxNum < 1 then
        local hint = TableData.GetHintById(225)
        hint = string_format(hint, stcData.Name.str)
        CS.PopupMessageManager.PopupPositiveString(hint)
        return
      end
    end
  else
    local storeGoodData = TableData.listStoreGoodDatas:GetDataById(TableData.GlobalConfigData.BattlepassGrade)
    if storeGoodData ~= nil and storeGoodData.price_type > 0 then
      local stcData = TableData.GetItemData(storeGoodData.price_type)
      local costItemNum = NetCmdItemData:GetItemCountById(storeGoodData.price_type)
      local maxNum = costItemNum / storeGoodData.price
      if maxNum < 1 then
        local hint = TableData.GetHintById(225)
        hint = string_format(hint, stcData.Name.str)
        CS.PopupMessageManager.PopupPositiveString(hint)
        return
      end
    end
  end
  UIManager.OpenUI(UIDef.UIBattlePassBoughtDialog)
end
function UIBpMissionPanel:onSlotReceived()
  self:Show(true)
  CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903323))
end
function UIBpMissionPanel:refreshTabRedPoint()
  for i, tab in pairs(self.tabTable) do
    local unlockid = 0
    if tab:GetUnlockId() then
      unlockid = tab:GetUnlockId()
    end
    local redPointVisible = AccountNetCmdHandler:CheckSystemIsUnLock(unlockid) and NetCmdBattlePassData:CheckIshaveGetReward(tab:GetType())
    tab:SetRedPointVisible(redPointVisible)
  end
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.BattlePass)
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.BattlePassTask)
  if self.topBtnFun then
    self:topBtnFun()
  end
end
function UIBpMissionPanel:Hide()
end
function UIBpMissionPanel:Release()
  self.refreshTime = nil
  MessageSys:RemoveListener(UIEvent.BPRefreshTime, self.refreshTimeFun)
  MessageSys:RemoveListener(UIEvent.BpTaskFish, self.RefreshFun2)
  MessageSys:RemoveListener(UIEvent.BPRefreshShareOutTime, self.BPRefreshShareOutTime)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpGetNewTask, self.RefreshFun)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpBuyAfterResfresh, self.RefreshFun2)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpExpRefreah, self.RefreshAddExp)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpResfresh, self.RefreshAddExp)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpOnLookClick, self.RefreshOne)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpTaskReceived, self.RefreshFun)
  gfdestroy(self.obj)
end
function UIBpMissionPanel:CompareIsNextDay(refreshTime)
  local nowTime = CS.CGameTime.ConvertLongToDateTime(CGameTime:GetTimestamp())
  if refreshTime < nowTime then
    MessageBox.ShowMidBtn(TableData.GetHintById(208), TableData.GetHintById(192099), nil, nil, function()
      UIManager.JumpToMainPanel()
    end)
    NetCmdBattlePassData:ClearPlayerPrefs()
    return true
  end
  return false
end
