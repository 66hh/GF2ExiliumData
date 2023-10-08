require("UI.UniTopbar.Item.ResourcesCommonItem")
require("UI.UIBaseCtrl")
UITopResourceBar = class("UITopResourceBar", UIBaseCtrl)
UITopResourceBar.__index = UITopResourceBar
UITopResourceBar.mCurrencyItemList = {}
UITopResourceBar.mStaminaItemList = {}
UITopResourceBar.mIsCommandCenter = false
UITopResourceBar.mIsPop = false
UITopResourceBar.mIndex = 0
UITopResourceBar.currencyParent = nil
function UITopResourceBar:ctor(csPanel)
  UITopResourceBar.super:ctor(csPanel)
end
function UITopResourceBar:InitFromPanel(root, resources, white)
  UITopResourceBar.super.SetRoot(self, root)
  self.mIsCommandCenter = white
  self:UpdateCurrencyContent(root, resources)
end
function UITopResourceBar:RegisterListeners()
  function self.OnUpdateItem()
    self:OnUpdateItemData()
  end
  function self.OnUpdateStamina()
    self:OnUpdateStaminaData()
  end
  MessageSys:AddListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.OnUpdateItem)
  MessageSys:AddListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.OnUpdateItem)
  MessageSys:AddListener(CS.GF2.Message.ModelDataEvent.StaminaUpdate, self.OnUpdateStamina)
end
function UITopResourceBar:Init(root, resources, white)
  UITopResourceBar.super.SetRoot(self, root)
  self.mIsCommandCenter = white
  if self.currencyParent == nil then
    return
  end
  self:UpdateCurrencyContent(self.currencyParent, resources)
end
function UITopResourceBar:UpdateCurrencyContent(root, resources)
  self.mCurrencyItemList = {}
  self.mStaminaItemList = {}
  local resItemList = self:GetResourcesDataList(resources)
  for i, data in ipairs(resItemList) do
    local item
    if i > #self.mCurrencyItemList then
      item = ResourcesCommonItem.New()
      item:InitCtrl(root, self.mIsCommandCenter)
      table.insert(self.mCurrencyItemList, item)
    else
      item = self.mCurrencyItemList[i]
    end
    local itemData = TableData.GetItemData(data.id)
    if itemData.type == GlobalConfig.ItemType.StaminaType then
      table.insert(self.mStaminaItemList, item)
    end
    item:SetData(data)
  end
end
function UITopResourceBar:FindCurrency()
  self.currencyParent = CS.TransformUtils.DeepFindChild(self.mParent, "GrpCurrency")
end
function UITopResourceBar:Hide()
  if self.mUIRoot == nil then
    return
  end
  setactive(self.mUIRoot, false)
end
function UITopResourceBar:Show()
  if self.mUIRoot == nil then
    return
  end
  self:RegisterListeners()
  for _, item in ipairs(self.mCurrencyItemList) do
    item:OnShow(self.isCommandCenter)
  end
end
function UITopResourceBar:GetResourcesDataList(str)
  local itemDataList = {}
  local strArr = string.split(str, ",")
  for _, v in ipairs(strArr) do
    if v ~= "" then
      local item = {}
      local temStr = string.split(v, ":")
      item.id = tonumber(temStr[1])
      item.jumpID = tonumber(temStr[2])
      item.param = tonumber(temStr[3])
      table.insert(itemDataList, item)
    end
  end
  return itemDataList
end
function UITopResourceBar:OnUpdate()
end
function UITopResourceBar:Close()
  if self.mUIRoot == nil then
    return
  end
  if self.OnUpdateItem then
    MessageSys:RemoveListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, self.OnUpdateItem)
  end
  if self.OnUpdateItem then
    MessageSys:RemoveListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.OnUpdateItem)
  end
  if self.OnUpdateStamina then
    MessageSys:RemoveListener(CS.GF2.Message.ModelDataEvent.StaminaUpdate, self.OnUpdateStamina)
  end
end
function UITopResourceBar:Release()
  printstack("      UITopResourceBar.Release       ")
  if self.mCurrencyItemList ~= nil then
    for _, item in ipairs(self.mCurrencyItemList) do
      item:OnRelease()
    end
    self.mCurrencyItemList = {}
    self.mStaminaItemList = {}
  end
end
function UITopResourceBar:ReleaseCurrencyItemList()
  if self.mCurrencyItemList ~= nil then
    for _, item in ipairs(self.mCurrencyItemList) do
      item:OnRelease()
    end
    self.mCurrencyItemList = {}
    self.mStaminaItemList = {}
  end
end
function UITopResourceBar:OnUpdateItemData()
  for _, item in ipairs(self.mCurrencyItemList) do
    item:UpdateData()
  end
end
function UITopResourceBar:OnUpdateStaminaData()
  for _, item in ipairs(self.mStaminaItemList) do
    item:UpdateData()
  end
end
function UITopResourceBar.UpdateParent(parent, isCommandCenter)
  for _, item in ipairs(self.mCurrencyItemList) do
    CS.LuaUIUtils.SetParent(item:GetRoot().gameObject, parent.gameObject, true)
    if isCommandCenter ~= nil then
      UIUtils.GetAnimator(item:GetRoot()):SetBool("CommandCenterW", isCommandCenter)
    end
  end
end
