UIPVPTeamGunAvatarItem = class("UIPVPTeamGunAvatarItem", UIBaseCtrl)
local self = UIPVPTeamGunAvatarItem
function UIPVPTeamGunAvatarItem:ctor(parent, obj)
  local itemPrefab, instObj
  if obj == nil then
    itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickSelf()
  end
end
function UIPVPTeamGunAvatarItem:InitGun(gunCmdData, pvpOpponentInfo, index, detailType)
  self.gunCmdData = gunCmdData
  self.isNpc = pvpOpponentInfo ~= nil and pvpOpponentInfo.uid == 0
  index = index or 0
  if not self.gunCmdData or gunCmdData.Id == 0 then
    setactive(self.ui.mTrans_None, true)
    setactive(self.ui.mTrans_Content, false)
    self.ui.mBtn_Self.enabled = false
    return
  end
  self.ui.mBtn_Self.enabled = true
  setactive(self.ui.mTrans_None, false)
  setactive(self.ui.mTrans_Content, true)
  if gunCmdData then
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("FFFFFF")
    self.ui.mText_LevelNum.text = gunCmdData.Level
    local stcGunData = gunCmdData.TabGunData
    local avatar
    if self.isNpc then
      avatar = IconUtils.GetCharacterBustSprite(stcGunData.code)
    elseif pvpOpponentInfo and 0 < pvpOpponentInfo:getClothIdByIndex(index) and detailType == UIPVPGlobal.LineUpType.Attack then
      avatar = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarBust, stcGunData.Id, pvpOpponentInfo:getClothIdByIndex(index))
    elseif pvpOpponentInfo and detailType == UIPVPGlobal.LineUpType.Defend then
      local clothId = pvpOpponentInfo:GetDefendClothId(stcGunData.Id)
      avatar = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarBust, stcGunData.Id, clothId)
    else
      local currMapId = 1004
      if UIPVPGlobal.curPreviewMapIndex and UIPVPGlobal.curPreviewMapIndex > -1 and UIPVPGlobal.curPreviewMapIndex < NetCmdPVPData.UserMapDic.Count then
        currMapId = NetCmdPVPData.UserMapDic[UIPVPGlobal.curPreviewMapIndex].Key
      end
      local clothId = NetCmdPVPData:GetClothIdByMapIndex(currMapId, index)
      avatar = IconUtils.GetCharacterTypeSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, IconUtils.cCharacterAvatarBust, stcGunData.Id, clothId)
    end
    local color = TableData.GetGlobalGun_Quality_Color2(stcGunData.rank)
    self.ui.mImg_Rank.color = color
    self.ui.mImage_Rank2.color = color
    self.ui.mImg_Icon.sprite = avatar
    setactive(self.ui.mTrans_Element, false)
    local dutyData = TableData.listGunDutyDatas:GetDataById(gunCmdData.TabGunData.Duty)
    local tmpDutyParent = self.ui.mTrans_Duty.transform
    local tmpScrollListChild = tmpDutyParent:GetComponent(typeof(CS.ScrollListChild))
    local tmpDutyObj
    if 0 < tmpScrollListChild.transform.childCount then
      tmpDutyObj = tmpScrollListChild.transform:GetChild(0).gameObject
    else
      tmpDutyObj = instantiate(tmpScrollListChild.childItem.gameObject, tmpDutyParent)
    end
    local tmpDutyImg = tmpDutyObj.transform:Find("Img_DutyIcon").transform:GetComponent(typeof(CS.UnityEngine.UI.Image))
    tmpDutyImg.sprite = IconUtils.GetGunTypeIcon(dutyData.icon)
  else
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("808080")
    local itemData = TableData.listItemDatas:GetDataById(tableData.CoreItemId)
    local curChipNum = NetCmdItemData:GetItemCount(itemData.id)
    local unLockNeedNum = tonumber(tableData.unlock_cost)
    self.ui.mText_Level.text = curChipNum
    self.ui.mText_UnLockTotal.text = "/" .. unLockNeedNum
  end
  setactive(self.ui.mTrans_Level.gameObject, gunCmdData ~= nil)
  setactive(self.ui.mTrans_Fragment, gunCmdData == nil)
end
function UIPVPTeamGunAvatarItem:OnRelease()
  self.gunCmdData = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIPVPTeamGunAvatarItem:OnClickSelf()
  CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(self.gunCmdData, self.isNpc)
end
