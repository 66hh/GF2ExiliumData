UIChrTalentDescSubPanel = class("UIChrTalentDescSubPanel", UIBaseCtrl)
function UIChrTalentDescSubPanel:ctor(root, uiChrTalentPanel)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root.transform)
  self.uiChrTalentPanel = uiChrTalentPanel
  self.ui.mBtn_BtnEquip.interactable = true
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnEquip.gameObject, function()
    self:onClickGotoEquip()
  end)
  self.ui.mBtn_BtnActivated.interactable = true
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnActivated.gameObject, function()
    self:onClickAuthorization()
  end)
  self.ui.mBtn_ReceiveShareItem.interactable = true
  UIUtils.AddBtnClickListener(self.ui.mBtn_ReceiveShareItem.gameObject, function()
    self:onClickReceiveShareItem()
  end)
  setactive(self.ui.mTrans_GrpAttribute, false)
  setactive(self.ui.mImage_QualityLine, true)
  self.attributeTalentKeyTable = {}
  self.attributeTalentPointTable = {}
  self.commonItemTalentKeyTable = {}
  self.commonItemTalentPointTable = {}
end
function UIChrTalentDescSubPanel:NewAttrBar(go)
  local attrBar = {}
  function attrBar:BindGo(root)
    self.root = root
    self.ui = UIUtils.GetUIBindTable(root)
  end
  function attrBar:Show(name, value)
    self.ui.mText_Num.text = value
    self.ui.mText_AttrName.text = name
  end
  function attrBar:SetVisible(visible)
    setactive(self.root, visible)
  end
  function attrBar:OnRelease(isDestroy)
    if isDestroy then
      gfdestroy(self.root)
    end
  end
  attrBar:BindGo(go)
  return attrBar
end
function UIChrTalentDescSubPanel:Init(gunId)
  self.gunId = gunId
end
function UIChrTalentDescSubPanel:SetVisible(visible)
  if visible then
    self:setAnimTrigger("FadeIn")
  end
  self.super.SetVisible(self, visible)
end
function UIChrTalentDescSubPanel:RefreshBySlot(treeId, groupId, level, groupIndex, slotIndex)
  self.treeId = treeId
  self.groupId = groupId
  self.level = level
  self.talentGunData = TableDataBase.listSquadTalentGunDatas:GetDataById(self.gunId)
  local suffix
  if slotIndex < 10 then
    suffix = "0" .. tostring(slotIndex)
  else
    suffix = tostring(slotIndex)
  end
  self.ui.mText_RightNum.text = groupIndex .. "-" .. suffix
  local groupData = TableData.listSquadTalentGroupDatas:GetDataById(groupId)
  local realLv = level
  local showLevel = groupData.level
  if realLv > showLevel then
    showLevel = realLv
  end
  local talentState = UITalentGlobal.GetGunTalentState(self.gunId, self.groupId)
  local talentType = UITalentGlobal.GetTalentType(groupId)
  self:refreshTopBar(talentState, talentType)
  local geneData = UITalentGlobal.GetTargetGeneDataByGroupData(groupData, showLevel)
  if not geneData then
    gferror("targetGeneData is nil!!!")
    return
  end
  self:refreshSlotIcon(geneData, talentType)
  self:refreshTalentDetailBySlot(geneData.PropertyId, geneData.ItemId, talentType)
  self:refreshSlotCost(talentType, talentState, groupData)
  self:refreshTips(talentState, talentType)
  self:refreshGrpBtn(talentState, talentType)
end
function UIChrTalentDescSubPanel:RefreshByInbornTalentSkill()
  self.treeId = nil
  self.groupId = nil
  self.level = nil
  setactive(self.ui.mAnimator_TopBar, false)
  setactive(self.ui.mTrans_GrpPropertyRoot, false)
  setactive(self.ui.mTrans_GrpTalentSkill, false)
  setactive(self.ui.mTrans_GrpInbornSkill, true)
  setactive(self.ui.mImage_QualityLine, false)
  setactive(self.ui.mTrans_GrpPrivateAttribute.parent, false)
  self:refreshSkillAndPropertyCost(nil, nil)
  self:refreshGrpBtn(nil, nil)
  self:refreshTips(nil, nil)
  setactive(self.ui.mBtn_ReceiveShareItem, false)
  self.ui.mText_RightNum.text = "# - 01"
  local talentGunData = TableDataBase.listSquadTalentGunDatas:GetDataById(self.gunId)
  local talentKeyData = TableDataBase.listTalentKeyDatas:GetDataById(talentGunData.InitialTalentKeyId)
  if talentKeyData.talent_key_type == 0 then
    self.ui.mImage_InbornTalentIcon.sprite = IconUtils.GetSkillIcon(talentKeyData.BattleSkillId)
  end
  local skillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(talentKeyData.BattleSkillId)
  self.ui.mTextFit_InbornSkillDesc.text = skillDisplayData.Description.str
