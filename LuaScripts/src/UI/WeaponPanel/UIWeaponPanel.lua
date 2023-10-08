require("UI.UIBasePanel")
UIWeaponPanel = class("UIWeaponPanel", UIBasePanel)
UIWeaponPanel.__index = UIWeaponPanel
UIWeaponPanel.curType = 0
UIWeaponPanel.tabList = {}
UIWeaponPanel.enhanceContent = nil
UIWeaponPanel.breakContent = nil
UIWeaponPanel.weaponPartContent = nil
UIWeaponPanel.attributeList = {}
UIWeaponPanel.weaponModel = nil
UIWeaponPanel.weaponInfoContent = nil
UIWeaponPanel.partsList = {}
UIWeaponPanel.curSlot = nil
UIWeaponPanel.evolutionList = {}
UIWeaponPanel.curEvolution = 0
UIWeaponPanel.curIndex = 0
UIWeaponPanel.OpenFromType = {
  Repository = 0,
  Barrack = 1,
  BattlePass = 2,
  RepositoryWeaponCompose = 3,
  BattlePassCollection = 4,
  GachaPreview = 5
}
local self = UIWeaponPanel
function UIWeaponPanel:ctor()
  UIWeaponPanel.super.ctor(self)
end
function UIWeaponPanel:OnClose()
  for _, tabItem in pairs(self.tabList) do
    if tabItem then
      tabItem:OnRelease()
    end
  end
  UIWeaponPanel.tabList = {}
  self:ReleaseCtrlTable(self.partsList, true)
  self.partsList = {}
  self:ReleaseCtrlTable(self.attributeList)
  self.attributeList = {}
  if self.enhanceContent then
    self.enhanceContent:OnClose()
  end
  if self.breakContent then
    self.breakContent:OnClose()
  end
  if self.weaponPartContent then
    self.weaponPartContent:OnClose()
  end
  if self.weaponInfoContent then
    self.weaponInfoContent:OnClose()
  end
  self.mView:OnClose()
  self:OnRelease()
end
function UIWeaponPanel:Close()
  if self.enhanceContent.isLevelUpMode then
    self.enhanceContent:CloseEnhance()
  elseif self.breakContent.isLevelUpMode then
    self.breakContent:CloseBreak()
  else
    if self.curType == UIWeaponGlobal.WeaponPanelTab.Evolution then
      UIWeaponGlobal:UpdateWeaponModelByConfig(self.weaponData)
    end
    CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.FacilityBarrackEvent.Back2LastContent, nil)
    UIManager.CloseUI(UIDef.UIWeaponPanel)
  end
  UIModelToucher.ReleaseWeaponToucher()
  UIWeaponPanel.curType = 0
  UIWeaponPanel.curSlot = nil
  UIWeaponPanel.curIndex = 0
  if self.needModel then
    UIWeaponGlobal:ReleaseWeaponModel()
  end
end
function UIWeaponPanel:OnRelease()
  if self.enhanceContent ~= nil then
    self.enhanceContent:OnRelease()
  end
  if self.breakContent ~= nil then
    self.breakContent:OnRelease()
  end
  self.enhanceContent = nil
  self.breakContent = nil
  self.weaponPartContent = nil
  self.weaponInfoContent = nil
