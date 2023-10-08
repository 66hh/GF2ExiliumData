require("UI.UIBasePanel")
UIDarkZoneSubEquipPanel = class("UIDarkZoneSubEquipPanel", UIBaseCtrl)
UIDarkZoneSubEquipPanel.__index = UIDarkZoneSubEquipPanel
UIDarkZoneSubEquipPanel.mView = nil
function UIDarkZoneSubEquipPanel:ctor()
end
function UIDarkZoneSubEquipPanel:InitCtrl(root, parentClass)
  self.parentClass = parentClass
  self:SetRoot(root)
  self.ui = {}
  self.equippedCache = {}
  self.repoItemListCache = nil
  self.mView = UIDarkZoneSubEquipPanelView.New()
  self.mView:InitCtrl(root, self.ui)
  self.comScreenItem = nil
  self.ui.mAnimator_Right:SetInteger("SwitchMyself", -1)
  self.ui.mAnimator_Right:SetInteger("SwitchLight", -1)
  self.typeNameList = {}
  for i = 1, 6 do
    local typeName = TableData.GetHintById(903171 + i)
    table.insert(self.typeNameList, typeName)
  end
  table.insert(self.typeNameList, TableData.GetHintById(903376))
  ComPropsDetailsHelper:InitComPropsDetailsItemObjNum(2)
  UIUtils.GetButtonListener(self.ui.mBtn_Install.gameObject).onClick = function()
    local isChange = DarkZoneNetRepoCmdData:SendCS_DarkZoneEquipOneClick()
    if self.repoItemList == nil or self.repoItemList.Count == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903093))
    elseif isChange then
      TimerSys:DelayCall(0.7, function()
        CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903104))
      end)
    end
    self.comScreenItem:DoFilter()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Uninstall.gameObject).onClick = function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneTakeOneClick()
    if self.equippedDict == nil or self.equippedDict.Count == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903095))
    else
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903106))
    end
    self.comScreenItem:DoFilter()
  end
  UIUtils.GetUIBlockHelper(self.ui.mUIRoot, self.ui.mTrans_DetailsLeft, function()
    self:ShowBriefLeft(false)
    self:ShowBriefRight(false)
  end)
  self.bagItem = {}
  self.repoItem = {}
  self.equippedItem = {}
  function self.refresh()
    self:ShowBriefLeft(false)
    self:ShowBriefRight(false)
    self.comScreenItem:SetList(DarkZoneNetRepoCmdData:GetRepoEquips(1, false, -1, 4, false))
    self.comScreenItem:DoFilter()
    self:SetEquipDict()
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkEquipped, self.refresh)
  self:InitRepoList()
  self:ShowBriefLeft(false)
  self:ShowBriefRight(false)
  self:ShowFilter(false)
  UIUtils.GetButtonListener(self.ui.mBtn_EffectNum.gameObject).onClick = function()
    local data = {}
    local equipList = DarkZoneNetRepoCmdData.EquippedDict
    data.dataType = 0
    data.list = equipList
    UIManager.OpenUIByParam(UIDef.UIDarkZonePropertyDetailDialog, data)
  end
  local data = {
    [1] = TableData.listReadmeTagDatas:GetDataById(9).tag_name.str,
    [2] = TableData.listReadmeTagDatas:GetDataById(9).hint_detail.str
  }
  UIUtils.GetButtonListener(self.ui.mBtn_Info.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, data)
  end
  setactive(self.ui.mAnimator_EffectFull, true)
  self.ui.mAnimator_EffectFull:SetInteger("Switch", 1)
end
function UIDarkZoneSubEquipPanel:ResetSort()
  self.sortItem:ResetItemListSort()
end
function UIDarkZoneSubEquipPanel:ShowBriefLeft(show)
  if not show then
    ComPropsDetailsHelper:Close(0)
  end
  setactive(self.ui.mTrans_DetailsLeft, show)
end
function UIDarkZoneSubEquipPanel:ShowBriefRight(show)
  if not show then
    ComPropsDetailsHelper:Close(1)
  end
  setactive(self.ui.mTrans_DetailsRight, show)
end
function UIDarkZoneSubEquipPanel:SortItemList(sortType, isAscend)
  self.sortType = sortType
  self.isAscend = isAscend
end
function UIDarkZoneSubEquipPanel:OnClickItem(data)
  self:ShowBriefLeft(true)
  if data.EquipData ~= nil and self.equippedDict:ContainsKey(data.EquipData.BuffType) then
    self:ShowBriefRight(true)
    self:ResetBriefBottomFunc(self.ui.mTrans_DetailsRight, UIDarkZoneBriefItem.ShowType.EquipEquipment, self.equippedDict[data.EquipData.BuffType], 1)
    self:ResetBriefBottomFunc(self.ui.mTrans_DetailsLeft, UIDarkZoneBriefItem.ShowType.EquipReplacement, data, 0)
  else
    self:ShowBriefRight(false)
    self:ResetBriefBottomFunc(self.ui.mTrans_DetailsLeft, UIDarkZoneBriefItem.ShowType.EquipEquipment, data, 0)
  end
