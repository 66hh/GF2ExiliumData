require("UI.FacilityBarrackPanel.UIGunTalent.UIGunTalentPluginSlot")
require("UI.FacilityBarrackPanel.UIGunTalent.UIGunTalentPluginItem")
require("UI.FacilityBarrackPanel.UIChrPowerUpPanel")
UIGunTalentAssemblyPanel = class("UIGunTalentAssemblyPanel", UIBasePanel)
UIGunTalentAssemblyPanel.__index = UIGunTalentAssemblyPanel
UIGunTalentAssemblyPanel.AssemblyType = {
  None = 0,
  Equip = 1,
  Unload = 2,
  Replace = 3
}
UIGunTalentAssemblyPanel.SlotType = {Personal = 1, Shared = 2}
UIGunTalentAssemblyPanel.mGunId = nil
UIGunTalentAssemblyPanel.curSlotItem = nil
UIGunTalentAssemblyPanel.curSelectPlugin = nil
UIGunTalentAssemblyPanel.curSelectUid = nil
UIGunTalentAssemblyPanel.curEquipPlugin = nil
UIGunTalentAssemblyPanel.pluginDataList = {}
UIGunTalentAssemblyPanel.privateSlotList = {}
UIGunTalentAssemblyPanel.publicSlotList = {}
UIGunTalentAssemblyPanel.isShowPluginList = false
UIGunTalentAssemblyPanel.isShowPluginInfo = false
UIGunTalentAssemblyPanel.canClickConfirm = false
UIGunTalentAssemblyPanel.mAnimator = nil
UIGunTalentAssemblyPanel.comScreenItemV2 = nil
function UIGunTalentAssemblyPanel:ctor(csPanel)
  UIGunTalentAssemblyPanel.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UIGunTalentAssemblyPanel:OnCameraStart()
  return 0.01
end
function UIGunTalentAssemblyPanel:OnCameraBack()
  return 0.01
end
function UIGunTalentAssemblyPanel:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mGunId = data[1]
  if data[2] then
    BarrackHelper.CameraMgr:StartCameraMoving(BarrackCameraOperate.OverviewToTalentTree)
    self.needMoveCamera = data[2]
  else
    self.needMoveCamera = false
  end
  self.curSlotItem = nil
  self.curSelectPlugin = nil
  self.curSelectUid = nil
  self.curEquipPlugin = nil
  self.pluginDataList = {}
  self.privateSlotList = {}
  self.publicSlotList = {}
  self.attributeItemTable = {}
  self.isShowPluginList = false
  self.isShowPluginInfo = false
  self.canClickConfirm = false
  self.mAnimator = self.ui.mAnimator
  self.comScreenItemV2 = nil
  setactive(self.ui.mTrans_GrpLeft.gameObject, false)
  setactive(self.ui.mTrans_GrpRight.gameObject, false)
  function self.PrivateSlotCallBack(msg)
    self:PrivatePluginsSlotCallBack(msg)
  end
  function self.PublicSlotCallBack(msg)
    self:PublicPluginsSlotCallBack(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.TalentEvent.PrivateSkillsSlotUpdate, self.PrivateSlotCallBack)
  MessageSys:AddListener(CS.GF2.Message.TalentEvent.PublicSkillsSlotUpdate, self.PublicSlotCallBack)
  UIUtils.GetButtonListener(self.ui.mBtn_BackFromList.gameObject).onClick = function()
    self:ClosePluginList()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnClickCloseButton()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self:SwitchGun(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self:SwitchGun(true)
  end
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  self:SetGunData()
  self:InitPluginSlots()
  setactivewithcheck(self.ui.mScrollListChild_Attribute, true)
end
function UIGunTalentAssemblyPanel:OnClose()
  setactive(self.ui.mTrans_GrpLeft.gameObject, false)
  setactive(self.ui.mTrans_GrpRight.gameObject, false)
  self.mGunId = nil
  self.curSlotItem = nil
  self.curSelectPlugin = nil
  self.curSelectUid = nil
  self.curEquipPlugin = nil
  for i = 1, #self.privateSlotList do
    gfdestroy(self.privateSlotList[i]:GetRoot())
  end
  for i = 1, #self.publicSlotList do
    gfdestroy(self.publicSlotList[i]:GetRoot())
  end
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.pluginDataList = {}
  self.privateSlotList = {}
  self.publicSlotList = {}
  self:ReleaseCtrlTable(self.attributeItemTable, true)
  self.attributeItemTable = nil
  self.isShowPluginList = false
  self.isShowPluginInfo = false
  self.canClickConfirm = false
  self.mAnimator = nil
  self.comScreenItemV2 = nil
  MessageSys:RemoveListener(CS.GF2.Message.TalentEvent.PrivateSkillsSlotUpdate, self.PrivateSlotCallBack)
  MessageSys:RemoveListener(CS.GF2.Message.TalentEvent.PublicSkillsSlotUpdate, self.PublicSlotCallBack)
  self.PrivateSlotCallBack = nil
  self.PublicSlotCallBack = nil
end
function UIGunTalentAssemblyPanel:SwitchGun(isNext)
  self.mAnimator:SetTrigger("Switch")
  FacilityBarrackGlobal.HideEffectNum()
  isNext = isNext == nil and true or isNext
  if isNext then
    CS.UIBarrackModelManager.Instance:SwitchRightGunModel(function(modelGameObject)
      self:UpdateModelCallback(modelGameObject)
    end)
  else
    CS.UIBarrackModelManager.Instance:SwitchLeftGunModel(function(modelGameObject)
      self:UpdateModelCallback(modelGameObject)
    end)
  end
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, true)
  CS.UIBarrackModelManager.Instance:PlayChangeGunEffect()
  local gunId = BarrackHelper.ModelMgr.GunStcDataId
  self:ReSetData(gunId)
  MessageSys:SendMessage(CS.GF2.Message.FacilityBarrackEvent.OnSwitchGun, gunId)
