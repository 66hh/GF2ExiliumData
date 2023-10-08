require("UI.UIBasePanel")
require("UI.ArchivesPanel.Item.Btn_ArchivesCenterChrItemV2")
ArchivesCenterChrEnterPanelV2 = class("ArchivesCenterChrEnterPanelV2", UIBasePanel)
ArchivesCenterChrEnterPanelV2.__index = ArchivesCenterChrEnterPanelV2
function ArchivesCenterChrEnterPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function ArchivesCenterChrEnterPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:OnBtnClick()
end
function ArchivesCenterChrEnterPanelV2:OnBtnClick()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterChrEnterPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function ArchivesCenterChrEnterPanelV2:OnInit(root, data)
  self.characterList = NetCmdArchivesData:GetCharacterList()
  function self.ui.mVirtualListEx_AchievementList.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx_AchievementList.itemRenderer(...)
    self:ItemRenderer(...)
  end
  self.ui.mVirtualListEx_AchievementList.numItems = self.characterList.Count
  self.ui.mVirtualListEx_AchievementList:Refresh()
end
function ArchivesCenterChrEnterPanelV2:ItemProvider()
  local itemView = Btn_ArchivesCenterChrItemV2.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ArchivesCenterChrEnterPanelV2:ItemRenderer(index, renderData)
  local data = self.characterList[index]
  local item = renderData.data
  item:SetData(data, index)
end
function ArchivesCenterChrEnterPanelV2:OnShowStart()
end
function ArchivesCenterChrEnterPanelV2:OnShowFinish()
end
function ArchivesCenterChrEnterPanelV2:OnBackFrom()
  self.ui.mVirtualListEx_AchievementList:Refresh()
end
function ArchivesCenterChrEnterPanelV2:OnClose()
end
function ArchivesCenterChrEnterPanelV2:OnHide()
end
function ArchivesCenterChrEnterPanelV2:OnHideFinish()
end
function ArchivesCenterChrEnterPanelV2:OnRelease()
end
