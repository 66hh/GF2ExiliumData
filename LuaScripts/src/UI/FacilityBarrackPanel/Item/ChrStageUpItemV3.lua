ChrStageUpItemV3 = class("ChrStageUpItemV3", UIBaseCtrl)
ChrStageUpItemV3.__index = ChrStageUpItemV3
function ChrStageUpItemV3:ctor()
  self.index = 0
  self.isActivate = false
  self.isLock = false
  self.isCanUpgrade = false
end
function ChrStageUpItemV3:InitCtrl(parent, index, callback, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.index = index
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    if callback ~= nil then
      callback()
    end
  end
end
function ChrStageUpItemV3:SetData(upgrade)
  self.isActivate = upgrade >= self.index
  self.isLock = self.index > upgrade + 1
  self.isCanUpgrade = self.index == upgrade + 1
  self:SetImageAlpha(self.ui.mImg_Locked, self.isLock)
  self:SetImageAlpha(self.ui.mImg_Line, not self.isLock)
  self.ui.mText_Name.text = TableData.GetHintById(170000 + self.index)
end
function ChrStageUpItemV3:SetSelect(enabled)
  self.ui.mBtn_Root.interactable = enabled
end
function ChrStageUpItemV3:SetItemEnough(isItemEnough)
  setactive(self.ui.mObj_RedPoint.gameObject, self.isCanUpgrade and isItemEnough)
  setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, self.isCanUpgrade and isItemEnough)
end
function ChrStageUpItemV3:SetImageAlpha(image, boolean)
  local color = image.color
  local alpha = 0
  if boolean then
    alpha = 1
  end
  color.a = alpha
  image.color = color
end
function ChrStageUpItemV3:OnClose()
end
function ChrStageUpItemV3:OnRelease()
  self.super.OnRelease(self)
end
