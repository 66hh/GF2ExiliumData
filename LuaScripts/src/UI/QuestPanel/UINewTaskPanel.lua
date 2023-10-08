require("UI.UIBasePanel")
require("UI.QuestPanel.NewTaskPhaseLineItem")
require("UI.QuestPanel.UIQuestNewbieSlotV2")
UINewTaskPanel = class("UINewTaskPanel", UIBasePanel)
UINewTaskPanel.__index = UINewTaskPanel
UINewTaskPanel.MileQuestRedPoint = "_MileQuestRedPoint_"
function UINewTaskPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UINewTaskPanel:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self.ui.mAnimator_Receive.keepAnimatorControllerStateOnDisable = true
  function self.onPhaseChangedCallback(msg)
    self:onPhaseChanged(msg)
  end
  self.tmpCacheMile = 2
  self.onOpenComReceive = true
  self:AddEventListener()
  self:InitData()
end
function UINewTaskPanel:AddEventListener()
  MessageSys:AddListener(UIEvent.OnNewbieQuestPhaseChanged, self.onPhaseChangedCallback)
end
function UINewTaskPanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UINewTaskPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_See.gameObject).onClick = function()
    self:ShowMileDetail()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_MileReceive.gameObject).onClick = function()
    self.ui.mBtn_MileReceive.interactable = false
    self:onClickMileReceive()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Receive.gameObject).onClick = function()
    self:onClickReceiveAll()
  end
end
function UINewTaskPanel:InitData()
  self.rewardShowList = {}
  self.phaseLineList = {}
  self.normalQuestList = {}
  self.mileQuest = nil
  self.isPhaseChanged = false
  self.isSlotReceived = false
  self.ui.mText_Receive.text = TableData.GetHintById(112025)
  self.ui.mText_PhaseName.text = TableData.GetHintById(112030)
  self:UpdateShow()
  self.ui.mMile_RedPoint.transform:SetAsLastSibling()
end
function UINewTaskPanel:UpdateShow()
  local curPhase = self:GetCurPhaseId()
  self.ui.mText_PhaseNum.text = string.format("-", curPhase)
  local guidePhaseData = TableData.listGuideQuestPhaseDatas:GetDataById(curPhase)
  self.ui.mText_PhaseRewardName.text = guidePhaseData.des.str
  self.rewardShowList = self:UpdatePhaseRewardList()
  local allPathSprite = IconUtils.GetAtlasSprite(guidePhaseData.RewardShow)
  local rewardLen = string.len(guidePhaseData.RewardShow)
  local rewardSplit = string.split(guidePhaseData.RewardShow, "_")
  setactive(self.ui.mTrans_PhaseFinish, false)
  if rewardSplit[3] ~= nil then
    local targetLen = rewardLen - string.len(rewardSplit[3])
    if string.sub(guidePhaseData.RewardShow, targetLen + 1, targetLen + string.len("Avatar")) == "Avatar" then
      self.ui.mImg_PhaseReward.sprite = allPathSprite
      setactive(self.ui.mImg_PhaseReward, true)
      setactive(self.ui.mImg_PhaseRewardItem, false)
      setactive(self.ui.mImg_PhaseRewardItem.transform.parent, false)
    else
      self.ui.mImg_PhaseRewardItem.sprite = allPathSprite
      setactive(self.ui.mImg_PhaseReward, false)
      setactive(self.ui.mImg_PhaseRewardItem, true)
      setactive(self.ui.mImg_PhaseRewardItem.transform.parent, true)
    end
  end
  self:SetComItemFinish(false)
  local receivedCount = self:GetCurPhaseReceivedSlotCount()
  local totalCount = NetCmdQuestData:GetGuideQuestListDatas(curPhase).Count
  for i = 1, #self.rewardShowList do
    local item = self.rewardShowList[i]
    item:SetPromptEffect(false)
  end
  if receivedCount == totalCount then
    if NetCmdQuestData:CheckNewbiePhaseIsReceived(curPhase) then
      setactive(self.ui.mTrans_State, false)
      setactive(self.ui.mBtn_Receive, false)
    else
      setactive(self.ui.mTrans_State, true)
      local flag = false
      if self.ui.mBtn_Receive.gameObject.activeInHierarchy == false then
        flag = true
      end
      setactive(self.ui.mBtn_Receive, true)
      if flag then
        self.ui.mAnimator_Receive:SetTrigger("FadeIn")
      end
      for i = 1, #self.rewardShowList do
        local item = self.rewardShowList[i]
        item:SetPromptEffect(true)
      end
    end
  else
    setactive(self.ui.mTrans_State, false)
    setactive(self.ui.mBtn_Receive, false)
  end
  self.ui.mText_PhaseProgress.text = string_format(TableData.GetHintById(903232), string.format("-", curPhase))
  self:UpdatePhaseLine()
  self:UpdateMileQuest()
  self:UpdateNomalQuest()
