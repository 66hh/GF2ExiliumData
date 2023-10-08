require("UI.Common.UICommonDutyItem")
ComChrInfoItem = class("ComChrInfoItem", UIBaseCtrl)
ComChrInfoItem.__index = ComChrInfoItem
function ComChrInfoItem:ctor()
  self.mGunCmdData = nil
  self.mGunData = nil
  self.isUnLock = true
  self.dutyItem = nil
  self.ItemIndex = -1
  self.redPointCount = 0
end
function ComChrInfoItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.dutyItem = UICommonDutyItem.New()
  self.dutyItem:InitCtrl(self.ui.mTrans_Duty)
end
function ComChrInfoItem:SetData(gunCmdData, gunData, callback)
  self.mGunCmdData = gunCmdData
  self.mGunData = gunData
  self.ui.mGuideHelper_Self.id = gunData.Id
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    callback()
  end
  self.isUnLock = self.mGunCmdData ~= nil
  if self.mGunData then
    local dutyData = TableData.listGunDutyDatas:GetDataById(self.mGunData.duty)
    local avatarCode
    if self.isUnLock then
      avatarCode = self.mGunCmdData.clothCode
    else
      avatarCode = self.mGunData.code
    end
    local avatar = IconUtils.GetCharacterBustSprite(avatarCode)
    local color = TableData.GetGlobalGun_Quality_Color2(self.mGunData.rank)
    self.ui.mImg_Rank.color = color
    self.ui.mImage_Rank2.color = color
    self.ui.mImg_Icon.sprite = avatar
    self.ui.mText_DutyName.text = dutyData.abbr.str
    self.dutyItem:SetData(dutyData)
  end
  if self.isUnLock then
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("FFFFFF")
    self.ui.mText_LevelNum.text = self.mGunCmdData.level
  else
    self.ui.mImg_Icon.color = Color(0.403921568627451, 0.44313725490196076, 0.45098039215686275, 0.9647058823529412)
    local itemData = TableData.listItemDatas:GetDataById(self.mGunData.core_item_id)
    local curChipNum = NetCmdItemData:GetItemCount(itemData.id)
    local unLockNeedNum = tonumber(self.mGunData.unlock_cost)
    self.ui.mText_UnLockNum.text = curChipNum
    self.ui.mText_UnLockTotal.text = "/" .. unLockNeedNum
  end
  setactive(self.ui.mTrans_Level, true)
  setactive(self.ui.mTrans_Level.gameObject, self.mGunCmdData ~= nil)
  setactive(self.ui.mTrans_Fragment, self.mGunCmdData == nil)
  setactive(self.mUIRoot, true)
  self:UpdateRedPoint()
end
function ComChrInfoItem:SetDormData(gunCmdData, gunData, callback)
  self.mGunCmdData = gunCmdData
  self.mGunData = gunData
  self.ui.mGuideHelper_Self.id = gunData.Id
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    callback()
  end
  self.isUnLock = NetCmdTeamData:GetGunDormUnlockByID(self.mGunCmdData.id) ~= nil
  if self.mGunData then
    local avatarCode
    avatarCode = self.mGunCmdData.dormClothCode
    local avatar = IconUtils.GetCharacterBustSprite(avatarCode)
    local color = TableData.GetGlobalGun_Quality_Color2(self.mGunData.rank)
    self.ui.mImg_Rank.color = color
    self.ui.mImage_Rank2.color = color
    self.ui.mImg_Icon.sprite = avatar
    setactive(self.ui.mText_DutyName, false)
    setactive(self.dutyItem:GetRoot(), false)
  end
  if self.isUnLock then
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("FFFFFF")
  else
    self.ui.mImg_Icon.color = CS.UnityEngine.Color(0.403921568627451, 0.44313725490196076, 0.45098039215686275, 0.9647058823529412)
    self.ui.mText_Name.color = CS.UnityEngine.Color(self.ui.mText_Name.color.r, self.ui.mText_Name.color.g, self.ui.mText_Name.color.b, 0.5)
  end
  self.ui.mText_Name.text = self.mGunCmdData.gunData.Name.str
  setactive(self.ui.mTrans_DormFeel, self.isUnLock and self.mGunCmdData.IsLove)
  setactive(self.ui.mTrans_Level, false)
  setactive(self.ui.mTrans_Name, true)
  setactive(self.mUIRoot, true)
  self:UpdateDormRedPoint()
end
function ComChrInfoItem:SetIsSelectTeamGun(gunID)
  local isSelect = gunID == self.mGunCmdData.id
  setactive(self.ui.mTrans_GrpSelBlack, isSelect)
end
function ComChrInfoItem:SetDisplay(gunId)
  self.mGunData = TableData.listGunDatas:GetDataById(gunId)
  local dutyData = TableData.listGunDutyDatas:GetDataById(self.mGunData.duty)
  local avatar = IconUtils.GetCharacterBustSprite(self.mGunData.code)
  local color = TableData.GetGlobalGun_Quality_Color2(self.mGunData.rank)
  self.ui.mImg_Rank.color = color
  self.ui.mImage_Rank2.color = color
  self.ui.mImg_Icon.sprite = avatar
  self.ui.mText_DutyName.text = dutyData.abbr.str
  self.ui.mText_Name.text = self.mGunData.name.str
  self.dutyItem:SetData(dutyData)
  setactive(self.ui.mTrans_Level.gameObject, false)
  setactive(self.mTrans_Name.gameObject, true)
end
function ComChrInfoItem:UpdateRedPoint()
  local count = 0
  if self.mGunCmdData then
    count = self.mGunCmdData:GetGunRedPoint()
  else
    count = NetCmdTeamData:UpdateLockRedPoint(self.mGunData)
  end
  self.redPointCount = count
  setactive(self.ui.mTrans_RedPoint, 0 < count)
end
function ComChrInfoItem:UpdateDormRedPoint()
  local count = 0
  if self.mGunCmdData then
    count = NetCmdLoungeData:GetDormRedPointByGunID(self.mGunCmdData.Id)
  end
  self.redPointCount = count
  setactive(self.ui.mTrans_RedPoint, 0 < count)
end
function ComChrInfoItem:SetSelect(boolean)
  UIUtils.SetInteractive(self.mUIRoot, not boolean)
end
function ComChrInfoItem:OnClose()
end
function ComChrInfoItem:OnRelease()
  self.super.OnRelease(self)
end
