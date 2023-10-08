require("UI.UIBasePanel")
UIDarkZoneStoreSingleSellDialog = class("UIDarkZoneStoreSingleSellDialog", UIBasePanel)
UIDarkZoneStoreSingleSellDialog.__index = UIDarkZoneStoreSingleSellDialog
function UIDarkZoneStoreSingleSellDialog:ctor(csPanel)
  UIDarkZoneStoreSingleSellDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneStoreSingleSellDialog:OnInit(root, data)
  UIDarkZoneStoreSingleSellDialog.super.SetRoot(UIDarkZoneStoreSingleSellDialog, root)
  self:InitBaseData()
  self.mData = data.Data
  self.tableData = data.storePanel
  self.SellPrice = data.SellPrice
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIDarkZoneStoreSingleSellDialog:OnShowFinish()
  self.IsPanelOpen = true
  self:InitInfoData()
end
function UIDarkZoneStoreSingleSellDialog:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneStoreSingleSellDialog:OnHideFinish()
  self.tableData:SetItemListClick()
end
function UIDarkZoneStoreSingleSellDialog:CloseFunction(skip)
  UIManager.CloseUI(UIDef.UIDarkZoneStoreSingleSellDialog)
  self.tableData.isSell = skip
end
function UIDarkZoneStoreSingleSellDialog:OnClose()
  self.ui.mSlider_Line.onValueChanged:RemoveAllListeners()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.GrpItem = nil
  self.AddExpNum = nil
  self.Slider = nil
  self.FavorList = nil
  self.SellList = nil
  self.FavorLevelList = nil
  self.ExpList = nil
  self.NextFavorList = nil
  self.NowFavorLevel = nil
  self.FakeValue = nil
end
function UIDarkZoneStoreSingleSellDialog:InitBaseData()
  self.mview = UIDarkZoneStoreSingleSellDialogView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.GrpItem = {}
  self.AddExpNum = 0
  self.Slider = true
  self.FavorList = {}
  self.SellList = {}
  self.FavorLevelList = {}
  self.ExpList = {}
  self.NextFavorList = {}
  self.NowFavorLevel = {}
  self.FakeValue = false
end
function UIDarkZoneStoreSingleSellDialog:InitInfoData()
  self.NowFavorLevel = self.tableData.FavorLevel
  self.NowFavorExp = self.tableData.FavorExp
  local AddRatio = 1000
  local NpcData = TableData.listDarkzoneNpcDatas:GetDataById(self.tableData.Npc)
  for k, v in pairs(NpcData.favor_item) do
    if k == self.mData.DarkZoneItemData.item_kind then
      AddRatio = v
      break
    end
  end
  local ration = AddRatio / 1000
  local BaseFavor = ration * self.mData.DarkZoneItemData.DarkzoneImpression
  BaseFavor = math.ceil(BaseFavor)
  local FavorLevel, FavorExp, NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(self.tableData.Npc, self.tableData.NpcFavor + BaseFavor)
  self.ui.mText_Level.text = DZStoreUtils:SetIndex(FavorLevel)
  self.ui.mText_ExpNum.text = FavorExp .. "/" .. NextFavor
  self.ui.mText_AddExpNum.text = "+" .. BaseFavor
  if self.NowFavorLevel ~= FavorLevel then
    setactive(self.ui.mSlider_Now.gameObject, false)
    self.ui.mSlider_Add.fillAmount = FavorExp / NextFavor
  else
    self.ui.mSlider_Now.fillAmount = self.NowFavorExp / NextFavor
    self.ui.mSlider_Add.fillAmount = FavorExp / NextFavor
  end
  if self.NowFavorLevel == TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel then
    self.ui.mText_AddExpNum.text = "+" .. 0
  elseif FavorLevel == TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel then
    self.ui.mText_AddExpNum.text = "+" .. FavorExp - self.tableData.NpcFavor
  end
  self.ui.mText_SellNum.text = 1
  self.ui.mText_ItemName.text = self.mData.ItemData.name.str
  self.ui.mText_Description.text = self.mData.ItemData.introduction.str
  local DZCoinStr = TableData.listItemDatas:GetDataById(18).icon
  self.ui.mImg_CoinIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. DZCoinStr)
  local LuaUIBindScript = self.ui.mBtn_GrpItem:GetComponent(UIBaseCtrl.LuaBindUi)
  local vars = LuaUIBindScript.BindingNameList
  for i = 0, vars.Count - 1 do
    self.GrpItem[vars[i]] = LuaUIBindScript:GetBindingComponent(vars[i])
  end
  TipsManager.Add(self.ui.mBtn_ItemDetails.gameObject, self.mData.ItemData)
  self.GrpItem.mImage_Bg.sprite = IconUtils.GetQuiltyByRank(self.mData.ItemData.rank)
  self.ui.mBtn_Select.interactable = false
  setactive(self.GrpItem.mTrans_Num, false)
  self.GrpItem.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. self.mData.ItemData.icon)
  self.SellNum = 1
  self.minnum = 1
  self.maxnum = self.mData.ItemCount
  self.ui.mText_MinNum.text = self.minnum
  self.ui.mText_MaxNum.text = self.maxnum
  for i = 1, self.maxnum do
    local CanGetNum = self.SellPrice * i
    self.SellList[i] = CanGetNum
    local CanGetFavor = BaseFavor * i
    self.FavorList[i] = CanGetFavor
    self.FavorLevelList[i], self.ExpList[i], self.NextFavorList[i] = DZStoreUtils:GetCurFavorLevelAndExp(self.tableData.Npc, self.tableData.NpcFavor + CanGetFavor)
  end
  self.ui.mText_GetNum.text = self.SellList[self.SellNum]
  if self.maxnum == 1 then
    self.ui.mSlider_Line.minValue = 1
    self.ui.mSlider_Line.maxValue = 2
    self.FakeValue = true
    self.ui.mSlider_Line.value = 2
    self.ui.mSlider_Line.interactable = false
    self.ui.mBtn_GrpIncrease.interactable = false
    self.ui.mBtn_GrpReduce.interactable = false
  else
    self.ui.mSlider_Line.value = 1
    self.ui.mSlider_Line.minValue = 1
    self.ui.mSlider_Line.maxValue = self.mData.ItemCount
    self.ui.mBtn_GrpReduce.interactable = false
  end