end
function UINewTaskPanel:UpdateMileQuest()
  local curMileNum = self:GetCurMileQuestIndex()
  self.curMileNumCache = curMileNum
  local maxMileNum = self:GetMaxMileQuestId()
  local curMileQuest = self:GetCurMileQuest()
  self.mileQuest = curMileQuest
  local guidequest = curMileQuest
  local tmp = string.split(guidequest.rewardShow, ":")
  setactive(self.ui.mImg_IconItem, false)
  setactive(self.ui.mImg_MileageReward, false)
  local redKey = AccountNetCmdHandler:GetUID() .. UINewTaskPanel.MileQuestRedPoint .. self.mileQuest.Id
  if tmp then
    local cache = PlayerPrefs.GetInt(redKey)
    if cache == 0 then
      setactive(self.ui.mMile_RedPoint, true)
    else
      setactive(self.ui.mMile_RedPoint, false)
    end
    local itemID = tonumber(tmp[1])
    local itemNum = tonumber(string.sub(tmp[2], 1, #tmp[2] - 1))
    local itemData = TableData.listItemDatas:GetDataById(itemID)
    if itemData.type == GlobalConfig.ItemType.Weapon then
      self.ui.mImg_MileageReward.sprite = IconUtils.GetWeaponSpriteL(itemData.icon)
      setactive(self.ui.mImg_MileageReward, true)
      self.ui.mText_MileageReward.text = itemData.name.str
    else
      setactive(self.ui.mImg_IconItem, true)
      self.ui.mImg_IconItem.sprite = IconUtils.GetItemIconSprite(itemID)
      self.ui.mText_MileageReward.text = itemData.name.str .. "×" .. itemNum
    end
  end
  self.ui.mText_MileageTarget.text = guidequest.description
  self.ui.mText_MileagePhase.text = string_format("{0}/{1}", curMileNum, maxMileNum)
  setactive(self.ui.mTrans_Finished, false)
  setactive(self.ui.mBtn_MileReceive.transform.parent.transform, false)
  setactive(self.ui.mBtn_See.transform.parent.transform, false)
  if curMileQuest.isReceived then
    setactive(self.ui.mTrans_Finished, true)
    PlayerPrefs.SetInt(redKey, 1)
    setactive(self.ui.mMile_RedPoint, false)
  elseif curMileQuest.isComplete then
    setactive(self.ui.mBtn_MileReceive.transform.parent.transform, true)
  else
    setactive(self.ui.mBtn_See.transform.parent.transform, true)
  end
end
function UINewTaskPanel:UpdateNomalQuest()
  local curPhase = self:GetCurPhaseId()
  local normalQuest = NetCmdQuestData:GetGuideQuestListDatasByPhase(curPhase, 2)
  for i = 0, normalQuest.Count - 1 do
    local item = self.normalQuestList[i + 1]
    if not item then
      item = UIQuestNewbieSlotV2.New(self.ui.mScrollChild_Mileage.childItem, self.ui.mScrollChild_Mileage.transform)
      table.insert(self.normalQuestList, item)
    end
    item:SetData(normalQuest[i], i + 1, function(ret)
      self:onSlotReceived(ret)
    end, self:GetCurPhaseId())
  end
end
function UINewTaskPanel:UpdatePhaseLine()
  local curPhase = self:GetCurPhaseId()
  local totalPhaseNum = self:GetMaxPhaseId()
  for i = 1, totalPhaseNum do
    local item = self.phaseLineList[i]
    if not item then
      item = NewTaskPhaseLineItem.New(self.ui.mTrans_GrpLine, self.ui.mTrans_GrpLine.transform.parent)
      table.insert(self.phaseLineList, item)
    end
    item:SetData(i <= curPhase)
    if i == curPhase then
      item:SetIsCur(true)
    end
  end
  setactive(self.ui.mTrans_GrpLine, false)
end
function UINewTaskPanel:UpdatePhaseRewardList()
  if self.rewardShowList then
    self:ReleaseCtrlTable(self.rewardShowList, true)
  end
  local tempTable = {}
  local template = self.ui.mScrollChild_Item.childItem
  local guideQuestPhaseData = TableData.listGuideQuestPhaseDatas:GetDataById(self:GetCurPhaseId())
  local rewards = UIUtils.GetKVSortItemTable(guideQuestPhaseData.reward_list)
  for index, pair in pairs(rewards) do
    local id = pair.id
    local num = pair.num
    local itemView = UICommonItem.New()
    itemView:InitCtrl(self.ui.mScrollChild_Item.transform)
    itemView:SetItemData(id, num)
    table.insert(tempTable, itemView)
  end
  return tempTable
end
function UINewTaskPanel:GetCurPhaseDataList(type)
  local phaseId = self:GetCurPhaseId()
  return NetCmdQuestData:GetGuideQuestListDatasByPhase(phaseId, type)
end
function UINewTaskPanel:GetCurPhaseId()
  return NetCmdQuestData:GetCurPhaseId()
end
function UINewTaskPanel:GetCurMileQuestIndex()
  return NetCmdQuestData:GetCurMileQuestIndex()
end
function UINewTaskPanel:GetMaxMileQuestId()
  return NetCmdQuestData:GetMaxMileQuestId()
end
function UINewTaskPanel:GetCurMileQuest()
  return NetCmdQuestData:GetCurMileQuest()
end
function UINewTaskPanel:GetCompletedPhaseNum()
  return NetCmdQuestData:GetCompletedPhaseNum()
end
function UINewTaskPanel:GetMaxPhaseId()
  local dataList = TableData.listGuideQuestPhaseDatas:GetList()
  return dataList[dataList.Count - 1].id
end
function UINewTaskPanel:GetCurPhaseReceivedSlotCount()
  local receivedCount = 0
  local curPhaseSlotDataList = NetCmdQuestData:GetGuideQuestListDatas(self:GetCurPhaseId())
  for k, newbieQuestData in pairs(curPhaseSlotDataList) do
    if newbieQuestData.isReceived then
      receivedCount = receivedCount + 1
    end
  end
  return receivedCount
end
function UINewTaskPanel:onSlotReceived(ret)
  gfdebug("onSlotReceived 1")
  if ret ~= ErrorCodeSuc then
    return
  end
  self.onOpenComReceive = false
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    function()
      self.onOpenComReceive = true
    end
  })
  gfdebug("onSlotReceived last")
  self.isSlotReceived = true
