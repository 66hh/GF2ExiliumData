require("UI.UIBaseCtrl")
DarkzoneInteractiveTipsItem = class("DarkzoneInteractiveTipsItem", UIBaseCtrl)
DarkzoneInteractiveTipsItem.__index = DarkzoneInteractiveTipsItem
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
function DarkzoneInteractiveTipsItem:InitCtrl(origin, parent)
  self.obj = instantiate(origin, parent.transform)
  self.parent = parent
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.trans = self.obj.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  self:SetRoot(self.obj.transform)
end
function DarkzoneInteractiveTipsItem:SetHost(host)
  self.mHost = host
  self.hasHost = true
  self.ui.mImg_Icon.sprite = self.mHost:GetInteractiveSceneIcon()
  local costType = self.mHost:GetCostType()
  if costType.Item1 ~= 2 or costType.Item2 == EnumDarkzoneProperty.Property.DzEnergy1Now then
  elseif costType.Item2 == EnumDarkzoneProperty.Property.DzEnergy2Now then
    self.ui.mImg_Icon.color = ColorUtils.StringToColor("3CBECF")
  end
  self.hasCd = self.mHost:HasCd()
  self.hasUseLimit = self.mHost:HasUseLimit()
  if self.hasCd or self.hasUseLimit then
    setactive(self.ui.mText_Des.gameObject, true)
  end
  self.ui.mHelp_Pos:SetHost(self.mHost.VM, 2)
end
function DarkzoneInteractiveTipsItem:UpdatePos()
  if self.mHost == nil then
    self:SetNull()
    return
  end
  local showType = self.mHost:GetShowType()
  if showType <= 1 then
    setactive(self.ui.mText_Des.gameObject, false)
    return
  end
  local tempHasCd = self.mHost:HasCd()
  local tempHasUseLimit = self.mHost:HasUseLimit()
  if tempHasCd then
    if not self.hasCd then
      setactive(self.ui.mText_Des.gameObject, true)
      self.ui.mText_Des.color = ColorUtils.RedColor
    end
    self.ui.mText_Des.text = string.format("%.1f", self.mHost:GetCD()) .. "s"
  elseif tempHasUseLimit then
    if not self.hasUseLimit or self.hasCd then
      setactive(self.ui.mText_Des.gameObject, true)
      self.ui.mText_Des.color = ColorUtils.WhiteColor
    end
    local useParam = self.mHost:GetUseLimit()
    self.ui.mText_Des.text = useParam.Item1 .. "/" .. useParam.Item2
  else
    setactive(self.ui.mText_Des.gameObject, false)
  end
  self.hasCd = tempHasCd
  self.hasUseLimit = tempHasUseLimit
end
function DarkzoneInteractiveTipsItem:SetNull()
  setactive(self.obj, false)
  self.hasHost = false
  self.mHost = nil
  self.ui.mHelp_Pos:SetHost(nil)
  self.hasCd = false
  self.hasUseLimit = false
  self.ui.mImg_Icon.color = ColorUtils.WhiteColor
end
function DarkzoneInteractiveTipsItem:OnRelease()
  self.ui.mHelp_Pos:SetHost(nil)
  self.ui = nil
  self.mview = nil
  self.mHost = nil
  self.parent = nil
  self.trans = nil
  self.hasHost = nil
  self.hasCd = nil
  self.hasUseLimit = nil
end
function DarkzoneInteractiveTipsItem:SetVisible(visible)
  self.obj.gameObject:SetActive(visible)
end