end
function UIDarkZoneSubEquipPanel:OnClickEquippedItem(data)
  self:ShowBriefRight(false)
  self:ShowBriefLeft(true)
  self:ResetBriefBottomFunc(self.ui.mTrans_DetailsLeft, UIDarkZoneBriefItem.ShowType.EquipUninstall, data, 0)
end
function UIDarkZoneSubEquipPanel:InitRepoList()
  self.repoItemList = DarkZoneNetRepoCmdData:GetRepoEquips(1, false, -1, 4, false)
  self.equippedDict = DarkZoneNetRepoCmdData.EquippedDict
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualList_Repo.itemProvider = self.itemProvider
  self.ui.mVirtualList_Repo.itemRenderer = self.itemRenderer
  self.ui.mVirtualList_Repo.numItems = self.repoItemList.Count
  self.ui.mVirtualList_Repo:Refresh()
  self:SetEquipDict(true)
  self:InitScreen()
end
function UIDarkZoneSubEquipPanel:CheckChange(newRepoItemList)
  if (self.repoItemList == nil or self.repoItemList.Count <= 0) and (newRepoItemList == nil or newRepoItemList.Count <= 0) then
    return false
  end
  if self.repoItemList.Count ~= newRepoItemList.Count then
    return true
  end
  for i = 0, self.repoItemList.Count - 1 do
    if self.repoItemList[i] ~= newRepoItemList[i] then
      return true
    end
  end
  return false
end
function UIDarkZoneSubEquipPanel:SetEquipDict(isInit)
  if not isInit then
    local tmpResultList = self.comScreenItem:GetResultList()
    if self:CheckChange(tmpResultList) then
      self.parentClass.ui.mAnimator_Root:SetTrigger("Refresh_FadeIn")
    end
    self.repoItemList = tmpResultList
    self.ui.mVirtualList_Repo.numItems = self.repoItemList.Count
  end
  self.equippedDict = DarkZoneNetRepoCmdData.EquippedDict
  self.ui.mText_RepoTitle.text = TableData.GetHintById(903131) .. "【" .. DarkZoneNetRepoCmdData:GetRepoItemCount(1) .. "/" .. DarkZoneNetRepoCmdData:GetRepoValidCount(1) .. "】"
  if self.repoItemList.Count == 0 or self.repoItemList == nil then
    setactive(self.ui.mText_NoRepo.gameObject, true)
    self.ui.mText_NoRepo.text = TableData.GetHintById(903459)
  else
    setactive(self.ui.mText_NoRepo.gameObject, false)
  end
  local showFlowerFull = 0
  local lightLv = 0
  for i = 1, 7 do
    local item
    if self.equippedItem[i] == nil then
      item = UIDarkZoneComEquipItem.New()
      item:InitCtrl(self.ui["mTrans_BtnEquip" .. i])
      item:SetEquipTypeBg(i)
      self.equippedItem[i] = item
    else
      item = self.equippedItem[i]
    end
    if self.equippedDict:ContainsKey(i) then
      local equipData = self.equippedDict[i]
      item:SetDarkZoneEquipData(equipData, i, function(data)
        self:OnClickEquippedItem(equipData)
      end)
      if self.equippedCache[i] ~= equipData and not isInit then
        self.ui.mAnimator_Right:SetInteger("SwitchLight", i - 1)
        self.ui.mAnimator_Right:Play(tostring(i - 1), i, 0)
      end
      self.equippedCache[i] = equipData
      setactive(item.mUIRoot, true)
      if i == 7 then
        item.ui.mText_EquipLightNum.text = "+" .. self.equippedDict[i].lightLv
        item.ui.mText_EquipLightNum.color = CS.GF2.UI.UITool.StringToColor("DF9E00")
      else
        lightLv = lightLv + equipData.lightLv
      end
      showFlowerFull = showFlowerFull + 1
    else
      if self.equippedItem[i] ~= nil then
        self.equippedItem[i]:RemoveDarkZoneEquip()
        self.ui.mAnimator_Right:Play("New State", i)
        if not self.equippedItem[i].isSetBlank then
          self.equippedItem[i]:SetBlankClick(function()
            self.comScreenItem.FilterId = i
            self.comScreenItem:ShowFilterTrans(true, self.typeNameList[i])
            self.comScreenItem:DoFilter()
            self:SetEquipDict()
          end)
        end
      end
      self.equippedCache[i] = nil
    end
    if i == 6 then
      lightLv = lightLv // 6
    end
    if i == 7 and self.equippedDict:ContainsKey(i) then
      lightLv = lightLv + self.equippedDict[i].lightLv
    end
    item:SetRedDot(DarkZoneNetRepoCmdData:HasValidEquip(i))
  end
  if not isInit then
    if showFlowerFull == 7 then
      self.ui.mAnimator_EffectFull:SetInteger("Switch", 0)
    else
      self.ui.mAnimator_EffectFull:SetInteger("Switch", 1)
    end
  end
  self.ui.mText_Lightlv.text = lightLv
  self.ui.mVirtualList_Repo:Refresh()
