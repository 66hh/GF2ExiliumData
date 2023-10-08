require("UI.UIBaseCtrl")
Btn_ActivityThemeOptionItem = class("Btn_ActivityThemeOptionItem", UIBaseCtrl)
Btn_ActivityThemeOptionItem.__index = Btn_ActivityThemeOptionItem
function Btn_ActivityThemeOptionItem:ctor()
end
function Btn_ActivityThemeOptionItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_ActivityThemeOptionItem.gameObject).onClick = function()
    if not self.parent.isQuestedList[self.questID] then
      self.parent.isQuestedList[self.questID] = true
      self.parent:UpdateAnswerDetail()
      self.parent:OnQuestIndexAdd(self.option)
      setactive(self.ui.mTrans_True.gameObject, self.option)
      setactive(self.ui.mTrans_False.gameObject, not self.option)
    else
      CS.PopupMessageManager.PopupString("您已经答过该题了！")
    end
  end
end
function Btn_ActivityThemeOptionItem:SetData(data, option, index, parent)
  self.option = option
  self.parent = parent
  self.index = index
  self.questID = data.id
  setactive(self.ui.mTrans_True.gameObject, false)
  setactive(self.ui.mTrans_False.gameObject, false)
  if option then
    self.ui.mText_Info.text = data.option_right.str
  else
    self.ui.mText_Info.text = data.option_error.str
  end
end
