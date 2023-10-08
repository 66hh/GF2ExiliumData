require("UI.UIBaseCtrl")
UIBarrackContentBase = class("UIBarrackContentBase", UIBaseCtrl)
UIBarrackContentBase.__index = UIBarrackContentBase
UIBarrackContentBase.PrefabPath = nil
function UIBarrackContentBase:ctor()
  UIBarrackContentBase.super.ctor(self)
  self.mData = nil
  self.mParent = nil
  self.mParentObj = nil
  self.itemPrefab = nil
  self.needModel = false
  self.enableTimer = nil
end
function UIBarrackContentBase:InitCtrl(obj)
  local instObj
  if self.PrefabPath ~= nil then
    self.mParentObj = obj
    instObj = self:InstantiatePrefab(obj)
  else
    self.mParentObj = nil
    instObj = obj
  end
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self:__InitCtrl()
end
function UIBarrackContentBase:InstantiatePrefab(parent)
  self.itemPrefab = UIUtils.GetUIRes(self.PrefabPath, false)
  local instObj = instantiate(self.itemPrefab)
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  return instObj
end
function UIBarrackContentBase:__InitCtrl()
  self.animator = UIUtils.GetAnimator(self.mUIRoot, "Root")
  if self.animator == nil and self.ui.mAnimator then
    self.animator = self.ui.mAnimator
  end
  setactive(self.mUIRoot.gameObject, false)
end
function UIBarrackContentBase:SetData(data, parent)
  self.mData = data
  self.mParent = parent
end
function UIBarrackContentBase:OnEnable(enable)
  if self.enableTimer then
    self.enableTimer:Stop()
    self.enableTimer = nil
  end
  if self.animator then
    if enable then
      setactive(self.mUIRoot.gameObject, enable)
      self.animator:ResetTrigger("FadeOut")
      self.animator:SetTrigger("FadeIn")
    else
      self.animator:ResetTrigger("FadeIn")
      self.animator:SetTrigger("FadeOut")
      local length = CSUIUtils.GetClipLengthByEndsWith(self.animator, "FadeOut")
      self.enableTimer = TimerSys:DelayCall(length, function()
        setactive(self.mUIRoot.gameObject, enable)
      end)
    end
  else
    setactive(self.mUIRoot.gameObject, enable)
  end
end
function UIBarrackContentBase:OnUpdateTop()
end
function UIBarrackContentBase:Close()
  if self.mParent then
    self.mParent:CloseChildPanel()
  end
end
function UIBarrackContentBase:EnableModel(enable)
  self.needModel = enable
  if self.mParent then
    self.mParent:EnableCharacterModel(enable)
  end
end
function UIBarrackContentBase:EnableMask(enable)
  if self.mParent then
    setactive(self.mParent.ui.mTrans_Mask, enable)
  end
end
function UIBarrackContentBase:EnableSwitchGun(enable)
  if self.mParent then
    self.mParent:EnableSwitchContent(enable)
  end
end
function UIBarrackContentBase:ChangeTab(tabId)
  if self.mParent and tabId then
    self.mParent:OnClickTab(tabId)
  end
end
function UIBarrackContentBase:EnableTabs(enable)
  if self.mParent then
    self.mParent:EnableTabs(enable)
  end
end
function UIBarrackContentBase:RefreshGun()
  if self.mParent then
    self.mParent:RefreshGun()
  end
end
function UIBarrackContentBase:UpdateRedPoint()
  if self.mParent then
    self.mParent:UpdateRedPoint()
    self.mParent:UpdateTabList()
  end
end
function UIBarrackContentBase:UpdateTabList()
  if self.mParent then
    self.mParent:UpdateTabList()
  end
end
function UIBarrackContentBase:PlaySwitchAni(step)
  if self.animator then
    if step == 1 then
      self.animator:SetTrigger("Next")
    elseif step == -1 then
      self.animator:SetTrigger("Previous")
    end
  end
end
function UIBarrackContentBase:PlaySwitchInAni()
end
function UIBarrackContentBase:Back2LastContent()
end
function UIBarrackContentBase:GunModelStopAudioAndEffect()
  self.mParent:GunModelStopAudioAndEffect()
end
function UIBarrackContentBase:OnRelease()
  if self.itemPrefab then
    gfdestroy(self.mUIRoot.gameObject)
  end
  self.super.super.OnRelease(self)
end
