require("UI.UIBaseCtrl")
UIWeeklyChrAvatarItem = class("UIWeeklyChrAvatarItem", UIBaseCtrl)
UIWeeklyChrAvatarItem.__index = UIWeeklyChrAvatarItem
function UIWeeklyChrAvatarItem:ctor()
  self.super.ctor(self)
end
function UIWeeklyChrAvatarItem:InitCtrl(parent, onClick)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComChrInfoItemV2.prefab", self), parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.mOnClick = onClick
end
function UIWeeklyChrAvatarItem:SetNoneItem(item, parent)
  self.mUINoneRoot = instantiate(item, parent)
end
function UIWeeklyChrAvatarItem:EnableNone(isNone)
  if self.mUINoneRoot then
    setactive(self.mUINoneRoot, isNone)
  end
  setactive(self.mUIRoot, not isNone)
end
function UIWeeklyChrAvatarItem:SetAsLastSibling()
  self.mUIRoot:SetAsLastSibling()
  if self.mUINoneRoot then
    self.mUINoneRoot:SetAsLastSibling()
  end
end
function UIWeeklyChrAvatarItem:SetData(gunData)
  if not gunData then
    return
  end
  if self.mUINoneRoot then
    setactive(self.mUINoneRoot, false)
  end
  self.mData = gunData
  self.mGunId = gunData.id
  self.tableData = gunData.TabGunData
  self.cmdData = NetCmdTeamData:GetGunByID(self.mGunId)
  self.isUnLock = self.cmdData ~= nil
  if self.tableData then
    local avatar = IconUtils.GetCharacterBustSpriteWithClothByGunId(self.mGunId)
    local color = TableData.GetGlobalGun_Quality_Color2(self.tableData.rank)
    self.ui.mImg_Rank.color = color
    self.ui.mImage_Rank2.color = color
    self.ui.mImg_Icon.sprite = avatar
  end
  if self.cmdData then
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("FFFFFF")
    self.ui.mText_LevelNum.text = self.cmdData.level
  else
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("808080")
    local itemData = TableData.listItemDatas:GetDataById(self.tableData.core_item_id)
    local curChipNum = NetCmdItemData:GetItemCount(itemData.id)
    local unLockNeedNum = tonumber(self.tableData.unlock_cost)
    self.ui.mText_Level.text = curChipNum
    self.ui.mText_UnLockTotal.text = "/" .. unLockNeedNum
  end
  setactive(self.ui.mTrans_Level.gameObject, self.cmdData ~= nil)
  setactive(self.ui.mTrans_Fragment, self.cmdData == nil)
  setactive(self.ui.mUIRoot, true)
  setactive(self.ui.mTrans_RedPoint, false)
  setactive(self.ui.mTrans_GrpChoose, false)
  setactive(self.ui.mTrans_Complete, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if self.mOnClick then
      self.mOnClick(self.mData)
    else
      CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(self.cmdData)
    end
  end
  self:EnableBtn(true)
end
function UIWeeklyChrAvatarItem:EnableChoose(enable)
  setactive(self.ui.mTrans_GrpChoose, enable)
end
function UIWeeklyChrAvatarItem:EnableSelect(enable)
  setactive(self.ui.mTrans_Complete, enable)
end
function UIWeeklyChrAvatarItem:EnableBtn(enable)
  self.ui.mBtn_Self.enabled = enable
end
