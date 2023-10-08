require("UI.UIBaseCtrl")
UIWeeklyModeCardDisplayItem = class("UIWeeklyModeCardDisplayItem", UIBaseCtrl)
UIWeeklyModeCardDisplayItem.__index = UIWeeklyModeCardDisplayItem
UIWeeklyModeCardDisplayItem.ui = nil
UIWeeklyModeCardDisplayItem.mData = nil
function UIWeeklyModeCardDisplayItem:__InitCtrl()
end
function UIWeeklyModeCardDisplayItem:ctor()
end
function UIWeeklyModeCardDisplayItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
end
function UIWeeklyModeCardDisplayItem:SetData(data)
  if data == nil then
    return
  end
  self.mData = data
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterGachaSprite(data.sprite)
  self.ui.mText_Level.text = data.level
  self.ui.mImg_ProgressBar.fillAmount = data.level / data.maxLevel
  self.ui.mAnimator:SetBool("Fx", data.levelUp)
end
function UIWeeklyModeCardDisplayItem:ShowLock(showLock)
  setactive(self.ui.mTrans_AvatarRoot.gameObject, not showLock)
  setactive(self.ui.mTrans_EmptyRoot.gameObject, showLock)
end
