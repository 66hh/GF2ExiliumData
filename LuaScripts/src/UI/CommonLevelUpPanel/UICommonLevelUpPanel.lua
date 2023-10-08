require("UI.CommonLevelUpPanel.UICommonLevelUpPanelView")
require("UI.UIBasePanel")
UICommonLevelUpPanel = class("UICommonLevelUpPanel", UIBasePanel)
UICommonLevelUpPanel.__index = UICommonLevelUpPanel
UICommonLevelUpPanel.ShowType = {
  GunLevelUp = 1,
  CommanderLevelUp = 2,
  Settlement = 3
}
UICommonLevelUpPanel.showType = 0
UICommonLevelUpPanel.lvUpData = nil
UICommonLevelUpPanel.callback = nil
UICommonLevelUpPanel.tempLv = "<size=86>Lv.</size>{0}"
UICommonLevelUpPanel.canClose = false
function UICommonLevelUpPanel.Open(type, data, showGet, showAllItems)
  UIManager.OpenUIByParam(UIDef.UICommonLevelUpPanel, {
    type,
    data,
    showGet,
    showAllItems
  })
end
function UICommonLevelUpPanel:ctor(csPanel)
  UICommonLevelUpPanel.super.ctor(UICommonLevelUpPanel, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UICommonLevelUpPanel.Close()
  local self = UICommonLevelUpPanel
  if not self:StopAnimator() then
    UIManager.CloseUI(self.mCSPanel)
    AccountNetCmdHandler.IsLevelUpdate = false
    AccountNetCmdHandler:CleanExpDelta()
  end
end
function UICommonLevelUpPanel:OnRelease()
  self.ui = {}
end
function UICommonLevelUpPanel:OnShow()
end
function UICommonLevelUpPanel:OnInit(root, data)
  AccountNetCmdHandler.IsLevelUpdate = false
  self:SetRoot(root)
  self.mView = UICommonLevelUpPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  if data then
    self.showType = data[1]
    self.showGet = true
    self.showAllItems = false
    if data.Length ~= nil then
      if data.Length >= 4 then
        self.showGet = data[3]
      end
      if data.Length >= 5 then
        self.showAllItems = data[4]
      end
    else
      if data[3] ~= nil then
        self.showGet = data[3]
      end
      if data[4] ~= nil then
        self.showAllItems = data[4]
      end
    end
    if self.showType == UICommonLevelUpPanel.ShowType.CommanderLevelUp then
      self.lvUpData = self:GetCommanderLvUpData()
    elseif self.showType == UICommonLevelUpPanel.ShowType.GunLevelUp then
      self.lvUpData = data[2]
    elseif self.showType == UICommonLevelUpPanel.ShowType.Settlement then
      self.lvUpData = self:GetCommanderLvUpData()
      self.callback = data[2]
    end
  end
  self.super.SetPosZ(self)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    if self.canClose then
      self.Close()
    end
  end
  self:UpdatePanel()
end
function UICommonLevelUpPanel:OnClose()
end
function UICommonLevelUpPanel:UpdatePanel()
  if self.showType == UICommonLevelUpPanel.ShowType.GunLevelUp then
    self:UpdateGunLvUpPanel()
  elseif self.showType == UICommonLevelUpPanel.ShowType.CommanderLevelUp or self.showType == UICommonLevelUpPanel.ShowType.Settlement then
    self:UpdateCommanderLvUpPanel()
  end
end
function UICommonLevelUpPanel:UpdateGunLvUpPanel()
  if self.lvUpData then
    self.ui.mText_Lv.text = string_format(UICommonLevelUpPanel.tempLv, self.lvUpData.level)
    self.ui.mText_BeforeLv.text = string_format(UICommonLevelUpPanel.tempLv, self.lvUpData.beforeLv)
    for _, prop in ipairs(self.lvUpData.propList) do
      local item = LevelUpPropertyItem.New()
      item:InitCtrl(self.ui.mTrans_PropertyList)
      item:SetData(prop)
    end
  end
end
function UICommonLevelUpPanel:UpdateCommanderLvUpPanel()
  if self.lvUpData then
    self.ui.mText_Lv_1.text = self.lvUpData.beforeLv % 10
    self.ui.mText_BeforeLv_1.text = self.lvUpData.beforeLv % 10
    local before = math.floor(self.lvUpData.beforeLv / 10)
    local after = math.floor(self.lvUpData.level / 10)
    self.ui.mText_Lv_2.text = before
    self.ui.mText_BeforeLv_2.text = before
    local showDataList = {}
    local item = {itemId = nil, itemNum = nil}
    local itemCount = 0
    local itemShowList = {}
    for i = self.lvUpData.beforeLv + 1, self.lvUpData.level do
      local levelData = TableData.listPlayerLevelDatas:GetDataById(i)
      for k, v in pairs(levelData.upgrade_reward) do
        if itemShowList[k] then
          itemShowList[k] = itemShowList[k] + v
        else
          itemShowList[k] = v
        end
      end
    end
    for k, v in pairs(itemShowList) do
      item = {itemId = k, itemNum = v}
      table.insert(showDataList, item)
      itemCount = itemCount + 1
    end
    if 1 < itemCount then
      table.sort(showDataList, function(a, b)
        return a.itemId < b.itemId
      end)
    end
    local desc = ""
    local limitUpText = ""
    for k, v in ipairs(showDataList) do
      if v.itemId == 6 then
        limitUpText = string_format(TableData.GetHintById(80326), v.itemNum)
      elseif v.itemId == 101 then
        desc = string_format(TableData.GetHintById(80349), v.itemNum)
      end
    end
    self.ui.mTextName.text = desc
    setactive(self.ui.mText_RewardText.transform.parent, 0 < string.len(limitUpText))
    self.ui.mText_RewardText.text = limitUpText
    UICommonLevelUpPanel.mTimer = TimerSys:DelayCall(1.6, function()
      self.ui.mText_Lv_2.text = after
      self.ui.mText_Lv_1.text = self.lvUpData.level % 10
      self.ui.mAnimText_1:SetTrigger("NumUp")
      if after > before then
        self.ui.mAnimText_2:SetTrigger("NumUp")
      end
      UICommonLevelUpPanel.canClose = true
    end)
    if self.lvUpData.level == self.lvUpData.beforeLv then
      UICommonLevelUpPanel.canClose = true
    else
      UICommonLevelUpPanel.canClose = false
      TimerSys:DelayCall(1, function(idx)
        if self.ui.mTrans_LvUp ~= nil then
          setactive(self.ui.mTrans_LvUp, true)
        end
      end, 0)
    end
  end
end
function UICommonLevelUpPanel:GetCommanderLvUpData()
  local lvUpData = {}
  lvUpData.level = AccountNetCmdHandler:GetLevel()
  if AccountNetCmdHandler.mLevelDelta > 0 then
    lvUpData.beforeLv = lvUpData.level - AccountNetCmdHandler.mLevelDelta
  else
    lvUpData.beforeLv = AccountNetCmdHandler.mLevelPre
  end
  lvUpData.propList = {}
  lvUpData.rewardList = {}
  local prop = {}
  local itemData = TableData.listItemDatas:GetDataById(GlobalConfig.MaxStaminaId)
  local levelData = TableData.listPlayerLevelDatas:GetDataById(lvUpData.level)
  prop.name = itemData.introduction.str
  prop.beforeValue = AccountNetCmdHandler.mMaxStaminaPre
  prop.afterValue = GlobalData.GetStaminaResourceMaxNum(GlobalConfig.StaminaId)
  table.insert(lvUpData.propList, prop)
  for id, value in pairs(levelData.reward_show) do
    local item = {}
    item.ItemId = id
    item.ItemNum = value
    table.insert(lvUpData.rewardList, item)
  end
  return lvUpData
end
function UICommonLevelUpPanel:OpenRewardPanel()
  if self.lvUpData and (self.showType == UICommonLevelUpPanel.ShowType.CommanderLevelUp or self.showType == UICommonLevelUpPanel.ShowType.Settlement) and self.showGet then
    if self.showAllItems then
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        nil,
        self.callback,
        {},
        true
      }, self.mCSPanel.UIGroupType)
    elseif #self.lvUpData.rewardList > 0 then
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        self.lvUpData.rewardList,
        self.callback,
        {}
      }, self.super.mCSPanel.UIGroupType)
    end
  end
end
function UICommonLevelUpPanel:StopAnimator()
  if self.ui.mAnimator and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mAnimator) then
    local animationState = self.ui.mAnimator:GetCurrentAnimatorStateInfo(0)
    if animationState:IsName("UICharacterLevelUpPop") and animationState.normalizedTime < 1 then
      self.ui.mAnimator:Play("UICharacterLevelUpPop", 0, 1)
      return true
    end
  end
  return false
end