end
function UIWeaponPanel:OnInit(root, data)
  UIWeaponPanel.super.SetRoot(UIWeaponPanel, root)
  local weaponId = data[1]
  local type = data[2]
  local needModel = data[3]
  self.openFromType = data[4]
  self.weaponData = NetCmdWeaponData:GetWeaponById(weaponId)
  self.curType = type
  self.needModel = needModel
  UIWeaponPanel.mView = UIWeaponPanelView.New()
  UIWeaponPanel.mView:InitCtrl(root)
  UIWeaponPanel.enhanceContent = UIWeaponEnhanceContent.New(self.weaponData, self)
  UIWeaponPanel.enhanceContent:InitCtrl(self.mView.ui.mTrans_Enhance, self.mView.weaponListContent)
  UIWeaponPanel.breakContent = UIWeaponBreakContent.New(self.weaponData, self)
  UIWeaponPanel.breakContent:InitCtrl(self.mView.ui.mTrans_Break, self.mView.weaponBreakListContent)
  UIWeaponPanel.evolutionContent = UIWeaponEvolutionContent.New(self.weaponData, self)
  UIWeaponPanel.evolutionContent:InitCtrl(self.mView.ui.mTrans_Evolution, self.mView.weaponListContent)
  if needModel then
    UIManager.EnableFacilityBarrack(true)
    UIModelToucher.SetStartEulerDirect(UIUtils.SplitStrToVector(self.weaponData.Rotation))
    self:InitWeaponModel(true)
  end
  UIWeaponPanel.super.SetPosZ(UIWeaponPanel)
  UIUtils.GetButtonListener(self.mView.ui.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.mView.ui.mBtn_CommandCenter.gameObject).onClick = function()
    UIModelToucher.ReleaseWeaponToucher()
    self.curType = 0
    self.curSlot = nil
    self.curIndex = 0
    if self.needModel then
      UIWeaponGlobal:ReleaseWeaponModel()
    end
    UIManager.JumpToMainPanel()
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  end
  UIUtils.GetButtonListener(self.mView.ui.mBtn_Preview.gameObject).onClick = function()
    UIWeaponPanel:OnClickPreview()
  end
  function self.tempWeaponToucherBlendFinishCallback()
    self:onWeaponToucherBlendFinish()
  end
  self:InitTabBtn()
  self:InitEvolutionVirtualList()
  self:UpdateGunInfo()
  setactive(self.mView.weaponListContent.mUIRoot, false)
  setactive(self.mView.weaponBreakListContent.mUIRoot, false)
end
function UIWeaponPanel:onWeaponToucherBlendFinish()
  UIWeaponGlobal:PutUpWeaponForDev(self.weaponData.StcData)
  UIWeaponGlobal:EnableWeaponModel(true)
  UIModelToucher.ResetWeaponModelToucher()
end
function UIWeaponPanel:OnShowStart()
  setactive(UISystem.BarrackCharacterCameraCtrl.CharacterCamera, true)
  if self.curType ~= 0 then
    if self.curType == UIWeaponGlobal.WeaponPanelTab.Evolution then
      if self.weaponData.Rank == UIWeaponGlobal.SRRank and self.weaponData.IsReachMaxLv then
        self:UpdateTab(self.curType)
      else
        self:UpdateTab(UIWeaponGlobal.WeaponPanelTab.Enhance)
      end
    else
      self:UpdateTab(self.curType)
    end
  else
    self:UpdateTab(UIWeaponGlobal.WeaponPanelTab.Info)
  end
  UIWeaponGlobal:EnableWeaponModel(false)
  if self.openFromType == UIWeaponPanel.OpenFromType.Repository then
    FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.WeaponToucher, false)
  else
    FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.WeaponToucher)
  end
  self:onWeaponToucherBlendFinish()
  self:UpdateTabList()
end
function UIWeaponPanel:OnUpdate()
end
function UIWeaponPanel:InitWeaponModel(enableToucher)
  UIWeaponGlobal:UpdateWeaponModelByConfig(self.weaponData, false, enableToucher)
end
function UIWeaponPanel:RotateWeapon()
  local trans = self.weaponModel.transform
  CS.UITweenManager.PlayRotationTweenLoop(trans, 8)
end
function UIWeaponPanel:InitTabBtn()
  for i = 1, 5 do
    local item = UIBarrackCommonTabItem.New()
    item:InitCtrl(self.mView.ui.mTrans_TabList, true)
    item.tagId = i
    item.hintId = item:SetNameByHint(UIWeaponGlobal.WeaponTabHint[i])
    item.systemId = UIWeaponGlobal.SystemIdList[i]
    item:UpdateSystemLock()
    UIUtils.GetButtonListener(item.mBtn_ClickTab.gameObject).onClick = function()
      self:OnClickTab(item.tagId)
    end
    self.tabList[i] = item
    if item.tagId == UIWeaponGlobal.WeaponPanelTab.WeaponPart then
      self:UpdatePartTabLock()
    end
  end
  self:UpdateTabList()
end
function UIWeaponPanel:UpdateTabList()
  setactive(self.tabList[UIWeaponGlobal.WeaponPanelTab.Evolution].mUIRoot, false)