end
function UIGunTalentAssemblyPanel:ReSetData(gunId)
  for i = 1, #self.privateSlotList do
    gfdestroy(self.privateSlotList[i]:GetRoot())
  end
  for i = 1, #self.publicSlotList do
    gfdestroy(self.publicSlotList[i]:GetRoot())
  end
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.mGunId = gunId
  self.curSlotItem = nil
  self.curSelectPlugin = nil
  self.curSelectUid = nil
  self.curEquipPlugin = nil
  self.pluginDataList = {}
  self.privateSlotList = {}
  self.publicSlotList = {}
  self.isShowPluginList = false
  self.isShowPluginInfo = false
  self.canClickConfirm = false
  self.mAnimator = self.ui.mAnimator
  self.comScreenItemV2 = nil
  setactive(self.ui.mTrans_GrpLeft.gameObject, false)
  setactive(self.ui.mTrans_GrpRight.gameObject, false)
  self:SetGunData()
  self:InitPluginSlots()
end
function UIGunTalentAssemblyPanel:UpdateModelCallback(modelGameObject)
  UIChrPowerUpPanel:SetLookAtCharacter(modelGameObject.gameObject)
  UIChrPowerUpPanel.mModelGameObject = modelGameObject
  if UIChrPowerUpPanel.mModelGameObject ~= nil and UIChrPowerUpPanel.mModelGameObject.gameObject ~= nil then
    FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
    UIChrPowerUpPanel.mModelGameObject:Show(true)
  end
  FacilityBarrackGlobal.HideEffectNum(false)
end
function UIGunTalentAssemblyPanel:OnRelease()
end
function UIGunTalentAssemblyPanel:OnClickCloseButton()
  UIManager.CloseUI(UIDef.UIGunTalentAssemblyPanel)
  if self.needMoveCamera then
    BarrackHelper.CameraMgr:StartCameraMoving(BarrackCameraOperate.TalentTreeToOverview)
  end
end
function UIGunTalentAssemblyPanel:SetGunData()
  self.mGunCmdData = NetCmdTeamData:GetGunByID(self.mGunId)
