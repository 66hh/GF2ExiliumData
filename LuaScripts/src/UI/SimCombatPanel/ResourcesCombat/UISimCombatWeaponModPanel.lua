require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourcePanelBase")
UISimCombatWeaponModPanel = class("UISimCombatWeaponModPanel", UISimCombatResourcePanelBase)
function UISimCombatWeaponModPanel:OnInit(root, data, behaviourId)
  self.simEntranceId = StageType.WeaponModStage.value__
  self.super.OnInit(self, root, data, behaviourId)
end
function UISimCombatWeaponModPanel:OnAwake(root, data)
  self.super.OnAwake(self, root, data)
  self.limitCount = 20
  UIUtils.AddBtnClickListener(self.stageDesc.ui.mBtn_Raid.gameObject, function()
    self:onClickRaid()
  end)
  UIUtils.AddBtnClickListener(self.stageDesc.ui.mBtn_BtnStart.gameObject, function()
    self:onClickBattle()
  end)
end
function UISimCombatWeaponModPanel:onClickRaid()
  if not TipsManager.CheckCanRaid(self.stageDesc.stageData) then
    return
  end
  if self.stageDesc.simEntranceData.ItemId > 0 and not TipsManager.CheckTicketIsEnough(1, self.stageDesc.simEntranceData.ItemId) then
    return
  end
  if not TipsManager.CheckStaminaIsEnoughOnly(self.stageDesc.stageData.stamina_cost) then
    TipsManager.ShowBuyStamina()
    return
  end
  if self:CheckItemIsOverflow() then
    return
  end
  local totalNum = CS.GF2.Data.GlobalData.weaponPart_capacity
  local itemCount = NetCmdWeaponPartsData:GetAllMods().Count
  local raidNum = math.floor((totalNum - itemCount) / self.limitCount)
  local tbLimitNum = TableData.GlobalSystemData.RaidOnetimeLimit
  raidNum = math.min(tbLimitNum, raidNum)
  if self.stageDesc.simResourceData.mod_suit_drop_on == 1 then
    local raidLimit = self.stageDesc.simResourceData.weapon_part_raid_limit
    if raidLimit == 1 then
      local t = {}
      t[0] = self.stageList:getCurSlot():GetSimCombatResourceData().id
      t[1] = function(callBack)
        local sendRaidCmd = function(callBack)
          NetCmdRaidData:SendRaidCmd(self.stageDesc.stageData.Id, 1, function(ret)
            if ret ~= ErrorCodeSuc then
              return
            end
            callBack()
            local param = {
              OnDuringEndCallback = function()
                UIRaidReceivePanel.OpenWithCheckPopupDownLeftTips()
                MessageSys:SendMessage(UIEvent.OnRaidDuringEnd, self.stageDesc.simResourceData.sim_type)
              end
            }
            UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
          end)
        end
        local remainingExtraDropTimes = 0
        if self.stageDesc.simEntranceData == nil or self.stageDesc.simEntranceData.ExtraDropCost == 0 then
          remainingExtraDropTimes = -1
        else
          remainingExtraDropTimes = NetCmdItemData:GetNetItemCount(self.stageDesc.simEntranceData.ExtraDropCost)
        end
        if remainingExtraDropTimes == -1 or remainingExtraDropTimes == 0 then
          sendRaidCmd(callBack)
        elseif remainingExtraDropTimes < 1 then
          local keyTable = {
            AccountNetCmdHandler.Uid,
            "TodayExtraTimes",
            CGameTime.CurGameDateTime.tm_year,
            CGameTime.CurGameDateTime.tm_mon,
            CGameTime.CurGameDateTime.tm_mday,
            self.stageDesc.simEntranceData.id
          }
          local key = table.concat(keyTable)
          local saveStr = PlayerPrefs.GetString(key)
          if saveStr == "" then
            local todayTipsParam = {}
            todayTipsParam[1] = TableData.GetHintById(103095)
            todayTipsParam[2] = function()
              PlayerPrefs.SetString(key, "save")
              sendRaidCmd(callBack)
            end
            todayTipsParam[3] = nil
            todayTipsParam[4] = nil
            UIManager.OpenUIByParam(UIDef.UIComTodayTipsDialog, todayTipsParam)
          else
            sendRaidCmd(callBack)
          end
        else
          sendRaidCmd(callBack)
        end
      end
      t[2] = true
      UIManager.OpenUIByParam(UIDef.UISimCombatWeaponModWishDialog, t)
    else
      if 0 < raidLimit then
        raidNum = math.min(raidLimit, raidNum)
      end
      local d = self.stageList:getCurSlot():GetSimCombatResourceData()
      local dropTable = {}
      for i, v in pairs(self.stageDesc.stageData.normal_drop_view_list) do
        local t = {}
        t.id = i
        t.num = v
        table.insert(dropTable, t)
      end
      local t = {}
      t.simCombatID = d.id
      t.costItemId = GlobalConfig.StaminaId
      t.costItemNum = self.stageDesc.stageData.stamina_cost
      t.maxSweepsNum = raidNum
      t.rewardItemList = dropTable
      t.SimTypeId = self.stageDesc.simResourceData.sim_type
      t.simEntranceData = self.stageDesc.simEntranceData
      UIManager.OpenUIByParam(UIDef.UISimCombatWeaponModWishRaidDialog, t)
    end
  else
    self.stageDesc:onClickRaid()
  end
end
function UISimCombatWeaponModPanel:onClickBattle()
  if self:CheckItemIsOverflow() then
    return
  end
  if self.stageDesc.simResourceData.mod_suit_drop_on == 1 then
    local t = {}
    t[0] = self.stageList:getCurSlot():GetSimCombatResourceData().id
    t[1] = function()
      self.stageDesc:onClickBattle()
    end
    UIManager.OpenUIByParam(UIDef.UISimCombatWeaponModWishDialog, t)
  else
    self.stageDesc:onClickBattle()
  end
end
function UISimCombatWeaponModPanel:CheckItemIsOverflow()
  local rewardList = {}
  local isFirst = self.stageDesc:isFirstOfStageBattle()
  if isFirst then
    for itemId, count in pairs(self.stageDesc.stageData.first_reward) do
      if rewardList[itemId] == nil then
        rewardList[itemId] = 0
      end
      rewardList[itemId] = rewardList[itemId] + count
    end
  end
  local normalDropList = self.stageDesc.stageData.normal_drop_view_list
  if 0 < normalDropList.Count then
    for itemId, count in pairs(normalDropList) do
      if rewardList[itemId] == nil then
        rewardList[itemId] = 0
      end
      rewardList[itemId] = rewardList[itemId] + count
    end
  end
  if TipsManager.CheckItemIsOverflowAndStopByList(rewardList, self.limitCount) then
    return true
  end
  return false
end
