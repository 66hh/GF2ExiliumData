require("UI.UAVPanel.UAVBreakAttributeItem")
require("UI.UAVPanel.UIUAVBreakDialogPanelView")
UIUAVBreakDialogPanel = class("UIUAVBreakDialogPanel", UIBasePanel)
function UIUAVBreakDialogPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUAVBreakDialogPanel:OnAwake(root, param)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  if self.topBar == nil then
    self.topBar = ResourcesCommonItem.New()
    self.topBar:InitCtrl(self.ui.mTrans_Topbar, true)
    self.topBar:SetData({
      id = GlobalConfig.CoinId
    })
  end
  UIUtils.GetButtonListener(self.ui.mUIContainer.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UAVBreakDialogPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UAVBreakDialogPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    local NowGrade = NetCmdUavData:GetUavGrade()
    local nextadvancedata = TableData.listUavAdvanceDatas:GetDataById(NowGrade + 1)
    local needCashNum = nextadvancedata.uav_cash
    local materialItemId = nextadvancedata.uav_material[0]
    local isItemEnough = false
    local owncash = NetCmdItemData:GetResItemCount(2)
    local breakItemNum = NetCmdItemData:GetNetItemCount(materialItemId)
    local condition1 = false
    local condition2 = false
    if needCashNum <= owncash and 1 <= breakItemNum then
      isItemEnough = true
    end
    if needCashNum <= owncash then
      condition1 = true
    end
    if 1 <= breakItemNum then
      condition2 = true
    end
    if isItemEnough then
      NetCmdUavData:SendUavUpGrade(function(ret)
        self:OnUpGradeCallback(ret)
      end)
    elseif condition1 and condition2 == false then
      local str = string_format(TableData.GetHintById(225), TableData.GetItemData(7100).Name.str)
      CS.PopupMessageManager.PopupString(str)
    elseif condition1 == false and condition2 then
      local str = string_format(TableData.GetHintById(225), TableData.GetItemData(2).Name.str)
      CS.PopupMessageManager.PopupString(str)
    else
      local str = string_format(TableData.GetHintById(105033), TableData.GetItemData(7100).Name.str, TableData.GetItemData(2).Name.str)
      CS.PopupMessageManager.PopupString(str)
    end
  end
end
function UIUAVBreakDialogPanel:OnInit(root, param)
  self.uavPanel = param
end
function UIUAVBreakDialogPanel:OnUpGradeCallback(ret)
  if ret == ErrorCodeSuc then
    gfdebug("无人机突破成功")
    self.uavPanel:UpdateUavMainViewInfo()
    self.uavPanel:UpdateBottomSkillState()
    MessageSys:SendMessage(CS.GF2.Message.RedPointEvent.RedPointUpdate, "UAV")
    local NowGrade = NetCmdUavData:GetUavGrade()
    NowGrade = NowGrade - 1
    local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(NowGrade)
    local nextadvancedata = TableData.listUavAdvanceDatas:GetDataById(NowGrade + 1)
    local attributeList = {}
    local nowEquipNum = uavadvancedata.equip_num
    local nextEquipNum = nextadvancedata.equip_num
    if nowEquipNum < nextEquipNum then
      local attribute = {}
      attribute.name = TableData.GetHintById(105027)
      attribute.nownum = nowEquipNum
      attribute.tonum = nextEquipNum
      attribute.minus = nextEquipNum - nowEquipNum
      table.insert(attributeList, attribute)
    end
    local nowCost = uavadvancedata.cost
    local nextCost = nextadvancedata.cost
    if nowCost < nextCost then
      local attribute = {}
      attribute.name = TableData.GetHintById(105016)
      attribute.nownum = nowCost
      attribute.tonum = nextCost
      attribute.minus = nextCost - nowCost
      table.insert(attributeList, attribute)
    end
    local nowFuel = uavadvancedata.fuel
    local nextFuel = nextadvancedata.fuel
    if nowFuel < nextFuel then
      local attribute = {}
      attribute.name = TableData.GetHintById(105008)
      attribute.nownum = nowFuel
      attribute.tonum = nextFuel
      attribute.minus = nextFuel - nowFuel
      table.insert(attributeList, attribute)
    end
    for i = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
      local propertyType = DevelopProperty.__CastFrom(i)
      if propertyType then
        local nowPropertyValue = PropertyHelper.GetPropertyValueByEnum(uavadvancedata.property_id, propertyType)
        local nextPropertyValue = PropertyHelper.GetPropertyValueByEnum(nextadvancedata.property_id, propertyType)
        local delta = nextPropertyValue - nowPropertyValue
        if 0 < delta then
          local attribute = {}
          local developProperty = PropertyWrapper.Convert2Prop(propertyType:ToString())
          local propertyTypeStr = PropertyWrapper.Convert2TableStr(developProperty)
          local propertyData = TableData.GetPropertyDataByName(propertyTypeStr)
          if propertyData then
            attribute.name = propertyData.ShowName.str
          end
          attribute.nownum = nowPropertyValue
          attribute.tonum = nextPropertyValue
          attribute.minus = nextPropertyValue - nowPropertyValue
          table.insert(attributeList, attribute)
        end
      end
    end
    local data = {
      attributeList,
      fromlv = NowGrade,
      tolv = NowGrade + 1
    }
    UIManager.CloseUI(UIDef.UAVBreakDialogPanel)
    self:OpenSuccessBreakPanel(data)
  else
    gfdebug("无人机突破失败")
    MessageBox.Show("出错了", "无人机突破失败!", MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
  end
end
function UIUAVBreakDialogPanel:OpenSuccessBreakPanel(data)
  UIManager.OpenUIByParam(UIDef.UIUavBreakSuccessPanel, data)
end
function UIUAVBreakDialogPanel:OnShowStart()
  self.IsPanelOpen = true
  self:Refresh()
end
function UIUAVBreakDialogPanel:OnHide()
  self.IsPanelOpen = false
end
function UIUAVBreakDialogPanel:OnClose()
  self:ReleaseCtrlTable(self.itemViewTable, true)
end
function UIUAVBreakDialogPanel:OnRelease()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.topBar = nil
  self.IsPanelOpen = nil
end
function UIUAVBreakDialogPanel:InitBaseData()
  self.mview = UIUAVBreakDialogPanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.itemViewTable = {}
end
function UIUAVBreakDialogPanel:Refresh()
  local NowGrade = NetCmdUavData:GetUavGrade()
  local uavadvancedata = TableData.listUavAdvanceDatas:GetDataById(NowGrade)
  local nextadvancedata = TableData.listUavAdvanceDatas:GetDataById(NowGrade + 1)
  local nowEquipNum = uavadvancedata.equip_num
  local nextEquipNum = nextadvancedata.equip_num
  if nowEquipNum < nextEquipNum then
    local item = UAVBreakAttributeItem.New()
    local data = {}
    data.name = TableData.GetHintById(105027)
    data.now = nowEquipNum
    data.next = nextEquipNum
    item:InitCtrl(self.ui.mTrans_GrpAttribute)
    item:SetData(data)
  end
  local nowCost = uavadvancedata.cost
  local nextCost = nextadvancedata.cost
  if nowCost < nextCost then
    local item = UAVBreakAttributeItem.New()
    local data = {}
    data.name = TableData.GetHintById(105016)
    data.now = nowCost
    data.next = nextCost
    item:InitCtrl(self.ui.mTrans_GrpAttribute)
    item:SetData(data)
  end
  local nowFuel = uavadvancedata.fuel
  local nextFuel = nextadvancedata.fuel
  if nowFuel < nextFuel then
    local item = UAVBreakAttributeItem.New()
    local data = {}
    data.name = TableData.GetHintById(105008)
    data.now = nowFuel
    data.next = nextFuel
    item:InitCtrl(self.ui.mTrans_GrpAttribute)
    item:SetData(data)
  end
  for i = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(i)
    if propertyType then
      local nowPropertyValue = PropertyHelper.GetPropertyValueByEnum(uavadvancedata.property_id, propertyType)
      local nextPropertyValue = PropertyHelper.GetPropertyValueByEnum(nextadvancedata.property_id, propertyType)
      local delta = nextPropertyValue - nowPropertyValue
      if 0 < delta then
        local item = UAVBreakAttributeItem.New()
        local data = {}
        local developProperty = PropertyWrapper.Convert2Prop(propertyType:ToString())
        local propertyTypeStr = PropertyWrapper.Convert2TableStr(developProperty)
        local propertyData = TableData.GetPropertyDataByName(propertyTypeStr)
        if propertyData then
          data.name = propertyData.ShowName.str
        end
        data.now = nowPropertyValue
        data.next = nextPropertyValue
        item:InitCtrl(self.ui.mTrans_GrpAttribute)
        item:SetData(data)
        table.insert(self.itemViewTable, item)
      end
    end
  end
  self.ui.mText_Now.text = NowGrade
  self.ui.mText_Next.text = NowGrade + 1
  local materialArr = nextadvancedata.uav_material
  local materialItemId = materialArr[0]
  local materialCost = materialArr[1]
  local itemTemplate = self.ui.mScroll_Item.childItem
  local uiComItemV2 = UIComItemV2.New(self.ui.mScroll_Item.transform, itemTemplate)
  uiComItemV2:Init(materialItemId, materialCost)
  self.ui.mText_CostNum.text = nextadvancedata.uav_cash
  local owncash = NetCmdItemData:GetResItemCount(2)
  if owncash < nextadvancedata.uav_cash then
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  else
    self.ui.mText_CostNum.color = ColorUtils.StringToColor("1A2C33")
  end
end