end
function UIGunTalentAssemblyPanel:InitPluginSlots()
  local privateSlotDataList = NetCmdTalentData:GetPrivateSlotData(self.mGunId)
  local publicSlotDataList = NetCmdTalentData:GetPublicSlotData(self.mGunId)
  local slotItemData
  self.slotUI = {}
  self:LuaUIBindTable(self.ui.mTrans_GrpSlot, self.slotUI)
  for i = 0, privateSlotDataList.Count - 1 do
    do
      slotItemData = privateSlotDataList[i]
      local slotItem = UIGunTalentPluginSlot.New()
      if i == 0 then
        slotItem:InitCtrl(self.slotUI.mComSlotOne)
      elseif i == 1 then
        slotItem:InitCtrl(self.slotUI.mComSlotTwo)
      elseif i == 2 then
        slotItem:InitCtrl(self.slotUI.mComSlotThree)
      end
      slotItem:SetData(true, slotItemData, self.mGunId, i)
      UIUtils.GetButtonListener(slotItem.ui.mBtn_SlotItem.gameObject).onClick = function()
        self:OnClickSlotItem(slotItem)
      end
      table.insert(self.privateSlotList, slotItem)
    end
  end
  for i = 0, publicSlotDataList.Count - 1 do
    do
      slotItemData = publicSlotDataList[i]
      local slotItem = UIGunTalentPluginSlot.New()
      if i == 0 then
        slotItem:InitCtrl(self.slotUI.mShareSlotOne)
      elseif i == 1 then
        slotItem:InitCtrl(self.slotUI.mShareSlotTwo)
      elseif i == 2 then
        slotItem:InitCtrl(self.slotUI.mShareSlotThree)
      end
      slotItem:SetData(false, slotItemData, self.mGunId, i)
      UIUtils.GetButtonListener(slotItem.ui.mBtn_SlotItem.gameObject).onClick = function()
        self:OnClickSlotItem(slotItem)
      end
      table.insert(self.publicSlotList, slotItem)
    end
  end
end
function UIGunTalentAssemblyPanel:OnClickSlotItem(slotItem)
  setactive(self.ui.mTrans_GrpArrow.gameObject, false)
  self.curSelectPlugin = nil
  self.curSelectUid = nil
  if self.curSlotItem == slotItem then
  else
    if self.curSlotItem ~= nil then
      self.curSlotItem.ui.mBtn_Self.interactable = true
    end
    self.curSlotItem = slotItem
    self.curSlotItem.ui.mBtn_Self.interactable = false
  end
  self:InitPluginList(slotItem, nil)
end
function UIGunTalentAssemblyPanel:RefreshSlotItem(slotItem, isPrivate, pluginItemData)
  slotItem:SetData(isPrivate, pluginItemData, self.mGunId)
end
function UIGunTalentAssemblyPanel:OnClickConfirm(data, assemblyType)
  if self.canClickConfirm == false then
    return
  end
  if assemblyType == self.AssemblyType.Equip then
    if self.curSlotItem.isPrivate then
      NetCmdTalentData:SendChangePrivateSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, data.itemId, function()
        UIUtils.PopupPositiveHintMessage(180012)
      end)
    elseif data.ownerId == 0 or data.ownerId == self.mGunId then
      NetCmdTalentData:SendChangePublicSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, data.uId, function()
        UIUtils.PopupPositiveHintMessage(180012)
      end)
    else
      local gunName = TableData.listGunDatas:GetDataById(data.ownerId).first_name.str
      local text = TableData.GetHintReplaceById(180016, gunName)
      MessageBox.Show(TableData.GetHintById(208), text, nil, function()
        NetCmdTalentData:SendChangePublicSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, data.uId, function()
          UIUtils.PopupPositiveHintMessage(180012)
        end)
      end, nil)
    end
  elseif assemblyType == self.AssemblyType.Unload then
    if self.curSlotItem.isPrivate then
      NetCmdTalentData:SendChangePrivateSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, 0, function()
        UIUtils.PopupPositiveHintMessage(180013)
      end)
    else
      NetCmdTalentData:SendChangePublicSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, 0, function()
        UIUtils.PopupPositiveHintMessage(180013)
      end)
    end
    UIUtils.PopupPositiveHintMessage(180013)
  elseif assemblyType == self.AssemblyType.Replace then
    if self.curSlotItem.isPrivate then
      if data.ownerId == 0 or data.ownerId == self.mGunId then
        NetCmdTalentData:SendChangePrivateSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, data.itemId, function()
          UIUtils.PopupPositiveHintMessage(180014)
        end)
      else
        gfwarning("专属技能插件不可能属于其他人形！")
      end
    elseif data.ownerId == 0 or data.ownerId == self.mGunId then
      NetCmdTalentData:SendChangePublicSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, data.uId, function()
        UIUtils.PopupPositiveHintMessage(180014)
      end)
    else
      local gunName = TableData.listGunDatas:GetDataById(data.ownerId).first_name.str
      local text = TableData.GetHintReplaceById(180016, gunName)
      MessageBox.Show(TableData.GetHintById(208), text, nil, function()
        NetCmdTalentData:SendChangePublicSkillsItemBelong(self.mGunId, self.curSlotItem.slotId, data.uId, function()
          UIUtils.PopupPositiveHintMessage(180014)
        end)
      end, nil)
    end
  end
  self.canClickConfirm = true
