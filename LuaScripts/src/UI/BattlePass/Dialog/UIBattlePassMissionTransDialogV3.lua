require("UI.BattlePass.UIBattlePassGlobal")
UIBattlePassMissionTransDialogV3 = class("UIBattlePassMissionTransDialogV3", UIBasePanel)
UIBattlePassMissionTransDialogV3.__index = UIBattlePassMissionTransDialogV3
function UIBattlePassMissionTransDialogV3:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIBattlePassMissionTransDialogV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.itemTable = {}
  self.needMap = {}
  self.needList = {}
  self.stcDataList = {}
  self.costItemNumList = {}
  self.needNumList = {}
  self.mCurrencyItem = nil
  self.CompareIsNextDay = nil
  self.refreshTime = nil
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListen()
  setactive(self.ui.mText_Description, false)
  setactive(self.ui.mTrans_Top, true)
end
function UIBattlePassMissionTransDialogV3:OnInit(root, data)
  self.data = data
  self.dialogType = data.type
  self.CompareIsNextDay = data.CompareIsNextDay
  self.refreshTime = data.refreshTime
  self.addDailyFlag = false
  self.addShareFlag = false
  local maxNum = 0
  local isAddTask = false
  if self.dialogType == UIBattlePassGlobal.BpTaskDialogType.AddDaily then
    self.ui.mText_TitleText.text = TableData.GetHintById(192024)
    self.needMap = TableData.GlobalSystemData.BattlepassTaskExtraItem
    maxNum = TableData.GlobalSystemData.BattlepassTaskExtraToplimit
    self.addDailyFlag = true
    isAddTask = true
  elseif self.dialogType == UIBattlePassGlobal.BpTaskDialogType.AddShare then
    self.ui.mText_TitleText.text = TableData.GetHintById(192024)
    self.needMap = TableData.GlobalSystemData.BattlepassTaskShareItem
    maxNum = TableData.GlobalSystemData.BattlepassTaskShareToplimit1
    self.addShareFlag = true
    isAddTask = true
  elseif self.dialogType == UIBattlePassGlobal.BpTaskDialogType.RefreshDaily then
    self.ui.mText_TitleText.text = TableData.GetHintById(192025)
    self.needMap = TableData.GlobalSystemData.BattlepassTaskDailyRefreshConsume
    maxNum = TableData.GlobalSystemData.BattlepassTaskDailyRefreshFrequency
    isAddTask = false
  elseif self.dialogType == UIBattlePassGlobal.BpTaskDialogType.RefreshWeek then
    self.ui.mText_TitleText.text = TableData.GetHintById(192025)
    self.needMap = TableData.GlobalSystemData.BattlepassTaskWeeklyRefreshConsume
    maxNum = TableData.GlobalSystemData.BattlepassTaskWeeklyRefreshFrequency
    isAddTask = false
  end
  self:ShowCommonItem(maxNum, isAddTask)
end
function UIBattlePassMissionTransDialogV3:ShowCommonItem(maxNum, isAddTask)
  local extraList = {}
  for i, v in pairs(self.needMap) do
    table.insert(extraList, {id = i, num = v})
  end
  for i = 1, #extraList do
    local item = {}
    if not self.itemTable[i] then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content.transform)
      table.insert(self.itemTable, item)
    else
      item = self.itemTable[i]
    end
    item:SetItemData(extraList[i].id, extraList[i].num)
    item.mUIRoot:SetAsLastSibling()
    local stcData = TableData.GetItemData(extraList[i].id)
    local costItemNum = NetCmdItemData:GetItemCountById(extraList[i].id)
    local needNum = extraList[i].num
    if self.stcDataList[i] then
      self.stcDataList[i] = stcData
    else
      table.insert(self.stcDataList, stcData)
    end
    if self.costItemNumList[i] then
      self.costItemNumList[i] = costItemNum
    else
      table.insert(self.costItemNumList, costItemNum)
    end
    if self.needNumList[i] then
      self.needNumList[i] = needNum
    else
      table.insert(self.needNumList, needNum)
    end
    TipsManager.Add(item.mUIRoot, stcData)
    if self.mCurrencyItem ~= nil then
      self.mCurrencyItem:OnRelease()
    end
    local item = {}
    item.id = stcData.id
    item.jumpID = nil
    item.param = 0
    self.mCurrencyItem = ResourcesCommonItem.New()
    self.mCurrencyItem:InitCtrl(self.ui.mTrans_GrpCurrency.transform, true)
    self.mCurrencyItem:SetData(item)
    setactive(self.ui.mText_Content, true)
    if isAddTask then
      setactive(self.ui.mText_Description, true)
      if self.addShareFlag then
        self.ui.mText_Content.text = string_format(TableData.GetHintById(192105), extraList[i].num, stcData.name)
        self.ui.mText_Description.text = string_format(TableData.GetHintById(192106), self.data.hasNum, self.data.maxnum)
      else
        self.ui.mText_Content.text = string_format(TableData.GetHintById(192039), extraList[i].num, stcData.name)
        self.ui.mText_Description.text = string_format(TableData.GetHintById(192040), self.data.hasNum, self.data.maxnum)
      end
    else
      setactive(self.ui.mText_Description, false)
      if self.dialogType == UIBattlePassGlobal.BpTaskDialogType.RefreshWeek then
        self.ui.mText_Content.text = string_format(TableData.GetHintById(192051), extraList[i].num, stcData.name)
      elseif self.dialogType == UIBattlePassGlobal.BpTaskDialogType.RefreshDaily then
        self.ui.mText_Content.text = string_format(TableData.GetHintById(192050), extraList[i].num, stcData.name)
      end
    end
  end
  self.needList = extraList
end
function UIBattlePassMissionTransDialogV3:OnShowStart()
end
function UIBattlePassMissionTransDialogV3:OnShowFinish()
end
function UIBattlePassMissionTransDialogV3:OnClose()
end
function UIBattlePassMissionTransDialogV3:OnRelease()
  self.ui = nil
  self.mData = nil
  self.itemTable = nil
end
function UIBattlePassMissionTransDialogV3:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIBattlePassMissionTransDialogV3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIBattlePassMissionTransDialogV3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.transform).onClick = function()
    UIManager.CloseUI(UIDef.UIBattlePassMissionTransDialogV3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.transform).onClick = function()
    if self.dialogType == UIBattlePassGlobal.BpTaskDialogType.AddShare or self.dialogType == UIBattlePassGlobal.BpTaskDialogType.AddDaily then
      NetCmdBattlePassData:SendCS_BattlepassGetDailyTask(self.dialogType, self.data.addTaskDialogConfirm)
    else
      for i = 1, #self.needList do
        local stcData = self.stcDataList[i]
        local costItemNum = self.costItemNumList[i]
        local needNum = self.needNumList[i]
        if costItemNum <= needNum then
          CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), stcData.Name.str))
        else
          local isNextDay = false
          if self.CompareIsNextDay ~= nil and self.refreshTime ~= nil then
            isNextDay = self:CompareIsNextDay(self.refreshTime)
          end
          if not isNextDay then
            NetCmdBattlePassData:SendCS_BattlepassRefreshTask(self.data.packData)
          end
        end
      end
    end
    UIManager.CloseUI(UIDef.UIBattlePassMissionTransDialogV3)
  end
end
