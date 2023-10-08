require("UI.UIBasePanel")
require("UI.DarkZonePanel.UIDarkZoneMakeTablePanel.UIDarkZoneMakeLeftTabItem")
require("UI.DarkZonePanel.UIDarkZoneModePanel.DarkZoneGlobal")
require("UI.DarkZonePanel.UIDarkZoneMakeTablePanel.DarkZoneMakeGlobal")
require("UI.DarkZonePanel.UIDarkZoneMakeTablePanel.UIDarkZoneItemInfoItem")
require("UI.Common.UICommonLeftTabItemV2")
require("UI.Repository.UIRepositoryGlobal")
UIDarkZoneMakeTablePanel = class("UIDarkZoneMakeTablePanel", UIBasePanel)
UIDarkZoneMakeTablePanel.__index = UIDarkZoneMakeTablePanel
UIDarkZoneMakeTablePanel.TabType = {Make = 1, Decompose = 2}
UIDarkZoneMakeTablePanel.maxDecomposeValue = TableData.GlobalSystemData.DarkzoneSplitLimit
UIDarkZoneMakeTablePanel.decomposeLevel = TableData.GlobalSystemData.ModDecomposeLevel
function UIDarkZoneMakeTablePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = false
end
function UIDarkZoneMakeTablePanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
end
function UIDarkZoneMakeTablePanel:OnInit(root, data)
  self.fromTop = false
  self:CreateTab()
  self:InitTab()
  self:InitMakePanel()
  self:InitDecomposePanel()
end
function UIDarkZoneMakeTablePanel:OnShowStart()
end
function UIDarkZoneMakeTablePanel:OnShowFinish()
  if self.fromTop then
    return
  end
  self.fromTop = false
  self:RefreshContent()
end
function UIDarkZoneMakeTablePanel:OnBackFrom()
  local camera = UIUtils.FindGameObject("MainCamera")
  if camera then
    setactive(camera, false)
  end
end
function UIDarkZoneMakeTablePanel:OnClose()
  self:ReleaseCtrlTable(self.tabList, true)
  self:OnCloseMakePanel()
  self:OnCloseDecomposePanel()
end
function UIDarkZoneMakeTablePanel:OnHide()
end
function UIDarkZoneMakeTablePanel:OnHideFinish()
end
function UIDarkZoneMakeTablePanel:OnTop()
  self.fromTop = true
  if self.playProgressAni and not DarkNetCmdMakeTableData.FullDecompose then
    self:RefreshContent()
    self:PlayProgressAnimation()
  end
end
function UIDarkZoneMakeTablePanel:OnRelease()
  self:OnReleaseMakePanel()
  self:OnReleaseDecomposePanel()
  self.ui = nil
end
function UIDarkZoneMakeTablePanel:OnRefresh()
  if not TutorialSystem.IsInTutorial then
    return
  end
  self:RefreshContent()
end
function UIDarkZoneMakeTablePanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneMakeTablePanel)
  end
  self:AddMakeBtnListener()
  self:AddDecomposeBtnListener()
end
function UIDarkZoneMakeTablePanel:CreateTab()
  local nameList = {
    TableData.GetHintById(903396),
    TableData.GetHintById(30003)
  }
  self.tabList = {}
  for i = UIDarkZoneMakeTablePanel.TabType.Make, UIDarkZoneMakeTablePanel.TabType.Decompose do
    do
      local item = UICommonLeftTabItemV2.New()
      local obj = instantiate(self.ui.mScrollListChild_TabContent.childItem, self.ui.mScrollListChild_TabContent.transform)
      item:InitCtrl(obj.transform)
      item:SetName(i, nameList[i])
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
        self:OnClickTab(item.tagId)
      end
      table.insert(self.tabList, item)
    end
  end
end
function UIDarkZoneMakeTablePanel:InitTab()
  self.curTab = UIDarkZoneMakeTablePanel.TabType.Make
  for i = UIDarkZoneMakeTablePanel.TabType.Make, UIDarkZoneMakeTablePanel.TabType.Decompose do
    self.tabList[i]:SetItemState(i == self.curTab)
  end
end
function UIDarkZoneMakeTablePanel:OnClickTab(index)
  if index == self.curTab then
    return
  end
  if self.curTab > 0 then
    local lastTab = self.tabList[self.curTab]
    lastTab:SetItemState(false)
  end
  self.tabList[index]:SetItemState(true)
  self.curTab = index
  self:RefreshContent(true)