end
function UIGunTalentAssemblyPanel:OpenPluginList()
  setactive(self.ui.mBtn_Back.gameObject, false)
  setactive(self.ui.mBtn_Home.gameObject, false)
  setactive(self.ui.mBtn_Des.gameObject, false)
  setactive(self.ui.mTrans_GrpLeft.gameObject, true)
  self.mAnimator:SetTrigger("Set2")
  self.isShowPluginList = true
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BackFromList)
end
function UIGunTalentAssemblyPanel:ClosePluginList()
  setactive(self.ui.mTrans_GrpArrow.gameObject, true)
  setactive(self.ui.mBtn_Back.gameObject, true)
  setactive(self.ui.mBtn_Home.gameObject, true)
  setactive(self.ui.mBtn_Des.gameObject, true)
  self.mAnimator:SetTrigger("Set1")
  if self.isShowPluginInfo then
    setactive(self.ui.mTrans_GrpRight.gameObject, false)
    self.isShowPluginInfo = false
  end
  if self.curSlotItem ~= nil then
    self.curSlotItem.ui.mBtn_Self.interactable = true
    self.curSlotItem = nil
  end
  if self.curSelectPlugin ~= nil then
    setactive(self.curSelectPlugin.ui.mTrans_Select.gameObject, false)
    self.curSelectPlugin.ui.mBtn_Select.interactable = true
    self.curSelectPlugin = nil
  end
  self.curSelectUid = nil
  self.isShowPluginList = false
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
end
function UIGunTalentAssemblyPanel:InitPluginList(slotItem, templist)
  if not self.isShowPluginList then
    self:OpenPluginList()
  end
  if slotItem.mSlotItemData.itemId ~= 0 then
    self.curEquipPlugin = slotItem.mSlotItemData
  else
    self.curEquipPlugin = nil
  end
  self.pluginDataList = {}
  local list
  if templist then
    list = templist
  elseif slotItem.isPrivate then
    list = NetCmdTalentData:GetPrivateSkillsItem(self.mGunId)
  else
    list = NetCmdTalentData:GetPublicSkillsItem(self.mGunId)
  end
  setactive(self.ui.mTransLeftNone.gameObject, list.Count == 0)
  setactive(self.ui.mTrans_LeftList.gameObject, list.Count ~= 0)
  setactive(self.ui.mTrans_GrpScreen.gameObject, list.Count ~= 0)
  if list ~= nil and 0 < list.Count then
    for i = 0, list.Count - 1 do
      table.insert(self.pluginDataList, list[i])
    end
    setactive(self.ui.mTrans_GrpRight.gameObject, true)
    self.isShowPluginInfo = true
    self:SetSortItem(list)
    if not slotItem.isPrivate then
      setactive(self.ui.mText_ListDuty.gameObject, true)
      local dutyId = TableData.listGunDatas:GetDataById(self.mGunId).duty
      local dutyText = TableData.listGunDutyDatas:GetDataById(dutyId).name.str
      self.ui.mText_ListDuty.text = TableData.GetHintReplaceById(180030, dutyText)
    else
      setactive(self.ui.mText_ListDuty.gameObject, false)
    end
  else
    setactive(self.ui.mText_ListDuty.gameObject, false)
    if self.isShowPluginInfo then
      setactive(self.ui.mTrans_GrpRight.gameObject, false)
      self.isShowPluginInfo = false
    end
    if slotItem.isPrivate then
      self.ui.mText_LeftNone.text = TableData.GetHintById(180027)
    else
      self.ui.mText_LeftNone.text = TableData.GetHintById(180028)
    end
  end
  local virtualList = self.ui.mVirtualList_Plugin
  function virtualList.itemProvider()
    local item = self:PluginItemProvider()
    return item
  end
  function virtualList.itemRenderer(index, renderDataItem)
    self:PluginItemRenderer(index, renderDataItem)
  end
  virtualList.numItems = 0
  virtualList.numItems = list.Count
  virtualList:Refresh()
  virtualList:SetConstraintCount(list.Count)
  if not self.curSlotItem.isPrivate then
    self:SetScroll()
  end
