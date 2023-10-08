require("UI.UIBaseCtrl")
require("UI.SimpleMessageBox.SimpleMessageBoxPanel")
require("UI.UIDarkZoneMapSelectPanel.MapSelectUtils")
UIDarkZoneExplorePanel = class(UIDarkZoneExplorePanel, UIBaseCtrl)
UIDarkZoneExplorePanel.__index = UIDarkZoneExplorePanel
UIDarkZoneExplorePanel.ui = nil
UIDarkZoneExplorePanel.mData = nil
UIDarkZoneExplorePanel.listItem = {}
function UIDarkZoneExplorePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIDarkZoneExplorePanel:InitCtrl(prefab, parent, parentPanel)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.parentPanel = parentPanel
  self.isCostEnough = false
  self.ui.mText_Tips.text = TableData.GetHintById(240063)
  self.canPlayAni = true
  self.animator = UIUtils.GetAnimator(self:GetRoot())
  self:AddBtnListener()
end
function UIDarkZoneExplorePanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.gameObject).onClick = function()
    SimpleMessageBoxPanel.ShowByParam(TableData.GetHintById(240048), TableData.GetHintById(240049))
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnImitate.gameObject).onClick = function()
    if not self.isCostEnough then
      PopupMessageManager.PopupString(TableData.GetHintById(240100))
      return
    end
    self:EnterDarkZoneTeam()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnStart.gameObject).onClick = function()
    if DarkNetCmdStoreData.ExploreRate >= 100 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRaidDialog, self.mData)
    else
      if not self.isCostEnough then
        PopupMessageManager.PopupString(TableData.GetHintById(240100))
        return
      end
      self:EnterDarkZoneTeam()
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_DeepExplore.gameObject).onClick = function()
    if not self.isCostEnough then
      PopupMessageManager.PopupString(TableData.GetHintById(240100))
      return
    end
    self:EnterDarkZoneTeam()
  end
end
function UIDarkZoneExplorePanel:EnterDarkZoneTeam()
  local data = {enterExplore = true}
  DarkZoneNetRepoCmdData:SendCS_DarkZoneStorage(UIManager.OpenUIByParam(UIDef.UIDarkZoneTeamPanelV2, data))
end
function UIDarkZoneExplorePanel:Show()
  if not self.ui then
    return
  end
  self:SetExploreData()
  if not self.mData then
    return
  end
  self:RefreshLevelReward()
  self:RefreshRightBottom()
  self:InitProgress()
  function self.queryCallBack(msg)
    self:UpdatePanel(msg)
  end
  function self.raidCallBack(msg)
    self:OnRaidReward(msg)
  end
  function self.updateCost(msg)
    self:RefreshCost()
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkZoneExporeInfo, self.queryCallBack)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkZoneRaidReward, self.raidCallBack)
  MessageSys:AddListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.updateCost)
  self.parentPanel.animator:ResetTrigger("ExploreMode_FadeOut")
  self.parentPanel.animator:SetTrigger("ExploreMode_FadeIn")
  self.animator:SetTrigger("FadeIn")
  if not self.parentPanel.isTop then
    self.parentPanel.ui.mAnimator_Mode:SetTrigger("MoveLight")
  end
  self:ShowUnlockTip()
end
function UIDarkZoneExplorePanel:OnUpdate(deltatime)
  if not self.curTime or DarkNetCmdStoreData.ExploreRate <= 0 or self.finishProgressAni or 0 >= self.mData.authority then
    return
  end
  local totalTime = 0.3
  if totalTime < self.curTime then
    self.ui.mText_Percentage.text = DarkNetCmdStoreData.ExploreRate .. "%"
    self.finishProgressAni = true
    return
  end
  self.curTime = self.curTime + deltatime
  local avg = DarkNetCmdStoreData.ExploreRate / totalTime
  local curVal = self.curTime * avg
  curVal = curVal > DarkNetCmdStoreData.ExploreRate and DarkNetCmdStoreData.ExploreRate or curVal
  local integer, decimal = math.modf(curVal)
  self.ui.mText_Percentage.text = integer .. "%"
  self:RefreshProgressBg()
