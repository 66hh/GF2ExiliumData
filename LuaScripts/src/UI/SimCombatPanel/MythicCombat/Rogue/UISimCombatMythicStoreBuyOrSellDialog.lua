require("UI.UIBasePanel")
UISimCombatMythicStoreBuyOrSellDialog = class("UISimCombatMythicStoreBuyOrSellDialog", UIBasePanel)
UISimCombatMythicStoreBuyOrSellDialog.__index = UISimCombatMythicStoreBuyOrSellDialog
local self = UISimCombatMythicStoreBuyOrSellDialog
function UISimCombatMythicStoreBuyOrSellDialog:ctor(obj)
  UISimCombatMythicStoreBuyOrSellDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicStoreBuyOrSellDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicStoreBuyOrSellDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.rogueStoreState = data.rogueStoreState
  self.rogueStoreItemState = data.rogueStoreItemState
  self.storeGoodData = data.storeGoodData
  self.itemData = data.itemData
  self.rogueBuffCofigData = data.rogueBuffCofigData
  self.rogueShopsellData = data.rogueShopsellData
  self.canLevelUpBuff = data.canLevelUpBuff
  self.storeNum = data.storeNum
  self.curBuyNum = 0
  self.curCostNum = 0
  self.itemSprite = data.itemSprite
  self.costIcon = data.costIcon
  self.curRogueStoreType = data.curRogueStoreType
  self:SetRogueStoreDialogData()
  UIUtils.GetButtonListener(self.ui.mBtn_Exit.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStoreBuyOrSellDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStoreBuyOrSellDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_AmountPlusButton.gameObject).onClick = function()
    self:SetSliderValue(self.ui.mSlider_Item.value + 1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_AmountMinusButton.gameObject).onClick = function()
    self:SetSliderValue(self.ui.mSlider_Item.value - 1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_MultiPriceDetail.gameObject).onClick = function()
    CS.RoleInfoCtrlHelper.Instance:InitSysPresetDataById(self.itemData.Id)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    if self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
      self:RogueStoreBuy()
    elseif self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Sell then
      if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun and NetCmdSimCombatRogueData.RogueStage.PreGunIds.Count <= UISimCombatRogueGlobal.RoguePreGunCount then
        local hint = string_format(TableData.GetHintById(111048), UISimCombatRogueGlobal.RoguePreGunCount)
        local content = MessageContent.New(hint, MessageContent.MessageType.DoubleBtn)
        MessageBoxPanel.Show(content)
      else
        self:RogueStoreSell()
      end
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStoreBuyOrSellDialog)
  end
end
function UISimCombatMythicStoreBuyOrSellDialog:SetRogueStoreDialogData()
  local titleHint = 111051
  if self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy and self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
    titleHint = 111051
  elseif self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy and self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
    titleHint = 111049
  elseif self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Sell and self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
    titleHint = 111052
  elseif self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Sell and self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
    titleHint = 111050
  end
  self.ui.mText_Title.text = TableData.GetHintById(titleHint)
  setactive(self.ui.mTrans_Item, true)
  setactive(self.ui.mBtn_InfoOpen1, true)
  local item = UICommonItem.New()
  item:InitCtrl(self.ui.mScrollListChild_Item)
  item:SetItemData(self.itemData.Id, 1)
  local button = UIUtils.GetButtonListener(self.ui.mBtn_StoreDetail.gameObject)
  local targetButton = UIUtils.GetButtonListener(item.mBtn_Select.gameObject)
  button.onClick = targetButton.onClick
  button.param = targetButton.param
  button.paramData = targetButton.paramData
  item.mBtn_Select.enabled = false
  setactive(self.ui.mBtn_PriceDetails, false)
  if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
    setactive(self.ui.mBtn_InfoOpen1, true)
    setactive(self.ui.mTrans_Item, true)
    setactive(self.ui.mTrans_Buff, false)
  elseif self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
    setactive(self.ui.mBtn_InfoOpen1, false)
    setactive(self.ui.mTrans_Item, false)
    setactive(self.ui.mTrans_Buff, true)
    self.ui.mImg_Icon.sprite = IconUtils.GetItemIconSprite(self.itemData.Id)
    self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.Rank)
  end
  if self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
    self.ui.mText_ItemName.text = self.storeGoodData.Name.str
    self.ui.mText_Description.text = self.storeGoodData.Description.str
    self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.storeGoodData.Rank)
    self.ui.mText_PrefixText.text = TableData.GetHintById(106009)
    setactive(self.ui.mTrans_TextSell.gameObject, false)
  else
    self.ui.mText_ItemName.text = self.itemData.Name.str
    self.ui.mText_Description.text = self.itemData.Introduction.str
    self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.Rank)
    self.ui.mText_PrefixText.text = TableData.GetHintById(111057)
    setactive(self.ui.mTrans_TextSell.gameObject, true)
    if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
      self.ui.mText_TextSell.text = TableData.GetHintById(111023)
    elseif self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
      self.ui.mText_TextSell.text = TableData.GetHintById(111024)
    end
  end
  if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
    self.storeNum = 1
  end
  self.ui.mSlider_Item.maxValue = self.storeNum > 0 and self.storeNum or 1
  self.ui.mText_MaxNum.text = self.storeNum > 0 and self.storeNum or 1
  self.ui.mSlider_Item.minValue = 1
  self.ui.mText_MinNum.text = 1
  self.ui.mSlider_Item.value = 1
  self.ui.mSlider_Item.onValueChanged:AddListener(function(value)
    self:SetSliderValue(value)
  end)
  self:SetSliderValue(1)
  self.ui.mImage_GoldIcon.sprite = self.costIcon
