require("UI.ArchivesPanel.Item.ArchivesCenterPlotLevelItemV2")
require("UI.UIBaseCtrl")
ArchivesCenterPlotListItemV2 = class("ArchivesCenterPlotListItemV2", UIBaseCtrl)
ArchivesCenterPlotListItemV2.__index = ArchivesCenterPlotListItemV2
function ArchivesCenterPlotListItemV2:__InitCtrl()
end
function ArchivesCenterPlotListItemV2:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self.avgItemList = {}
  self.avgIDList = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function ArchivesCenterPlotListItemV2:SetData(data)
  if data.num == 0 then
    self.ui.mText_Num.text = "00"
  else
    self.ui.mText_Num.text = ArchivesUtils:SetIndex(data.num)
  end
  self.ui.mText_Name.text = data.Name.str
  self.ui.mImg_Bg.sprite = IconUtils.GetArchivesIcon(data.chapter_img)
  if NetCmdArchivesData:ChapterAvgUnLock(data.id) then
    setactive(self.ui.mTrans_Avg.gameObject, true)
    setactive(self.ui.mTrans_Text.gameObject, false)
    self.avgIDList = NetCmdArchivesData:GetChapterByChapterId(data.id)
    self:InstAvgItem()
  else
    setactive(self.ui.mTrans_Text.gameObject, true)
  end
end
function ArchivesCenterPlotListItemV2:InstAvgItem()
  local item
  local data = {index = 1, avgId = 1}
  for i = 0, self.avgIDList.Count - 1 do
    local index = i + 1
    data = {
      Index = index,
      avgId = self.avgIDList[i]
    }
    if self.avgItemList[index] then
      self.avgItemList[index]:SetData(data)
    else
      item = ArchivesCenterPlotLevelItemV2.New()
      item:InitCtrl(self.ui.mTrans_Avg)
      item:SetData(data)
      table.insert(self.avgItemList, item)
    end
  end
end
function ArchivesCenterPlotListItemV2:RefreshAnimator()
  for k, v in pairs(self.avgItemList) do
    v:UpdateAniState()
  end
end
