require("UI.UIBaseCtrl")
ArchivesCenterStoryItemV2 = class("ArchivesCenterStoryItemV2", UIBaseCtrl)
ArchivesCenterStoryItemV2.__index = ArchivesCenterStoryItemV2
function ArchivesCenterStoryItemV2:ctor()
end
function ArchivesCenterStoryItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ArchivesCenterRecordPanelV2, {
      1,
      self.data
    })
    self.parent.scrollIndex = self.index
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Item.gameObject).onClick = function()
    local stcData = TableData.GetItemData(self.data.item_id)
    UITipsPanel.Open(stcData, nil, true)
  end
end
function ArchivesCenterStoryItemV2:SetData(data, index, parent)
  self.data = data
  self.parent = parent
  self.index = index
  self.ui.mText_Num.text = data.code.str
  self.ui.mImg_Pic.sprite = IconUtils.GetArchivesIcon(data.icon)
  self.ui.mText_Name.text = data.name.str
  setactive(self.ui.mTrans_RedPoint, NetCmdArchivesData:PlotSingleHaveRed(data.id))
  local currPlotCount = NetCmdArchivesData:GetPlotCurrCount(data.id)
  local maxPlotCount = NetCmdArchivesData:GetPlotGroupCount(data.id)
  self.ui.mText_Text.text = string.format("%d/%d", currPlotCount, maxPlotCount)
  if currPlotCount >= maxPlotCount then
    self.ui.mAnimator_Root:SetBool("Bool", true)
  else
    self.ui.mAnimator_Root:SetBool("Bool", false)
  end
  local itemData = TableDataBase.listItemDatas:GetDataById(data.item_id)
  if itemData then
    self.ui.mImg_Item.sprite = IconUtils.GetItemIconSprite(itemData.id)
  end
end
