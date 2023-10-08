require("UI.UIBaseCtrl")
DZMainEnterFunctionItem = class("DZMainEnterFunctionItem", UIBaseCtrl)
DZMainEnterFunctionItem.__index = DZMainEnterFunctionItem
function DZMainEnterFunctionItem:__InitCtrl()
end
function DZMainEnterFunctionItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self.mData = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.ui.mAnim_Self.keepAnimatorControllerStateOnDisable = true
end
function DZMainEnterFunctionItem:SetData(nameHitID, tipHitID, func, unlockID, tipHitStr)
  self.clickFunc = func
  self.unlockID = unlockID
  self.mIsUnLock = self.unlockID == nil or not (self.unlockID > 0)
  if tipHitID and 0 < tipHitID then
    self.hint = TableData.GetHintById(tipHitID)
  elseif unlockID and 0 < unlockID then
    local d = TableData.GetUnLockInfoByType(unlockID)
    if d then
      local str = UIUtils.CheckUnlockPopupStr(d)
      self.hint = str
    end
  end
  if tipHitStr then
    self.hint = tipHitStr
  end
  if nameHitID then
    self.ui.mText_ItemName.text = TableData.GetHintById(nameHitID)
  end
  self.ui.mBtn_Self.onClick:AddListener(function()
    self:ClickFunction()
  end)
end
function DZMainEnterFunctionItem:SetImage(imgName)
  self.ui.mImg_Icon.sprite = IconUtils.GetDarkzoneIcon(imgName)
end
function DZMainEnterFunctionItem:RefreshLockState()
  if self.unlockID and self.unlockID > 0 then
    self.mIsUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(self.unlockID)
  end
  self.ui.mAnim_Self:SetBool("UnLock", self.mIsUnLock)
end
function DZMainEnterFunctionItem:RefreshRedDot(needShow)
  setactive(self.ui.mTrans_RedPoint, needShow)
end
function DZMainEnterFunctionItem:ClickFunction()
  if self.mIsUnLock == false then
    PopupMessageManager.PopupString(self.hint)
    return
  end
  if self.clickFunc then
    self.clickFunc()
  end
end
function DZMainEnterFunctionItem:OnClose()
  self.mIsUnLock = nil
  self.clickFunc = nil
  self.hint = nil
  self:DestroySelf()
end
