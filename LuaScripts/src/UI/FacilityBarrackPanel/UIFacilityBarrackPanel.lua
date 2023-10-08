require("UI.UIBasePanel")
UIFacilityBarrackPanel = class("UIFacilityBarrackPanel", UIBasePanel)
UIFacilityBarrackPanel.__index = UIFacilityBarrackPanel
local self = UIFacilityBarrackPanel
UIFacilityBarrackPanel.mView = nil
UIFacilityBarrackPanel.gunDataList = {}
UIFacilityBarrackPanel.gunList = {}
UIFacilityBarrackPanel.gunItemList = {}
UIFacilityBarrackPanel.gunShowList = {}
UIFacilityBarrackPanel.dutyList = {}
UIFacilityBarrackPanel.curType = nil
UIFacilityBarrackPanel.ItemDataList = {}
UIFacilityBarrackPanel.sortList = {}
UIFacilityBarrackPanel.curSort = nil
UIFacilityBarrackPanel.sortPointer = nil
UIFacilityBarrackPanel.sortListObj = nil
function UIFacilityBarrackPanel:ctor()
  UIFacilityBarrackPanel.super.ctor(self)
end
function UIFacilityBarrackPanel:Close()
  UIManager.CloseUI(UIDef.UIFacilityBarrackPanel)
end
function UIFacilityBarrackPanel.ClearUIRecordData()
end
function UIFacilityBarrackPanel:OnInit(root, data)
  UIFacilityBarrackPanel.super.SetRoot(UIFacilityBarrackPanel, root)
  self = UIFacilityBarrackPanel
  self.mView = UIFacilityBarrackPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  if data == nil then
    self.assistFlag = false
  else
    self.assistFlag = data
    self.autoSelectDutyId = data.AutoSelectDutyId
  end
  MessageSys:AddListener(5002, self.OnQuickBuyCallback)
  FacilityBarrackGlobal:ParseSortType()
  UIUtils.GetButtonListener(self.ui.mBtn_BackItem.gameObject).onClick = function()
    UIFacilityBarrackPanel:OnReturnClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_HomeItem.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  end
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BackItem)
  self.ui.virtualist.itemProvider = self.ItemProvider
  self.ui.virtualist.itemRenderer = self.ItemRenderer
end
function UIFacilityBarrackPanel:OnRecover()
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  self:OnShowStart()
end
function UIFacilityBarrackPanel:OnShowStart()
  self:InitDutyList()
  self:InitGunList()
  self:InitSortContent()
  self.curSort = self.sortList[1]
  self.curSort.txtName.color = self.textcolor.AfterSelected
  setactive(self.curSort.grpset, true)
  for i = 1, #self.sortList do
    if self.sortList[i] ~= self.curSort then
      self.sortList[i].txtName.color = self.textcolor.BeforeSelected
      setactive(self.sortList[i].grpset, false)
    else
      self.sortList[i].txtName.color = self.textcolor.AfterSelected
      setactive(self.sortList[i].grpset, true)
    end
  end
  self:OnClickDuty(self.curType)
  setactive(self.ui.mList_Card, true)
  if self.autoSelectDutyId then
    self:ClickGunByFirstDutyId(self.autoSelectDutyId)
    self.autoSelectDutyId = nil
  end
end
function UIFacilityBarrackPanel:OnShowFinish()
  self:UpdateGunList()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
end
function UIFacilityBarrackPanel:OnClose()
  if self.sortListObj then
    gfdestroy(self.sortListObj.gameObject)
  end
  self:ReleaseCtrlTable(self.dutyList, true)
end
function UIFacilityBarrackPanel:OnRelease()
  self = UIFacilityBarrackPanel
  UIFacilityBarrackPanel.gunDataList = {}
  UIFacilityBarrackPanel.gunList = {}
  UIFacilityBarrackPanel.gunItemList = {}
  UIFacilityBarrackPanel.gunShowList = {}
  UIFacilityBarrackPanel.dutyList = {}
  UIFacilityBarrackPanel.curType = nil
  UIFacilityBarrackPanel.sortList = {}
  UIFacilityBarrackPanel.curSort = nil
  UIFacilityBarrackPanel.sortPointer = nil
  UIFacilityBarrackPanel.ui.virtualist.AllowChangeName = false
  MessageSys:RemoveListener(5002, self.OnQuickBuyCallback)
  FacilityBarrackGlobal:SaveSortType()
  self.autoSelectDutyId = nil
end
function UIFacilityBarrackPanel:OnHide()
  UIFacilityBarrackPanel.ui.virtualist.AllowChangeName = false
