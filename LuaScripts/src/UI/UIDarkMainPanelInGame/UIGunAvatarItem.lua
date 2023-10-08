require("UI.UIBaseCtrl")
UIGunAvatarItem = class("UIGunAvatarItem", UIBaseCtrl)
function UIGunAvatarItem:ctor(parent)
  local go = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComChrInfoItemV2.prefab", self), parent)
  self:SetRoot(go.transform)
  self.ui = UIUtils.GetUIBindTable(go)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Self.gameObject, function()
    self:onClickSelf()
  end)
  setactive(self.ui.mTrans_RedPoint, false)
  setactive(self:GetRoot(), true)
end
function UIGunAvatarItem:InitByGunId(gunId)
  local gunCmdData = NetCmdTeamData:GetGunByID(gunId)
  self:InitByGunCmdData(gunCmdData)
end
function UIGunAvatarItem:InitById(id, level)
  local darkGunData = {}
  darkGunData.GunCmdData = {}
  darkGunData.GunCmdData.Level = level or 1
  darkGunData.GunCmdData.TabGunData = TableData.listGunDatas:GetDataById(id)
  self:InitByGunCmdData(darkGunData)
end
function UIGunAvatarItem:InitByGunCmdData(darkGunData)
  self.darkGunCmdData = darkGunData
  self.gunCmdData = darkGunData.GunCmdData
end
function UIGunAvatarItem:AddBtnClickListener(callback)
  self.callback = callback
end
function UIGunAvatarItem:Refresh()
  if not self.gunCmdData then
    setactive(self.ui.mUIRoot, false)
    return
  end
  local gunCmdData = self.gunCmdData
  if gunCmdData then
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("FFFFFF")
    self.ui.mText_LevelNum.text = gunCmdData.Level
    local stcGunData = gunCmdData.TabGunData
    local avatar = IconUtils.GetCharacterBustSprite(stcGunData.code)
    local color = TableData.GetGlobalGun_Quality_Color2(stcGunData.rank)
    self.ui.mImg_Rank.color = color
    self.ui.mImage_Rank2.color = color
    self.ui.mImg_Icon.sprite = avatar
    local elementData = TableData.listLanguageElementDatas:GetDataById(stcGunData.Element)
    if elementData then
      self.ui.mImage_Element.sprite = IconUtils.GetElementIconM(elementData.icon)
    end
    setactive(self.ui.mTrans_Element, elementData ~= nil)
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
function UIGunAvatarItem:OnRelease()
  self.darkGunCmdData = nil
  self.gunCmdData = nil
  self.callback = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIGunAvatarItem:onClickSelf()
  if self.callback then
    self.callback(self.darkGunCmdData)
  end
end