end
function UIDarkZoneMakeTablePanel:RefreshContent(bClickTab)
  setactive(self.ui.mTrans_Make.gameObject, self.curTab == UIDarkZoneMakeTablePanel.TabType.Make)
  setactive(self.ui.mTrans_Decompose.gameObject, self.curTab == UIDarkZoneMakeTablePanel.TabType.Decompose)
  if bClickTab then
    self.ui.mAni_Root:ResetTrigger("Tab_FadeIn")
    self.ui.mAni_Root:SetTrigger("Tab_FadeIn")
  end
  if self.curTab == UIDarkZoneMakeTablePanel.TabType.Make then
    if bClickTab then
      self.selectFormulaData = nil
      self:ResetMakeScreen()
      self:ResetMaterialListFadeManager()
    end
    self:RefreshMakeContent()
  else
    if bClickTab then
      self:ResetDecomposeScreen()
      self:ResetPartListFadeManager()
    end
    self:RefreshDecomposeContent()
  end
end
function UIDarkZoneMakeTablePanel:InitMakePanel()
  self.listMaterialItem = {}
  self.curMakeCount = 1
  self.selectGunId = 0
  self.selectFormulaData = nil
  self.ui.mVirtualListEx_FormulaList.verticalNormalizedPosition = 1
  self.materialListFadeManager = self.ui.mScrollListChild_GrpItemList:GetComponent(typeof(CS.MonoScrollerFadeManager))
  self:ResetMakeScreen()
  self:InitFormulaList()
end
function UIDarkZoneMakeTablePanel:OnReleaseMakePanel()
  self.curMakeCount = 1
  self.selectFormulaData = nil
  self.materialListFadeManager = nil
  if not CS.LuaUtils.IsNullOrDestroyed(self.makeScreenItemV2) then
    self.makeScreenItemV2:OnRelease()
  end
  self.makeScreenItemV2 = nil
  self.formulaList = nil
end
function UIDarkZoneMakeTablePanel:OnCloseMakePanel()
  self:ReleaseCtrlTable(self.listMaterialItem, true)
end
function UIDarkZoneMakeTablePanel:SetFormulaData()
  local data = DarkNetCmdMakeTableData:GetFormualsList(self.filterFormulaType)
  if not CS.LuaUtils.IsNullOrDestroyed(self.makeScreenItemV2) then
    self.makeScreenItemV2:SetList(data)
  else
    self.makeScreenItemV2 = ComScreenItemHelper:InitDarkZoneFormula(self.ui.mTrans_BtnScreen.gameObject, data, function()
      self.filterFormulaType = self.makeScreenItemV2.SortId
      self.selectFormulaData = nil
      self.formulaList = self.makeScreenItemV2:GetResultList()
      self:RefreshMakeContent()
    end, nil)
  end
  self.formulaList = self.makeScreenItemV2:GetResultList()
end
function UIDarkZoneMakeTablePanel:ResetMakeScreen()
  self.filterFormulaType = 0
  if not CS.LuaUtils.IsNullOrDestroyed(self.makeScreenItemV2) then
    self.makeScreenItemV2:SetDefault()
    self.makeScreenItemV2:ShowScreenTransEx(false)
  end
end
function UIDarkZoneMakeTablePanel:RefreshMakeContent()
  self:SetFormulaData()
  self:RefreshFormulaList()
  self:RefreshMakeRightPart()
end
function UIDarkZoneMakeTablePanel:RefreshMakeRightPart()
  self:GetMakeCost()
  self:RefreshMakeRightPartVisible()
  self:RefreshCurMakeCountText()
  self:RefreshMaterial()
  self:RefreshWishToolInfo()
  self:RefreshDelegateRole()
  self:RefreshLockContent()
end
function UIDarkZoneMakeTablePanel:InitFormulaList()
  self.formulaList = {}
  self.ui.mVirtualListEx_FormulaList.numItems = 0
  function self.ui.mVirtualListEx_FormulaList.itemProvider()
    local item = self:FormulaItemProvider()
    return item
  end
  function self.ui.mVirtualListEx_FormulaList.itemRenderer(index, renderData)
    self:FormulaItemRenderer(index, renderData)
  end
end
function UIDarkZoneMakeTablePanel:FormulaItemProvider()
  local itemView = UIDarkZoneMakeLeftTabItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneMakeTablePanel:FormulaItemRenderer(index, renderData)
  if index + 1 > self.formulaList.Count then
    return
  end
  local item = renderData.data
  item:SetData(self.formulaList[index], UIDarkZoneMakeTablePanel.SelectFormulaItem)
  item:SetSelect(self.selectFormulaData and self.selectFormulaData.Data.id or 0)
