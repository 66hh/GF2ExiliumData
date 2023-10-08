require("UI.UIBaseCtrl")
UICommonArrowBtnItem = class("UICommonArrowBtnItem", UIBaseCtrl)
UICommonArrowBtnItem.__index = UICommonArrowBtnItem
function UICommonArrowBtnItem:__InitCtrl()
end
function UICommonArrowBtnItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("SimComBatHard/SimComBatHardChapterItem.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:InitObj(instObj)
end
function UICommonArrowBtnItem:InitObj(instObj)
  self:SetRoot(instObj.transform)
  self:SetBaseData()
end
function UICommonArrowBtnItem:SetBaseData()
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.leftArrowClickFunction = nil
  self.rightArrowClickFunction = nil
  self.leftArrowActiveFunction = nil
  self.rightArrowActiveFunction = nil
end
function UICommonArrowBtnItem:SetLeftArrowClickFunction(callBack)
  self.leftArrowClickFunction = callBack
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = self.leftArrowClickFunction
end
function UICommonArrowBtnItem:SetRightArrowClickFunction(callBack)
  self.rightArrowClickFunction = callBack
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = self.rightArrowClickFunction
end
function UICommonArrowBtnItem:SetLeftArrowActiveFunction(callBack)
  self.leftArrowActiveFunction = callBack
end
function UICommonArrowBtnItem:SetRightArrowActiveFunction(callBack)
  self.rightArrowActiveFunction = callBack
end
function UICommonArrowBtnItem:RefreshArrowActive()
  local active
  if self.leftArrowActiveFunction then
    active = self.leftArrowActiveFunction()
  end
  if active == nil then
    active = false
  end
  setactive(self.ui.mBtn_PreGun, active)
  active = nil
  if self.rightArrowActiveFunction then
    active = self.rightArrowActiveFunction()
  end
  if active == nil then
    active = false
  end
  setactive(self.ui.mBtn_NextGun, active)
end
