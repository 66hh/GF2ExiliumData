ChrBarrackTopBarItemV3 = class("ChrBarrackTopBarItemV3", UIBaseCtrl)
ChrBarrackTopBarItemV3.__index = ChrBarrackTopBarItemV3
function ChrBarrackTopBarItemV3:ctor()
  self.contentType = nil
  self.systemId = 0
end
function ChrBarrackTopBarItemV3:InitCtrl(parent, contentType, callback, obj)
  self.contentType = contentType
  local barrackTabItem = TableData.listBarrackDatas:GetDataById(self.contentType)
  self.systemId = barrackTabItem.unlock
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  self.globalTab = GetOrAddComponent(instObj.gameObject, (typeof(GlobalTab)))
  self.globalTab:SetGlobalTabId(barrackTabItem.GlobalTab, barrackTabItem.unlock)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrBarrackTopBarItemV3.gameObject).onClick = function()
    if callback ~= nil then
      callback(self.contentType)
    end
  end
  local name = ""
  if contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
    name = TableData.GetHintById(160001)
  elseif contentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
    name = barrackTabItem.Name.str
  elseif contentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
    name = TableData.GetHintById(160002)
  end
  self.ui.mText_Name.text = name
end
function ChrBarrackTopBarItemV3:OnClose()
end
function ChrBarrackTopBarItemV3:OnRelease()
  self.super.OnRelease(self)
end
function ChrBarrackTopBarItemV3:GetGlobalTab()
  return self.globalTab
end
function ChrBarrackTopBarItemV3:SetSelect(enabled)
  self.ui.mBtn_ChrBarrackTopBarItemV3.interactable = not enabled
end
function ChrBarrackTopBarItemV3:UpdateRedPoint(enabled)
  setactive(self.ui.mObj_RedPoint.gameObject, enabled)
  setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, enabled)
end
function ChrBarrackTopBarItemV3:UpdateSystemLock()
  if self.systemId == 0 or self.systemId == nil then
    self.isLock = false
  else
    self.isLock = not AccountNetCmdHandler:CheckSystemIsUnLock(self.systemId)
  end
  self:SetLock(self.isLock)
end
function ChrBarrackTopBarItemV3:SetLock(locked)
  self.ui.mAnimator_ChrBarrackTopBarItemV3:SetBool("Unlock", not locked)
end
function ChrBarrackTopBarItemV3:SetSwitchMask(isMask)
  self.ui.mAnimator_ChrBarrackTopBarItemV3:SetBool("SwitchMask", isMask)
end
