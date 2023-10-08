require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.MonopolyActivity.SelectInfo.Item.ActivityTourBuffDetailItem")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
ActivityTourInfoItem = class("ActivityTourInfoItem", UIBaseCtrl)
ActivityTourInfoItem.__index = ActivityTourInfoItem
ActivityTourInfoItem.ui = nil
ActivityTourInfoItem.mData = nil
function ActivityTourInfoItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourInfoItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent.transform)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self.roleId = 0
  self.buffList = {}
  self.enemyHeadList = {}
  if not self.oriColor then
    self.oriColor = self.ui.mImg_AvatarBg.color
  end
  setactive(self.ui.mTrans_BuffDetailItem.gameObject, false)
  setactive(self.ui.mTrans_EnemyItem.gameObject, false)
end
function ActivityTourInfoItem:Refresh(roleId)
  local actorData = MonopolyWorld.MpData:GetActorData(roleId)
  if not actorData then
    return
  end
  self.roleId = roleId
  self.showEmpty = true
  local isMonster = actorData.actorType == ActivityTourGlobal.ActorType.Monster
  setactive(self.ui.mText_EnemyTeamInfo.gameObject, isMonster)
  setactive(self.ui.mTrans_EnemyInfo.gameObject, isMonster)
  if not isMonster then
    self:RefreshPlayer(actorData)
  else
    self:RefreshMonster(actorData)
  end
  self:RefreshBuff(actorData)
  setactive(self.ui.mTrans_Empty.gameObject, self.showEmpty)
end
function ActivityTourInfoItem:RefreshPlayer(actorData)
  local gunId = actorData.configId
  local gunData = TableData.listGunDatas:GetDataById(gunId)
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHeadSprite(gunData.code)
  self.ui.mText_AvatarName.text = AccountNetCmdHandler:GetName()
  self.ui.mImg_AvatarBg.color = ColorUtils.BlueColor2
  self.ui.mText_AvatarTeamNum.text = TableData.GetHintById(270300)
  setactive(self.ui.mTrans_EnemyItem.gameObject, false)
end
function ActivityTourInfoItem:RefreshMonster(actorData)
  local monsterActor = MonopolyWorld:GetMonsterActor(self.roleId)
  if monsterActor == nil then
    return
  end
  local mpEnemyData = TableData.listMonopolyEnemyDatas:GetDataById(monsterActor.Data.Id)
  if mpEnemyData == nil then
    return
  end
  local robotId = actorData.configId
  local enemyCfg = TableData.listMonopolyEnemyDatas:GetDataById(robotId)
  self.ui.mImg_Avatar.sprite = IconUtils.GetTourCharacterSprite(enemyCfg.chess_icon)
  self.ui.mText_AvatarName.text = mpEnemyData.name.str
  self.ui.mText_EnemyTeamInfo.text = mpEnemyData.des.str
  self.ui.mImg_AvatarBg.color = ColorUtils.RedColor4
  self.ui.mText_AvatarTeamNum.text = TableData.GetHintById(270299)
  local stageData = TableData.listStageDatas:GetDataById(mpEnemyData.region)
  if stageData == nil then
    return
  end
  local stageConfig = TableData.listStageConfigDatas:GetDataById(stageData.stage_config)
  if stageConfig == nil then
    return
  end
  setactive(self.ui.mTrans_EnemyItem.gameObject, true)
  for i = 1, stageConfig.enemies.Count do
    do
      local item = self.enemyHeadList[i]
      if item == nil then
        item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mTrans_EnemyItem.gameObject)
        self.enemyHeadList[i] = item
      end
      local enemyId = stageConfig.enemies[i - 1]
      local enemyData = TableData.GetEnemyData(enemyId)
      item:SetData(enemyData, stageData.stage_class)
      item:EnableLv(true)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, stageData.stage_class)
      end
    end
  end
  for i = stageConfig.enemies.Count + 1, #self.enemyHeadList do
    setactive(self.enemyHeadList[i]:GetRoot(), false)
  end
  self.showEmpty = false
end
function ActivityTourInfoItem:RefreshBuff(actorData)
  local buffs = actorData.buffs
  local haveBuff = buffs.Count > 0
  local bufNum = buffs.Count
  for i = 1, bufNum do
    if not self.buffList[i] then
      self.buffList[i] = ActivityTourBuffDetailItem.New()
      self.buffList[i]:InitCtrl(self.ui.mTrans_BuffDetailItem.gameObject, self.ui.mTrans_BuffRoot)
    end
    setactive(self.buffList[i]:GetRoot(), true)
    self.buffList[i]:Refresh(buffs[i - 1], i ~= bufNum)
  end
  for i = bufNum + 1, #self.buffList do
    setactive(self.buffList[i]:GetRoot(), false)
  end
  setactive(self.ui.mTrans_BuffRoot.gameObject, haveBuff)
  setactive(self.ui.mTrans_BuffDetails.gameObject, haveBuff)
  if haveBuff then
    self.showEmpty = false
  end
end
function ActivityTourInfoItem:OnRelease()
  self.ui = nil
  self.mData = nil
  for i = 1, #self.buffList do
    self.buffList[i]:OnRelease(true)
  end
  for i = 1, #self.enemyHeadList do
    self.enemyHeadList[i]:OnRelease()
  end
  self.buffList = nil
  self.enemyHeadList = nil
  self.super.OnRelease(self, true)
end