end
function UIWeaponPanel:RefreshPanel()
  setactive(self.mView.weaponListContent.mUIRoot, false)
  setactive(self.mView.weaponBreakListContent.mUIRoot, false)
  self:UpdateTab(self.curType)
  self:UpdateTabList()
end
function UIWeaponPanel:OnClickTab(id)
  if TipsManager.NeedLockTips(UIWeaponGlobal.SystemIdList[id]) or self.curType == id or id == nil or id <= 0 then
    return
  end
  if id == UIWeaponGlobal.WeaponPanelTab.Evolution then
    self.curIndex = 0
  end
  self:UpdateTab(id)
end
function UIWeaponPanel:UpdateTab(id)
  if self.curType > 0 then
    local lastTab = self.tabList[self.curType]
    lastTab:SetItemState(false)
    if self.curType == UIWeaponGlobal.WeaponPanelTab.Evolution then
      UIWeaponGlobal:UpdateWeaponModelByConfig(self.weaponData)
    end
  end
  local curTab = self.tabList[id]
  curTab:SetItemState(true)
  self.curType = id
  self:UpdatePanelByType(id)
end
function UIWeaponPanel:UpdatePanelByType(type)
  if type == UIWeaponGlobal.WeaponPanelTab.Info then
    self:UpdateWeaponDetail()
  elseif type == UIWeaponGlobal.WeaponPanelTab.Enhance then
    self.enhanceContent:ResetWeaponList()
    self.enhanceContent:UpdatePanel()
  elseif type == UIWeaponGlobal.WeaponPanelTab.Break then
    self.breakContent:ResetWeaponList()
    self.breakContent:UpdatePanel()
  elseif type == UIWeaponGlobal.WeaponPanelTab.Evolution then
    self:UpdateWeaponEvolution()
    self.evolutionContent:UpdateEvolutionWeapon(self.curEvolution)
  elseif type == UIWeaponGlobal.WeaponPanelTab.WeaponPart then
    self:UpdateWeaponPartsContent()
  end
  setactive(self.mView.ui.mTrans_WeaponInfo, type == UIWeaponGlobal.WeaponPanelTab.Info)
  setactive(self.mView.ui.mTrans_Enhance, type == UIWeaponGlobal.WeaponPanelTab.Enhance)
  setactive(self.mView.ui.mTrans_WeaponPartContent, type == UIWeaponGlobal.WeaponPanelTab.WeaponPart)
  setactive(self.mView.ui.mTrans_Break, type == UIWeaponGlobal.WeaponPanelTab.Break)
  setactive(self.mView.ui.mTrans_Evolution, type == UIWeaponGlobal.WeaponPanelTab.Evolution)
  setactive(self.mView.ui.mTrans_EvolutionList, type == UIWeaponGlobal.WeaponPanelTab.Evolution)
end
function UIWeaponPanel:UpdatePartTabLock()
  local hasPart = self.weaponData:CheckHasPart()
  if not hasPart then
    setactive(self.tabList[UIWeaponGlobal.WeaponPanelTab.WeaponPart].mUIRoot, false)
  end
end
function UIWeaponPanel:UpdateWeaponDetail()
  if self.weaponInfoContent == nil then
    self.weaponInfoContent = UIBarrackWeaponInfoItem.New()
    self.weaponInfoContent:InitCtrl(self.mView.ui.mTrans_WeaponInfo)
  end
  self.weaponInfoContent:SetData(self.weaponData)
  self.weaponInfoContent:SetWeaponInfoVisible(true)
  self:UpdatePreview()
  self:UpdateUse()
end
function UIWeaponPanel:UpdateSkill(skill, data)
  setactive(skill.obj, data ~= nil)
  if data then
    skill.imageIcon.sprite = UIUtils.GetIconSprite("Icon/Skill", data.icon)
    skill.txtName.text = data.name.str
    skill.txtDesc.text = data.description.str
  end
end
function UIWeaponPanel:UpdateLockStatue()
  setactive(self.mView.ui.mTrans_Lock, self.weaponData.IsLocked)
  setactive(self.mView.ui.mTrans_UnLock, not self.weaponData.IsLocked)
