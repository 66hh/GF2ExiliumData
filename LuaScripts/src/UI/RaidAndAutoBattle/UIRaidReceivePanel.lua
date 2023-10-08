require("UI.Common.UICommonItem")
require("UI.CommonLevelUpPanel.UICommonLevelUpPanel")
UIRaidReceivePanel = class("UIRaidReceivePanel", UIBasePanel)
function UIRaidReceivePanel.OpenWithCheckPopupDownLeftTips()
  local userDropCacheDict = NetCmdRaidData.ResultData.UserDropCacheDict
  for dropType, userDropCacheList in pairs(userDropCacheDict) do
    for i = 0, userDropCacheList.Count - 1 do
      local userDropCache = userDropCacheList[i]
      if userDropCache.OverflowNum ~= 0 then
        local itemData = TableData.listItemDatas:GetDataById(userDropCache.ItemId)
        local itemTypeData = TableData.listItemTypeDescDatas:GetDataById(itemData.type)
        if itemTypeData.overflow == 1 then
          PopupMessageManager.PopupDownLeftTips(userDropCache.OverflowNum)
        end
      end
    end
  end
  local checkExtraTempTable = {}
  for dropType, userDropCacheList in pairs(userDropCacheDict) do
    for i = 0, userDropCacheList.Count - 1 do
      local userDropCache = userDropCacheList[i]
      local itemData = {}
      itemData.ItemId = userDropCache.ItemId
      itemData.ItemNum = userDropCache.ItemNum
      itemData.RelateId = userDropCache.Relate
      itemData.IsDropUp = userDropCache.DropUp
      if dropType == DropType.ExtraCoin or dropType == DropType.ExtraExpBook or dropType == DropType.ExtraDropPackage then
        itemData.IsExtra = true
      else
        itemData.IsExtra = false
      end
      table.insert(checkExtraTempTable, itemData)
    end
  end
  local rewardDataTable = {}
  local mergedRewardDataTable = {}
  for i, itemData in ipairs(checkExtraTempTable) do
    local itemTableData = TableData.GetItemData(itemData.ItemId)
    local itemTypeData = TableData.listItemTypeDescDatas:GetDataById(itemTableData.type, true)
    if itemTypeData and itemTypeData.pile == 0 then
      table.insert(rewardDataTable, itemData)
    elseif not mergedRewardDataTable[itemData.ItemId] then
      mergedRewardDataTable[itemData.ItemId] = itemData
    else
      mergedRewardDataTable[itemData.ItemId].ItemNum = mergedRewardDataTable[itemData.ItemId].ItemNum + itemData.ItemNum
    end
  end
  for k, itemData in pairs(mergedRewardDataTable) do
    table.insert(rewardDataTable, itemData)
  end
  local specialDrop = NetCmdRaidData.ResultData.SpecialDrop
  if specialDrop then
    for i = 0, specialDrop.Drops.Count - 1 do
      local dropInfo = specialDrop.Drops[i]
      local gradeId = dropInfo.Arg1
      local userDropCacheList = dropInfo.Cache
      local itemData = {}
      for j = 0, userDropCacheList.Count - 1 do
        local userDropCache = userDropCacheList[j]
        itemData.ItemId = userDropCache.ItemId
        itemData.ItemNum = userDropCache.ItemNum
        itemData.GradeId = gradeId
        table.insert(rewardDataTable, itemData)
      end
    end
  end
  local param = {RewardDataTable = rewardDataTable, OnClickClose = nil}
  UIManager.OpenUIByParam(UIDef.UIRaidReceivePanel, param)
end
function UIRaidReceivePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIRaidReceivePanel:OnAwake(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Confirm.gameObject, function()
    self:OnClickClose()
  end)
end
function UIRaidReceivePanel:OnInit(root, param)
  self.rewardDataTable = param.RewardDataTable
  self.onClickClose = param.OnClickClose
  self.itemViewTable = {}
  self.ui.mFadeManager:onItemFadeInEnd("+", self.onItemFadeInEnd)
end
function UIRaidReceivePanel:OnShowStart()
  self.ui.mBtn_Confirm.interactable = false
  self.mCSPanel:SetUIInteractable(false)
  if self.timer then
    self.timer:Stop()
    self.timer = nil
  end
  self.timer = TimerSys:DelayCall(1.5, function(tempSelf)
    tempSelf.ui.mBtn_Confirm.interactable = true
    tempSelf.mCSPanel:SetUIInteractable(true)
  end, self)
  self.ui.mFadeManager:InitFade()
  self:Refresh()
end
function UIRaidReceivePanel:OnHide()
  if self.timer ~= nil then
    self.timer:Stop()
    self.timer = nil
  end
end
function UIRaidReceivePanel:OnClose()
  self:ReleaseCtrlTable(self.itemViewTable, true)
  self.itemViewTable = nil
  self.ui.mFadeManager:onItemFadeInEnd("-", self.onItemFadeInEnd)
end
function UIRaidReceivePanel:OnRelease()
  self.ui = nil
end
function UIRaidReceivePanel:Refresh()
  self:RefreshItemView()
  self:UpdateExpData()