end
function UIDarkZoneSubEquipPanel:ItemProvider()
  local item = UICommonItem.New()
  item:InitCtrl(self.ui.mTrans_RepoContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = item:GetRoot().gameObject
  renderDataItem.data = item
  return renderDataItem
end
function UIDarkZoneSubEquipPanel:ItemRenderer(index, renderDataItem)
  local itemData = self.repoItemList[index]
  local item = renderDataItem.data
  UIUtils.GetButtonListener(UIUtils.GetButton(renderDataItem.renderItem).gameObject).onClick = function()
    self:OnClickItem(itemData)
  end
  if itemData.EquipData ~= nil then
    item:SetItemData(itemData.EquipData.Id, itemData.lightLv, false, false, nil, nil, nil, function(data)
      if data.data ~= nil then
        self:OnClickItem(data.data)
      else
        self:ShowBriefRight(false)
        self:ShowBriefLeft(false)
      end
    end, nil, nil, itemData)
  end
  item.ui.mEquip_Light.sprite = IconUtils.GetAtlasIcon("BtnIcon/Icon_Btn_Darkzone_Energy")
  setactive(item.ui.mEquip_Light, true)
end
function UIDarkZoneSubEquipPanel:InitScreen()
  self.comScreenItem = ComScreenItemHelper:InitDarkZoneRepoComScreenItemV2(self.ui.mBtn_Screen.gameObject, self.repoItemList, function()
    self:SetEquipDict()
  end, self.ui.mUIRoot.gameObject, 0)
end
function UIDarkZoneSubEquipPanel:OnClickFilterBtn()
  setactive(self.ui.mTrans_Filter, not self.filterOn)
end
function UIDarkZoneSubEquipPanel:ShowFilter(isOn)
  self.filterOn = isOn
  setactive(self.ui.mTrans_Filter, isOn)
end
function UIDarkZoneSubEquipPanel:Close()
  self.mView = nil
  self.bagItem = {}
  for i = 1, #self.repoItem do
    self.repoItem[i]:DestroySelf()
  end
  self.repoItem = {}
  for i = 1, #self.equippedItem do
    self.equippedItem[i]:DestroySelf()
  end
  self.equippedItem = {}
  self.equippedCache = {}
  self.showFlowerFull = nil
end
function UIDarkZoneSubEquipPanel:Release()
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkEquipped, self.refresh)
  self.refresh = nil
  ComPropsDetailsHelper:Release()
  self.ui = nil
  if self.sortItem then
    self.sortItem:Release()
  end
  self.sortItem = nil
  if self.filterItem then
    self.filterItem:Release()
  end
  self.filterItem = nil
  self.comScreenItem:OnRelease()
end
function UIDarkZoneSubEquipPanel:ResetBriefBottomFunc(parent, type, data, index)
  local ShowItemDetail = function()
    UITipsPanel.Open(data.ItemData, 0, true)
  end
  ComPropsDetailsHelper:InitDarkItemData(parent.transform, type, data, ShowItemDetail, index)
  ComPropsDetailsHelper:OnClickExistBtn(function()
    if data.IsItem and data.ItemCount > 1 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRepositoryExistDialog, {data, false})
    else
      DarkZoneNetRepoCmdData:StorageMove(false, data, function()
        ComPropsDetailsHelper:Close()
      end)
    end
  end, index)
  ComPropsDetailsHelper:OnClickEquipedBtn(function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneEquip(data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903104))
      ComPropsDetailsHelper:Close()
    end)
  end, index)
  ComPropsDetailsHelper:OnClickTakeBtn(function()
    if data.IsItem and data.ItemCount > 1 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRepositoryExistDialog, {data, true})
    else
      DarkZoneNetRepoCmdData:StorageMove(true, data, function()
        ComPropsDetailsHelper:Close()
      end)
    end
  end, index)
  ComPropsDetailsHelper:OnClickUninstallBtn(function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneTake(data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903106))
      ComPropsDetailsHelper:Close()
    end)
  end, index)
  ComPropsDetailsHelper:OnClickReplaceBtn(function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneEquip(data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903105))
      ComPropsDetailsHelper:Close()
    end)
  end, index)
end
