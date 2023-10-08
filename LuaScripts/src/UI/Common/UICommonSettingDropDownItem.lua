UICommonSettingDropDownItem = class("UICommonSettingDropDownItem", UIBaseCtrl)
UICommonSettingDropDownItem.__index = UICommonSettingDropDownItem
UICommonSettingDropDownItem.mText_SuitName = nil
UICommonSettingDropDownItem.mText_SuitNum = nil
function UICommonSettingDropDownItem:__InitCtrl()
end
function UICommonSettingDropDownItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComSettingDropDownItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self.ui = {}
  self:SetRoot(obj.transform)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  self.textcolor = obj.transform:GetComponent(typeof(CS.TextImgColor))
  self.beforecolor = self.textcolor.BeforeSelected
  self.aftercolor = self.textcolor.AfterSelected
  self.imgbeforecolor = self.textcolor.ImgBeforeSelected
  self.imgaftercolor = self.textcolor.ImgAfterSelected
end
function UICommonSettingDropDownItem:SetData(data, callback)
  self.id = data.id
  self.ui.mText_Name.text = data.name
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    if callback then
      callback(self)
    end
  end
end
function UICommonSettingDropDownItem:SetSelected(selected)
  if selected then
    self.ui.mImg_Bg.color = self.imgaftercolor
    self.ui.mText_Name.color = self.aftercolor
    setactive(self.ui.mTrans_Sel, true)
  else
    self.ui.mImg_Bg.color = self.imgbeforecolor
    self.ui.mText_Name.color = self.beforecolor
    setactive(self.ui.mTrans_Sel, false)
  end
end