end
function UIWeaponPanel:UpdateAttribute(data)
  local attrList = {}
  local expandList = TableData.GetPropertyExpandList()
  for i = 0, expandList.Count - 1 do
    local lanData = expandList[i]
    if lanData.type == 1 then
      local value = data:GetPropertyByLevelAndSysName(lanData.sys_name, data.Level, data.BreakTimes)
      if 0 < value then
        local attr = {}
        attr.propData = lanData
        attr.value = value
        table.insert(attrList, attr)
      end
    end
  end
  table.sort(attrList, function(a, b)
    return a.propData.order < b.propData.order
  end)
  for _, item in ipairs(self.attributeList) do
    item:SetData(nil)
  end
  for i = 1, #attrList do
    local item
    if i <= #self.attributeList then
      item = self.attributeList[i]
    else
      item = PropertyItemS.New()
      item:InitCtrl(self.mView.ui.mTrans_Properties)
      table.insert(self.attributeList, item)
    end
    item:SetData(attrList[i].propData, attrList[i].value, i % 2 == 0, ColorUtils.WhiteColor, false)
  end
end
function UIWeaponPanel:UpdateGunInfo()
  if self.weaponData.gun_id ~= 0 then
    local gunData = TableData.listGunDatas:GetDataById(self.weaponData.gun_id)
    self.mView.ui.mImage_GunIcon.sprite = IconUtils.GetCharacterHeadSprite(gunData.code)
  end
  setactive(self.mView.ui.mTrans_Equipped, self.weaponData.gun_id ~= 0)
end
function UIWeaponPanel:OnClickLock()
  NetCmdWeaponData:SendGunWeaponLockUnlock(self.weaponData.id, function()
    self:UpdateLockStatue()
  end)
end
function UIWeaponPanel:UpdateWeaponPartsContent()
  self:UpdateWeaponPartsList(self.weaponData)
  if self.curSlot then
    self:OnClickPart(self.curSlot)
  end
end
function UIWeaponPanel:UpdateWeaponPartsList(data)
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
    return
  end
  if data == nil then
    return
  end
  for i, part in ipairs(self.partsList) do
    part:SetData(nil, nil)
  end
  local slotList = data.slotList
  for i = 0, slotList.Count - 1 do
    do
      local item = self.partsList[i + 1]
      if item == nil then
        item = UICommonItem.New()
        item:InitCtrl(self.mView.ui.mTrans_WeaponPartList)
        table.insert(self.partsList, item)
      end
      local data = data:GetWeaponPartByType(i)
      item:SetSlotData(data, slotList[i], i + 1)
      UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
        self:OnClickPart(item)
      end
    end
  end
  setactive(self.mView.ui.mTrans_WeaponPartsInfo, 0 < data.BuffSkillId)
end
function UIWeaponPanel:UpdateWeaponPartsListByType(type, partId)
  if partId == nil then
    return
  end
  local curSlot
  for _, slot in ipairs(self.partsList) do
    if slot.typeId and slot.typeId == type then
      curSlot = slot
      break
    end
  end
  local data = NetCmdWeaponPartsData:GetWeaponModById(partId)
  curSlot:SetData(data, curSlot.typeId)
end
function UIWeaponPanel:OnClickPart(item)
  if self.weaponPartContent == nil then
    self.weaponPartContent = UIWeaponPartsReplaceContent.New()
    self.weaponPartContent:InitCtrl(self.mView.ui.mTrans_WeaponPartContent, self.mParentObj)
    self.weaponPartContent:SetReplaceCallback(function()
      if self.weaponData then
        self:UpdateWeaponPartsList(self.weaponData)
      end
      self:InitWeaponModel()
      UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData, self.curSlot.slotId)
      MessageSys:SendMessage(CS.GF2.Message.UIEvent.OnChangeWeapon, nil)
      self.mView.ui.mVirtual_Evolution:Refresh()
      self:UpdateTabList()
      self:UpdateRedPoint()
    end)
    self.weaponPartContent:SetLockCallback(function(id)
      self:UpdateWeaponPartStateById(id)
    end)
    self.weaponPartContent:SetCloseCallback(function()
      self:CloseWeaponPartRelpace()
      UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData)
      UIModelToucher.ResetWeaponModelToucher()
    end)
    self.weaponPartContent:SetChangePartselectCallback(function()
      UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData, self.curSlot.slotId)
    end)
  end
  self:UpdateWeaponPartsList(self.weaponData)
  self.weaponPartContent:OnClickSuitTipsClose()
  if self.curSlot then
    self.curSlot:SetItemSelect(false)
  end
  self.curSlot = item
  self.curSlot:SetItemSelect(true)
  self.weaponPartContent:SetData(self.curSlot.partData, self.curSlot.typeId, self.weaponData.id, self.curSlot.slotId)
  setactive(self.weaponPartContent.mUIRoot, true)
  setactive(self.mView.ui.mTrans_Left, false)
  self:InitWeaponModel(false)
  UIModelToucher.ReleaseWeaponToucher()
  UIWeaponGlobal:PutUpWeaponForObservation(self.weaponData.StcData, self.curSlot.slotId)