end
function UIRaidReceivePanel:GetItemView(itemId, itemNum, isExtra, gradeId, relateId, isUpItem)
  local itemData = TableData.GetItemData(itemId)
  if itemData == nil then
    return nil
  end
  local itemView
  if itemData.type == 8 then
    local weaponInfoItem = UICommonItem.New()
    weaponInfoItem:InitCtrl(self.ui.mTrans_ItemList)
    weaponInfoItem:SetData(itemData.args[0], 1)
    itemView = weaponInfoItem
  elseif itemData.type == GlobalConfig.ItemType.WeaponPart then
    local weaponPartItem = UICommonItem.New()
    local partData = NetCmdWeaponPartsData:GetWeaponModById(relateId)
    weaponPartItem:InitCtrl(self.ui.mTrans_ItemList)
    weaponPartItem:SetPartData(partData, nil, false)
    weaponPartItem:SetQualityLine(true)
    TipsManager.Add(weaponPartItem.ui.mBtn_Select.gameObject, itemData, 1, false, nil, relateId, nil, nil, true)
    itemView = weaponPartItem
  else
    itemView = UICommonItem.New()
    itemView:InitCtrl(self.ui.mTrans_ItemList)
    if itemData.type == 5 then
      itemView:SetEquipData(itemData.args[0], 0, nil, itemId)
    else
      itemView:SetItemData(itemId, itemNum, nil, nil, nil, relateId)
    end
    itemView:SetExtraIconVisible(isExtra or false)
    if gradeId ~= nil then
      local sprite = IconUtils.GetSimCombatTopRightSprite(gradeId)
      itemView:SetTopRightIconVisible(true)
      itemView:SetTopRightIcon(sprite)
    end
  end
  itemView:SetUpIconVisible(isUpItem == true)
  return itemView
end
function UIRaidReceivePanel:RefreshItemView()
  local itemTable = self.rewardDataTable
  self:SortItemTable(itemTable)
  for _, item in ipairs(itemTable) do
    local itemView = self:GetItemView(item.ItemId, item.ItemNum, item.IsExtra, item.GradeId, item.RelateId, item.IsDropUp)
    table.insert(self.itemViewTable, itemView)
  end
end
function UIRaidReceivePanel:UpdateExpData()
  setactive(self.ui.mTrans_RaidPanel, true)
  local levelUp = AccountNetCmdHandler.mLevelDelta
  local curLevel = AccountNetCmdHandler:GetLevel()
  local beforeLv = curLevel - levelUp
  local maxLevel = TableData.GlobalSystemData.CommanderLevel
  self.ui.mText_ExpAdd.text = "+" .. AFKBattleManager.PlayerExpData:GetAddExp()
  self.ui.mText_Lv.text = "Lv." .. beforeLv
  local notNeedShowExp = beforeLv >= maxLevel
  setactive(self.ui.mTrans_GrpAdd, not notNeedShowExp)
  setactive(self.ui.mImage_ExpBefore, not (curLevel >= maxLevel))
  if notNeedShowExp then
    self.ui.mText_Lv.text = TableData.GetHintById(160012)
    self.ui.mText_Lv.color = ColorUtils.OrangeColor2
    self.ui.mImage_ExpAfter.color = ColorUtils.OrangeColor2
    self.ui.mImage_ExpAfter.fillAmount = 1
    return
  end
  local oldExp = AccountNetCmdHandler:GetOldExpPct()
  self.ui.mImage_ExpAfter.fillAmount = oldExp
  local last_level = oldExp
  local cur_level = AccountNetCmdHandler:GetExpPct()
  local mSequence = CS.LuaDOTweenUtils.SetComRoleLevelUp(self.ui.mImage_ExpBefore, self.ui.mImage_ExpAfter, 0 < levelUp, last_level, cur_level, function()
    if 0 < levelUp then
      UICommonLevelUpPanel.Open(UICommonLevelUpPanel.ShowType.CommanderLevelUp)
    end
    if curLevel >= maxLevel then
      self.ui.mText_Lv.text = TableData.GetHintById(160012)
      self.ui.mText_Lv.color = ColorUtils.OrangeColor2
      self.ui.mImage_ExpAfter.color = ColorUtils.OrangeColor2
      self.ui.mImage_ExpAfter.fillAmount = 1
    end
  end, function()
    self.ui.mText_Lv.text = "Lv." .. curLevel
  end)
  UITweenManager.TweenPlay(mSequence)
end
function UIRaidReceivePanel:SortItemTable(itemTable)
  table.sort(itemTable, function(l, r)
    local data1 = TableData.GetItemData(l.ItemId)
    local data2 = TableData.GetItemData(r.ItemId)
    local typeData1 = TableData.listItemTypeDescDatas:GetDataById(data1.type)
    local typeData2 = TableData.listItemTypeDescDatas:GetDataById(data2.type)
    if l.IsExtra and r.IsExtra then
      if data1.rank == data2.rank then
        if l.GradeId and r.GradeId then
          return l.GradeId > r.GradeId
        elseif l.GradeId then
          return true
        elseif r.GradeId then
          return false
        else
          return data1.id > data2.id
        end
      end
      return data1.rank > data2.rank
    elseif l.IsExtra then
      return true
    elseif r.IsExtra then
      return false
    elseif l.GradeId and r.GradeId then
      return l.GradeId > r.GradeId
    elseif l.GradeId then
      return true
    elseif r.GradeId then
      return false
    else
      if typeData1.rank ~= typeData2.rank then
        return typeData2.rank > typeData1.rank
      end
      if data1.type ~= data2.type then
        return data2.type > data1.type
      end
      if data1.rank ~= data2.rank then
        return data2.rank < data1.rank
      end
      return data1.Id > data2.Id
    end
  end)
end
function UIRaidReceivePanel.onItemFadeInEnd(go)
  local animator = go:GetComponentInChildren(typeof(CS.UnityEngine.Animator))
  if not animator then
    return
  end
  animator:SetTrigger("FadeIn")
end
function UIRaidReceivePanel:OnClickClose()
  UIManager.CloseUI(UIDef.UIRaidReceivePanel)
  if self.onClickClose ~= nil then
    self.onClickClose()
    self.onClickClose = nil
  end
  if AccountNetCmdHandler.IsLevelUpdate then
    UICommonLevelUpPanel.Open(UICommonLevelUpPanel.ShowType.CommanderLevelUp)
  end
end