end
function UIDarkZoneExplorePanel:RefreshLevelReward()
  self.ui.mText_Text.text = self.mData.authority_des.str
  self.ui.mText_Lv.text = ""
  for _, item in pairs(self.listItem) do
    setactive(item:GetRoot(), false)
  end
  local index = 1
  for i = 0, self.mData.reward.Count - 1 do
    local itemId = tonumber(self.mData.reward[i])
    local itemData = TableData.GetItemData(itemId)
    if itemData then
      local rewardItem = self.listItem[index]
      if rewardItem == nil then
        rewardItem = UICommonItem.New()
        rewardItem:InitCtrl(self.ui.mScrollListChild_Content, true)
        table.insert(self.listItem, rewardItem)
      else
        setactive(rewardItem:GetRoot(), true)
      end
      rewardItem:SetItemData(itemId, 1, false)
      index = index + 1
    end
  end
end
function UIDarkZoneExplorePanel:InitProgress()
  if not self.canPlayAni then
    self.canPlayAni = true
    return
  end
  self.curTime = 0
  self.ui.mText_Percentage.text = ""
  self.finishProgressAni = false
  if not self.mData then
    setactive(self.ui.mTrans_GrpProgress, false)
    return
  end
  if 0 < self.mData.authority then
    self.ui.mText_Percentage.text = "0%"
  end
  self:RefreshProgressBg()
end
function UIDarkZoneExplorePanel:RefreshRightBottom()
  if not self.mData then
    setactive(self.ui.mTrans_GrpBottom, false)
    return
  end
  setactive(self.ui.mTrans_GrpBottom, true)
  local visible = NetCmdAchieveData:CheckComplete(420003)
  setactive(self.ui.mTrans_GrpProgress, visible)
  self:RefreshCost()
  setactive(self.ui.mBtn_DeepExplore.gameObject, DarkNetCmdStoreData.ExploreRate >= 100)
  self.ui.mText_Start.text = DarkNetCmdStoreData.ExploreRate >= 100 and TableData.GetHintById(240114) or TableData.GetHintById(240017)
  setactive(self.ui.mBtn_BtnImitate, self.mData.authority == 0)
  setactive(self.ui.mBtn_BtnStart, self.mData.authority > 0)
end
function UIDarkZoneExplorePanel:RefreshCost()
  if not self.mData then
    return
  end
  self.isCostEnough = false
  for k, v in pairs(self.mData.use_item) do
    local item = tonumber(k)
    local num = tonumber(v)
    self.ui.mImg_Icon.sprite = CS.IconUtils.GetItemIconSprite(item)
    local itemOwn = NetCmdItemData:GetItemCount(item)
    if not self.oriColor then
      self.oriColor = self.ui.mText_Num.color
    end
    self.ui.mText_Num.text = itemOwn .. "/" .. num
    self.ui.mText_Num.color = num <= itemOwn and self.oriColor or ColorUtils.RedColor
    self.isCostEnough = num <= itemOwn
  end
end
function UIDarkZoneExplorePanel:Hide()
  self:ClearData()
  self.parentPanel.animator:ResetTrigger("ExploreMode_FadeIn")
  self.parentPanel.animator:SetTrigger("ExploreMode_FadeOut")
  if not self.parentPanel.isTop then
    self.parentPanel.ui.mAnimator_Mode:SetTrigger("MoveLight")
  end
end
function UIDarkZoneExplorePanel:OnTop()
  self.canPlayAni = false
end
function UIDarkZoneExplorePanel:ClearData()
  self.finishProgressAni = true
  if self.raidCallBack then
    MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkZoneRaidReward, self.raidCallBack)
    self.raidCallBack = nil
  end
  if self.queryCallBack then
    MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkZoneExporeInfo, self.queryCallBack)
    self.queryCallBack = nil
  end
  if self.updateCost then
    MessageSys:RemoveListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.updateCost)
    self.updateCost = nil
  end