end
function UIDarkZoneMakeTablePanel:RefreshFormulaList()
  if self.formulaList ~= nil and self.formulaList.Count > 0 then
    if self.selectFormulaData then
      for i = 0, self.formulaList.Count - 1 do
        if self.formulaList[i].Data.id == self.selectFormulaData.Data.id then
          self.selectFormulaData.State = self.formulaList[i].State
          break
        end
      end
    else
      self.selectFormulaData = self.formulaList[0]
    end
  end
  self.ui.mVirtualListEx_FormulaList.numItems = self.formulaList and self.formulaList.Count or 0
  self.ui.mVirtualListEx_FormulaList:Refresh()
end
function UIDarkZoneMakeTablePanel.SelectFormulaItem(data)
  self = UIDarkZoneMakeTablePanel
  if not (data and self.selectFormulaData) or data.Data.id == self.selectFormulaData.Data.id then
    return
  end
  self.selectFormulaData = data
  self:RefreshFormulaList()
  self.ui.mAni_Root:ResetTrigger("GrpMake_0_Tab_FadeIn")
  self.ui.mAni_Root:SetTrigger("GrpMake_0_Tab_FadeIn")
  self:RefreshMakeRightPart()
end
function UIDarkZoneMakeTablePanel:ResetMaterialListFadeManager()
  if self.materialListFadeManager then
    self.materialListFadeManager.enabled = false
    self.materialListFadeManager.enabled = true
  end
end
function UIDarkZoneMakeTablePanel:RefreshWishToolInfo()
  if not self.selectFormulaData then
    return
  end
  local data = self.selectFormulaData.Data
  if not data then
    return
  end
  for k, v in pairs(data.create) do
    self.ui.mImg_WishToolIcon.sprite = IconUtils.GetItemIconSprite(k)
    break
  end
  for i = 1, 3 do
    setactive(self.ui["mTrans_Quality" .. i], false)
  end
  for i = 1, data.create_show.Count do
    setactive(self.ui["mTrans_Quality" .. i], true)
    self.ui["mText_num" .. i].text = data.create_show[i - 1] .. "%"
  end
  self.ui.mText_Des.text = data.create_des.str
  self.ui.mText_WishToolName.text = data.create_title.str
end
function UIDarkZoneMakeTablePanel:RefreshMaterial()
  if not self.selectFormulaData then
    return
  end
  local data = self.selectFormulaData.Data
  if not data then
    return
  end
  for _, v in pairs(self.listMaterialItem) do
    setactive(v:GetRoot().gameObject, false)
  end
  local listMaterial = {}
  for k, v in pairs(data.material) do
    table.insert(listMaterial, {id = k, num = v})
  end
  table.sort(listMaterial, function(a, b)
    local dataA = TableData.GetItemData(a.id)
    local dataB = TableData.GetItemData(b.id)
    if dataA and dataB then
      return dataA.rank > dataB.rank
    else
      return a.id < b.id
    end
  end)
  for i = 1, #listMaterial do
    local item = self.listMaterialItem[i]
    if not item then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpItemList)
      table.insert(self.listMaterialItem, item)
    else
      setactive(item:GetRoot(), true)
    end
    local costNum = listMaterial[i].num * self.curMakeCount
    item:SetItemData(listMaterial[i].id, costNum, false, true)
    item:RefreshItemNum(costNum, true)
  end
end
function UIDarkZoneMakeTablePanel:AddMakeBtnListener()
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnReduce.gameObject, function()
    self:OnClickReduce()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnIncrease.gameObject, function()
    self:OnClickIncrease()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnRepository.gameObject, function()
    UIManager.OpenUI(UIDef.UIDarkZoneRepositoryPanel)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnGoExplore.gameObject, function()
    self:OnBtnExplore()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnGoQuest.gameObject, function()
    self:OnBtnQuest()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_WishChr.gameObject, function()
    self:OnBtnRoleSelect()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnMake.gameObject, function()
    self:OnBtnMake()
  end)
end
function UIDarkZoneMakeTablePanel:OnBtnExplore()
  local unlockId = DarkZoneGlobal.ModeUnlockId[DarkZoneGlobal.PanelType.Explore]
  local data = TableData.GetUnLockInfoByType(unlockId)
  if not data then
    return
  end
  if not AccountNetCmdHandler:CheckSystemIsUnLock(unlockId) then
    local unlockData = TableData.listUnlockDatas:GetDataById(unlockId, true)
    local str = UIUtils.CheckUnlockPopupStr(unlockData)
    PopupMessageManager.PopupString(str)
    return
  end
  SceneSwitch:SwitchByID(10004)