end
function UINewTaskPanel:onClickReceiveAll()
  NetCmdQuestData:SendGuideQuestTakePhaseReward(self:GetCurPhaseId(), function(ret)
    self:onReceivedLeftAll(ret)
  end)
end
function UINewTaskPanel:onReceivedLeftAll(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  self.onOpenComReceive = false
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    function()
      self.onOpenComReceive = true
    end
  })
end
function UINewTaskPanel:ShowMileDetail()
  local redKey = AccountNetCmdHandler:GetUID() .. UINewTaskPanel.MileQuestRedPoint .. self.mileQuest.Id
  PlayerPrefs.SetInt(redKey, 1)
  setactive(self.ui.mMile_RedPoint, false)
  UIManager.OpenUIByParam(UIDef.UINewTaskSeeDialog, self.mileQuest)
end
function UINewTaskPanel:onClickMileReceive()
  for itemId, num in pairs(self.mileQuest.reward_list) do
    if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
      self.ui.mBtn_MileReceive.interactable = true
      return
    end
  end
  NetCmdQuestData:SendGuideQuestTakeReward({
    self.mileQuest.Id
  }, function(ret)
    local redKey = AccountNetCmdHandler:GetUID() .. UINewTaskPanel.MileQuestRedPoint .. self.mileQuest.Id
    PlayerPrefs.SetInt(redKey, 1)
    setactive(self.ui.mMile_RedPoint, false)
    self:onSlotReceived(ret)
    self.ui.mBtn_MileReceive.interactable = true
  end)
