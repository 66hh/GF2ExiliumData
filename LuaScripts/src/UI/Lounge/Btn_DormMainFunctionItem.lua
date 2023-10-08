require("UI.UIBaseCtrl")
Btn_DormMainFunctionItem = class("Btn_DormMainFunctionItem", UIBaseCtrl)
Btn_DormMainFunctionItem.__index = Btn_DormMainFunctionItem
function Btn_DormMainFunctionItem:ctor()
end
function Btn_DormMainFunctionItem:InitCtrl(itemPrefab)
  if itemPrefab == nil then
    return
  end
  local instObj = instantiate(itemPrefab.childItem, itemPrefab.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  UIUtils.AddListItem(instObj.gameObject, itemPrefab.gameObject)
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_Item.gameObject).onClick = function()
    self.clickFunction()
  end
end
function Btn_DormMainFunctionItem:SetData(data)
end
function Btn_DormMainFunctionItem:SetBtnName(str)
  self.ui.mText_Text.text = str
end
function Btn_DormMainFunctionItem:SetClickFunction(func)
  self.clickFunction = func
end
function Btn_DormMainFunctionItem:SetIcon(path)
  self.ui.mImg_Type.sprite = IconUtils.GetAtlasV2("Dorm", path)
end
function Btn_DormMainFunctionItem:SetLineVisible(isShow)
  setactive(self.ui.mTrans_ImgLine, isShow)
end
function Btn_DormMainFunctionItem:SetRedPoint(isShow)
  setactive(self.ui.mTrans_RedPoint, isShow)
end
