require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.ActivityTour.Btn_ActivityTourEnemyHeadItem")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
ActivityTourEnemyInfoDialog = class("ActivityTourEnemyInfoDialog", UIBasePanel)
ActivityTourEnemyInfoDialog.__index = ActivityTourEnemyInfoDialog
function ActivityTourEnemyInfoDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourEnemyInfoDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:ManualUI()
end
function ActivityTourEnemyInfoDialog:ManualUI()
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourEnemyInfoDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourEnemyInfoDialog)
  end
  self.enemyUIList = {}
  self.enemyHeadList = {}
  self.spineItemList = {}
end
function ActivityTourEnemyInfoDialog:CleanSpineInfo()
  for k, v in pairs(self.spineItemList) do
    ResourceDestroy(v)
    v = nil
  end
  self.spineItemList = {}
end
function ActivityTourEnemyInfoDialog:OnClickItem(item, index)
  if item == self.curItem then
    return
  end
  if self.curItem ~= nil then
    self.curItem:SetBtnSelect(false)
  end
  self.curItem = item
  self.curItem:SetBtnSelect(true)
  self:RefreshRightInfo(index)
end
function ActivityTourEnemyInfoDialog:UpdateSpineIndex(index)
  for k, v in pairs(self.spineItemList) do
    setactive(v, k == index)
  end
end
function ActivityTourEnemyInfoDialog:RefreshRightInfo(index)
  local enemyId = self.enemyDataList[index]
  if enemyId == nil then
    return
  end
  local enemyData = TableData.listMonopolyEnemyDatas:GetDataById(enemyId)
  if enemyData == nil then
    return
  end
  if self.spineItemList[index] == nil then
    ResSys:GetSpineUIObjectAsync(enemyData.spine, function(path, go, data)
      if go ~= nil then
        local spine = go:GetComponent(typeof(CS.GFSpineUI))
        if spine then
          spine:EnableSpineShadow(false)
        end
        self.spineItemList[index] = go
        CS.LuaUIUtils.SetParent(go, self.ui.mTrans_Enemy.gameObject, false)
      end
      self:UpdateSpineIndex(index)
    end)
  else
    self:UpdateSpineIndex(index)
  end
  self.ui.mText_Name.text = enemyData.name.str
  self.ui.mText_Team.text = TableData.GetHintById(270299)
  self.ui.mTextFit_TextDescribe.text = enemyData.des.str
  local stageData = TableData.listStageDatas:GetDataById(enemyData.region)
  if stageData == nil then
    return
  end
  local stageConfig = TableData.listStageConfigDatas:GetDataById(stageData.stage_config)
  if stageConfig == nil then
    return
  end
  for i = 1, stageConfig.enemies.Count do
    do
      local item = self.enemyHeadList[i]
      if item == nil then
        item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mTrans_enemyContent.gameObject)
        table.insert(self.enemyHeadList, item)
      end
      local enemyId = stageConfig.enemies[i - 1]
      local enemyData = TableData.GetEnemyData(enemyId)
      setactive(item.obj, false)
      item:SetData(enemyData, stageData.stage_class)
      item:EnableLv(true)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, stageData.stage_class)
      end
    end
  end
  if #self.enemyHeadList > stageConfig.enemies.Count then
    for i = stageConfig.enemies.Count + 1, #self.enemyHeadList do
      setactive(self.enemyHeadList[i].obj, false)
    end
  end
end
function ActivityTourEnemyInfoDialog:CleanSelectState()
  for i = 1, #self.enemyUIList do
    self.enemyUIList[i]:SetBtnSelect(false)
  end
end
function ActivityTourEnemyInfoDialog:OnInit(root, data)
  self.enemyDataList = NetCmdThemeData:GetEnemyList(data.levelStageData.EnemyList)
  for i = 0, self.enemyDataList.Count - 1 do
    local index = i + 1
    local item
    if index <= #self.enemyUIList then
      item = self.enemyUIList[index]
    else
      item = Btn_ActivityTourEnemyHeadItem.New()
      item:InitCtrl(self.ui.mTrans_Content.gameObject)
      table.insert(self.enemyUIList, item)
    end
    item:UpdateShow(true)
    item:SetData(self.enemyDataList[i])
    UIUtils.GetButtonListener(item.ui.mBtn_Root.gameObject).onClick = function()
      self:OnClickItem(item, i)
    end
  end
  if #self.enemyUIList > self.enemyDataList.Count then
    for i = self.enemyDataList.Count + 1, #self.enemyUIList do
      self.enemyUIList[i]:UpdateShow(false)
    end
  end
  self:OnClickItem(self.enemyUIList[1], 0)
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourEnemyInfoDialog:OnShowStart()
end
function ActivityTourEnemyInfoDialog:OnShowFinish()
end
function ActivityTourEnemyInfoDialog:OnTop()
end
function ActivityTourEnemyInfoDialog:OnBackFrom()
end
function ActivityTourEnemyInfoDialog:OnClose()
  self.curItem = nil
  self:CleanSelectState()
  self:CleanSpineInfo()
end
function ActivityTourEnemyInfoDialog:OnHide()
end
function ActivityTourEnemyInfoDialog:OnHideFinish()
end
function ActivityTourEnemyInfoDialog:OnRelease()
  self.curItem = nil
  self:CleanSelectState()
  self:CleanSpineInfo()
end
