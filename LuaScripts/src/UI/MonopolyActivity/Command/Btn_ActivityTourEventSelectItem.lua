require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
Btn_ActivityTourEventSelectItem = class("Btn_ActivityTourEventSelectItem", UIBaseCtrl)
Btn_ActivityTourEventSelectItem.__index = Btn_ActivityTourEventSelectItem
function Btn_ActivityTourEventSelectItem:ctor()
  self.super.ctor(self)
end
function Btn_ActivityTourEventSelectItem:InitCtrl(itemPrefab, parent)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.oriColor = self.ui.mImg_Quality.color
end
function Btn_ActivityTourEventSelectItem:ResetShow()
  self.ui.mImg_Quality.color = self.oriColor
  setactive(self.ui.mTrans_CommonBg.gameObject, true)
  setactive(self.ui.mTrans_ItemBg.gameObject, false)
end
function Btn_ActivityTourEventSelectItem:SetCommandData(commandID)
  self:ResetShow()
  setactive(self.ui.mImage_Buff, false)
  self.mData = TableData.listMonopolyOrderDatas:GetDataById(commandID)
  if not self.mData then
    print_error(string_format("MonopolyOrder表中不存在ID:{0}", commandID))
    return
  end
  self.ui.mImage_Icon.sprite = ActivityTourGlobal.GetActivityTourSprite(self.mData.order_icon)
  self.ui.mText_Name.text = self.mData.name.str
  self.ui.mText_Type.text = UIUtils.GetHintStr(270274)
  self.ui.mText_Desc.text = self.mData.order_desc.str
  self.ui.mImg_Quality.color = TableData.GetActivityTourCommand_Quality_Color(self.mData.level)
  local isShowMove = self.mData.section and self.mData.section.Count > 0
  setactive(self.ui.mTrans_Move, isShowMove)
  if isShowMove then
    if self.mData.section.Count == 1 then
      self.ui.mText_Move.text = tostring(self.mData.section.Count)
    else
      self.ui.mText_Move.text = UIUtils.StringFormatWithHintId(270164, self.mData.section[0], self.mData.section[1])
    end
  end
  self.ui.mBtn_Root.interactable = true
  setactive(self.ui.mTrans_New, false)
  setactive(self.ui.mBtn_Delete.gameObject, false)
  setactive(self.ui.mBtn_Replace.gameObject, false)
end
function Btn_ActivityTourEventSelectItem:ShowNew(isShow)
  setactive(self.ui.mTrans_New, isShow)
end
function Btn_ActivityTourEventSelectItem:ShowDeleteBtn(onClickDelete)
  setactive(self.ui.mBtn_Delete.gameObject, true)
  setactive(self.ui.mBtn_Replace.gameObject, false)
  if onClickDelete then
    UIUtils.GetListener(self.ui.mBtn_Delete.gameObject).onClick = function()
      onClickDelete()
    end
  end
end
function Btn_ActivityTourEventSelectItem:ShowReplaceBtn(onClickReplace)
  setactive(self.ui.mBtn_Delete.gameObject, false)
  setactive(self.ui.mBtn_Replace.gameObject, true)
  if onClickReplace then
    UIUtils.GetListener(self.ui.mBtn_Replace.gameObject).onClick = function()
      onClickReplace()
    end
  end
end
function Btn_ActivityTourEventSelectItem:SetSelectCallBack(index, selCallBack)
  self.index = index
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    selCallBack(index)
  end
end
function Btn_ActivityTourEventSelectItem:RefreshSelect(selIdx)
  self.ui.mBtn_Root.interactable = self.index ~= selIdx
end
function Btn_ActivityTourEventSelectItem:EnableBtn(enable)
  self.ui.mBtn_Root.enabled = enable
end
function Btn_ActivityTourEventSelectItem:SetPointData(point)
  self:ResetShow()
  setactive(self.ui.mImage_Buff, false)
  self.ui.mImage_Icon.sprite = IconUtils.GetActivityTourIcon(MonopolyWorld.MpData.levelData.token_icon)
  self.ui.mText_Name.text = point
  self.ui.mText_Type.text = TableData.GetHintById(270227)
  self.ui.mText_Desc.text = TableData.GetHintById(270228)
  self.ui.mBtn_Root.interactable = true
  setactive(self.ui.mTrans_Move, false)
  setactive(self.ui.mTrans_New, false)
  setactive(self.ui.mBtn_Delete.gameObject, false)
  setactive(self.ui.mBtn_Replace.gameObject, false)
end
function Btn_ActivityTourEventSelectItem:SetInspirationData(itemId, itemNum)
  self:ResetShow()
  setactive(self.ui.mImage_Buff, false)
  local data = TableData.GetItemData(itemId)
  if data then
    self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(itemId)
    self.ui.mText_Name.text = data.name.str .. string_format(TableData.GetHintById(270313), itemNum)
    self.ui.mText_ItemType.text = TableData.GetHintById(270229)
    self.ui.mText_Desc.text = data.introduction.str
    self.ui.mImg_Quality.color = IconUtils.GetItemColorByRank(data.Rank)
  else
    self.ui.mText_Name.text = ""
    self.ui.mText_ItemType.text = ""
    self.ui.mText_Desc.text = ""
  end
  self.ui.mBtn_Root.interactable = true
  setactive(self.ui.mTrans_Move, false)
  setactive(self.ui.mTrans_New, false)
  setactive(self.ui.mBtn_Delete.gameObject, false)
  setactive(self.ui.mBtn_Replace.gameObject, false)
  setactive(self.ui.mTrans_CommonBg.gameObject, false)
  setactive(self.ui.mTrans_ItemBg.gameObject, true)
end
function Btn_ActivityTourEventSelectItem:SetBuffData(buffID)
  self:ResetShow()
  setactive(self.ui.mImage_Buff, true)
  self.ui.mImg_Quality.color = TableData.GetActivityTourCommand_Quality_Color(ActivityTourGlobal.EventPointBuffRare)
  local buffData = TableData.listMonopolyEffectDatas:GetDataById(buffID)
  if not buffData then
    return
  end
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIcon(ActivityTourGlobal.EventPointBuffIconPath)
  self.ui.mImage_Buff.sprite = IconUtils.GetBuffIcon(buffData.icon)
  self.ui.mText_Name.text = buffData.name.str
  if buffData.buff_type == CS.LuaUtils.EnumToInt(CS.GF2.Monopoly.BuffEffectType.DeBuff) then
    self.ui.mText_Type.text = TableData.GetHintById(270281)
  else
    self.ui.mText_Type.text = TableData.GetHintById(270230)
  end
  self.ui.mText_Desc.text = buffData.desc.str
  self.ui.mBtn_Root.interactable = true
  setactive(self.ui.mTrans_Move, false)
  setactive(self.ui.mTrans_New, false)
  setactive(self.ui.mBtn_Delete.gameObject, false)
  setactive(self.ui.mBtn_Replace.gameObject, false)
end