end
function UIDarkZoneMakeTablePanel:OnBtnRoleSelect()
  if not self.selectFormulaData then
    return
  end
  local listId = {}
  local index = 1
  listId[index] = 0
  index = index + 1
  local num = TableData.listDarkzoneWishCreateCharacterDatas.Count
  for i = 0, num - 1 do
    local tmpData = TableData.listDarkzoneWishCreateCharacterDatas:GetDataByIndex(i)
    if tmpData.create_id == self.selectFormulaData.Data.id then
      local gundData = NetCmdTeamData:GetGunByID(tmpData.gun_id)
      if gundData then
        listId[index] = tmpData.gun_id
        index = index + 1
      end
    end
  end
  for i = 0, NetCmdTeamData.GunCount - 1 do
    local gunData = NetCmdTeamData:GetGun(i)
    local bFind = false
    for j = 1, #listId do
      if listId[j] == gunData.id then
        bFind = true
        break
      end
    end
    if not bFind then
      listId[index] = gunData.id
      index = index + 1
    end
  end
  UIManager.OpenUIByParam(UIDef.UIDarkZoneMakeChrSeDialog, {
    formulaId = self.selectFormulaData.Data.id,
    listGunId = listId,
    selectGunId = self.selectGunId,
    callback = function(selectId)
      self.selectGunId = selectId
      self:RefreshRolePartVisible()
      self:RefreshDelegateRole()
    end
  })
end
function UIDarkZoneMakeTablePanel:OnBtnMake()
  if not self.selectGunId or self.curMakeCount <= 0 or not self.selectFormulaData then
    return
  end
  DarkNetCmdMakeTableData:SendCS_DarkZoneManufacture(self.curMakeCount, self.selectGunId, self.selectFormulaData.Data.id, function(ret)
    if ret == ErrorCodeSuc then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneMakingDialog, function()
        self.curMakeCount = 1
        self:RefreshMakeContent()
      end)
    end
  end)
end
function UIDarkZoneMakeTablePanel:OnBtnQuest()
  local unlockId = DarkZoneGlobal.ModeUnlockId[DarkZoneGlobal.PanelType.Quest]
  local data = TableData.GetUnLockInfoByType(unlockId)
  if not data then
    return
  end
  if not AccountNetCmdHandler:CheckSystemIsUnLock(unlockId) then
    local unlockData = TableData.listUnlockDatas:GetDataById(unlockId, true)
    local str = UIUtils.CheckUnlockPopupStr(unlockData)
    PopupMessageManager.PopupString(str)
    return
  end
  local args = TableData.listJumpListContentnewDatas:GetDataById(self.selectFormulaData.Data.jump_id).args
  local argsList = string.split(args, ":")
  local questID = tonumber(argsList[2])
  local mode = tonumber(argsList[1])
  local quest = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID)
  local state = NetCmdDarkZoneSeasonData:IsQuestUnlock(questID)
  if state == 2 then
    PopupMessageManager.PopupString(string_format(TableData.GetHintById(240066), quest.unlock1))
    return
  elseif state == 3 then
    local reason = ""
    for i = 0, quest.unlock2.Count - 1 do
      reason = reason .. TableData.listDarkzoneSystemQuestDatas:GetDataById(quest.unlock2[i]).QuestName.str
    end
    PopupMessageManager.PopupString(string_format(TableData.GetHintById(240087), reason))
    return
  end
  local list = new_list(typeof(CS.System.Int32))
  list:Add(questID)
  list:Add(mode)
  SceneSwitch:SwitchByID(self.selectFormulaData.Data.jump_id, false, list)
end
function UIDarkZoneMakeTablePanel:OnClickReduce()
  self:ChangeMakeCount(-1)
  self:RefreshMaterial()
end
function UIDarkZoneMakeTablePanel:OnClickIncrease()
  if self.curMakeCount >= self.maxMakeCount then
    local hint = TableData.GetHintById(1106)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  self:ChangeMakeCount(1)
  self:RefreshMaterial()
end
function UIDarkZoneMakeTablePanel:ChangeMakeCount(delta)
  local targetValue = self.curMakeCount + delta
  if targetValue > self.maxMakeCount then
    targetValue = self.maxMakeCount
  elseif targetValue < 1 then
    targetValue = 1
    local hint = TableData.GetHintById(240125)
    CS.PopupMessageManager.PopupString(hint)
  end
  self.curMakeCount = targetValue
  self:OnMakeCountChanged()
end
function UIDarkZoneMakeTablePanel:OnMakeCountChanged()
  self:RefreshCurMakeCountText()
