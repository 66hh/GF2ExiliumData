require("UI.UIBaseCtrl")
ActivityTourBuffDetailItem = class("ActivityTourBuffDetailItem", UIBaseCtrl)
ActivityTourBuffDetailItem.__index = ActivityTourBuffDetailItem
ActivityTourBuffDetailItem.ui = nil
ActivityTourBuffDetailItem.mData = nil
function ActivityTourBuffDetailItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ActivityTourBuffDetailItem:InitCtrl(itemPrefab, parent)
  local obj = instantiate(itemPrefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
end
function ActivityTourBuffDetailItem:Refresh(buffInfo, showLine)
  local buffData = TableData.listMonopolyEffectDatas:GetDataById(buffInfo.Id)
  if not buffData then
    return
  end
  self.ui.mIcon.sprite = IconUtils.GetBuffIcon(buffData.icon)
  self.ui.mTxtName.text = buffData.name.str
  local round = buffInfo.RestTurn
  setactive(self.ui.mTrans_Round.gameObject, buffData.turn < 99)
  self.ui.mTxtRound.text = round
  self.ui.mTxtDes.text = buffData.desc.str
  setactive(self.ui.mTrans_Line.gameObject, showLine)
end
