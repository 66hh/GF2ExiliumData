require("UI.UIBasePanel")
UIGunBreakDialog = class("UIGunBreakDialog", UIBasePanel)
function UIGunBreakDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIGunBreakDialog:OnClickClose()
  UIManager.CloseUI(UIDef.UIGunBreakDialog)
end
function UIGunBreakDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickConfirm()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:OnClickClose()
  end
  self.levelUpAttr = self:InitAttribute(self.ui.mTrans_GrpLvelUp)
  self.attackAttr = self:InitAttribute(self.ui.mTrans_GrpAttack)
  self.itemList = {}
end
function UIGunBreakDialog:OnInit(root, data)
  self.gunData = NetCmdTeamData:GetGunByID(data)
  self:UdpatePanel()
end
function UIGunBreakDialog:InitAttribute(obj)
  if obj then
    local item = {}
    item.gameObject = obj
    self:LuaUIBindTable(obj, item)
    return item
  end
end
function UIGunBreakDialog:UdpatePanel()
  self:UpdateAttribute()
  self:UpdateCostItem()
end
function UIGunBreakDialog:UpdateAttribute()
  self:UpdateLvUpItem()
  self:UpdateAttrUpItem()
end
function UIGunBreakDialog:UpdateLvUpItem()
  if self.levelUpAttr then
    local curClass = self.gunData.curGunClass
    local nextClass = self.gunData.nextGunClass
    self.levelUpAttr.mText_NumNow.text = curClass.gun_level_max
    self.levelUpAttr.mText_NumAfter.text = nextClass.gun_level_max
  end
end
function UIGunBreakDialog:UpdateAttrUpItem()
  if self.attackAttr then
    local changeValue = {
      name = "",
      value = 0,
      afterValue = 0
    }
    local curClass = self.gunData.curGunClass
    local nextClass = self.gunData.nextGunClass
    local curAttr = CSDictionary2LuaTable(CS.PropertyHelper.GetPropertyStringDicById(curClass.property_id))
    local nextAttr = CSDictionary2LuaTable(CS.PropertyHelper.GetPropertyStringDicById(nextClass.property_id))
    for name, value in pairs(curAttr) do
      if name ~= "pow" and name ~= "max_hp" and name ~= "physical_shield" and name ~= "magical_shield" then
        local nextValue = nextAttr[name]
        if value < nextValue then
          changeValue.name = name
          changeValue.value = value
          changeValue.afterValue = nextValue
        end
      end
    end
    if changeValue.name ~= "" then
      local baseValue = self.gunData:GetGunBasePropertyValue(changeValue.name) + self.gunData:GetGunClassValueByName(changeValue.name)
      local propData = TableData.GetPropertyDataByName(changeValue.name, 1)
      self.attackAttr.mText_Name.text = propData.show_name.str
      self.attackAttr.mImg_Icon.sprite = IconUtils.GetAttributeIcon(propData.icon)
      if propData.show_type == 2 then
        self.attackAttr.mText_NumNow.text = math.ceil(baseValue / 10) .. "%"
        self.attackAttr.mText_NumAfter.text = math.ceil((baseValue + changeValue.afterValue) / 10) .. "%"
      else
        self.attackAttr.mText_NumNow.text = baseValue
        self.attackAttr.mText_NumAfter.text = baseValue + changeValue.afterValue
      end
    end
  end
end
function UIGunBreakDialog:UpdateCostItem()
  local coinItem = {}
  local itemList = {}
  for i, v in ipairs(self.itemList) do
    v:SetItemData(nil)
  end
  for id, num in pairs(self.gunData.curGunClass.item_cost) do
    if id == GlobalConfig.CoinId then
      coinItem = {id = id, num = num}
    else
      local item = {id = id, num = num}
      table.insert(itemList, item)
    end
  end
  table.sort(itemList, function(a, b)
    return a.id < b.id
  end)
  for i, item in ipairs(itemList) do
    if self.itemList[i] == nil then
      self.itemList[i] = UICommonItem.New()
      self.itemList[i]:InitCtrl(self.ui.mTrans_Content)
    end
    self.itemList[i]:SetItemData(item.id, item.num, true, true)
  end
  local count = NetCmdItemData:GetItemCountById(GlobalConfig.CoinId)
  if count < coinItem.num then
    self.ui.mText_Num.text = string_format("<color=#FF5E41>{0}</color>", coinItem.num)
  else
    self.ui.mText_Num.text = coinItem.num
  end
  self.coinNum = coinItem.num
end
function UIGunBreakDialog:OnClickConfirm()
  if not self:CheckItemEnough() then
    return
  end
  NetCmdTrainGunData:SendCmdGunClassUp(self.gunData.id, function(ret)
    if ret == ErrorCodeSuc then
      FacilityBarrackGlobal.GunDataDirty = true
      self:OnClickClose()
      UIManager.OpenUIByParam(UIDef.UICharacterBreakSuccPanel, self.gunData.id)
      RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.Barracks)
    end
  end)
end
function UIGunBreakDialog:CheckItemEnough()
  for i, item in ipairs(self.itemList) do
    if item.itemId ~= nil and not item:IsItemEnough() then
      UIUtils.PopupHintMessage(102073)
      return false
    end
  end
  if NetCmdItemData:GetItemCountById(GlobalConfig.CoinId) < self.coinNum then
    UIUtils.PopupHintMessage(102074)
    return false
  end
  return true
end