end
function UIChrTalentDescSubPanel:RefreshByShareTalentItem()
  self.treeId = nil
  self.groupId = nil
  self.level = nil
  setactive(self.ui.mAnimator_TopBar, false)
  setactive(self.ui.mTrans_Received, false)
  self.ui.mText_RightNum.text = "# - 02"
  local talentGunData = TableDataBase.listSquadTalentGunDatas:GetDataById(self.gunId)
  self.ui.mImage_SkillTalentIcon.sprite = IconUtils.GetItemIconSprite(talentGunData.FullyActiveItemId)
  self:refreshTalentDetailByShareTalentKey(talentGunData.FullyActiveItemId)
  self:refreshSkillAndPropertyCost(nil, nil)
  self:refreshGrpBtn(nil, nil)
  setactive(self.ui.mBtn_ReceiveShareItem, false)
  setactivewithcheck(self.ui.mTrans_GrpTips, false)
  local gunCmdData = NetCmdTeamData:GetGunByID(self.gunId)
  local isReceived = gunCmdData.IsReceivedShareTalentItem
  if isReceived then
    setactive(self.ui.mTrans_Received, true)
    setactivewithcheck(self.ui.mTrans_GrpTips, true)
  else
    local isAllAuthorized = NetCmdTalentData:IsAllAuthorized(self.gunId)
    if isAllAuthorized then
      setactive(self.ui.mBtn_ReceiveShareItem, true)
    else
      setactive(self.ui.mTrans_LockedRoot, true)
      self.ui.mText_Locked.text = TableData.GetHintById(180010)
    end
  end
end
function UIChrTalentDescSubPanel:OnHide()
  self:setAnimTrigger("FadeOut")
end
function UIChrTalentDescSubPanel:OnHideFinish()
  self:SetActive(false)
end
function UIChrTalentDescSubPanel:OnRelease()
  self:ReleaseCtrlTable(self.attributeTalentKeyTable, true)
  self:ReleaseCtrlTable(self.attributeTalentPointTable, true)
  self:ReleaseCtrlTable(self.commonItemTalentKeyTable, true)
  self:ReleaseCtrlTable(self.commonItemTalentPointTable, true)
  self.attributeTalentKeyTable = nil
  self.attributeTalentPointTable = nil
  self.commonItemTalentKeyTable = nil
  self.commonItemTalentPointTable = nil
  self.treeId = nil
  self.groupId = nil
  self.level = nil
  self.super.OnRelease(self)
end
function UIChrTalentDescSubPanel:Refresh()
  local groupData = TableData.listSquadTalentGroupDatas:GetDataById(self.groupId)
  local talentState = UITalentGlobal.GetGunTalentState(self.gunId, self.groupId)
  local talentType = UITalentGlobal.GetTalentType(self.groupId)
  self:refreshTopBar(talentState, talentType)
  self:refreshSlotCost(talentType, talentState, groupData)
  self:refreshGrpBtn(talentState, talentType)
