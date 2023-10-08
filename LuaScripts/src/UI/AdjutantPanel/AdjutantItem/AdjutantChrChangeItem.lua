require("UI.UIBaseCtrl")
AdjutantChrChangeItem = class("AdjutantChrChangeItem", UIBaseCtrl)
local self = AdjutantChrChangeItem
function AdjutantChrChangeItem:ctor()
end
function AdjutantChrChangeItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.showIndex = false
  self.data = nil
end
function AdjutantChrChangeItem:SetAdjutantListData(adjutantChrChangeItemData)
  self.data = adjutantChrChangeItemData
  if self.data.pos == -1 then
    setactive(self.ui.mTrans_SerialNum, false)
  else
    if self.data.pos ~= 0 and self.showIndex then
      setactive(self.ui.mTrans_SerialNum, true)
    end
    self.ui.mText_Num.text = self.data.pos
  end
  setactive(self.ui.mTrans_Adjutant.gameObject, adjutantChrChangeItemData.isLock)
  local str = "Icon_Character_{0}_W"
  self.ui.mImg_CharacterIcon.sprite = ResSys:GetAtlasSprite("Icon/CharacterIcon/" .. string_format(str, self.data.characterData.EnName))
  self.ui.mImg_Avatar.sprite = ResSys:GetCharacterAvatarFullName("Avatar_Half_" .. self.data.gunData.Code)
end
function AdjutantChrChangeItem:SetSelected(boolean)
  self.ui.mBtn_Self.interactable = not boolean
end
function AdjutantChrChangeItem:ShowIndex(boolean)
  self.showIndex = boolean
end
function AdjutantChrChangeItem:SetCurSelected(boolean)
  setactive(self.ui.mTrans_Selected.gameObject, boolean)
  setactive(self.ui.mTrans_SelNow.gameObject, boolean)
end
function AdjutantChrChangeItem:OnRelease()
  self:DestroySelf()
end
