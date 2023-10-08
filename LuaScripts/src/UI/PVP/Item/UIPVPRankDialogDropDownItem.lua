UIPVPRankDialogDropDownItem = class("UIPVPRankDialogDropDownItem", UIBaseCtrl)
function UIPVPRankDialogDropDownItem:ctor()
end
function UIPVPRankDialogDropDownItem:InitCtrl(obj, parent, parentUI)
  local instObj = instantiate(obj, parent)
  self.parent = parent
  self.parentUI = parentUI
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self:SetRoot(instObj.transform)
end
function UIPVPRankDialogDropDownItem:SetData(data, selectCallBack)
  self.mData = data
  self.dropDown = instantiate(self.ui.mScrollListChild_Content.childItem, self.ui.mScrollListChild_Content.transform)
  self:LuaUIBindTable(self.dropDown, self.ui)
  self.ui.mText_SuitName.text = TableData.listNrtpvpSeasonDatas:GetDataById(self.mData.Id).Name.str
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    self:OnHandleClick()
    selectCallBack(data.Id)
  end
end
function UIPVPRankDialogDropDownItem:OnHandleClick()
  setactive(self.ui.mTrans_GrpSel, true)
  self.parentUI.prevPlanId = self.mData.Id
  self.parentUI.ui.mText_SuitName.text = TableData.listNrtpvpSeasonDatas:GetDataById(self.mData.Id).Name.str
  setactive(self.parentUI.ui.mBlockHelper_Screen, false)
end
function UIPVPRankDialogDropDownItem:OnRelease()
  gfdestroy(self.mUIRoot)
  self.index = 0
  self.ui = nil
end