end
function UIChrTalentDescSubPanel:refreshTopBar(talentState, talentType)
  setactive(self.ui.mAnimator_TopBar, true)
  if talentState == UITalentGlobal.TalentState.Lock then
    self.ui.mAnimator_TopBar:SetBool("Bool", false)
  elseif talentState == UITalentGlobal.TalentState.PrevConditionLock then
    self.ui.mAnimator_TopBar:SetBool("Bool", false)
  elseif talentState == UITalentGlobal.TalentState.Unauthorized then
    self.ui.mAnimator_TopBar:SetBool("Bool", false)
  elseif talentState == UITalentGlobal.TalentState.Authorized then
    self.ui.mAnimator_TopBar:SetBool("Bool", true)
  end
  if talentType == UITalentGlobal.TalentType.NormalAttribute then
    self.ui.mText_PointType.text = TableData.GetHintById(180002)
  elseif talentType == UITalentGlobal.TalentType.AdvancedAttribute then
    self.ui.mText_PointType.text = TableData.GetHintById(180002)
  elseif talentType == UITalentGlobal.TalentType.PrivateTalentKey then
    self.ui.mText_PointType.text = TableData.GetHintById(180003)
  end
end
function UIChrTalentDescSubPanel:showSkill(talentKeyId)
  setactivewithcheck(self.ui.mTextFit_TalentSkillDesc, false)
  local itemData = TableDataBase.listItemDatas:GetDataById(talentKeyId)
  self.ui.mText_TalentSkillName.text = itemData.Name.str
  self.ui.mImage_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(itemData.Rank)
  local talentKeyData = TableDataBase.listTalentKeyDatas:GetDataById(talentKeyId)
  if talentKeyData.BattleSkillId > 0 then
    local skillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(talentKeyData.BattleSkillId)
    self.ui.mTextFit_TalentSkillDesc.text = skillDisplayData.Description.str
    setactivewithcheck(self.ui.mTextFit_TalentSkillDesc, true)
  end
end
function UIChrTalentDescSubPanel:showSkillDiff(curLvSkillId, curLevel, nextLvSkillId)
  local curLvSkillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(curLvSkillId)
  local nextLvSkillDisplayData = TableData.listBattleSkillDisplayDatas:GetDataById(nextLvSkillId)
  self.ui.mText_CurLevel.text = TableData.GetHintReplaceById(80057, tostring(curLevel))
  self.ui.mText_CurSkillDesc.text = curLvSkillDisplayData.Description.str
  self.ui.mText_NextLevel.text = TableData.GetHintReplaceById(80057, tostring(curLevel + 1))
  self.ui.mText_NextSkillDesc.text = nextLvSkillDisplayData.Description.str
  setactive(self.ui.mTrans_GrpSkillUp, true)
end
function UIChrTalentDescSubPanel:refreshGrpBtn(talentState, talentType)
  setactive(self.ui.mTrans_LockedRoot, false)
  setactive(self.ui.mTrans_BtnAuthorized, false)
  setactive(self.ui.mBtn_BtnActivated, false)
  setactive(self.ui.mBtn_BtnEquip, false)
  setactive(self.ui.mBtn_ReceiveShareItem, false)
  setactive(self.ui.mTrans_Received, false)
  if talentState == UITalentGlobal.TalentState.Lock then
    local groupData = TableDataBase.listSquadTalentGroupDatas:GetDataById(self.groupId)
    if groupData.UnlockCondition > 0 and not NetCmdAchieveData:CheckComplete(groupData.UnlockCondition) then
      setactive(self.ui.mTrans_LockedRoot, true)
      local achievementDetailData = TableDataBase.listAchievementDetailDatas:GetDataById(groupData.UnlockCondition)
      self.ui.mText_Locked.text = achievementDetailData.des.str
    end
  elseif talentState == UITalentGlobal.TalentState.PrevConditionLock then
    setactive(self.ui.mTrans_LockedRoot, true)
    self.ui.mText_Locked.text = TableData.GetHintById(180006)
  elseif talentState == UITalentGlobal.TalentState.Unauthorized then
    setactive(self.ui.mTrans_AuthorizeRedPoint, NetCmdTalentData:IsCanAuthorizePoint(self.gunId, self.groupId))
    setactive(self.ui.mBtn_BtnActivated, true)
  elseif talentState == UITalentGlobal.TalentState.Authorized then
    if talentType == UITalentGlobal.TalentType.NormalAttribute then
      setactive(self.ui.mTrans_BtnAuthorized, true)
    elseif talentType == UITalentGlobal.TalentType.AdvancedAttribute then
      setactive(self.ui.mTrans_BtnAuthorized, true)
    elseif talentType == UITalentGlobal.TalentType.PrivateTalentKey then
      setactive(self.ui.mTrans_BtnAuthorized, true)
    end
  end
