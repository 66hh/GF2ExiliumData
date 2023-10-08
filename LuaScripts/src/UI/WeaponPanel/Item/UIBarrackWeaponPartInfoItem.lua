require("UI.UIBaseCtrl")
UIBarrackWeaponPartInfoItem = class("UIBarrackWeaponPartInfoItem", UIBaseCtrl)
UIBarrackWeaponPartInfoItem.__index = UIBarrackWeaponPartInfoItem
function UIBarrackWeaponPartInfoItem:ctor()
  UIBarrackWeaponPartInfoItem.super.ctor(self)
  self.data = nil
  self.stcData = nil
  self.lockCallback = nil
  self.mainProp = nil
  self.subPropList = {}
  self.suitItem = nil
  self.ui = {}
end
function UIBarrackWeaponPartInfoItem:__InitCtrl()
  self.mainProp = UICommonPropertyItem.New()
  self.mainProp:InitCtrl(self.ui.mTrans_MainProp, true)
  self:InitLockItem()
  UIUtils.GetButtonListener(self.lockItem.ui.btnLock.gameObject).onClick = function()
    self:OnClickLock()
  end
end
function UIBarrackWeaponPartInfoItem:InitLockItem()
  local parent = self.ui.mTrans_Lock
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitCtrl(parent)
end
function UIBarrackWeaponPartInfoItem:OnClose()
  self:ReleaseCtrlTable(self.subPropList, true)
  self.mainProp:OnRelease(true)
  self.suitItem:OnRelease(true)
end
function UIBarrackWeaponPartInfoItem:OnClickLock()
  NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.data.id, function()
    if self.lockCallback ~= nil then
      self.lockCallback(self.data.id, self.data.IsLocked)
    end
    self:UpdateLockStatue()
  end)
end
function UIBarrackWeaponPartInfoItem:UpdateLockStatue()
  setactive(self.lockItem.ui.transUnlock, not self.data.IsLocked)
  setactive(self.lockItem.ui.transLock, self.data.IsLocked)
end
function UIBarrackWeaponPartInfoItem:InitCtrl(root, lockCallback)
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.lockCallback = lockCallback
end
function UIBarrackWeaponPartInfoItem:SetData(data, suitCount)
  if data then
    self.data = data
    self.stcData = TableData.listWeaponModDatas:GetDataById(data.stcId)
    local typeData = TableData.listWeaponModTypeDatas:GetDataById(data.type)
    self.ui.mText_Name.text = data.name
    self.ui.mText_Type.text = typeData.name.str
    self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    self.ui.mText_Level.text = GlobalConfig.SetLvTextWithMax(data.level, self.stcData.max_level)
    self:UpdateLockStatue()
    self:UpdateMainProp()
    self:UpdateSubProp()
    self:UpdateSuitInfo(suitCount)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBarrackWeaponPartInfoItem:UpdateMainProp()
  self.mainProp:SetDataByName(self.data.mainProp, self.data.mainPropValue, true, false, false)
end
function UIBarrackWeaponPartInfoItem:UpdateSubProp()
  for i, item in ipairs(self.subPropList) do
    item:SetData(nil)
  end
  local dataList = self.data.subPropList
  for i = 0, dataList.Count - 1 do
    local data = dataList[i]
    local item = self.subPropList[i + 1]
    if item == nil then
      item = UICommonPropertyItem.New()
      item:InitCtrl(self.ui.mTrans_SubProp, true)
      table.insert(self.subPropList, item)
    end
    local rankList = self:GetSubPropRankList(data)
    item:SetData(data.propData, data.value, true, false, false, true)
    item:SetPropQuality(rankList)
  end
end
function UIBarrackWeaponPartInfoItem:UpdateSuitInfo(suitCount)
  if self.suitItem == nil then
    self.suitItem = UIWeaponModSuitItem.New()
    self.suitItem:InitCtrl(self.ui.mTrans_Suit, true)
  end
  if suitCount then
    self.suitItem:SetData(self.data.suitId, suitCount)
  else
    self.suitItem:SetData(self.data.suitId, self.data.suitCount)
  end
end
function UIBarrackWeaponPartInfoItem:GetSubPropRankList(data)
  local rankList = {}
  local affixData = TableData.listModAffixDatas:GetDataById(data.affixId)
  table.insert(rankList, affixData.rank)
  for i = 0, data.levelData.Count - 1 do
    local lvUpData = TableData.listPropertyLevelUpGroupDatas:GetDataById(data.levelData[i])
    table.insert(rankList, lvUpData.rank)
  end
  return rankList
end
function UIBarrackWeaponPartInfoItem:SetWeaponPartsInfoVisible(visible)
  if visible then
    if not self.data then
      setactive(self.ui.mText_WeaponPartsInfo, false)
      return
    end
    self.ui.mText_WeaponPartsInfo.text = self.data.des
  end
  setactive(self.ui.mText_WeaponPartsInfo, visible)
end
function UIBarrackWeaponPartInfoItem:SetVisible(visible)
  setactive(self:GetRoot(), visible)
end
