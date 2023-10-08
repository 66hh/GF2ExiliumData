require("UI.UIBaseCtrl")
DarkMainPanelInGameBuffItem = class("DarkMainPanelInGameBuffItem", UIBaseCtrl)
DarkMainPanelInGameBuffItem.__index = DarkMainPanelInGameBuffItem
function DarkMainPanelInGameBuffItem:InitCtrl(root)
  self.obj = instantiate(root.childItem)
  self.parent = root.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.trans = self.ui.mTran_Self.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  self:SetRoot(self.obj.transform)
  self.hasHost = false
  self.buffCount = 0
  self.tween = false
  self.tweener = nil
  function self.fun3()
    self.tweener = nil
    self:SetNull()
  end
  self.mark = false
  self.busyLs = nil
  self.freeLs = nil
  setactive(self.obj.gameObject, false)
end
function DarkMainPanelInGameBuffItem:Mark(enable)
  self.mark = enable
end
function DarkMainPanelInGameBuffItem:CheckMark()
  if self.mark then
    return
  end
  self:SetNull()
end
function DarkMainPanelInGameBuffItem:SetHost(host, busyLs, freeLs)
  if self.mHost ~= nil then
    gferror("Check Logic")
  end
  self.busyLs = busyLs
  self.freeLs = freeLs
  self.mHost = host
  self.hasHost = true
  setactive(self.obj, true)
  local image = IconUtils.GetDarkzoneBuffIcon(self.mHost.DzBuffData.icon)
  self.ui.mImg_Icon1.sprite = image
  self.ui.mImg_Icon4.sprite = image
  local switch = host:TryGetSwitchSLGId()
  setactive(self.ui.mTran_Switch.gameObject, switch)
  self.ui.mAni_Ani:SetInteger("Type", self.mHost.DzBuffData.buff_type - 1)
  if self.buffCount ~= self.mHost.BuffCount then
    if 1 < self.mHost.BuffCount then
      self.ui.mAni_Ani:SetTrigger("Add")
    end
    self.buffCount = self.mHost.BuffCount
    self.ui.mText_BuffCount.text = self.buffCount
    if self.buffCount < 2 then
      setactive(self.ui.mText_BuffCount.gameObject, false)
    else
      setactive(self.ui.mText_BuffCount.gameObject, true)
    end
  end
  self.ui.mImg_Countdown.fillAmount = 1 - self.mHost:FillAmount()
  self.tween = true
end
function DarkMainPanelInGameBuffItem:SetNull()
  if self.tweener ~= nil then
    LuaDOTweenUtils.Kill(self.tweener, false)
  end
  self.ui.mCanvaGroup_Root.alpha = 1
  if self.busyLs ~= nil then
    local buffIndex = self.mHost:GetBuffIndex()
    self.busyLs[buffIndex] = nil
    self.busyLs = nil
  end
  if self.freeLs ~= nil then
    local freeCount = #self.freeLs
    self.freeLs[freeCount + 1] = self
    self.freeLs = nil
  end
  setactive(self.obj, false)
  self.hasHost = false
  self.mHost = nil
  self.buffCount = 0
  self.ui.mImg_Countdown.fillAmount = 0
  self.tween = false
  self.mark = false
end
function DarkMainPanelInGameBuffItem:OnUpdate()
  if self.hasHost == true then
    if self.buffCount ~= self.mHost.BuffCount then
      if self.mHost.BuffCount > 1 then
        self.ui.mAni_Ani:SetTrigger("Add")
      end
      self.buffCount = self.mHost.BuffCount
      self.ui.mText_BuffCount.text = self.buffCount
      if self.buffCount < 2 then
        setactive(self.ui.mText_BuffCount.gameObject, false)
      else
        setactive(self.ui.mText_BuffCount.gameObject, true)
      end
    end
    self.ui.mImg_Countdown.fillAmount = 1 - self.mHost:FillAmount()
    if self.tween and self.mHost.Interval:AsFloat() <= 3 then
      self.tween = false
      self.tweener = CS.LuaDOTweenUtils.CanvasGroupFade(self.ui.mCanvaGroup_Root, 0, 0.3, 0.5, CS.LuaDOTweenUtils.InOutQuad, 6, CS.LuaDOTweenUtils.Yoyo, self.fun3)
    elseif not self.tween and self.mHost.Interval:AsFloat() > 3 and self.tweener ~= nil then
      LuaDOTweenUtils.Kill(self.tweener, false)
      self.tweener = nil
      self.ui.mCanvaGroup_Root.alpha = 1
      self.tween = true
    end
  end
end
function DarkMainPanelInGameBuffItem:OnRelease()
  if self.tweener ~= nil then
    LuaDOTweenUtils.Kill(self.tweener, false)
    self.tweener = nil
  end
  self.ui = nil
  self.mHost = nil
  self.parent = nil
  self.trans = nil
  self.hasHost = nil
  self.buffCount = nil
  self.tween = nil
  self.fun3 = nil
  self.mark = nil
  self.busyLs = nil
  self.freeLs = nil
end
