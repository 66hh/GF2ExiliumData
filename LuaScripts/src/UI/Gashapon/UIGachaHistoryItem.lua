require("UI.UIBaseCtrl")
UIGachaHistoryItem = class("UIGachaHistoryItem", UIBaseCtrl)
UIGachaHistoryItem.__index = UIGachaHistoryItem
function UIGachaHistoryItem:__InitCtrl()
  self.mText_Time = self:GetText("Text_Time")
  self.mText_Type = self:GetText("Text_Type")
  self.mText_Source = self:GetText("Text_Source")
  self.mText_Name = self:GetText("Text_Name")
  self.mTrans_Bg = self:GetRectTransform("ImgBg")
end
function UIGachaHistoryItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Gashapon/GashaponProbabilityDetailsRecordItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(root, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
end
function UIGachaHistoryItem:SetData(history)
  local gachaData = TableDataBase.listGachaDatas:GetDataById(history.GachaId)
  local itemData = TableData.GetItemData(history.ItemId)
  self.mText_Name.text = itemData.name.str
  if itemData.rank == 4 then
    self.mText_Name.color = ColorUtils.PurpleColor
  elseif itemData.rank == 5 then
    self.mText_Name.color = ColorUtils.YellowColor
  else
    self.mText_Name.color = CS.GF2.UI.UITool.StringToColor("1A2C3399")
  end
  if itemData.type == 10 then
    self.mText_Type.text = TableData.GetHintById(107048)
  elseif itemData.type == 20 then
    self.mText_Type.text = TableData.GetHintById(107049)
  end
  self.mText_Source.text = gachaData.name.str
  self.mText_Time.text = CS.CGameTime.ConvertLongToDateTime(history.GachaTime):ToString("yyyy-MM-dd HH:mm:ss")
end
function UIGachaHistoryItem:SetBG(isActive)
  setactive(self.mTrans_Bg, isActive)
end
