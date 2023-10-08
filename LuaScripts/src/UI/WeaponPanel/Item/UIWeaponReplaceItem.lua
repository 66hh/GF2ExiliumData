require("UI.UIBaseCtrl")
UIWeaponReplaceItem = class("UIWeaponReplaceItem", UIBaseCtrl)
UIWeaponReplaceItem.__index = UIWeaponReplaceItem
function UIWeaponReplaceItem:ctor()
  UIWeaponReplaceItem.super.ctor(self)
  self.starList = {}
  self.slotList = {}
  self.suitList = {}
  self.rankColorList = {}
  self.weaponData = nil
  self.cmdData = nil
  self.ui = {}
end
function UIWeaponReplaceItem:__InitCtrl()
  for i = 1, UIWeaponGlobal.MaxStar do
    local obj = self:GetRectTransform("GrpNor/GrpStage/StageItem_" .. i)
    local item = self:InitUpgrade(obj)
    table.insert(self.starList, item)
  end
  for i = 1, UIWeaponGlobal.WeaponMaxSlot do
    local obj = self:GetRectTransform("GrpNor/Trans_GrpWeaponParts/GrpPosition" .. i)
    local item = self:InitSlot(obj)
    table.insert(self.slotList, item)
  end
  for i = 1, 2 do
    local obj = self:GetRectTransform("GrpNor/GrpSuit/SuitIcon" .. i)
    local item = self:InitSuit(obj)
    table.insert(self.suitList, item)
  end
  self.rankColorList = {
    self.ui.mImage_RankColor1,
    self.ui.mImage_RankColor2
  }
end
function UIWeaponReplaceItem:InitUpgrade(obj)
  if obj then
    local item = {}
    item.obj = obj
    item.transOn = UIUtils.GetRectTransform(obj, "Trans_On")
    item.transOff = UIUtils.GetRectTransform(obj, "Trans_Off")
    return item
  end
end
function UIWeaponReplaceItem:InitSlot(obj)
  if obj then
    local item = {}
    item.obj = obj
    item.imgOn = UIUtils.GetImage(obj, "Trans_On")
    item.transOff = UIUtils.GetRectTransform(obj, "ImgOff")
    return item
  end
end
function UIWeaponReplaceItem:InitSuit(obj)
  if obj then
    local item = {}
    item.obj = obj
    item.imgIcon = UIUtils.GetImage(obj, "Img_Icon")
    return item
  end
end
function UIWeaponReplaceItem:InitCtrl()
  local obj = instantiate(UIUtils.GetGizmosPrefab("Character/ChrBarrackWeaponListItemV2.prefab", self))
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(obj, self.ui)
  self:__InitCtrl()
end
function UIWeaponReplaceItem:SetData(data)
  if data then
    self.weaponData = data
    self.cmdData = NetCmdWeaponData:GetWeaponById(data.id)
    local elementData = TableData.listLanguageElementDatas:GetDataById(data.element)
    self.ui.mText_WeaponLv.text = GlobalConfig.SetLvText(data.level)
    self.ui.mImage_WeaponIcon.sprite = IconUtils.GetWeaponNormalSprite(data.stcData.res_code)
    if data.gunId ~= 0 then
      local gunData = TableData.listGunDatas:GetDataById(data.gunId)
      self.ui.mImage_GunIcon.sprite = IconUtils.GetCharacterHeadSprite(gunData.code)
    end
    setactive(self.ui.mTrans_Select, data.isSelect)
    self:UpdateRankColor()
    self:UpdateStar(data.breakTimes)
    self:UpdateSlot()
    self:UpdateSuitInfo()
    setactive(self.ui.mTrans_Equipped, data.gunId ~= 0)
    setactive(self.ui.mTrans_Lock, data.isLock)
    setactive(self.ui.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIWeaponReplaceItem:UpdateStar(star)
  for i, item in ipairs(self.starList) do
    setactive(item.transOn, i <= star)
    setactive(item.transOff, star < i)
  end
end
function UIWeaponReplaceItem:UpdateSlot()
  for i, part in ipairs(self.slotList) do
    setactive(part.obj, false)
  end
  local slotList = self.cmdData.slotList
  for i = 0, slotList.Count - 1 do
    local item = self.slotList[i + 1]
    local data = self.cmdData:GetWeaponPartByType(i)
    if data then
      item.imgOn.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
      setactive(item.imgOn.gameObject, true)
    else
      setactive(item.imgOn.gameObject, false)
    end
    setactive(item.obj, true)
  end
end
function UIWeaponReplaceItem:UpdateSuitInfo()
  for i, item in ipairs(self.suitList) do
    setactive(item.obj, false)
  end
  local list = self.cmdData:GetSuitList()
  for i = 0, list.Count - 1 do
    local item = self.suitList[i + 1]
    local suitData = TableData.listModPowerDatas:GetDataById(list[i])
    item.imgIcon.sprite = IconUtils.GetWeaponPartIcon(suitData.image)
    setactive(item.obj, true)
  end
end
function UIWeaponReplaceItem:UpdateRankColor()
  for _, rank in ipairs(self.rankColorList) do
    rank.color = TableData.GetGlobalGun_Quality_Color2(self.weaponData.rank)
  end
end
function UIWeaponReplaceItem:SetSelect(isSelect)
  setactive(self.ui.mTrans_Select, self.weaponData.isSelect)
end
function UIWeaponReplaceItem:SetNowEquip(isEquip)
  setactive(self.ui.mTrans_NowEquip, isEquip)
end