end
function UIDarkZoneMakeTablePanel:RefreshCurMakeCountText()
  self.ui.mText_Num.text = self.curMakeCount
end
function UIDarkZoneMakeTablePanel:GetMakeCost()
  if not self.selectFormulaData then
    return
  end
  local data = self.selectFormulaData.Data
  if not data then
    return
  end
  local maxValue = 0
  for k, v in pairs(data.material) do
    local costItem = tonumber(k)
    local costItemNum = tonumber(v)
    local curItemNum = NetCmdItemData:GetItemCountById(costItem)
    if 0 < curItemNum and 0 < costItemNum then
      if maxValue == 0 then
        maxValue = math.floor(curItemNum / costItemNum)
      else
        maxValue = math.min(maxValue, math.floor(curItemNum / costItemNum))
      end
    end
  end
  self.maxMakeCount = maxValue
  if self.curMakeCount > self.maxMakeCount then
    self.curMakeCount = 1
  end
  if self.selectFormulaData.State == DarkZoneMakeGlobal.State_IsNotEnough then
    self.curMakeCount = 1
  end
end
function UIDarkZoneMakeTablePanel:RefreshMakeRightPartVisible()
  setactive(self.ui.m_TransOpen.gameObject, self.selectFormulaData and self.selectFormulaData.State ~= DarkZoneMakeGlobal.State_IsLock)
  setactive(self.ui.m_TransLock.gameObject, not self.selectFormulaData or self.selectFormulaData.State == DarkZoneMakeGlobal.State_IsLock)
  setactive(self.ui.mTrans_CanMake.gameObject, self.selectFormulaData and self.selectFormulaData.State == DarkZoneMakeGlobal.State_CanProduce)
  setactive(self.ui.mTrans_ConsumeLess.gameObject, self.selectFormulaData and self.selectFormulaData.State == DarkZoneMakeGlobal.State_IsNotEnough)
  self:RefreshRolePartVisible()
end
function UIDarkZoneMakeTablePanel:RefreshRolePartVisible()
  self.ui.mAni_WishChr:SetBool("Bool", self.selectGunId > 0)
end
function UIDarkZoneMakeTablePanel:RefreshLockContent()
  if not self.selectFormulaData or self.selectFormulaData.State ~= DarkZoneMakeGlobal.State_IsLock then
    return
  end
  self.ui.m_TextLock.text = self.selectFormulaData.Data.unlock_des.str
end
function UIDarkZoneMakeTablePanel:RefreshDelegateRole()
  if not (self.selectGunId and not (self.selectGunId <= 0) and self.selectFormulaData) or not self.selectFormulaData.Data then
    return
  end
  local data
  for i = 0, TableData.listDarkzoneWishCreateCharacterDatas.Count - 1 do
    local tempData = TableData.listDarkzoneWishCreateCharacterDatas:GetDataByIndex(i)
    if tempData.gun_id == self.selectGunId and tempData.create_id == self.selectFormulaData.Data.id then
      data = tempData
      break
    end
  end
  self.ui.mText_RoleDesc.text = data and data.des.str or TableData.GetHintById(240106)
  local gunData = TableData.GetGunData(self.selectGunId)
  if gunData then
    self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHeadSprite(gunData.code)
    self.ui.mText_RoleName.text = gunData.name.str
    local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
    self.ui.mText_RoleType.text = string_format(TableData.GetHintById(240105), dutyData.name.str)
  end
end
function UIDarkZoneMakeTablePanel:InitDecomposePanel()
  self.selectPartTable = {}
  self.selectPartId = -1
  self.lastPartItem = nil
  self.decomposeDetailInfo = nil
  self.ui.mImg_CurProgress.fillAmount = DarkNetCmdMakeTableData.CurExp / self.maxDecomposeValue
  self.ui.mImg_AddProgress.fillAmount = 0
  self.playProgressAni = false
  self:ResetDecomposeScreen()
  self.partListFadeManager = self.ui.mScrollListChild_PartContent:GetComponent(typeof(CS.MonoScrollerFadeManager))
  self.weaponPartList = nil
  self.weaponPartExpList = nil
  self:InitDecomposeList()
end
function UIDarkZoneMakeTablePanel:OnReleaseDecomposePanel()
  self.lastPartItem = nil
  self.partRankType = 0
  self.partListFadeManager = nil
  if not CS.LuaUtils.IsNullOrDestroyed(self.decomposeScreenItemV2) then
    self.decomposeScreenItemV2:OnRelease()
  end
  self.decomposeScreenItemV2 = nil
  self.weaponPartList = nil
  self.weaponPartExpList = nil
