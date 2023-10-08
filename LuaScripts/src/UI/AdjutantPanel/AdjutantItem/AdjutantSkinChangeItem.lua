require("UI.UIBaseCtrl")
AdjutantSkinChangeItem = class("AdjutantSkinChangeItem", UIBaseCtrl)
local self = AdjutantSkinChangeItem
function AdjutantSkinChangeItem:ctor()
end
function AdjutantSkinChangeItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.data = nil
end
function AdjutantSkinChangeItem:SetAdjutantSkinListData(adjutantSkinChangeItemData)
  self.data = adjutantSkinChangeItemData
  self:SetSelected(false)
  self:SetCurSelected(false)
  self.ui.mBtn_Self.interactable = true
  self.isLock = self.data.isLock
  setactive(self.ui.mTrans_Locked, self.isLock)
  self.ui.mImg_Avatar.sprite = ResSys:GetCharacterAvatarFullName("Avatar_Gacha_" .. self.data.gunData.Code)
end
function AdjutantSkinChangeItem:SetSelected(boolean)
  self.ui.mBtn_Self.interactable = not boolean
end
function AdjutantSkinChangeItem:SetCurSelected(boolean)
  setactive(self.ui.mTrans_Selected.gameObject, boolean)
end
function AdjutantSkinChangeItem:OnRelease()
end
