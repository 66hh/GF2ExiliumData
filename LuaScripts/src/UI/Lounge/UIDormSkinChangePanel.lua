require("UI.UIBasePanel")
require("UI.Lounge.UIDormChangeSkinSlot")
require("UI.Lounge.DormGlobal")
UIDormSkinChangePanel = class("UIDormSkinChangePanel", UIBasePanel)
UIDormSkinChangePanel.__index = UIDormSkinChangePanel
function UIDormSkinChangePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIDormSkinChangePanel:OnAwake(root, data)
end
function UIDormSkinChangePanel:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self.slotTable = nil
  self.curSlotIndex = 0
  local id = data
  self.bpClothes = nil
  if data and type(data) == "userdata" then
    id = data[0]
    if data.Length > 1 then
      self.bpClothes = data[1]
    end
  end
  self.gunCmdData = NetCmdLoungeData:GetCurrGunCmdData()
  self:InitContent()
  self.ui.mBtn_Back.interactable = true
end
function UIDormSkinChangePanel:InitContent()
  function self.ui.mVirtualList.itemProvider(renderData)
    return self:slotProvider(renderData)
  end
  function self.ui.mVirtualList.itemRenderer(index, renderData)
    self:slotRenderer(index, renderData)
  end
  function self.onContentValueChanged()
    gfdebug(self.ui.mRect_Content.anchoredPosition.x .. " " .. self.ui.mRect_Content.anchoredPosition.x)
  end
  self.isShow = false
  self.ui.mText_Name.text = TableData.GetHintById(280009)
  self.ui.mText_Name0.text = TableData.GetHintById(280008)
  self.ui.mBtn_Change.interactable = true
  self.ui.mBtn_TakeOff.interactable = true
  self.slotTable = self:initAllSlot()
  if #self.slotTable <= 0 then
    self:SetNoneState()
    return
  end
  setactive(self.ui.mTrans_None, false)
  setactive(self.ui.mVirtualList.transform, true)
  self.curSlotIndex = self:getEquippedSkinSlotIndex()
  if self.curSlotIndex == -1 then
    self.curSlotIndex = 1
  end
end
function UIDormSkinChangePanel:SetNoneState()
  setactive(self.ui.mTrans_None, true)
  setactive(self.ui.mVirtualList.transform, false)
end
function UIDormSkinChangePanel:initAllSlot()
  local tempSlotTable = {}
  local gunData = TableDataBase.listGunDatas:GetDataById(self.gunCmdData.id)
  local tempTable = CSList2LuaTable(gunData.costume_replace)
  table.sort(tempTable, function(l, r)
    local clothesDataL = TableDataBase.listClothesDatas:GetDataById(l)
    local clothesDataR = TableDataBase.listClothesDatas:GetDataById(r)
    return clothesDataL.order < clothesDataR.order
  end)
  local curBPId = NetCmdBattlePassData:GetCurOrRecentBpId()
  local index = 1
  for i, clothesId in ipairs(tempTable) do
    local d = TableDataBase.listClothesDatas:GetDataById(clothesId)
    local isUnlock = NetCmdGunClothesData:IsUnlock(clothesId)
    if (d.display_config > 0 or d.display_config == 0 and isUnlock) and isUnlock and d.clothes_type == 2 then
      local slot = UIDormChangeSkinSlot.New()
      slot:SetData(self.gunCmdData, d, index)
      slot:AddBtnClickListener(function(tempIndex)
        self:onClickSlot(tempIndex)
      end)
      index = index + 1
      table.insert(tempSlotTable, slot)
    end
  end
  return tempSlotTable
end
function UIDormSkinChangePanel:getEquippedSkinSlotIndex()
  for i, slot in ipairs(self.slotTable) do
    if slot:GetClothesId() == self.gunCmdData.dormCostume then
      return slot:GetIndex()
    end
  end
  return -1
end
function UIDormSkinChangePanel:OnShowStart()
  self.isJumpToMain = false
  self:refresh(false, true)
  LoungeHelper.AnimCtrl:PlayAnimByName("Cloth_Idle")
end
function UIDormSkinChangePanel:OnShowFinish()
  LoungeHelper.CameraCtrl.isDebug = false
  self:scrollToCurSlotIndex(false)
end
function UIDormSkinChangePanel:refresh(needGunClothesAnim, isRefresh)
  self.ui.mVirtualList.numItems = #self.slotTable
  self.ui.mVirtualList:Refresh()
  self:refreshModel(needGunClothesAnim)
  self:refreshGrpBtn()