end
function UIDarkZoneStoreSingleSellDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickConfirm()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpReduce.gameObject).onClick = function()
    self:OnDecreaseItem()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpIncrease.gameObject).onClick = function()
    self:OnInCreaseItem()
  end
  self.ui.mSlider_Line.onValueChanged:AddListener(function(value)
    self:OnSliderChange(value)
  end)
end
function UIDarkZoneStoreSingleSellDialog:OnClickConfirm()
  if self.mData.IsItem == false then
    DarkNetCmdStoreData.Sellentities:Clear()
    DarkNetCmdStoreData.Sellentities:Add(self.mData.Id)
  else
    DarkNetCmdStoreData.SellOthers:Clear()
    local ProItem = CS.ProtoObject.Item()
    if self.mData.IsItem == false then
      ProItem.Id = self.mData.Id
    else
      ProItem.Id = self.mData.ItemId
    end
    ProItem.Num = self.SellNum
    DarkNetCmdStoreData.SellOthers:Add(ProItem)
  end
  DZStoreUtils:GetCurFavorLevelAndExp(self.tableData.Npc, self.tableData.NpcFavor)
  DarkNetCmdStoreData:SellItem(self.tableData.Npc, function()
    self:CloseFunction(true)
    DarkNetCmdStoreData:ReqMessage(function()
      self.mData.ItemCount = self.mData.ItemCount - self.SellNum
      if self.mData.ItemCount <= 0 then
        DarkNetCmdStoreData:RemoveStorageItem(self.mData.mIndex)
      end
      DarkNetCmdStoreData:SendCS_DarkZoneStorage()
      local Nextfavorlevel = self.FavorLevelList[self.SellNum]
      if Nextfavorlevel ~= self.NowFavorLevel then
        local data = {}
        data.From = self.NowFavorLevel
        data.To = Nextfavorlevel
        UIManager.OpenUIByParam(UIDef.UIDarkZoneFavorUpDownDialog, data)
      else
        UIManager.OpenUI(UIDef.UICommonReceivePanel)
      end
    end)
  end)
end
function UIDarkZoneStoreSingleSellDialog:OnInCreaseItem()
  if self.SellNum < self.maxnum then
    self.SellNum = self.SellNum + 1
    self:SetValue()
  end
end
function UIDarkZoneStoreSingleSellDialog:OnDecreaseItem()
  if self.SellNum > self.minnum then
    self.SellNum = self.SellNum - 1
    self:SetValue()
  end
end
function UIDarkZoneStoreSingleSellDialog:OnSliderChange(value)
  self.ui.mSlider_Line.value = value
  local RealValue = math.floor(value)
  self.SellNum = RealValue
  if self.SellNum >= self.maxnum then
    self.SellNum = self.maxnum
  elseif self.SellNum < self.minnum then
    self.SellNum = self.minnum
  end
  self:SetValue()
  if value >= self.maxnum or value <= self.minnum then
    self.Slider = false
  else
    self.Slider = true
  end
  if self.Slider == false then
    return
  end
end
function UIDarkZoneStoreSingleSellDialog:SetValue()
  self.ui.mText_SellNum.text = self.SellNum
  self.ui.mText_GetNum.text = self.SellList[self.SellNum]
  if self.FakeValue then
    self.ui.mSlider_Line.value = 2
  else
    self.ui.mSlider_Line.value = self.SellNum
  end
  self.ui.mBtn_GrpIncrease.interactable = true
  self.ui.mBtn_GrpReduce.interactable = true
  if self.SellNum == self.maxnum then
    self.ui.mBtn_GrpIncrease.interactable = false
  end
  if self.SellNum == self.minnum then
    self.ui.mBtn_GrpReduce.interactable = false
  end
  self.ui.mText_AddExpNum.text = "+" .. self.FavorList[self.SellNum]
  self.ui.mText_Level.text = DZStoreUtils:SetIndex(self.FavorLevelList[self.SellNum])
  self.ui.mText_ExpNum.text = self.ExpList[self.SellNum] .. "/" .. self.NextFavorList[self.SellNum]
  if self.NowFavorLevel ~= self.FavorLevelList[self.SellNum] then
    setactive(self.ui.mSlider_Now.gameObject, false)
    self.ui.mSlider_Add.fillAmount = self.ExpList[self.SellNum] / self.NextFavorList[self.SellNum]
  else
    setactive(self.ui.mSlider_Now.gameObject, true)
    self.ui.mSlider_Now.fillAmount = self.NowFavorExp / self.NextFavorList[self.SellNum]
    self.ui.mSlider_Add.fillAmount = self.ExpList[self.SellNum] / self.NextFavorList[self.SellNum]
  end
  if self.NowFavorLevel == TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel then
    self.ui.mText_AddExpNum.text = "+" .. 0
  elseif self.FavorLevelList[self.SellNum] == TableDataBase.GlobalDarkzoneData.DarkzoneNpcMaxFavorLevel then
    self.ui.mText_AddExpNum.text = "+" .. self.ExpList[#self.ExpList] - self.tableData.NpcFavor
  end
  self.TotalPrice = self.SellList[self.SellNum]
end
