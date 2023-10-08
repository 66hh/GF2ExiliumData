require("UI.UIBaseCtrl")
require("UI.StorePanel.Daiyan.Btn_DaiyanChapterListItem")
DaiyanChapterListItem = class("DaiyanChapterListItem", UIBaseCtrl)
DaiyanChapterListItem.__index = DaiyanChapterListItem
function DaiyanChapterListItem:ctor()
end
function DaiyanChapterListItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.itemViewList = {}
  self.storyDataList = {}
  setactive(self.ui.mTrans_Main.gameObject, false)
  setactive(self.ui.mTrans_BranchAbove.gameObject, false)
  setactive(self.ui.mTrans_BranchBlow.gameObject, false)
  setactive(self.ui.mTrans_AboveGO.gameObject, false)
  setactive(self.ui.mTrans_BelowGO.gameObject, false)
end
function DaiyanChapterListItem:SetMainData(chapterData, data)
  self:UpdateCtrl(chapterData, data, self.ui.mTrans_Main)
  self.itemViewList[data.id]:UpdateBg(1)
  if not NetCmdThemeData:LevelIsUnLock(data.id) then
    self.ui.mImg_Line.color = Color(0.13333333333333333, 0.13333333333333333, 0.13333333333333333, 0.8)
  end
end
function DaiyanChapterListItem:SetTopData(chapterData, data)
  self:UpdateCtrl(chapterData, data, self.ui.mTrans_AboveParent)
  self.itemViewList[data.id]:UpdateBg(2)
  if not NetCmdThemeData:LevelIsUnLock(data.id) then
    self.ui.mImg_AboveLine.color = Color(0.13333333333333333, 0.13333333333333333, 0.13333333333333333, 0.8)
  end
end
function DaiyanChapterListItem:SetBtmData(chapterData, data)
  self:UpdateCtrl(chapterData, data, self.ui.mTrans_BelowParent)
  self.itemViewList[data.id]:UpdateBg(2)
  if not NetCmdThemeData:LevelIsUnLock(data.id) then
    self.ui.mImg_BlowLine.color = Color(0.13333333333333333, 0.13333333333333333, 0.13333333333333333, 0.8)
  end
end
function DaiyanChapterListItem:UpdateCtrl(chapterData, data, trans)
  self.storyDataList[data.id] = data
  if self.itemViewList[data.id] == nil then
    self.itemViewList[data.id] = Btn_DaiyanChapterListItem.New()
    self.itemViewList[data.id]:InitCtrl(trans)
  end
  self.itemViewList[data.id]:SetData(chapterData, data)
  setactive(trans.gameObject, true)
  if data.type == 1 or data.type == 2 then
    setactive(self.ui.mTrans_ImgLine.gameObject, data.next_id.Count > 0)
  end
  self.itemViewList[data.id]:SetNextLine(false)
end
function DaiyanChapterListItem:SetTopGroupData(chapterData, data)
  if self.itemViewList[data.id] == nil then
    local instObj = instantiate(self.ui.mTrans_AboveGO, self.ui.mTrans_BranchAbove)
    local topItem = Btn_DaiyanChapterListItem.New()
    setactive(instObj.gameObject, true)
    topItem:InitCtrl(instObj.transform)
    self.itemViewList[data.id] = topItem
    self.storyDataList[data.id] = data
  end
  setactive(self.ui.mTrans_BranchAbove.gameObject, true)
  self.itemViewList[data.id]:SetData(chapterData, data)
  if self.itemViewList[data.pre_id[0]] then
    self.itemViewList[data.pre_id[0]]:SetNextLine(true)
  end
  self.itemViewList[data.id]:UpdateBg(2)
end
function DaiyanChapterListItem:SetBtmGroupData(chapterData, data)
  if self.itemViewList[data.id] == nil then
    self.storyDataList[data.id] = data
    local instObj = instantiate(self.ui.mTrans_BelowGO, self.ui.mTrans_BranchBlow)
    setactive(instObj.gameObject, true)
    local btmItem = Btn_DaiyanChapterListItem.New()
    btmItem:InitCtrl(instObj)
    self.itemViewList[data.id] = btmItem
  end
  setactive(self.ui.mTrans_BranchBlow.gameObject, true)
  self.itemViewList[data.id]:SetData(chapterData, data)
  if self.itemViewList[data.pre_id[0]] then
    self.itemViewList[data.pre_id[0]]:SetNextLine(true)
  end
  self.itemViewList[data.id]:UpdateBg(2)
end
function DaiyanChapterListItem:UpdateItem(storyData)
  self.itemViewList[storyData.id]:UpdateItem()
end
function DaiyanChapterListItem:SetSelected(storyData, isSelect)
  self.itemViewList[storyData.id]:SetSelected(isSelect)
end
function DaiyanChapterListItem:CleanAllSelected()
  for k, v in pairs(self.itemViewList) do
    v:SetSelected(false)
  end
end