end
function UIGunTalentAssemblyPanel:PluginItemProvider()
  local itemView = UIGunTalentPluginItem.New()
  local renderDataItem = CS.RenderDataItem()
  itemView:InitCtrl()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIGunTalentAssemblyPanel:PluginItemRenderer(index, renderDataItem)
  local itemData = self.pluginDataList[index + 1]
  local item = renderDataItem.data
  UIUtils.GetButtonListener(UIUtils.GetButton(renderDataItem.renderItem).gameObject).onClick = function()
    self:OnClickPluginItem(item)
  end
  item:SetData(itemData, self.curSlotItem.isPrivate, self.mGunId)
  item:SetSelect(false)
  if self.curSelectPlugin then
    local same = false
    if self.curSlotItem.isPrivate then
      same = self.curSelectUid == itemData.itemId
    else
      same = self.curSelectUid == itemData.uId
    end
    if same then
      self:OnClickPluginItem(item)
    end
  end
  if self.curEquipPlugin then
    local same = false
    if self.curSlotItem.isPrivate then
      same = self.curEquipPlugin.itemId == itemData.itemId
    else
      same = self.curEquipPlugin.uId == itemData.uId
    end
    if same then
      item:SetEquip(true)
      if self.curSelectPlugin == nil then
        self:OnClickPluginItem(item)
      end
    else
      item:SetEquip(false)
    end
  else
    item:SetEquip(false)
  end
  if self.curSelectPlugin == nil and self.curEquipPlugin == nil and #self.pluginDataList > 0 then
    local data = self.pluginDataList[1]
    local same = false
    if self.curSlotItem.isPrivate then
      same = data.itemId == itemData.itemId
    else
      same = data.uId == itemData.uId
    end
    if same then
      self:OnClickPluginItem(item)
    end
  end
end
function UIGunTalentAssemblyPanel:SetScroll()
  if #self.pluginDataList > 0 then
    for i = 1, #self.pluginDataList do
      local itemData = self.pluginDataList[i]
      if self.curEquipPlugin then
        local same = false
        if self.curSlotItem.isPrivate then
          same = self.curEquipPlugin.itemId == itemData.itemId
        else
          same = self.curEquipPlugin.uId == itemData.uId
        end
        if same then
          if #self.pluginDataList > 15 then
            if i > #self.pluginDataList - 12 then
              i = #self.pluginDataList - 12
            end
            self:ScrollToPosByIndex(i, true)
          end
          self:RefreshPluginInfo(self.pluginDataList[i])
        end
      elseif self.curSelectPlugin then
        local same = false
        if self.curSlotItem.isPrivate then
          same = self.curSelectUid == itemData.itemId
        else
          same = self.curSelectUid == itemData.uId
        end
        if same then
          if #self.pluginDataList > 15 then
            if i > #self.pluginDataList - 12 then
              i = #self.pluginDataList - 12
            end
            self:ScrollToPosByIndex(i, true)
          end
          self:RefreshPluginInfo(self.pluginDataList[i])
        end
      end
    end
    if self.curSelectPlugin == nil and self.curEquipPlugin == nil then
      self:ScrollToPosByIndex(1, true)
      self:RefreshPluginInfo(self.pluginDataList[1])
    end
  end
end
function UIGunTalentAssemblyPanel:ScrollToPosByIndex(index, needAni)
  local content = self.ui.mScrollListChild_Content:GetComponent(typeof(CS.UnityEngine.RectTransform))
  local gridLayoutGroup = content.transform:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
  local offset = gridLayoutGroup.spacing.y + gridLayoutGroup.cellSize.y
  local moveY = offset * ((index - 1) / 3)
  if needAni then
    LuaDOTweenUtils.DOAnchorPosY(content, moveY, 0.5)
  else
    content.anchoredPosition = Vector2(content.anchoredPosition.x, moveY)
  end
