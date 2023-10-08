require("UI.ArchivesPanel.Item.ArchivesCenterPlotListItemV2")
require("UI.ArchivesPanel.Item.PlotReviewLeftTabItem")
require("UI.UIBasePanel")
ArchivesCenterPanelV2 = class("ArchivesCenterPanelV2", UIBasePanel)
ArchivesCenterPanelV2.__index = ArchivesCenterPanelV2
function ArchivesCenterPanelV2:ctor(root)
  self.super.ctor(self, root)
end
function ArchivesCenterPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitDataAndAddListener()
  self:InstTabItem()
  self.itemUIList = {}
  self.chapterDataList = NetCmdArchivesData:GetChapterDataList()
  self.tablist[1].ui.mBtn_Self.onClick:Invoke()
end
function ArchivesCenterPanelV2:OnInit(root, data)
  self:UpdateRightItem()
end
function ArchivesCenterPanelV2:InitDataAndAddListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mTrans_CG.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.ArchivesCenterCGPanelV2)
  end
end
function ArchivesCenterPanelV2:InstTabItem()
  self.tablist = {}
  for i = 1, 1 do
    local item = PlotReviewLeftTabItem.New()
    item:InitCtrl(self.ui.mTrans_TabContent)
    item:SetData(i)
    table.insert(self.tablist, item)
  end
end
function ArchivesCenterPanelV2:UpdateRightItem()
  for i = 0, self.chapterDataList.Count - 1 do
    local index = i + 1
    if self.itemUIList[index] then
      self.itemUIList[index]:SetData(self.chapterDataList[i])
    else
      local item = ArchivesCenterPlotListItemV2.New()
      item:InitCtrl(self.ui.mTrans_Content)
      item:SetData(self.chapterDataList[i])
      table.insert(self.itemUIList, item)
    end
  end
end
function ArchivesCenterPanelV2:UpdateAnimatorState()
  for k, v in pairs(self.itemUIList) do
    v:RefreshAnimator()
  end
end
function ArchivesCenterPanelV2:OnShowStart()
end
function ArchivesCenterPanelV2:OnShowFinish()
  self:UpdateAnimatorState()
end
function ArchivesCenterPanelV2:OnBackFrom()
  self:UpdateRightItem()
end
function ArchivesCenterPanelV2:OnClose()
end
function ArchivesCenterPanelV2:OnHide()
end
function ArchivesCenterPanelV2:OnHideFinish()
end
function ArchivesCenterPanelV2:OnRelease()
  self:ReleaseCtrlTable(self.tablist)
end