end
function UIDarkZoneMakeTablePanel:OnCloseDecomposePanel()
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  self.listTween = nil
  if self.decomposeDetailInfo ~= nil then
    self.decomposeDetailInfo:OnRelease()
  end
  self.decomposeDetailInfo = nil
end
function UIDarkZoneMakeTablePanel:AddDecomposeBtnListener()
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnQuickSelect.gameObject, function()
    self:QuicklySelectWeaponParts()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnDecompose.gameObject, function()
    self:OnBtnDecompose()
  end)
end
function UIDarkZoneMakeTablePanel:RefreshDecomposeContent()
  self:InitDecomposeDetailInfo()
  self:RefreshDecomposePartList()
  self:RefreshDecomposeProgress()
end
function UIDarkZoneMakeTablePanel:InitDecomposeDetailInfo()
  if not self.decomposeDetailInfo then
    self.decomposeDetailInfo = UIDarkZoneItemInfoItem.New()
    self.decomposeDetailInfo:InitCtrl(self.ui.mScrollChild_Detail.transform, self.UnLockPart, self.UnLockPartMsgReturn)
  else
    self.decomposeDetailInfo:InitShow(false)
  end
end
function UIDarkZoneMakeTablePanel:RefreshDecomposePartList()
  self:UpdateDecomposeSortContent()
  self:RefreshVirtualPartList()
end
function UIDarkZoneMakeTablePanel:InitDecomposeList()
  self.partList = {}
  self.ui.mVirtualListEx_PartList.numItems = 0
  function self.ui.mVirtualListEx_PartList.itemProvider()
    local item = self:PartItemProvider()
    return item
  end
  function self.ui.mVirtualListEx_PartList.itemRenderer(index, renderData)
    self:PartItemRenderer(index, renderData)
  end