end
function UIGunTalentAssemblyPanel:OnClickPluginItem(pluginItem)
  if pluginItem == nil then
    self.curSelectPlugin = nil
    self.curSelectUid = nil
    setactive(self.ui.mTrans_GrpRight.gameObject, false)
    self:SetConfirmBtnByType(self.AssemblyType.None)
  else
    if self.curSelectPlugin ~= nil then
      self.curSelectPlugin:SetSelect(false)
    end
    self.curSelectPlugin = pluginItem
    if self.curSlotItem.isPrivate then
      self.curSelectUid = pluginItem.pluginData.itemId
    else
      self.curSelectUid = pluginItem.pluginData.uId
    end
    self.curSelectPlugin:SetSelect(true)
    setactive(self.ui.mTrans_GrpRight.gameObject, true)
    self:RefreshPluginInfo(pluginItem.pluginData)
    for key, slot in pairs(self.privateSlotList) do
      slot:Refresh()
    end
    for key, slot in pairs(self.publicSlotList) do
      slot:Refresh()
    end
    if self.curSlotItem.mSlotItemData.itemId == 0 then
      self:SetConfirmBtnByType(self.AssemblyType.Equip)
    else
      local same = false
      if self.curSlotItem.isPrivate then
        same = self.curSlotItem.mSlotItemData.itemId == self.curSelectUid
      else
        same = self.curSlotItem.mSlotItemData.uId == self.curSelectUid
      end
      if same then
        self:SetConfirmBtnByType(self.AssemblyType.Unload)
      else
        self:SetConfirmBtnByType(self.AssemblyType.Replace)
      end
    end
  end
end
function UIGunTalentAssemblyPanel:SetSortItem(list)
  if self.comScreenItemV2 then
    self.comScreenItemV2:SetList(list)
  else
    self.comScreenItemV2 = ComScreenItemHelper:InitTalentSkill(self.ui.mTrans_GrpScreen.gameObject, list, function()
      self:OnClickSort()
    end, nil, 0)
  end
end
function UIGunTalentAssemblyPanel:OnClickSort()
  local templist = self.comScreenItemV2:GetResultList()
  self:InitPluginList(self.curSlotItem, templist)
end
function UIGunTalentAssemblyPanel:SetConfirmBtnByType(assemblyType)
  setactive(self.ui.mBtn_Set.gameObject, assemblyType == self.AssemblyType.Equip)
  setactive(self.ui.mBtn_Unload.gameObject, assemblyType == self.AssemblyType.Unload)
  setactive(self.ui.mBtn_Replace.gameObject, assemblyType == self.AssemblyType.Replace)
  if assemblyType == self.AssemblyType.Equip then
    UIUtils.GetButtonListener(self.ui.mBtn_Set.gameObject).onClick = function()
      self:OnClickConfirm(self.curSelectPlugin.pluginData, assemblyType)
    end
  elseif assemblyType == self.AssemblyType.Unload then
    UIUtils.GetButtonListener(self.ui.mBtn_Unload.gameObject).onClick = function()
      self:OnClickConfirm(self.curSelectPlugin.pluginData, assemblyType)
    end
  elseif assemblyType == self.AssemblyType.Replace then
    UIUtils.GetButtonListener(self.ui.mBtn_Replace.gameObject).onClick = function()
      self:OnClickConfirm(self.curSelectPlugin.pluginData, assemblyType)
    end
  end
  self.canClickConfirm = true
end
function UIGunTalentAssemblyPanel:RefreshPluginInfo(pluginData)
  local talentKeyData = TableData.listTalentKeyDatas:GetDataById(pluginData.itemId)
  local slotItemData = TableData.listItemDatas:GetDataById(pluginData.itemId)
  local jobStr = ""
  if talentKeyData.talent_key_type == 2 then
    if talentKeyData.require_job == 0 then
      jobStr = string_format(TableData.GetHintById(180033), TableData.GetHintById(180035))
    else
      local gunDutyData = TableData.listGunDutyDatas:GetDataById(talentKeyData.require_job)
      jobStr = string_format(TableData.GetHintById(180033), gunDutyData.name.str)
    end
  elseif talentKeyData.talent_key_type == 1 then
    jobStr = TableData.GetHintById(180034)
  end
  self.ui.mText_PluginType.text = jobStr
  self.ui.mText_PluginName.text = slotItemData.name.str
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(slotItemData.Rank)
  setactivewithcheck(self.ui.mText_SkillDescription, false)
  local pluginBattleSkillData = TableData.listBattleSkillDatas:GetDataById(talentKeyData.battle_skill_id, true)
  if pluginBattleSkillData then
    self.ui.mText_SkillDescription.text = pluginBattleSkillData.description.str
    setactivewithcheck(self.ui.mText_SkillDescription, true)
  end
  self.ui.mText_ItemDescription.text = slotItemData.introduction.str
  self:ShowPropertyNow(pluginData.TalentKeyStcData.PropertyId)