end
function UIFacilityBarrackPanel.OnQuickBuyCallback()
  self = UIFacilityBarrackPanel
  printstack("快速購買刷新")
  self:UpdateLockInfo(self.CurrentGun)
end
function UIFacilityBarrackPanel:OnReturnClick()
  if self.ui.mAnimator then
    self.ui.mAnimator:SetBool("ComPage_FadeOut", true)
    self:Close()
  end
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
end
function UIFacilityBarrackPanel:OnGunClick(gun)
  if gun then
    UIManager.OpenUIByParam(UIDef.UICharacterDetailPanel, gun.tableData.id)
  end
end
function UIFacilityBarrackPanel:OnClickGunById(gunId, tabId)
  local param = {}
  param.GunId = gunId
  param.TabId = tabId
  UIManager.OpenUIByParam(UIDef.UICharacterDetailPanel, param)
end
function UIFacilityBarrackPanel:OnClickDuty(item)
  if item then
    if self.curType and self.curType.type ~= item.type then
      self.curType.mBtn.interactable = true
    end
    self.curType = item
    self.curType.mBtn.interactable = false
    self:OnClickSort(self.curSort.sortType)
  end
end
function UIFacilityBarrackPanel:OnClickSortList()
  setactive(self.ui.mTrans_SortList, true)
end
function UIFacilityBarrackPanel:CloseItemSort()
  setactive(self.ui.mTrans_SortList, false)
end
function UIFacilityBarrackPanel:OnClickSort(type)
  if type then
    if self.curSort and self.curSort.sortType ~= type then
      self.curSort.txtName.color = self.textcolor.BeforeSelected
      setactive(self.curSort.grpset, false)
    else
    end
    self.curSort = self.sortList[type]
    self.curSort.txtName.color = self.textcolor.AfterSelected
    setactive(self.curSort.grpset, true)
    FacilityBarrackGlobal:SetSortType(self.curSort)
    self:UpdateGunList()
    self:CloseItemSort()
  end
end
function UIFacilityBarrackPanel:OnClickAscend()
  if self.curSort then
    self.curSort.isAscend = not self.curSort.isAscend
    FacilityBarrackGlobal:SetSortType(self.curSort)
    self:UpdateGunList()
  end
end
function UIFacilityBarrackPanel:RefreshGunList(list)
  for _, gun in ipairs(list) do
    if gun then
      gun:UpdateData()
    end
  end
end
function UIFacilityBarrackPanel.ItemProvider()
  self = UIFacilityBarrackPanel
  local itemView = UIBarrackCardDisplayItem.New()
  itemView:InitCtrl(self.ui.mContent_Card.transform)
  self.ui.mTrans_Empty:SetAsLastSibling()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIFacilityBarrackPanel.ItemRenderer(index, renderData)
  self = UIFacilityBarrackPanel
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  if data.TabGunData ~= nil then
    item.mUIRoot.name = data.TabGunData.Code
  else
    item.mUIRoot.name = "Recyle_" .. index
  end
  item:SetBaseData(data.id)
  UIUtils.GetButtonListener(item.mBtn_Gun.gameObject).onClick = function()
    self = UIFacilityBarrackPanel
    self:OnGunClick(item)
  end
end
function UIFacilityBarrackPanel:UpdateGunList()
  local hasNewItem = false
  self.gunList = self:GetGunListByDuty(self.curType.type)
  local sortFunc = FacilityBarrackGlobal:GetSortFunc(1, self.curSort.sortCfg, self.curSort.isAscend)
  table.sort(self.gunList, sortFunc)
  self.ItemDataList = {}
  if self.gunList then
    for i = 1, #self.gunList do
      local data = self.gunList[i]
      table.insert(self.ItemDataList, data)
    end
  end
  self.ui.virtualist.numItems = #self.ItemDataList
  self.ui.virtualist:Refresh()
  setactive(self.ui.mMonoScrollerFadeManager_Content.gameObject, false)
  setactive(self.ui.mMonoScrollerFadeManager_Content.gameObject, true)
end
function UIFacilityBarrackPanel:GetGunListByDuty(duty)
  if duty then
    local tempGunList = {}
    if duty == 0 then
      for _, gunList in pairs(self.gunDataList) do
        if gunList then
          for _, gunId in ipairs(gunList) do
            local data = NetCmdTeamData:GetGunByID(gunId)
            if data == nil then
              data = FacilityBarrackGlobal:GetLockGunData(gunId)
            end
            table.insert(tempGunList, data)
          end
        end
      end
    else
      local gunIdList = self.gunDataList[duty]
      if gunIdList then
        for _, gunId in ipairs(gunIdList) do
          local data = NetCmdTeamData:GetGunByID(gunId)
          if data == nil then
            data = FacilityBarrackGlobal:GetLockGunData(gunId)
          end
          table.insert(tempGunList, data)
        end
      end
    end
    return tempGunList
  end
  return nil
