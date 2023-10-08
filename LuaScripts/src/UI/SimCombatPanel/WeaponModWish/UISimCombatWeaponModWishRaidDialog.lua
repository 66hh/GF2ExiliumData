require("UI.Common.UICommonSimpleView")
require("UI.SimCombatPanel.WeaponModWish.UISimCombatWeaponModWishSelectItem")
require("UI.UIBasePanel")
UISimCombatWeaponModWishRaidDialog = class("UISimCombatWeaponModWishRaidDialog", UIBasePanel)
UISimCombatWeaponModWishRaidDialog.__index = UISimCombatWeaponModWishRaidDialog
local WishStateType = {selectItem = 1, selectRaidTime = 2}
function UISimCombatWeaponModWishRaidDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UISimCombatWeaponModWishRaidDialog:OnInit(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self.wishSelectItem = UISimCombatWeaponModWishSelectItem.New()
  self.wishSelectItem:InitCtrl(self.ui.mTrans_Info)
  self.mData = data
  self.simTypeId = data.SimTypeId
  self.simCombatData = TableData.listSimCombatResourceDatas:GetDataById(data.simCombatID)
  self.simEntranceData = data.simEntranceData
  self:InitRaid()
end
function UISimCombatWeaponModWishRaidDialog:OnShowStart()
  self.wishSelectItem:SetData(self.simCombatData)
  self:ChangeWishState(WishStateType.selectItem)
end
function UISimCombatWeaponModWishRaidDialog:OnShowFinish()
  self.currentCostItemCount = NetCmdItemData:GetNetItemCount(self.mData.costItemId)
end
function UISimCombatWeaponModWishRaidDialog:OnTop()
  self:RefreshTabItem()
end
function UISimCombatWeaponModWishRaidDialog:OnBackForm()
  self:RefreshTabItem()
end
function UISimCombatWeaponModWishRaidDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UISimCombatWeaponModWishRaidDialog)
end
function UISimCombatWeaponModWishRaidDialog:OnClose()
  for i, v in ipairs(self.iconList) do
    gfdestroy(v.obj)
  end
  self.iconList = nil
  self.ui.mSlider.onValueChanged:RemoveListener(self.onSliderValueChangedCallback)
  self.onSliderValueChangedCallback = nil
  self.ui = nil
  self.mview = nil
  self.simCombatData = nil
  self.simEntranceData = nil
  self.wishSelectItem:OnRelease()
  self.wishSelectItem = nil
  self.super.OnClose(self)
end
function UISimCombatWeaponModWishRaidDialog:OnRelease()
  self.super.OnRelease(self)
end
function UISimCombatWeaponModWishRaidDialog:InitBaseData()
  self.mview = UICommonSimpleView.New()
  self.ui = {}
  self.iconList = {}
end
function UISimCombatWeaponModWishRaidDialog:AddBtnListen()
  local f = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = f
  UIUtils.GetButtonListener(self.ui.mBtn_BGClose.gameObject).onClick = f
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = f
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:StartRaid()
  end
  UIUtils.AddBtnClickListener(self.ui.mBtn_Reduce.gameObject, function()
    self:onClickReduce()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Increase.gameObject, function()
    self:onClickIncrease()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Back.gameObject, function()
    self:ChangeWishState(WishStateType.selectItem)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Goto.gameObject, function()
    self:ChangeWishState(WishStateType.selectRaidTime)
  end)
end
function UISimCombatWeaponModWishRaidDialog:InitRaid()
  self.stageData = TableData.listStageDatas:GetDataById(self.simCombatData.id)
  local challengeRemainingNum = self:getRemainingChallengeTimes()
  if challengeRemainingNum == -1 then
    self.maxValue = TableData.GlobalSystemData.RaidOnetimeLimit
  else
    self.maxValue = math.min(TableData.GlobalSystemData.RaidOnetimeLimit, challengeRemainingNum)
  end
  self.minValue = self.maxValue >= 1 and 1 or 0
  self.ui.mBtn_Confirm.interactable = true
  self.ui.mSlider.minValue = self.minValue
  self.ui.mSlider.maxValue = self.maxValue
  self.ui.mSlider.value = self.minValue
  self.ui.mText_MinNum.text = tostring(self.minValue)
  self.ui.mText_MaxNum.text = tostring(self.maxValue)
  self.curRaidTimes = self.minValue
  self.currentCostItemCount = NetCmdItemData:GetNetItemCount(self.mData.costItemId)
  self.itemList = {}
  function self.onSliderValueChangedCallback(num)
    self:onSliderValueChanged(num)
  end
  self.ui.mSlider.onValueChanged:AddListener(self.onSliderValueChangedCallback)
  self:refreshCostIcon()
  self:changeRaidTimes(0)