end
function UIGunTalentAssemblyPanel:PrivatePluginsSlotCallBack(msg)
  if msg.Sender.GunId == self.mGunId then
    local privateSlotDataList = NetCmdTalentData:GetPrivateSlotData(self.mGunId)
    for i = 0, privateSlotDataList.Count - 1 do
      local slotItemData = privateSlotDataList[i]
      local slotItem = self.privateSlotList[i + 1]
      slotItem:SetData(true, slotItemData, self.mGunId, i)
    end
  end
  self:OnClickPluginItem(nil)
  self:OnClickSlotItem(self.curSlotItem)
end
function UIGunTalentAssemblyPanel:PublicPluginsSlotCallBack(msg)
  local gun1Data = msg.Sender.Gun1
  local gun2Data = msg.Sender.Gun2
  local publicSlotDataList = NetCmdTalentData:GetPublicSlotData(self.mGunId)
  if gun1Data ~= nil and gun1Data.GunId == self.mGunId then
    for i = 0, publicSlotDataList.Count - 1 do
      local slotItemData = publicSlotDataList[i]
      local slotItem = self.publicSlotList[i + 1]
      slotItem:SetData(false, slotItemData, self.mGunId, i)
    end
  end
  if gun2Data ~= nil and gun2Data.GunId == self.mGunId then
    for i = 0, publicSlotDataList.Count - 1 do
      local slotItemData = publicSlotDataList[i]
      local slotItem = self.publicSlotList[i + 1]
      slotItem:SetData(false, slotItemData, self.mGunId, i)
    end
  end
  self:OnClickPluginItem(nil)
  self:OnClickSlotItem(self.curSlotItem)
end
function UIGunTalentAssemblyPanel:ShowPropertyNow(propertyId)
  for i, attributeScript in ipairs(self.attributeItemTable) do
    attributeScript:SetVisible(false)
  end
  local usedIndex = 1
  for j = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(j)
    if propertyType then
      local propertyValue = PropertyHelper.GetPropertyValueByEnum(propertyId, propertyType)
      if 0 < propertyValue then
        local propertyData = TableData.GetPropertyDataByName(propertyType:ToString())
        if propertyData then
          local name = propertyData.ShowName.str
          local nowValue = propertyValue
          if propertyData.ShowType == 2 then
            nowValue = nowValue / 10
            nowValue = math.floor(nowValue * 10 + 0.5) / 10
            nowValue = nowValue .. "%"
          end
          if usedIndex > #self.attributeItemTable then
            local template = self.ui.mScrollListChild_Attribute.childItem
            local go = UIUtils.InstantiateByTemplate(template, self.ui.mScrollListChild_Attribute.transform)
            local attrBar = self:NewAttrBar(go)
            table.insert(self.attributeItemTable, attrBar)
          end
          local attributeScript = self.attributeItemTable[usedIndex]
          attributeScript:Show(name, nowValue)
          attributeScript:SetVisible(true)
          usedIndex = usedIndex + 1
        end
      end
    end
  end
  self:SetLastAttrLineInvisible()
end
function UIGunTalentAssemblyPanel:NewAttrBar(go)
  local attrBar = {}
  function attrBar:BindGo(root)
    self.root = root
    self.ui = UIUtils.GetUIBindTable(root)
  end
  function attrBar:Show(name, value)
    self.ui.mText_Num.text = value
    self.ui.mText_Name.text = name
  end
  function attrBar:SetLineVisible(visible)
    setactive(self.ui.mTrans_Line, visible)
  end
  function attrBar:SetVisible(visible)
    setactive(self.root, visible)
  end
  function attrBar:OnRelease(isDestroy)
    if isDestroy then
      gfdestroy(self.root)
    end
  end
  attrBar:BindGo(go)
  return attrBar
end
function UIGunTalentAssemblyPanel:SetLastAttrLineInvisible()
  local count = #self.attributeItemTable
  for i, attributeScript in ipairs(self.attributeItemTable) do
    attributeScript:SetLineVisible(i ~= count)
  end
end
