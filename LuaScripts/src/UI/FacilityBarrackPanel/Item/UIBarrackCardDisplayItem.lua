require("UI.UIBaseCtrl")
UIBarrackCardDisplayItem = class("UIBarrackCardDisplayItem", UIBaseCtrl)
UIBarrackCardDisplayItem.__index = UIBarrackCardDisplayItem
UIBarrackCardDisplayItem.starList = {}
UIBarrackCardDisplayItem.mData = nil
function UIBarrackCardDisplayItem:ctor()
  UIBarrackCardDisplayItem.super.ctor(self)
  self.starList = {}
  self.upgradeList = {}
  self.tableData = nil
  self.cmdData = nil
  self.curChipNum = 0
  self.unLockNeedNum = 0
end
function UIBarrackCardDisplayItem:__InitCtrl()
  self.mBtn_Gun = self.ui.mBtn_Gun
  self.mImg_Figure = self.ui.mImg_Figure
  self.mImg_Line = self.ui.mImg_Line
  self.mText_Level = self.ui.mText_Level
  self.mImage_Duty = self.ui.mImage_Duty
  self.mText_Name = self.ui.mText_Name
  self.mText_Type = self.ui.mText_Type
  self.mImage_Class = self.ui.mImage_Class
  self.mText_UnLockNum = self.ui.mText_UnLockNum
  self.mText_UnLockTotal = self.ui.mText_UnLockTotal
  self.mImage_Talent = self.ui.mImage_Talent
  self.mTrans_RedPoint = self.ui.mTrans_RedPoint
  self.animator = self.ui.animator
  local itemPrefab = self.ui.mTrans_Stage.transform:GetComponent(typeof(CS.ScrollListChild))
  for i = 1, TableData.GlobalSystemData.GunMaxGrade do
    local instObj = instantiate(itemPrefab.childItem)
    UIUtils.AddListItem(instObj.gameObject, self.ui.mTrans_Stage.gameObject)
    local upgrade = instObj.transform:Find("Trans_On").gameObject
    setactive(instObj.transform:Find("Trans_Off").gameObject, true)
    table.insert(self.upgradeList, upgrade)
  end
end
function UIBarrackCardDisplayItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self:__InitCtrl()
end
function UIBarrackCardDisplayItem:SetBaseData(gunId)
  if gunId then
    self.tableData = TableData.listGunDatas:GetDataById(gunId)
    local dutyData = TableData.listGunDutyDatas:GetDataById(self.tableData.duty)
    local avatar = IconUtils.GetCharacterGachaSprite(self.tableData.code)
    local color = TableData.GetGlobalGun_Quality_Color2(self.tableData.rank)
    self.mImg_Line.color = color
    self.mImg_Figure.sprite = avatar
    self.mText_Name.text = self.tableData.first_name.str
    self.mText_Type.text = self.tableData.second_name.str
    self.mImage_Duty.sprite = IconUtils.GetGunTypeIcon(dutyData.icon)
    self:SetNetData(gunId)
    setactive(self.mUIRoot, true)
    self.animator:SetBool("Locked", not self.isUnLock)
    setactive(self.ui.mTrans_Stage.gameObject, self.isUnLock)
  else
    setactive(self.mUIRoot, false)
  end
end
function UIBarrackCardDisplayItem:SetNetData(gunId)
  self.cmdData = NetCmdTeamData:GetGunByID(gunId)
  self.isUnLock = self.cmdData ~= nil
  if self.cmdData then
    self.mText_Level.text = string_format(TableData.GetHintById(102111), self.cmdData.level)
    self:SetUpgrade(self.cmdData.upgrade)
    self:SetTalent(self.cmdData.id)
  else
    self.itemData = TableData.listItemDatas:GetDataById(self.tableData.core_item_id)
    local curChipNum = NetCmdItemData:GetItemCount(self.itemData.id)
    local unLockNeedNum = tonumber(self.tableData.unlock_cost)
    self.mText_UnLockNum.text = curChipNum
    self.mText_UnLockTotal.text = "/" .. unLockNeedNum
  end
  self:UpdateRedPoint()
end
function UIBarrackCardDisplayItem:UpdateData()
  local cmdData = NetCmdTeamData:GetGunByID(self.tableData.id)
  self:SetNetData(cmdData)
end
function UIBarrackCardDisplayItem:Enable(enable)
  setactive(self.mUIRoot, enable)
end
function UIBarrackCardDisplayItem:SetGunRank(rank)
  if rank then
    for i = 1, #self.starList do
      setactive(self.starList[i], i <= rank)
    end
  end
end
function UIBarrackCardDisplayItem:SetUpgrade(upgrade)
  if upgrade then
    for i = 1, #self.upgradeList do
      setactive(self.upgradeList[i], i <= upgrade)
    end
  end
end
function UIBarrackCardDisplayItem:UpdateRedPoint()
  local count = 0
  if self.cmdData then
    count = NetCmdTeamData:UpdateUpgradeRedPoint(self.cmdData) + NetCmdTeamData:UpdateBreakRedPoint(self.cmdData) + NetCmdTeamData:UpdateWeaponModRedPoint(self.cmdData) + NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.cmdData.WeaponId, self.cmdData.GunId)
  else
    count = NetCmdTeamData:UpdateLockRedPoint(self.tableData)
  end
  setactive(self.mTrans_RedPoint, 0 < count)
end
function UIBarrackCardDisplayItem:SetTalent(id)
  local isTalentLock = NetCmdTalentData:GetTalentTreeGroupId(id) == 0
  if isTalentLock then
    setactive(self.mImage_Talent.transform.parent.gameObject, false)
    return
  end
  setactive(self.mImage_Talent.transform.parent.gameObject, true)
  local sprite = NetCmdTalentData:GetTalentIcon(id)
  if sprite ~= nil then
    self.mImage_Talent.sprite = sprite
  else
    printstack("mylog:Lua:" .. "出错了")
  end
end