end
function UIWeaponPanel:CloseWeaponPartRelpace()
  self:UpdateWeaponPartsList(self.weaponData)
  self.curSlot:SetItemSelect(false)
  self.curSlot = nil
  setactive(self.weaponPartContent.mUIRoot, false)
  setactive(self.mView.ui.mTrans_Left, true)
  UIModelToucher.ResetStartEuler()
end
function UIWeaponPanel:UpdateWeaponPartStateById(id)
  for i, part in ipairs(self.partsList) do
    if part.partData and part.partData.id == id then
      local data = NetCmdWeaponPartsData:GetWeaponModById(id)
      part:SetData(data, part.typeId)
      return
    end
  end
end
function UIWeaponPanel:UpdateWeaponEvolution()
  self.evolutionList = {}
  for i = 0, self.weaponData.AdvanceWeapon.Count - 1 do
    local itemData = {}
    itemData.data = self.weaponData.AdvanceWeapon[i]
    itemData.index = i
    table.insert(self.evolutionList, itemData)
  end
  self.curEvolution = self.evolutionList[self.curIndex + 1].data
  self.mView.ui.mVirtual_Evolution.numItems = #self.evolutionList
  self.mView.ui.mVirtual_Evolution:Refresh()
end
function UIWeaponPanel:InitEvolutionVirtualList()
  function self.mView.ui.mVirtual_Evolution.itemProvider()
    local item = self:EvolutionItemProvider()
    return item
  end
  function self.mView.ui.mVirtual_Evolution.itemRenderer(index, rendererData)
    self:EvolutionItemRenderer(index, rendererData)
  end
end
function UIWeaponPanel:EvolutionItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIWeaponPanel:EvolutionItemRenderer(index, rendererData)
  local itemData = self.evolutionList[index + 1]
  local item = rendererData.data
  local data = TableData.listGunWeaponDatas:GetDataById(itemData.data)
  item:SetData(itemData.data, data.default_maxlv, function(data)
    self:OnClickEvolutionWeapon(data, itemData.index)
  end)
  setactive(item.mTrans_Select, self.curEvolution == item.mData.id)
end
function UIWeaponPanel:OnClickEvolutionWeapon(item, index)
  self.curEvolution = item.mData.id
  if self.curIndex ~= index then
    self.mView.ui.mVirtual_Evolution:RefreshItem(self.curIndex)
    self.curIndex = index
  end
  setactive(item.mTrans_Select, true)
  self.evolutionContent:UpdateEvolutionWeapon(item.mData.id)
  UIWeaponGlobal:UpdateWeaponModelByConfig(NetCmdWeaponData:GetWeaponByStcId(self.curEvolution))
end
function UIWeaponPanel:OnClickPreview()
end
function UIWeaponPanel:UpdatePreview()
  setactive(self.mView.ui.mTrans_Preview, false)
end
function UIWeaponPanel:UpdateUse()
  if self.weaponData.StcData.character_id > 0 then
    local characterData = TableData.listGunCharacterDatas:GetDataById(self.weaponData.StcData.character_id)
    if not characterData then
      gferror("没有找到characterData characterId: " .. self.weaponData.StcData.character_id)
      return
    end
    self.mView.ui.mText_Gun.text = string_format(TableData.GetHintById(40039), characterData.name.str)
    setactive(self.mView.ui.mTrans_Use, true)
  else
    setactive(self.mView.ui.mTrans_Use, false)
  end
end
function UIWeaponPanel:SetWeaponStartEuler(euler)
  UIModelToucher.SetStartEuler(euler)
end