end
function UIDarkZoneMakeTablePanel:RefreshVirtualPartList()
  setactive(self.ui.mTrans_Empty.gameObject, #self.partList <= 0)
  self.ui.mVirtualListEx_PartList.vertical = #self.partList > 0
  self.ui.mVirtualListEx_PartList.numItems = #self.partList
  self.ui.mVirtualListEx_PartList:Refresh()
end
function UIDarkZoneMakeTablePanel:ResetPartListFadeManager()
  if not self.partListFadeManager then
    return
  end
  self.partListFadeManager.enabled = false
  self.partListFadeManager.enabled = true
end
function UIDarkZoneMakeTablePanel:PartItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_PartContent.transform, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneMakeTablePanel:PartItemRenderer(index, renderData)
  if index + 1 > #self.partList then
    return
  end
  local item = renderData.data
  local data = self.partList[index + 1]
  item:SetWeaponPartsData(data, function(tempItem)
    self:OnClickComposePart(index, tempItem)
  end)
  local id = item:GetWeaponPartsItemId()
  local bSelect = self:IfInSelectPartTable(id)
  item:SetSelectShow(self.selectPartId == id)
  item:SetSelect(bSelect)
  item:SetLock(data.IsLocked)
end
function UIDarkZoneMakeTablePanel:UpdateDecomposeSortContent()
  self.weaponPartList = NetCmdWeaponPartsData:GetMakeTableWeaponPartsListByRank(0)
  self:GetWeaponOfferExpDic()
  if not CS.LuaUtils.IsNullOrDestroyed(self.decomposeScreenItemV2) then
    self.decomposeScreenItemV2:SetList(self.weaponPartList)
  else
    self.decomposeScreenItemV2 = ComScreenItemHelper:InitDarkZoneDecompose(self.ui.mScrollListChild_BtnScreen.gameObject, self.weaponPartList, function()
      self:SortDecomposePartList()
    end, nil)
  end
  self.selectPartTable = {}
  self.selectPartId = -1
  self:GetDecomposeParts()
end
function UIDarkZoneMakeTablePanel:GetDecomposeParts()
  self.partRankType = self.decomposeScreenItemV2:GetCurSortRank()
  self.partList = {}
  for _, item in pairs(self.weaponPartList) do
    local itemId = item.stcId
    local itemTabData = TableData.GetItemData(itemId)
    if itemTabData.rank == self.partRankType or self.partRankType == 0 then
      table.insert(self.partList, item)
    end
  end
  table.sort(self.partList, function(a, b)
    if a.rank ~= b.rank then
      return a.rank < b.rank
    else
      local flagA = a.level <= 1 and a.exp <= 0
      local flagB = b.level <= 1 and b.exp <= 0
      if flagA and not flagB then
        return true
      elseif not flagA and flagB then
        return false
      else
        return a.WeaponModData.id < b.WeaponModData.id
      end
    end
  end)
end
function UIDarkZoneMakeTablePanel:SortDecomposePartList()
  self:GetDecomposeParts()
  self:RefreshVirtualPartList()
  self:InitDecomposeDetailInfo()
  self:RefreshDecomposeProgress()
end
function UIDarkZoneMakeTablePanel:OnClickComposePart(index, item, quicklySelect)
  local weaponPartData = self.partList[index + 1]
  if not weaponPartData then
    return
  end
  local id = item:GetWeaponPartsItemId()
  local bSelect = true
  if not quicklySelect and self:RemoveIdFromSelectPartTable(id) then
    item:SetSelect(false)
    bSelect = false
  end
  if weaponPartData.IsLocked then
    if not quicklySelect then
      UIUtils.PopupHintMessage(1096)
    end
    bSelect = false
  end
  local bFullProgress = self:CheckMaxDecomposeProgress()
  if bSelect then
    if not quicklySelect and bFullProgress then
      UIUtils.PopupHintMessage(1106)
    end
    if not quicklySelect and not bFullProgress then
      self:InsertSelectPartTable(id)
    end
    if not bFullProgress then
      item:SetSelect(true)
    end
  end
  if self.lastPartItem then
    self.lastPartItem:SetSelectShow(false)
  end
  item:SetSelectShow(true)
  item:SetLock(weaponPartData.IsLocked)
  self.lastPartItem = item
  self.selectPartId = id
  self:RefreshDecomposeDetail(weaponPartData)
  self:RefreshDecomposeProgress()
end
function UIDarkZoneMakeTablePanel:RemoveIdFromSelectPartTable(id)
  for i = 1, #self.selectPartTable do
    if self.selectPartTable[i] == id then
      table.remove(self.selectPartTable, i)
      return true
    end
  end
  return false
end
function UIDarkZoneMakeTablePanel:InsertSelectPartTable(id)
  for i = 1, #self.selectPartTable do
    if self.selectPartTable[i] == id then
      return false
    end
  end
  table.insert(self.selectPartTable, id)
  return true
end
function UIDarkZoneMakeTablePanel:IfInSelectPartTable(id)
  for i = 1, #self.selectPartTable do
    if self.selectPartTable[i] == id then
      return true
    end
  end
  return false
end
function UIDarkZoneMakeTablePanel:RefreshDecomposeDetail(weaponPartData)
  self.decomposeDetailInfo:Refresh(weaponPartData)
end
function UIDarkZoneMakeTablePanel:QuicklySelectWeaponParts()
  local preCount = #self.selectPartTable
  for _, item in pairs(self.partList) do
    if self:CheckMaxDecomposeProgress() then
      break
    end
    local itemId = item.stcId
    local itemTabData = TableData.GetItemData(itemId)
    if not item.IsLocked and (itemTabData.rank <= self.partRankType or self.partRankType == 0) then
      self:InsertSelectPartTable(item.id)
    end
  end
  if #self.selectPartTable == 0 then
    UIUtils.PopupHintMessage(1094)
  elseif preCount == #self.selectPartTable and not self:CheckMaxDecomposeProgress() then
    UIUtils.PopupHintMessage(1107)
  elseif preCount == #self.selectPartTable and self:CheckMaxDecomposeProgress() then
    UIUtils.PopupHintMessage(1106)
  else
    local index = 0
    for i = 0, self.ui.mVirtualListEx_PartList.numItems - 1 do
      local item = self.ui.mVirtualListEx_PartList:GetDataByIndex(i)
      if item and self:IfInSelectPartTable(item:GetWeaponPartsItemId()) then
        index = i
        break
      end
    end
    UIUtils.PopupPositiveHintMessage(220077)
    self:UpdateSelectItem()
    local targetItem = self.ui.mVirtualListEx_PartList:GetDataByIndex(index)
    if targetItem then
      self:OnClickComposePart(index, targetItem, true)
    end
  end
end
function UIDarkZoneMakeTablePanel:OnBtnDecompose()
  if #self.selectPartTable <= 0 then
    return
  end
  local listIds = {}
  for i = 1, #self.selectPartTable do
    table.insert(listIds, self.selectPartTable[i])
  end
  if #listIds <= 0 then
    return
  end
  DarkNetCmdMakeTableData:SendCS_DarkZoneWishDismantle(listIds, function(ret)
    if ret == ErrorCodeSuc then
      self.ui.mImg_AddProgress.fillAmount = 0
      self.playProgressAni = true
      UIManager.OpenUIByParam(UIDef.UIDarkZoneDecomposingDialog, function()
        self:RefreshContent()
        self:PlayProgressAnimation()
      end)
    end
  end)
end
function UIDarkZoneMakeTablePanel:UpdateSelectItem()
  for _, value in pairs(self.selectPartTable) do
    for i = 0, self.ui.mVirtualListEx_PartList.numItems - 1 do
      local targetItem = self.ui.mVirtualListEx_PartList:GetDataByIndex(i)
      if targetItem and targetItem:GetWeaponPartsItemId() == value then
        targetItem:SetSelect(true)
        targetItem:SetSelectShow(false)
        break
      end
    end
  end
end
function UIDarkZoneMakeTablePanel.UnLockPart(id)
  self = UIDarkZoneMakeTablePanel
  for i = 0, self.ui.mVirtualListEx_PartList.numItems - 1 do
    local targetItem = self.ui.mVirtualListEx_PartList:GetDataByIndex(i)
    if targetItem and targetItem:GetWeaponPartsItemId() == id then
      targetItem:SetSelect(false)
      self:RemoveIdFromSelectPartTable(id)
      break
    end
  end
end
function UIDarkZoneMakeTablePanel.UnLockPartMsgReturn(isOn, id)
  self = UIDarkZoneMakeTablePanel
  for i = 0, self.ui.mVirtualListEx_PartList.numItems - 1 do
    local targetItem = self.ui.mVirtualListEx_PartList:GetDataByIndex(i)
    if targetItem and targetItem:GetWeaponPartsItemId() == id then
      targetItem:SetLock(isOn)
      break
    end
  end
  self:RefreshDecomposeProgress()
end
function UIDarkZoneMakeTablePanel:RefreshDecomposeProgress()
  setactive(self.ui.mTrans_GrpNum.gameObject, #self.selectPartTable > 0)
  setactive(self.ui.mBtn_BtnDecompose.gameObject, #self.selectPartTable > 0)
  setactive(self.ui.mTrans_Disabled.gameObject, #self.selectPartTable <= 0)
  self.ui.mText_DecomposeNum.text = string_format(TableData.GetHintById(903518), #self.selectPartTable)
  local curValue = self:GetCurDecomposeExp() + DarkNetCmdMakeTableData.CurExp
  local percent = math.floor(curValue * 100 / self.maxDecomposeValue)
  self.ui.mText_DecomposeProgress.text = percent .. "%"
  if not self.playProgressAni then
    self.ui.mImg_AddProgress.fillAmount = curValue / self.maxDecomposeValue
  end
end
function UIDarkZoneMakeTablePanel:PlayProgressAnimation()
  self.ui.mImg_AddProgress.fillAmount = 0
  if DarkNetCmdMakeTableData.FullDecompose then
    self.ui.mImg_CurProgress.fillAmount = 0
  end
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  local getter = function(tempSelf)
    return tempSelf.ui.mImg_CurProgress.fillAmount
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mImg_CurProgress.fillAmount = value
  end
  local curValue = self:GetCurDecomposeExp() + DarkNetCmdMakeTableData.CurExp
  local percent = curValue / self.maxDecomposeValue
  self.listTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, percent, 1, function()
    self.playProgressAni = false
  end)
end
function UIDarkZoneMakeTablePanel:GetCurDecomposeExp()
  if not self.weaponPartExpList then
    return 0
  end
  local value = 0
  for i = 1, #self.selectPartTable do
    local id = self.selectPartTable[i]
    if self.weaponPartExpList[id] then
      value = value + self.weaponPartExpList[id]
    end
  end
  return value
end
function UIDarkZoneMakeTablePanel:GetWeaponOfferExpDic()
  if not self.weaponPartList then
    return nil
  end
  self.weaponPartExpList = {}
  for _, item in pairs(self.weaponPartList) do
    self.weaponPartExpList[item.id] = item:GetWeaponOfferExp()
  end
end
function UIDarkZoneMakeTablePanel:CheckMaxDecomposeProgress()
  return self:GetCurDecomposeExp() + DarkNetCmdMakeTableData.CurExp >= self.maxDecomposeValue
end
function UIDarkZoneMakeTablePanel:ResetDecomposeScreen()
  self.partRankType = 0
  if not CS.LuaUtils.IsNullOrDestroyed(self.decomposeScreenItemV2) then
    self.decomposeScreenItemV2:SetDefault()
    self.decomposeScreenItemV2:ShowScreenTransEx(false)
  end
end