end
function UIChrTalentDescSubPanel:showProperty(attributeItemTable, propertyId, template)
  if propertyId == 0 then
    return
  end
  local usedIndex = 1
  for j = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(j)
    if propertyType then
      local propertyValue = PropertyHelper.GetPropertyValueByEnum(propertyId, propertyType)
      if 0 < propertyValue then
        local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
        if propertyData then
          local name = propertyData.ShowName.str
          local nowValue = propertyValue
          if propertyData.ShowType == 2 then
            nowValue = nowValue / 10
            nowValue = math.floor(nowValue * 10 + 0.5) / 10
            nowValue = nowValue .. "%"
          end
          if usedIndex > #attributeItemTable then
            local go = UIUtils.InstantiateByTemplate(template, template.transform.parent)
            local attrBar = self:NewAttrBar(go)
            table.insert(attributeItemTable, attrBar)
          end
          local attributeScript = attributeItemTable[usedIndex]
          attributeScript:Show(name, nowValue)
          attributeScript:SetVisible(true)
          usedIndex = usedIndex + 1
        end
      end
    end
  end
end
function UIChrTalentDescSubPanel:onClickAuthorization()
  local gunId = self.gunId
  local groupId = self.groupId
  local talentGunData = TableData.listSquadTalentGunDatas:GetDataById(gunId)
  if not AccountNetCmdHandler:CheckSystemIsUnLock(talentGunData.AchievementDetailId) then
    return
  end
  local groupData = TableData.listSquadTalentGroupDatas:GetDataById(groupId)
  for itemId, cost in pairs(groupData.cost) do
    local count = NetCmdItemData:GetItemCount(itemId)
    if cost > count then
      local itemData = TableData.GetItemData(itemId)
      UITipsPanel.Open(itemData, nil, true)
      return
    end
  end
  self.ui.mBtn_BtnActivated.interactable = false
  NetCmdTalentData:ReqGunTalentAuthorization(gunId, groupId, function(ret)
    self.ui.mBtn_BtnActivated.interactable = true
    if ret ~= ErrorCodeSuc then
      return
    end
    self.uiChrTalentPanel:onAuthorize(groupId)
  end)
end
function UIChrTalentDescSubPanel:onClickReceiveShareItem()
  local isAllAuthorized = NetCmdTalentData:IsAllAuthorized(self.gunId)
  if not isAllAuthorized then
    return
  end
  local gunCmdData = NetCmdTeamData:GetGunByID(self.gunId)
  if gunCmdData.IsReceivedShareTalentItem then
    return
  end
  self.ui.mBtn_ReceiveShareItem.interactable = false
  NetCmdTalentData:ReqReceiveGunShareSkillItem(self.gunId, function(ret)
    if ret ~= ErrorCodeSuc then
      return
    end
    self.ui.mBtn_ReceiveShareItem.interactable = true
    gunCmdData:SetIsGetShareTalentItem()
    self:RefreshByShareTalentItem()
    self.uiChrTalentPanel:onReceivedShareSkillItem()
  end)
end
function UIChrTalentDescSubPanel:refreshTips(talentState, talentType)
  setactive(self.ui.mTrans_GrpTips, talentType == UITalentGlobal.TalentType.PrivateTalentKey and talentState == UITalentGlobal.TalentState.Authorized)
end
function UIChrTalentDescSubPanel:refreshSlotCost(talentType, talentState, groupData)
  if talentType == UITalentGlobal.TalentType.NormalAttribute then
    self:refreshPropertyCost(talentState, groupData)
  elseif talentType == UITalentGlobal.TalentType.AdvancedAttribute then
    self:refreshPropertyCost(talentState, groupData)
  elseif talentType == UITalentGlobal.TalentType.PrivateTalentKey then
    self:refreshSkillAndPropertyCost(talentState, groupData)
  end
