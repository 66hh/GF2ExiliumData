require("UI.UIBaseCtrl")
UIGachaOptionItem = class("UIGachaOptionItem", UIBaseCtrl)
UIGachaOptionItem.__index = UIGachaOptionItem
function UIGachaOptionItem:__InitCtrl()
end
function UIGachaOptionItem:InitCtrl(itemPrefab)
  if itemPrefab == nil then
    return
  end
  local obj = instantiate(itemPrefab.childItem, itemPrefab.transform)
  self:InitCtrlWithoutInstantiate(obj)
end
function UIGachaOptionItem:InitCtrlWithoutInstantiate(obj, setToZero)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Preview.gameObject, function()
    local listType = CS.System.Collections.Generic.List(CS.System.Int32)
    local mlist = listType()
    mlist:Add(self.id)
    mlist:Add(FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
    mlist:Add(0)
    SceneSwitch:SwitchByID(4001, false, mlist)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Item.gameObject, function()
    self:ClickFunction()
  end)
end
function UIGachaOptionItem:SetData(id)
  self.id = id
  local gunData = TableDataBase.listGunDatas:GetDataById(id)
  self.ui.mText_Name.text = gunData.name.str
  self.ui.mImg_Avatar.sprite = ResSys:GetCharacterAvatarFullName("Avatar_Half_" .. gunData.en_name)
  setactive(self.ui.mTrans_Gray, GashaponNetCmdHandler.GachaOptionalTimes < TableData.GlobalSystemData.GachaSelfSelectedProcess)
  setactive(self.ui.mTrans_Get, GashaponNetCmdHandler.GachaOptionalTimes >= TableData.GlobalSystemData.GachaSelfSelectedProcess and NetCmdTeamData:CheckHasGunByCharacterId(gunData.character_id))
  self.ui.mBtn_Item.enabled = GashaponNetCmdHandler.GachaOptionalTimes >= TableData.GlobalSystemData.GachaSelfSelectedProcess
end
function UIGachaOptionItem:SetSelected(value)
  setactive(self.ui.mTrans_Sel, value)
end
function UIGachaOptionItem:SetClickFunction(func)
  self.clickFunction = func
end
function UIGachaOptionItem:ClickFunction()
  self.clickFunction(self)
end