end
function UIDarkZoneExplorePanel:OnHide()
  self.parentPanel.animator:ResetTrigger("ExploreMode_FadeIn")
  self.parentPanel.animator:ResetTrigger("ExploreMode_FadeOut")
  self.animator:SetTrigger("FadeOut")
end
function UIDarkZoneExplorePanel:Release()
  self:ClearData()
  self.ui = nil
  self.mData = nil
  self.parentPanel = nil
  self:ReleaseCtrlTable(self.listItem, true)
end
function UIDarkZoneExplorePanel:OnShowFinish()
end
function UIDarkZoneExplorePanel:OnShowStart()
end
function UIDarkZoneExplorePanel:OnBackFrom()
  self:Show()
end
function UIDarkZoneExplorePanel:UpdatePanel(msg)
  self:Show()
end
function UIDarkZoneExplorePanel:OnRaidReward(msg)
  self:RefreshCost()
end
function UIDarkZoneExplorePanel.GetExploreData(level)
  local seasonId = NetCmdDarkZoneSeasonData.SeasonID
  local num = TableData.listDarkzoneSystemExploreDatas.Count
  for i = 0, num - 1 do
    local tmpData = TableData.listDarkzoneSystemExploreDatas:GetDataByIndex(i)
    if tmpData.season == seasonId and tmpData.authority == level then
      return tmpData
    end
  end
end
function UIDarkZoneExplorePanel:SetExploreData()
  local seasonId = NetCmdDarkZoneSeasonData.SeasonID
  self.mData = UIDarkZoneExplorePanel.GetExploreData(DarkNetCmdStoreData.ExploreAuth)
  if not self.mData then
    gferror("can't find DarkzoneSystemExploreData, seasonId = " .. seasonId .. ", level = " .. DarkNetCmdStoreData.ExploreAuth)
  end
  gfdebug("explore key " .. PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewExploreRedPointKey .. seasonId .. "_" .. DarkNetCmdStoreData.ExploreAuth) .. " " .. DarkNetCmdStoreData.ExploreAuth)
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewExploreRedPointKey .. seasonId .. "_" .. DarkNetCmdStoreData.ExploreAuth, 0)
  self.parentPanel.mTopTab[DarkZoneGlobal.PanelType.Explore]:SetRedPoint(false)
end
function UIDarkZoneExplorePanel:RefreshProgressBg()
  if DarkNetCmdStoreData.ExploreRate >= 100 then
    self.ui.mImg_Progress1.sprite = IconUtils.GetDarkZoneModelSprite("Img_DarkzoneExplore_Line3")
    self.ui.mImg_Progress2.sprite = IconUtils.GetDarkZoneModelSprite("Img_DarkzoneExplore_Line3")
  else
    if not self.haveSetProgress then
      local index = math.random(1, 2)
      local path = "Img_DarkzoneExplore_Line" .. index
      self.ui.mImg_Progress1.sprite = IconUtils.GetDarkZoneModelSprite(path)
      self.ui.mImg_Progress2.sprite = IconUtils.GetDarkZoneModelSprite(path)
    end
    self.haveSetProgress = true
  end
end
function UIDarkZoneExplorePanel:ShowUnlockTip()
  if NetCmdAchieveData:CheckComplete(420003) then
    local isUnlock = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.ExploreZoneBeaconUnlock) == 1
    if not isUnlock then
      CS.PopupMessageManager.PopupDZStateChangeString(TableData.GetHintById(240091))
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.ExploreZoneBeaconUnlock, 1)
    end
  end
  if DarkNetCmdStoreData.ExploreRate >= 100 then
    local isUnlock = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.ExploreZoneRaidUnlock) == 1
    if not isUnlock then
      CS.PopupMessageManager.PopupDZStateChangeString(TableData.GetHintById(240093))
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.ExploreZoneRaidUnlock, 1)
    end
  end
end
