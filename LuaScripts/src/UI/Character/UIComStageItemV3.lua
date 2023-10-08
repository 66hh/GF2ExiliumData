UIComStageItemV3 = class("UIComStageItemV3", UIBaseCtrl)
UIComStageItemV3.__index = UIComStageItemV3
function UIComStageItemV3:ctor()
  UIComStageItemV3.super.ctor(self)
end
function UIComStageItemV3:InitCtrl(parent, useScrollListChild, obj)
  if obj ~= nil then
    self.prefab = obj
  elseif useScrollListChild then
    local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    self.prefab = instantiate(itemPrefab.childItem)
  else
    self.prefab = ResSys:GetUIGizmos("UICommonFramework/ComStageItemV2.prefab")
  end
  if parent then
    CS.LuaUIUtils.SetParent(self.prefab.gameObject, parent.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.prefab.transform, self.ui)
  self:SetRoot(self.prefab.transform)
end
function UIComStageItemV3:SetData(num)
  setactive(self.ui.mTrans_None.gameObject, num == 0)
  setactive(self.ui.mText_Num.gameObject, num ~= 0)
  if num ~= 0 then
    self.ui.mText_Num.text = num
  end
end
function UIComStageItemV3:Release()
  ResourceManager:DestroyInstance(self.prefab.gameObject)
end