end
function UISimCombatMythicStoreBuyOrSellDialog:SetSliderValue(num)
  if num == 0 then
    num = 1
  end
  self.curBuyNum = num
  self.ui.mSlider_Item.value = num
  self.ui.mText_AmountText.text = math.ceil(num)
  if self.rogueStoreState == UISimCombatRogueGlobal.RogueStoreTabBtnTypes.Buy then
    self.ui.mText_Price.text = 0
    if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
      self.ui.mText_Price.text = math.ceil(self.storeGoodData.price)
      self.curCostNum = self.storeGoodData.price
    elseif self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
      local tmpCost = UISimCombatRogueGlobal.GetBuffCost(self.storeGoodData, self.rogueBuffCofigData)
      self.ui.mText_Price.text = math.ceil(tmpCost)
      self.curCostNum = tmpCost
    end
    self.ui.mText_Price.color = ColorUtils.BlackColor
    self.ui.mText_AmountText.color = ColorUtils.BlackColor
    local isEnough = GlobalData.GetResourceItemCount(UISimCombatRogueGlobal.PriceType) < self.curCostNum
    self.ui.mBtn_AmountPlusButton.interactable = self.curBuyNum < self.storeNum and isEnough
    self.ui.mBtn_AmountMinusButton.interactable = 1 < self.curBuyNum and isEnough
    if isEnough then
      self.ui.mText_Price.color = ColorUtils.RedColor
      self.ui.mText_AmountText.color = ColorUtils.RedColor
    end
  else
    self.ui.mBtn_AmountPlusButton.interactable = self.curBuyNum < self.storeNum
    self.ui.mBtn_AmountMinusButton.interactable = 1 < self.curBuyNum
    local costType, costNum
    for cost, sellNum in pairs(self.rogueShopsellData.SellPrice) do
      costType = cost
      costNum = sellNum
    end
    self.ui.mText_Price.text = math.ceil(costNum * num)
  end
end
function UISimCombatMythicStoreBuyOrSellDialog:RogueStoreBuy()
  if GlobalData.GetResourceItemCount(UISimCombatRogueGlobal.PriceType) < self.curCostNum then
    local hint = TableData.GetHintById(111047)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if self.curBuyNum == 0 then
    return
  end
  NetCmdSimCombatRogueData:SendStoreBuy(self.storeGoodData.Id, self.curCostNum, self.curBuyNum, function(ret)
    if ret == ErrorCodeSuc then
      UIManager.CloseUI(UIDef.UISimCombatMythicStoreBuyOrSellDialog)
      local hint
      if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
        if self.canLevelUpBuff then
          local nextLevelRogueBuffData = TableData.listRogueBuffCofigDatas:GetDataById(self.rogueBuffCofigData.GroupId * 100 + self.rogueBuffCofigData.Level + 1)
          if nextLevelRogueBuffData ~= nil then
            hint = string_format(TableData.GetHintById(111031), nextLevelRogueBuffData.Name)
            CS.PopupMessageManager.PopupStateChangeString(hint)
          else
            printstack("mylog:Lua:" .. "没有下一等级buff？")
          end
        else
          hint = string_format(TableData.GetHintById(111030), self.rogueBuffCofigData.Name)
          CS.PopupMessageManager.PopupStateChangeString(hint)
        end
      elseif self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
        hint = string_format(TableData.GetHintById(111033), self.storeGoodData.Name)
        CS.PopupMessageManager.PopupStateChangeString(hint)
      end
    end
  end)
end
function UISimCombatMythicStoreBuyOrSellDialog:RogueStoreSell()
  if self.curBuyNum > 0 then
    NetCmdSimCombatRogueData:GetCS_SimCombatRogueSell(self.rogueShopsellData.Id, function(ret)
      if ret == ErrorCodeSuc then
        local itemDataName = TableData.listItemDatas:GetDataById(self.rogueShopsellData.SellGoods).Name
        if self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Buff then
          hint = string_format(TableData.GetHintById(111032), itemDataName)
          CS.PopupMessageManager.PopupStateChangeString(hint)
        elseif self.rogueStoreItemState == UISimCombatRogueGlobal.StoreTypes.Gun then
          hint = string_format(TableData.GetHintById(111034), itemDataName)
          CS.PopupMessageManager.PopupStateChangeString(hint)
          NetCmdSimCombatRogueData.RogueStage:RemovePreGun(self.rogueShopsellData.SellGoods)
        end
        UIManager.CloseUI(UIDef.UISimCombatMythicStoreBuyOrSellDialog)
      end
    end)
  end
end
function UISimCombatMythicStoreBuyOrSellDialog:OnHide()
  self.isHide = true
end
function UISimCombatMythicStoreBuyOrSellDialog:OnClose()
  UISimCombatMythicStoreDialog.RefreshRogueTab()
  self:ReleaseCtrlTable(self.tabList)
end