end
function UIChrTalentDescSubPanel:refreshPropertyCost(talentState, groupData)
  setactive(self.ui.mTrans_GrpConsumeBar2, false)
  setactive(self.ui.mScrollListChildItem_Consume2, false)
  for i, commonItem in ipairs(self.commonItemTalentPointTable) do
    commonItem:SetVisible(false)
  end
  if talentState == UITalentGlobal.TalentState.Lock then
  elseif talentState == UITalentGlobal.TalentState.PrevConditionLock then
  elseif talentState == UITalentGlobal.TalentState.Unauthorized then
    local kvPairList = LuaUtils.SortItemByDict(groupData.cost)
    local userIndex = 1
    for itemId, cost in pairs(kvPairList) do
      if itemId == 2 then
        self.ui.mText_CostNum2.text = UIUtils.GetIfNotEnoughTextWithDigit(itemId, cost)
        self.ui.mImage_CostIcon2.sprite = IconUtils.GetItemIconSprite(itemId)
        UIUtils.GetButtonListener(self.ui.mTrans_GrpConsumeBar2.gameObject).onClick = function()
          local itemData = TableData.GetItemData(itemId)
          UITipsPanel.Open(itemData, 0, true)
        end
        setactive(self.ui.mTrans_GrpConsumeBar2, true)
      else
        if userIndex > #self.commonItemTalentPointTable then
          local commonItemNew = UICommonItem.New()
          commonItemNew:InitCtrl(self.ui.mScrollListChildItem_Consume2)
          table.insert(self.commonItemTalentPointTable, commonItemNew)
        end
        local commonItem = self.commonItemTalentPointTable[userIndex]
        commonItem:SetItemData(itemId, cost, true, true, nil, nil, nil, nil, nil, nil, nil, true)
        local itemOwn = NetCmdItemData:GetItemCountById(itemId)
        commonItem:SetCostItemNum(itemOwn, cost)
        commonItem:SetVisible(true)
        setactivewithcheck(self.ui.mScrollListChildItem_Consume2, true)
        userIndex = userIndex + 1
      end
    end
  elseif talentState == UITalentGlobal.TalentState.Authorized then
  end
end
function UIChrTalentDescSubPanel:refreshSkillAndPropertyCost(talentState, groupData)
  setactive(self.ui.mTrans_GrpConsumeBar1, false)
  setactive(self.ui.mScrollListChildItem_Consume1, false)
  for i, commonItem in ipairs(self.commonItemTalentKeyTable) do
    commonItem:SetVisible(false)
  end
  if talentState == UITalentGlobal.TalentState.Lock then
  elseif talentState == UITalentGlobal.TalentState.PrevConditionLock then
  elseif talentState == UITalentGlobal.TalentState.Unauthorized then
    local kvPairList = LuaUtils.SortItemByDict(groupData.cost)
    local userIndex = 1
    for itemId, cost in pairs(kvPairList) do
      if itemId == 2 then
        self.ui.mText_CostNum1.text = UIUtils.GetIfNotEnoughTextWithDigit(itemId, cost)
        self.ui.mImage_CostIcon1.sprite = IconUtils.GetItemIconSprite(itemId)
        UIUtils.GetButtonListener(self.ui.mTrans_GrpConsumeBar1.gameObject).onClick = function()
          local itemData = TableData.GetItemData(itemId)
          UITipsPanel.Open(itemData, 0, true)
        end
        setactive(self.ui.mTrans_GrpConsumeBar1, true)
      else
        if userIndex > #self.commonItemTalentKeyTable then
          local commonItemNew = UICommonItem.New()
          commonItemNew:InitCtrl(self.ui.mScrollListChildItem_Consume1)
          table.insert(self.commonItemTalentKeyTable, commonItemNew)
        end
        local commonItem = self.commonItemTalentKeyTable[userIndex]
        commonItem:SetItemData(itemId, cost, true, true, nil, nil, nil, nil, nil, nil, nil, true)
        local itemOwn = NetCmdItemData:GetItemCountById(itemId)
        commonItem:SetCostItemNum(itemOwn, cost)
        setactivewithcheck(self.ui.mScrollListChildItem_Consume1, true)
        userIndex = userIndex + 1
      end
    end
  elseif talentState == UITalentGlobal.TalentState.Authorized then
  end
