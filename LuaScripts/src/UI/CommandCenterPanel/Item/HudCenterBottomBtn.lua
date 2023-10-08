HudCenterBottomBtn = class("HudCenterBottomBtn", UIBaseCtrl)
local self = HudCenterBottomBtn
function HudCenterBottomBtn:ctor()
  self.systemId = 0
end
function HudCenterBottomBtn:InitCtrl(parent, systemId, name)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.systemId = systemId
  self:InitHudCenterBottomBtn(name)
end
function HudCenterBottomBtn:InitHudCenterBottomBtn(name)
  local parent = self.mUIRoot
  if parent then
    self.systemId = self.systemId
    self.parent = parent
    self.btn = self.mUIRoot.transform:Find("Root"):GetComponent(typeof(CS.UnityEngine.UI.GFButton))
    self.textName = UIUtils.GetText(self.mUIRoot.transform, "Root/GrpText/Text_Name")
    self.textName.text = name
    self.transRedPoint = UIUtils.GetRectTransform(self.mUIRoot.transform, "Root/Trans_RedPoint")
    self.textRandom = UIUtils.GetText(self.mUIRoot.transform, "Root/GrpText/GrpRandom/Text_Random")
    self.textRandom.text = "// . L" .. math.random(11, 99) .. "-" .. self:GetRandomText()
    self.animator = UIUtils.GetAnimator(self.mUIRoot.transform, "Root")
    self.dot = self.mUIRoot.transform:Find("Root/GrpBg/Trans_RightArrow")
  end
end
function HudCenterBottomBtn:GetRandomText()
  local num = math.random(1, 9999)
  if num < 10 then
    return "000" .. tostring(num)
  elseif num < 100 then
    return "00" .. tostring(num)
  elseif num < 1000 then
    return "0" .. tostring(num)
  end
  return tostring(num)
end
function HudCenterBottomBtn:HideDot()
  setactive(self.dot, false)
end
function HudCenterBottomBtn:UpdateData()
end
function HudCenterBottomBtn:OnRelease()
  self:DestroySelf()
end