end
function UIFacilityBarrackPanel:InitGunList()
  self.gunDataList = {}
  for i = 0, TableData.listGunDatas.Count - 1 do
    local gunData = TableData.listGunDatas[i]
    if self.gunDataList[gunData.duty] == nil then
      self.gunDataList[gunData.duty] = {}
    end
    table.insert(self.gunDataList[gunData.duty], gunData.id)
  end
end
function UIFacilityBarrackPanel:InitDutyList()
  self.dutyList = {}
  local dutyDataList = {}
  local data = {}
  data.id = 0
  table.insert(dutyDataList, data)
  local list = TableData.listGunDutyDatas:GetList()
  for i = 0, list.Count - 1 do
    local data = list[i]
    table.insert(dutyDataList, data)
  end
  for i = 1, #dutyDataList do
    do
      local data = dutyDataList[i]
      local item = UIBarrackMainTabItem.New()
      item:InitCtrl(self.ui.mContent_TypeSel.transform)
      item:SetData(data)
      local tempItem = item
      UIUtils.GetButtonListener(item.mBtn.gameObject).onClick = function()
        UIFacilityBarrackPanel:OnClickDuty(tempItem)
      end
      table.insert(self.dutyList, item)
    end
  end
  self.curType = self.dutyList[1]
end
function UIFacilityBarrackPanel:InitSortContent()
  local sortList = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_SortList)
  self.sortListObj = sortList
  local parent = UIUtils.GetRectTransform(sortList, "Content")
  self.sortList = {}
  for i = 1, 4 do
    local obj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", parent)
    if obj then
      local sort = {}
      sort.obj = obj
      sort.btnSort = UIUtils.GetButton(obj)
      sort.txtName = UIUtils.GetText(obj, "GrpText/Text_SuitName")
      sort.sortType = i
      sort.hintID = FacilityBarrackGlobal.SortHint[i]
      sort.sortCfg = FacilityBarrackGlobal.GunSortCfg[i]
      sort.isAscend = false
      sort.grpset = obj.transform:Find("GrpSel")
      sort.txtName.text = TableData.GetHintById(sort.hintID)
      self.textcolor = obj.transform:GetComponent("TextImgColor")
      self.beforecolor = self.textcolor.BeforeSelected
      self.aftercolor = self.textcolor.AfterSelected
      UIUtils.GetButtonListener(sort.btnSort.gameObject).onClick = function()
        self:OnClickSort(sort.sortType)
      end
      table.insert(self.sortList, sort)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Sort.gameObject).onClick = function()
    self:OnClickSortList()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Ascend.gameObject).onClick = function()
    self:OnClickAscend()
  end
  UIUtils.GetUIBlockHelper(self.ui.mUIRoot, self.ui.mTrans_SortList, function()
    UIFacilityBarrackPanel:CloseItemSort()
  end)
  self.curSort = self.sortList[FacilityBarrackGlobal.GunSortType.Time]
end
function UIFacilityBarrackPanel:UpdateReward()
  self.ui.mBtn_GetAssistRewardButton.interactable = not (AccountNetCmdHandler.AssistantRewards <= 0)
  self.ui.mText_RewardNum.text = AccountNetCmdHandler.AssistantRewards
end
function UIFacilityBarrackPanel:OnSetAssistGun()
  if self.CurrentGun then
    if self.CurrentGun.tableData.id == AccountNetCmdHandler.AssistantGunId then
      self:OnReturnClick()
      return
    end
    AccountNetCmdHandler:SendReqSetAssistant(self.CurrentGun.tableData.id, function()
      UIPlayerInfoPanel:RefreshAssistGun()
      self:OnReturnClick()
    end)
  end
end
function UIFacilityBarrackPanel:OnGetRewards()
  AccountNetCmdHandler:SendReqAssistantAcquire(function()
    self:UpdateReward()
  end)
end
function UIFacilityBarrackPanel:ClickGunByFirstDutyId(dutyId)
  for i = 1, #self.ItemDataList do
    local gunCmdData = self.ItemDataList[i]
    if gunCmdData.TabGunData and gunCmdData.TabGunData.Duty == dutyId then
      self:OnClickGunById(gunCmdData.TabGunData.Id, FacilityBarrackGlobal.PowerUpType.GunTalent)
      break
    end
  end
end