end
function UISimCombatWeaponModWishRaidDialog:refreshCostIcon()
  local valid = self.mData.costItemId > 0 and 0 < self.mData.costItemNum
  setactive(self.ui.mImg_Icon.transform.parent, valid)
  if valid then
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(self.mData.costItemId)
  end
end
function UISimCombatWeaponModWishRaidDialog:RefreshTabItem()
end
function UISimCombatWeaponModWishRaidDialog:StartRaid()
  if self.curRaidTimes == 0 then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if not TipsManager.CheckStaminaIsEnoughOnly(self.stageData.stamina_cost * self.curRaidTimes) then
    return
  end
  local sendRaidCmd = function()
    NetCmdSimulateBattleData:SendSimCombatWeaponModAssignedDrop(self.stageData.id, self.stageData.type, self.wishSelectItem.selectSuitID, function()
      self.ui.mBtn_Confirm.interactable = false
      NetCmdRaidData:SendRaidCmd(self.stageData.Id, self.curRaidTimes, function(ret)
        self:onResponseRaid(ret)
      end)
    end)
  end
  local remainingExtraDropTimes = self:getExtraDropTimes()
  if remainingExtraDropTimes == -1 or remainingExtraDropTimes == 0 then
    sendRaidCmd()
  elseif remainingExtraDropTimes < self.curRaidTimes then
    local keyTable = {
      AccountNetCmdHandler.Uid,
      "TodayExtraTimes",
      CGameTime.CurGameDateTime.tm_year,
      CGameTime.CurGameDateTime.tm_mon,
      CGameTime.CurGameDateTime.tm_mday,
      self.simEntranceData.id
    }
    local key = table.concat(keyTable)
    local saveStr = PlayerPrefs.GetString(key)
    if saveStr == "" then
      local todayTipsParam = {}
      todayTipsParam[1] = TableData.GetHintById(103095)
      todayTipsParam[2] = function()
        PlayerPrefs.SetString(key, "save")
        sendRaidCmd()
      end
      todayTipsParam[3] = nil
      todayTipsParam[4] = nil
      UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
    else
      sendRaidCmd()
    end
  else
    sendRaidCmd()
  end
end
function UISimCombatWeaponModWishRaidDialog:getExtraDropTimes()
  if not self.simEntranceData then
    return -1
  end
  if self.simEntranceData.ExtraDropCost == 0 then
    return -1
  end
  return NetCmdItemData:GetNetItemCount(self.simEntranceData.ExtraDropCost)