end
function UIDormSkinChangePanel:OnBackFrom()
  self:refresh(false)
end
function UIDormSkinChangePanel:slotProvider(renderData)
  local skinCardTemplate = self.ui.mScrollListChild_SkinCard.childItem
  local slotTrans = UIUtils.InstantiateByTemplate(skinCardTemplate, self.ui.mScrollListChild_SkinCard.transform)
  slotTrans.position = vectorone * 1000
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = slotTrans.gameObject
  renderDataItem.data = nil
  return renderDataItem
end
function UIDormSkinChangePanel:slotRenderer(index, renderData)
  local slot = self.slotTable[index + 1]
  local go = renderData.renderItem
  slot:SetRoot(go.transform)
  if slot:GetIndex() == self.curSlotIndex then
    slot:Select()
  else
    slot:Deselect()
  end
  slot:Refresh()
end
function UIDormSkinChangePanel:scrollToCurSlotIndex(isSmooth)
  self:scrollTo(self.curSlotIndex, isSmooth)
end
function UIDormSkinChangePanel:scrollTo(index, isSmooth)
  if not index then
    return
  end
  local targetIndex = index - 1
  if targetIndex < 0 then
    targetIndex = 0
  end
  if self.listTween then
    LuaDOTweenUtils.Kill(self.listTween, false)
  end
  local getter = function(tempSelf)
    return Vector2(tempSelf.ui.mRect_Content.offsetMin.x, tempSelf.ui.mRect_Content.offsetMax.x)
  end
  local setter = function(tempSelf, value)
    if value.x + value.y > -self.ui.mLoopGrid_List.ItemSize.y or value.x > 0 or value.y > 0 then
      return
    end
    tempSelf.ui.mRect_Content.offsetMin = Vector2(value.x, tempSelf.ui.mRect_Content.offsetMin.y)
    tempSelf.ui.mRect_Content.offsetMax = Vector2(value.y, tempSelf.ui.mRect_Content.offsetMax.y)
  end
  self.ui.mVirtualList:ScrollTo(targetIndex, isSmooth, nil, ScrollAlign.Center)
end
function UIDormSkinChangePanel:OnHideFinish()
  if not self.isJumpToMain then
    LoungeHelper.CameraCtrl.CameraPreObj:ExitLookAt()
  end
