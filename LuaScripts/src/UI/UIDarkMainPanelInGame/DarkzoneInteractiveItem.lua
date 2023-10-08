require("UI.UIBaseCtrl")
DarkzoneInteractiveItem = class("DarkzoneInteractiveItem", UIBaseCtrl)
DarkzoneInteractiveItem.__index = DarkzoneInteractiveItem
function DarkzoneInteractiveItem:InitCtrl(root, mainPanel, pool)
  self.obj = instantiate(root.childItem)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.mainPanel = mainPanel
  self.root = root
  self.pool = pool
  CS.LuaUIUtils.SetParent(self.obj.gameObject, self.root.gameObject, false)
  self.select = false
  self.useful = false
  self.delay = false
  self.host = nil
  function self.ClickFun()
    self:ClickItem()
  end
  self.ui.mBtn_Interactive.onClick:AddListener(self.ClickFun)
  function self.PointEnterFun()
    self:PointEnterItem()
  end
  self.ui.mBtn_Interactive.PointEnterEvent:AddListener(self.PointEnterFun)
  if not CS.LuaUtils.IsNullOrDestroyed(self.ui.Box) then
    CS.LuaUIUtils.GetUIPCKey(self.ui.Box.transform).text = TableData.listHintDatas:GetDataById(903304).Chars.str
    setactive(self.ui.Box.gameObject, false)
  end
end
function DarkzoneInteractiveItem:SetDetail(interactive, rootVisible, index)
  self.host = interactive
  self.ui.mText_Name.text = string_format(interactive:GetInteractiveItemName())
  self.ui.mImg_Icon.sprite = interactive:GetInteractiveItemIcon()
  self.useful = true
  self.delay = false
  self.ui.mBtn_Interactive.interactable = true
  if self.delayFadeOut ~= nil then
    self.delayFadeOut:Stop()
    self.delayFadeOut = nil
  else
    CS.LuaUIUtils.SetParent(self.obj.gameObject, self.root.gameObject, false)
    setactive(self.obj.gameObject, true)
  end
  self.obj.transform:SetSiblingIndex(index)
  if rootVisible then
    self.ui.mAni_Root:SetTrigger("FadeIn")
    self.ui.mAni_Root:SetBool("Bool", self.host:GetItemType())
  end
end
function DarkzoneInteractiveItem:ClickItem()
  if self.host == nil then
    return
  end
  local handler = CS.SysMgr.dzPlayerMgr.MainPlayer.pickHandler
  local input = CS.SysMgr.dzPlayerMgr.MainPlayer.receiveInputComp
  if input:UIClick(CS.DarkUnitWorld.UIClickType.PickInteractive) then
    self.mainPanel:ShowWindow(0)
    handler:PlayerPickInteractive(self.host)
  end
end
function DarkzoneInteractiveItem:PointEnterItem()
  if self.select or self.host == nil then
    return
  end
  self.mainPanel:SelectInteractive(self)
end
function DarkzoneInteractiveItem:Select(select, show)
  if show then
    if select then
      self.mainPanel:RegistrationKeyboard(KeyCode.F, self.ui.mBtn_Interactive)
    else
      self.mainPanel:UnRegistrationKeyboard(KeyCode.F)
    end
  end
  self.select = select
  if CS.LuaUtils.IsNullOrDestroyed(self.ui.Box) then
    return
  end
  if show then
    if select then
      self.ui.mAni_Root:SetTrigger("Highlighted")
    else
      self.ui.mAni_Root:SetTrigger("Normal")
    end
  end
  setactive(self.ui.Box.gameObject, select)
end
function DarkzoneInteractiveItem:Close(rootVisible)
  if self.select then
    self.mainPanel:SelectInteractive(nil)
  end
  self.ui.mBtn_Interactive.interactable = false
  self.useful = false
  self.host = nil
  if rootVisible then
    self.ui.mAni_Root:SetTrigger("FadeOut")
    self.delay = true
    self.delayFadeOut = TimerSys:DelayCall(1, function()
      self.delay = false
      self.delayFadeOut = nil
      setactive(self.obj.gameObject, false)
      CS.LuaUIUtils.SetParent(self.obj.gameObject, self.pool.gameObject, false)
    end)
  else
    self.delay = false
    self.delayFadeOut = nil
    setactive(self.obj.gameObject, false)
    CS.LuaUIUtils.SetParent(self.obj.gameObject, self.pool.gameObject, false)
  end
  if not CS.LuaUtils.IsNullOrDestroyed(self.ui.Box) then
    setactive(self.ui.Box.gameObject, false)
  end
end
function DarkzoneInteractiveItem:CheckUseful(useful)
  self.useful = useful
  if useful and self.host.pickComp:CanInteractive() then
    self.ui.mText_Name.text = string_format(self.host:GetInteractiveItemName())
    self.ui.mImg_Icon.sprite = self.host:GetInteractiveItemIcon()
  end
end
function DarkzoneInteractiveItem:RootVisible()
  self.ui.mAni_Root:SetTrigger("FadeIn")
  self.ui.mAni_Root:SetBool("Bool", self.host:GetItemType())
end
function DarkzoneInteractiveItem:OnRelease()
  self.ui.mBtn_Interactive.onClick:RemoveListener(self.ClickFun)
  self.ClickFun = nil
  self.ui.mBtn_Interactive.PointEnterEvent:RemoveListener(self.PointEnterFun)
  self.PointEnterFun = nil
  self.ui = nil
  self.obj = nil
  self.mainPanel = nil
  self.host = nil
  self.select = nil
  self.useful = nil
  self.delay = nil
  if self.delayFadeOut ~= nil then
    self.delayFadeOut:Stop()
    self.delayFadeOut = nil
  end
end