end
function UIChrTalentDescSubPanel:refreshSlotIcon(geneData, talentType)
  if talentType == UITalentGlobal.TalentType.NormalAttribute then
    self.ui.mImage_PropertyTalentIcon.sprite = self:getPropertyIcon(geneData.PropertyId)
    TimerSys:DelayFrameCall(1, function(data)
      self.ui.mAnimator_Property:SetInteger("State", 0)
    end)
  elseif talentType == UITalentGlobal.TalentType.AdvancedAttribute then
    self.ui.mImage_PropertyTalentIcon.sprite = self:getPropertyIcon(geneData.PropertyId)
    TimerSys:DelayFrameCall(1, function(data)
      self.ui.mAnimator_Property:SetInteger("State", 1)
    end)
  elseif talentType == UITalentGlobal.TalentType.PrivateTalentKey then
    self.ui.mAnimator_Property:SetInteger("State", 2)
    self.ui.mImage_SkillTalentIcon.sprite = IconUtils.GetItemIconSprite(geneData.ItemId)
  end
end
function UIChrTalentDescSubPanel:refreshTalentDetailBySlot(propertyId, talentItemId, talentType)
  setactive(self.ui.mTrans_GrpPropertyRoot, false)
  setactive(self.ui.mTrans_GrpTalentSkill, false)
  setactive(self.ui.mTrans_GrpInbornSkill, false)
  setactive(self.ui.mTrans_GrpPrivateAttribute.parent, false)
  if talentType == UITalentGlobal.TalentType.NormalAttribute then
    self:showProperty(self.attributeTalentPointTable, propertyId, self.ui.mTrans_GrpAttribute)
    setactive(self.ui.mTrans_GrpPropertyRoot, true)
  elseif talentType == UITalentGlobal.TalentType.AdvancedAttribute then
    self:showProperty(self.attributeTalentPointTable, propertyId, self.ui.mTrans_GrpAttribute)
    setactive(self.ui.mTrans_GrpPropertyRoot, true)
  elseif talentType == UITalentGlobal.TalentType.PrivateTalentKey then
    for i, attributeScript in ipairs(self.attributeTalentKeyTable) do
      attributeScript:SetVisible(false)
    end
    local talentKeyData = TableDataBase.listTalentKeyDatas:GetDataById(talentItemId)
    if talentKeyData.PropertyId ~= 0 then
      setactive(self.ui.mTrans_GrpPrivateAttribute.parent, true)
      self:showProperty(self.attributeTalentKeyTable, talentKeyData.PropertyId, self.ui.mTrans_GrpPrivateAttribute)
    end
    if talentItemId ~= 0 then
      self:showSkill(talentItemId)
    end
    setactive(self.ui.mTrans_GrpTalentSkill, true)
  end
end
function UIChrTalentDescSubPanel:refreshTalentDetailByShareTalentKey(talentItemId)
  setactive(self.ui.mTrans_GrpPropertyRoot, false)
  setactive(self.ui.mTrans_GrpTalentSkill, true)
  setactive(self.ui.mTrans_GrpInbornSkill, false)
  setactive(self.ui.mTrans_GrpPrivateAttribute.parent, false)
  for i, attributeScript in ipairs(self.attributeTalentKeyTable) do
    attributeScript:SetVisible(false)
  end
  local talentKeyData = TableDataBase.listTalentKeyDatas:GetDataById(talentItemId)
  if talentKeyData.PropertyId ~= 0 then
    setactive(self.ui.mTrans_GrpPrivateAttribute.parent, true)
    self:showProperty(self.attributeTalentKeyTable, talentKeyData.PropertyId, self.ui.mTrans_GrpPrivateAttribute)
  end
  if talentItemId ~= 0 then
    self:showSkill(talentItemId)
  end
end
function UIChrTalentDescSubPanel:getPropertyIcon(propertyId)
  local propertyTypeName = PropertyHelper.GetOnlyOnePropty(propertyId)
  local propertyData = TableData.GetPropertyDataByName(propertyTypeName)
  return IconUtils.GetAttributeIcon(propertyData.icon)
end
function UIChrTalentDescSubPanel:OnSwitchGun()
  self:SetVisible(true)
  self:setAnimTrigger("Switch")
end
function UIChrTalentDescSubPanel:setAnimTrigger(triggerName)
  self.ui.mAnimator_Root:SetTrigger(triggerName)
end
function UIChrTalentDescSubPanel:onClickGotoEquip()
  UIManager.OpenUIByParam(UIDef.UIGunTalentAssemblyPanel, {
    self.gunId,
    false
  })
end
