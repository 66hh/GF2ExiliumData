require("UI.UIBaseCtrl")
Btn_ActivityMuseDialogItem = class("Btn_ActivityMuseDialogItem", UIBaseCtrl)
Btn_ActivityMuseDialogItem.__index = Btn_ActivityMuseDialogItem
function Btn_ActivityMuseDialogItem:ctor()
end
function Btn_ActivityMuseDialogItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_ActivityMuseDialogItem.gameObject).onClick = function()
    if not self.isCanClick then
      return
    end
    if self.type == 1 then
      if self.data.id == self.parent.leftSelectID then
        return
      end
      self.parent:OnSelectLeft(self.index)
    else
      if self.data.id == self.parent.rightSelectID then
        return
      end
      self.parent:OnSelectRight(self.index)
    end
  end
end
function Btn_ActivityMuseDialogItem:SetSelect(isSelect)
  self.ui.mBtn_ActivityMuseDialogItem.enabled = not isSelect
  setactive(self.ui.mTrans_ImgSel.gameObject, isSelect)
end
function Btn_ActivityMuseDialogItem:SetDisable(disable)
  if self.type == 1 then
    setactive(self.ui.mTrans_ImgSel.gameObject, not disable and self.parent.leftSelectID == self.data.id)
    self.ui.mBtn_ActivityMuseDialogItem.interactable = not disable and self.itemCount > 0
  else
    setactive(self.ui.mTrans_ImgSel.gameObject, not disable and self.parent.rightSelectID == self.data.id)
    self.ui.mBtn_ActivityMuseDialogItem.interactable = not disable
  end
end
function Btn_ActivityMuseDialogItem:CleanState()
  self.ui.mBtn_ActivityMuseDialogItem.enabled = true
  self.ui.mBtn_ActivityMuseDialogItem.interactable = true
  setactive(self.ui.mTrans_ImgSel.gameObject, false)
end
function Btn_ActivityMuseDialogItem:SetData(data, type, parent, index, isCanClick)
  self.data = data
  self.type = type
  self.parent = parent
  self.index = index
  self.isCanClick = isCanClick
  self.ui.mText_Name.text = data.name
  self.itemCount = NetCmdItemData:GetItemCount(data.id)
  if self.itemCount <= 0 then
    self.ui.mText_Num.text = TableData.GetHintById(106056) .. "<color=#FF5E41>" .. self.itemCount .. "</color>"
  else
    self.ui.mText_Num.text = TableData.GetHintById(106056) .. self.itemCount
  end
  print(data.id, type, self.itemCount)
  if type == 1 then
    self.ui.mAnimator_ActivityMuseDialogItem:SetBool("Disabled", self.itemCount <= 0)
    setactive(self.ui.mTrans_ImgSel.gameObject, parent.leftSelectID == data.id)
    self.ui.mBtn_ActivityMuseDialogItem.interactable = self.itemCount > 0
  else
    self.ui.mAnimator_ActivityMuseDialogItem:SetBool("Disabled", parent.rightSelectID == data.id)
    setactive(self.ui.mTrans_ImgSel.gameObject, parent.rightSelectID == data.id)
  end
  if self.sendItem == nil then
    self.sendItem = UICommonItem.New()
    self.sendItem:InitCtrl(self.ui.mTrans_ImgItem)
  end
  self.sendItem:SetItemData(data.id, 1, nil, nil, nil, nil, nil, function()
    UITipsPanel.Open(TableData.GetItemData(data.id))
  end)
end
function Btn_ActivityMuseDialogItem:UpdateCount(data)
  if self.sendItem then
    self.sendItem:SetItemData(data.id, 1, nil, nil, nil, nil, nil, function()
      UITipsPanel.Open(TableData.GetItemData(data.id))
    end)
  end
end
function Btn_ActivityMuseDialogItem:SetExchangeData(exchangeData, type, isCanClick)
  self.isCanClick = isCanClick
  local itemId = exchangeData.Offer
  if type == 2 then
    itemId = exchangeData.Need
  end
  local itemData = TableData.listCollectionItemDatas:GetDataById(itemId)
  if itemData then
    self.ui.mText_Name.text = itemData.name
  end
  setactive(self.ui.mTrans_ImgSel.gameObject, false)
  local itemCount = NetCmdItemData:GetItemCount(itemId)
  if itemCount <= 0 then
    self.ui.mText_Num.text = TableData.GetHintById(106056) .. "<color=#FF5E41>" .. itemCount .. "</color>"
  else
    self.ui.mText_Num.text = TableData.GetHintById(106056) .. itemCount
  end
  if self.sendItem == nil then
    self.sendItem = UICommonItem.New()
    self.sendItem:InitCtrl(self.ui.mTrans_ImgItem)
  end
  self.sendItem:SetItemData(itemId, 1, nil, nil, nil, nil, nil, function()
    UITipsPanel.Open(TableData.GetItemData(itemId))
  end)
end