end
function UISimCombatWeaponModWishRaidDialog:onResponseRaid(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  self:CloseFunction()
  local param = {
    OnDuringEndCallback = function()
      self:onDuringEnd()
    end
  }
  UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
  if self.onClickStartRaidCallback then
    self.onClickStartRaidCallback()
  end
end
function UISimCombatWeaponModWishRaidDialog:onDuringEnd()
  UIRaidReceivePanel.OpenWithCheckPopupDownLeftTips()
  MessageSys:SendMessage(UIEvent.OnRaidDuringEnd, self.simTypeId)
end
function UISimCombatWeaponModWishRaidDialog:onClickIncrease()
  if self.curRaidTimes >= self.maxValue then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if self.curRaidTimes >= TableData.GlobalSystemData.RaidOnetimeLimit then
    local hint = TableData.GetHintById(609)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  self:changeRaidTimes(1)
end
function UISimCombatWeaponModWishRaidDialog:onClickReduce()
  self:changeRaidTimes(-1)
end
function UISimCombatWeaponModWishRaidDialog:refreshCurValueText()
  self.ui.mText_CompoundNum.text = self.curRaidTimes
end
function UISimCombatWeaponModWishRaidDialog:refreshSliderValue()
  self.ui.mSlider.value = self.curRaidTimes
end
function UISimCombatWeaponModWishRaidDialog:refreshSliderBtn()
  self.ui.mBtn_Reduce.interactable = self.curRaidTimes ~= self.minValue
  self.ui.mBtn_Increase.interactable = self.curRaidTimes ~= self.maxValue
end
function UISimCombatWeaponModWishRaidDialog:refreshCostText()
  self.ui.mText_CostNum.text = self.mData.costItemNum * self.curRaidTimes
  if self.currentCostItemCount >= self.mData.costItemNum * self.curRaidTimes then
    self.ui.mText_CostNum.color = Color.black
  else
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  end
end
function UISimCombatWeaponModWishRaidDialog:RefreshRewardList()
  self.itemDataTable = {}
  for _, v in ipairs(self.mData.rewardItemList) do
    local itemID = v.id
    local itemNum = v.num
    local rewardNum = itemNum * self.curRaidTimes
    if self.itemDataTable[itemID] == nil then
      self.itemDataTable[itemID] = 0
    end
    self.itemDataTable[itemID] = self.itemDataTable[itemID] + rewardNum
  end
end
function UISimCombatWeaponModWishRaidDialog:onSliderValueChanged()
  local delta = math.ceil(self.ui.mSlider.value) - self.curRaidTimes
  self:changeRaidTimes(delta)
end
function UISimCombatWeaponModWishRaidDialog:changeRaidTimes(delta)
  local targetValue = self.curRaidTimes + delta
  if targetValue > self.maxValue then
    targetValue = self.maxValue
  elseif targetValue < self.minValue then
    targetValue = self.minValue
  end
  self.curRaidTimes = targetValue
  self:onRiadTimesChanged()
end
function UISimCombatWeaponModWishRaidDialog:onRiadTimesChanged()
  self:refreshCurValueText()
  self:refreshSliderValue()
  self:refreshSliderBtn()
  self:refreshCostText()
end
function UISimCombatWeaponModWishRaidDialog:checkNormalDropIsOverflow()
  for itemId, num in pairs(self.itemDataTable) do
    if TipsManager.CheckItemIsOverflow(itemId, num, true) then
      return true
    end
  end
  return false
end
function UISimCombatWeaponModWishRaidDialog:getRemainingChallengeTimes()
  if self.mData.maxSweepsNum then
    return self.mData.maxSweepsNum
  end
  if self.mData.costItemId == 0 or self.mData.costItemNum == 0 then
    return -1
  end
  local itemNum = NetCmdItemData:GetNetItemCount(self.mData.costItemId)
  local result = math.floor(itemNum / self.mData.costItemNum)
  return result
end
function UISimCombatWeaponModWishRaidDialog:ChangeWishState(state)
  setactive(self.ui.mTrans_Info, state == WishStateType.selectItem)
  setactive(self.ui.mTrans_Consume, state == WishStateType.selectRaidTime)
  setactive(self.ui.mBtn_Back.transform.parent, state == WishStateType.selectRaidTime)
  setactive(self.ui.mBtn_Goto.transform.parent, state == WishStateType.selectItem)
  setactive(self.ui.mBtn_Cancel.transform.parent, state == WishStateType.selectItem)
  setactive(self.ui.mBtn_Confirm.transform.parent, state == WishStateType.selectRaidTime)
  local switchNum = state == WishStateType.selectItem and 0 or 1
  self.ui.mAnimator_Title:SetInteger("Switch", switchNum)
  if state == WishStateType.selectRaidTime then
    self:RefreshTitleIcon()
  end
end
function UISimCombatWeaponModWishRaidDialog:RefreshTitleIcon()
  for i, v in ipairs(self.iconList) do
    setactive(v.obj, false)
  end
  if self.wishSelectItem.selectSuitID == nil and self.wishSelectItem.curSelectItem then
    return
  end
  self.ui.mText_SelectSuitName.text = self.wishSelectItem.selectSuitName
  local modSuitPlanIDList = self.wishSelectItem.selectSuitIDList
  local listCount = modSuitPlanIDList.Count
  local index = 1
  for i = 0, listCount - 1 do
    local suitID = modSuitPlanIDList[i]
    local tbData = TableData.listModPowerDatas:GetDataById(suitID, true)
    local modData = TableData.listModPowerEffectDatas:GetDataById(tbData.power_id)
    index = i + 1
    if self.iconList[index] == nil then
      local obj = instantiate(self.ui.mTrans_WeaponPart, self.ui.mTrans_WeaponPart.parent)
      local t = {}
      t.obj = obj
      t.mImg_Icon = obj:GetComponent(typeof(CS.UnityEngine.UI.Image))
      self.iconList[index] = t
    end
    local item = self.iconList[index]
    item.mImg_Icon.sprite = IconUtils.GetIconV2("WeaponPart", modData.image)
    setactive(item.obj, true)
  end
end