end
function UIDormSkinChangePanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self.ui.mBtn_Back.interactable = false
    UIManager.CloseUI(UIDef.UIDormSkinChangePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
    self.isJumpToMain = true
    LoungeHelper.CameraCtrl.CameraPreObj:ExitLookAt()
    SceneSys:UnloadLoungeScene()
  end
  UIUtils.AddBtnClickListener(self.ui.mBtn_Change.gameObject, function()
    self:onClickChangeClothes()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_TakeOff.gameObject, function()
    self:onClickTakeOff()
  end)
  function self.onEndDrag(eventData)
    local value = self.ui.mVirtualList.horizontalNormalizedPosition
    if value < 0 then
      value = 0
    elseif 1 < value then
      value = 1
    end
    local index = math.floor(value * self.ui.mVirtualList.content.sizeDelta.x / (self.ui.mLayoutGroup.spacing.x + self.ui.mVirtualList.paddingWidth) + 0.5) + 1
    self:onClickSlot(index)
  end
  self.ui.mVirtualList:AddOnEndDrag(self.onEndDrag)
end
function UIDormSkinChangePanel:onClickTakeOff()
  local curSlot = self:getCurSlot()
  if curSlot == nil then
    return
  end
  local clothesData = curSlot:GetClothesData()
  self.ui.mBtn_Change.interactable = false
  self.ui.mBtn_TakeOff.interactable = false
  NetCmdLoungeData:SendChangeCostumeCmd(self.gunCmdData.id, 0, function(ret)
    if ret ~= ErrorCodeSuc then
      return
    end
    self:ChangeSkinFunction(0)
  end)
end
function UIDormSkinChangePanel:onClickChangeClothes()
  local curSlot = self:getCurSlot()
  local clothesData = curSlot:GetClothesData()
  NetCmdGunClothesData:SetDormPreviewedRecord(clothesData.id)
  self.ui.mBtn_Change.interactable = false
  self.ui.mBtn_TakeOff.interactable = false
  NetCmdLoungeData:SendChangeCostumeCmd(self.gunCmdData.id, clothesData.id, function(ret)
    if ret ~= ErrorCodeSuc then
      return
    end
    self:ChangeSkinFunction(clothesData.id)
  end)
end
function UIDormSkinChangePanel:ChangeSkinFunction(clothID)
  self:RootAnimatorPlayAnimByTrigger("FadeOut")
  LoungeHelper.AnimCtrl:PlayAnimByName("Cloth_Before", function()
    self:refresh(false)
    self.gunCmdData:SetDormCostume(clothID)
    UISystem.UISystemBlackCanvas:PlayFadeOutEnhanceBlack(0.2, function()
      CS.LoungeModelManager.Instance:SwitchGunModel(self.gunCmdData.id, function()
        UISystem.UISystemBlackCanvas:PlayFadeInEnhanceBlack(0.2, function()
        end)
        LoungeHelper.AnimCtrl:PlayAnimByName("Cloth_After", function()
          local text = TableData.GetHintById(230009)
          PopupMessageManager.PopupPositiveString(text)
          self.ui.mBtn_Change.interactable = true
          self.ui.mBtn_TakeOff.interactable = true
          self:RootAnimatorPlayAnimByTrigger("FadeIn")
          LoungeHelper.AnimCtrl:PlayAnimByName("Cloth_Idle")
        end)
      end, false)
    end)
  end)
end
function UIDormSkinChangePanel:onClickVisual()
  self.isShow = not self.isShow
  if self.isShow then
    setactive(self.ui.mTrans_Icon1, false)
    setactive(self.ui.mTrans_Icon2, true)
    setactive(self.ui.mTrans_Right, true)
  else
    setactive(self.ui.mTrans_Icon1, true)
    setactive(self.ui.mTrans_Icon2, false)
    setactive(self.ui.mTrans_Right, false)
  end
end
function UIDormSkinChangePanel:refreshModel(needGunClothesAnim)
end
function UIDormSkinChangePanel:refreshGrpBtn()
  setactivewithcheck(self.ui.mBtn_Change, false)
  setactivewithcheck(self.ui.mBtn_TakeOff, false)
  if #self.slotTable <= 0 then
    return
  end
  local curSlot = self:getCurSlot()
  if curSlot == nil then
    setactivewithcheck(self.ui.mBtn_Change, true)
    return
  end
  local clothesData = curSlot:GetClothesData()
  local isFocusEquipped = curSlot:GetClothesId() == self.gunCmdData.dormCostume
  if isFocusEquipped then
    setactivewithcheck(self.ui.mBtn_TakeOff, true)
    return
  end
  if clothesData.unlock_type == 1 then
    setactivewithcheck(self.ui.mBtn_Change, true)
  elseif clothesData.unlock_type == 2 then
    local isUnlock = curSlot:IsUnlock()
    if isUnlock then
      setactivewithcheck(self.ui.mBtn_Change, true)
    end
  elseif clothesData.unlock_type == 3 then
    local isUnlock = curSlot:IsUnlock()
    if isUnlock then
      setactivewithcheck(self.ui.mBtn_Change, true)
    end
  elseif clothesData.unlock_type == 4 then
    local isUnlock = curSlot:IsUnlock()
    if isUnlock then
      setactivewithcheck(self.ui.mBtn_Change, true)
    end
  end
end
function UIDormSkinChangePanel:playChangeClothesAnim(clothesData)
end
function UIDormSkinChangePanel:onClickSlot(slotIndex)
  if not slotIndex then
    return
  end
  if self.curSlotIndex == slotIndex then
    self:scrollToCurSlotIndex(true)
    return
  end
  if slotIndex <= 0 or slotIndex > #self.slotTable then
    return
  end
  local prevSlotIndex = self.curSlotIndex
  self.curSlotIndex = slotIndex
  self:onSwitchedSelectSlotAfter(prevSlotIndex, self.curSlotIndex)
end
function UIDormSkinChangePanel:onSwitchedSelectSlotAfter(prevSlotIndex, curSlotIndex)
  self:refresh(true)
  self:scrollToCurSlotIndex(true)
  local curSlot = self:getCurSlot()
  if curSlot == nil then
    return
  end
  local clothesData = curSlot:GetClothesData()
  if curSlot:IsUnlock() then
    NetCmdGunClothesData:SetDormPreviewedRecord(clothesData.id)
  end
end
function UIDormSkinChangePanel:getCurSlot()
  return self.slotTable[self.curSlotIndex]
end
function UIDormSkinChangePanel:refreshGunDesc()
end
function UIDormSkinChangePanel:OnClose()
  LoungeHelper.CameraCtrl.isDebug = true
  self.ui.mBtn_Change.interactable = true
  self.ui.mBtn_TakeOff.interactable = true
end
