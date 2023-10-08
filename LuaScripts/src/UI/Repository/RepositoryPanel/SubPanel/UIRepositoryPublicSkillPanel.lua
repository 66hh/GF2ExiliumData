require("UI.Repository.RepositoryPanel.SubPanel.UIRepositoryBasePanel")
UIRepositoryPublicSkillPanel = class("UIRepositoryPublicSkillPanel", UIRepositoryBasePanel)
function UIRepositoryPublicSkillPanel:ctor(parent, panelId, subPanelRoot)
  self.super.ctor(self, parent, panelId, subPanelRoot)
  self.parent = parent
  self.panelId = panelId
  self.itemList = {}
  self.isSub = false
  self.param = nil
  self.skillTypeId = 0
  self.TopTabTable = {}
  self.transRoot = subPanelRoot
  self.selectedItemData = nil
  self.comScreenItemV2 = nil
end
function UIRepositoryPublicSkillPanel:Show()
  self.super.Show(self)
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self:InitTypeDropItem()
  local skillList = NetCmdTalentData:GetPublicSkillsItemByType()
  self.comScreenItemV2 = ComScreenItemHelper:InitPublicSkill(self.parent.ui.mTrans_BtnScreen.gameObject, skillList, function()
    self:RefreshItemList()
  end, nil)
  self.currentIndex = 0
  self.currentTypeID = 0
  self:OnClickTypeDropdownItem(1)
  self.parent.ui.mTrans_Empty.text = TableData.GetHintById(180022)
  self.parent:SetOwnAndLimitNumVisible(true)
  setactive(self.parent.ui.mTrans_Bottom, true)
  self.parent.ui.mTrans_Other.localPosition = vectorzero
end
function UIRepositoryPublicSkillPanel:OnPanelBack()
  self:Refresh()
end
function UIRepositoryPublicSkillPanel:Close()
  self.super.Close(self)
  self.parent:SetOwnAndLimitNumVisible(false)
  setactive(self.parent.ui.mTrans_Bottom, false)
  self.parent.ui.mTrans_Other.localPosition = Vector3(0, 3000, 0)
  setactive(self.parent.ui.mTrans_Empty, false)
  setactive(self.parent.ui.mTrans_ChrTalentList, false)
  setactive(self.parent.ui.mTrans_TalentImgLine, false)
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.comScreenItemV2 = nil
  if 0 < self.currentIndex then
    self.TopTabTable[self.currentIndex]:SetSelectState(false)
  end
  self.currentIndex = nil
  self.currentTypeID = nil
  for i, v in ipairs(self.TopTabTable) do
    v:OnRelease()
  end
  self.TopTabTable = {}
end
function UIRepositoryPublicSkillPanel:OnRelease()
  self.itemList = nil
  self.parent = nil
  self.panelId = 0
  self.param = nil
  self.selectedItemData = nil
  self.selectedItemOldLv = nil
end
function UIRepositoryPublicSkillPanel:InitTypeDropItem()
  local tableData = TableData.listRepositoryTagDatas:GetDataById(self.panelId)
  local allDataList = tableData.toptag
  local allDataTable = CSList2LuaTable(allDataList)
  if #allDataTable == 0 then
    local itemData = TableData.listRepositoryToptagDatas:GetDataById(11)
    if itemData then
      self:RegTypeDropdownItem(itemData.title.str, itemData.icon, -1, 1)
    end
    setactivewithcheck(self.parent.ui.mTrans_ChrTalentList, false)
    setactive(self.parent.ui.mTrans_TalentImgLine, false)
    return
  end
  for i = 1, #allDataTable do
    local itemData = TableData.listRepositoryToptagDatas:GetDataById(allDataTable[i])
    if itemData then
      self:RegTypeDropdownItem(itemData.title.str, itemData.icon, itemData.args[0], i)
    end
  end
  setactive(self.parent.ui.mTrans_ChrTalentList, true)
  setactive(self.parent.ui.mTrans_TalentImgLine, true)
end
function UIRepositoryPublicSkillPanel:RegTypeDropdownItem(suitName, spriteName, typeId, index)
  if self.TopTabTable[index] == nil then
    local item1 = UIRepositoryPublicTabItem.New()
    item1:InitCtrl(self.parent.ui.mTrans_ChrTalentList.transform)
    self.TopTabTable[index] = item1
    item1:SetRedPoint(false)
  end
  local item = self.TopTabTable[index]
  item.itemIndex = index
  item.typeId = typeId
  item:SetData(suitName)
  item:SetClickFunction(function()
    self:OnClickTypeDropdownItem(item.itemIndex)
  end)
end
function UIRepositoryPublicSkillPanel:OnClickTypeDropdownItem(itemIndex)
  if self.currentIndex > 0 then
    self.TopTabTable[self.currentIndex]:SetSelectState(false)
  end
  self.currentIndex = itemIndex
  self.TopTabTable[self.currentIndex]:SetSelectState(true)
  self.currentTypeID = self.TopTabTable[itemIndex].typeId
  self:RefreshItemList()
end
function UIRepositoryPublicSkillPanel:ItemRenderer(index, renderData)
  local data = self.itemList[index + 1]
  if data then
    local item = renderData.data
    item:SetPublicSkillData(data, nil)
  end
end
function UIRepositoryPublicSkillPanel:FocusItem(cmdId)
  if not cmdId then
    return
  end
  local targetIndex = 0
  for i, weaponCmdData in ipairs(self.itemList) do
    if weaponCmdData.id == cmdId then
      targetIndex = i - 1
      break
    end
  end
  self:ScrollTo(targetIndex)
end
function UIRepositoryPublicSkillPanel:ScrollTo(itemIndex)
  local rowIndex = math.floor(itemIndex / 7)
  local virtualList = self.virtualList
  local elementHeight = virtualList.cellSize.y + virtualList.spacing.y
  local targetPosY = rowIndex * elementHeight
  self.parent.ui.mTrans_Content.anchoredPosition = Vector2(self.parent.ui.mTrans_Content.anchoredPosition.x, targetPosY)
end
function UIRepositoryPublicSkillPanel:Refresh()
end
function UIRepositoryPublicSkillPanel:RefreshItemList()
  self.itemList = self:GetSkillList()
  self.parent:SetOwnAndLimitNum(#self.itemList, CS.GF2.Data.GlobalData.weapon_capacity)
  setactive(self.parent.ui.mTrans_Empty, #self.itemList == 0)
  self.super.RefreshItemList(self)
end
function UIRepositoryPublicSkillPanel:InitFiltrateItemList()
  local tempList = {}
  for _, item in ipairs(self.itemList) do
    if not item.isEquip and not item.isLock then
      table.insert(tempList, item)
    end
  end
  self.itemList = tempList
  self.super.UpdateItemList(self)
end
function UIRepositoryPublicSkillPanel:OnClickSkillItem(item)
  local param = {
    item:GetWeaponItemStcId(),
    UIWeaponGlobal.WeaponPanelTab.Info,
    true,
    UIWeaponPanel.OpenFromType.Repository
  }
end
function UIRepositoryPublicSkillPanel:GetSkillList()
  local list = {}
  local weaponList = self.comScreenItemV2:GetResultList()
  for i = 0, weaponList.Count - 1 do
    if self.currentTypeID ~= -1 then
      local t = weaponList[i].TalentKeyStcData.require_job
      if t == self.currentTypeID then
        table.insert(list, weaponList[i])
      end
    else
      table.insert(list, weaponList[i])
    end
  end
  return list
end