end
function UINewTaskPanel:OnShowFinish()
  if self.normalQuestList then
    for i = 1, #self.normalQuestList do
      self.normalQuestList[i]:Refresh()
    end
  end
  self.ui.mMile_RedPoint.transform:SetAsLastSibling()
end
function UINewTaskPanel:OnBackFrom()
  self:OnTop()
end
function UINewTaskPanel:OnTop()
  if self.isPhaseChanged then
    self:ShowPhaseStateChange()
  end
  local stateChange = false
  if self.isSlotReceived then
    stateChange = self:ShowStateChange()
    self.isSlotReceived = false
  end
  local curMileNum = self:GetCurMileQuestIndex()
  if self.curMileNumCache ~= curMileNum and not self.isPhaseChanged and curMileNum == 1 then
    self.ui.mAnimator_Refresh:SetTrigger("RefreshAll")
  elseif self.curMileNumCache ~= curMileNum and not self.isPhaseChanged then
    self.ui.mAnimator_Refresh:SetTrigger("Refresh")
  end
  if self.isPhaseChanged then
    self.isPhaseChanged = false
    setactive(self.ui.mBtn_Receive, false)
    setactive(self.ui.mTrans_PhaseFinish, true)
    setactive(self.ui.mTrans_State, true)
    self:SetComItemFinish(true)
  elseif stateChange then
    self:UpdateMileQuest()
    self:UpdateNomalQuest()
  else
    self:UpdateShow()
  end
end
function UINewTaskPanel:SetComItemFinish(isReceived)
  for i = 1, #self.rewardShowList do
    self.rewardShowList[i]:SetReceivedIcon(isReceived)
  end
end
function UINewTaskPanel:ShowStateChange()
  local curPhase = self:GetCurPhaseId()
  local totalCount = NetCmdQuestData:GetGuideQuestListDatas(curPhase).Count
  local receivedCount = self:GetCurPhaseReceivedSlotCount()
  if totalCount == receivedCount then
    PopupMessageManager.PopupDZStateChangeString(TableData.GetHintById(112031), function()
      self:UpdateShow()
    end)
    return true
  end
  return false
end
function UINewTaskPanel:ShowPhaseStateChange()
  local totalPhaseNum = self:GetMaxPhaseId()
  local completePhaseNum = self:GetCompletedPhaseNum()
  if totalPhaseNum == completePhaseNum then
    PopupMessageManager.PopupOrangeStateChangeString(TableData.GetHintById(112021))
  else
    UIManager.OpenUIByParam(UIDef.UINewTaskNewStageDialog, completePhaseNum + 1)
  end
end
function UINewTaskPanel:onPhaseChanged(msg)
  self.isPhaseChanged = true
end
function UINewTaskPanel:OnClose()
  self.isPhaseChanged = nil
  self.isSlotReceived = nil
  MessageSys:RemoveListener(UIEvent.OnNewbieQuestPhaseChanged, self.onPhaseChangedCallback)
  self:ReleaseCtrlTable(self.rewardShowList, true)
  self:ReleaseCtrlTable(self.normalQuestList, true)
  self:ReleaseCtrlTable(self.phaseLineList, true)
end
function UINewTaskPanel:IsReadyToStartTutorial()
  return self.onOpenComReceive
end
