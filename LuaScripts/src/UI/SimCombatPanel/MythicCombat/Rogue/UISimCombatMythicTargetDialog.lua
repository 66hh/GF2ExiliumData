require("UI.SimCombatPanel.Item.Rogue.SimCombatMythicTargetItem")
require("UI.UIBasePanel")
UISimCombatMythicTargetDialog = class("UISimCombatMythicTargetDialog", UIBasePanel)
UISimCombatMythicTargetDialog.__index = UISimCombatMythicTargetDialog
local self = UISimCombatMythicTargetDialog
function UISimCombatMythicTargetDialog:ctor(obj)
  UISimCombatMythicTargetDialog.super.ctor(self)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicTargetDialog:OnInit(root, data)
  self.super.SetRoot(UISimCombatMythicTargetDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.targetList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicTargetDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicTargetDialog)
  end
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, itemData)
    self:ItemRenderer(index, itemData)
  end
  self.ui.mVirtualListEx_TargetList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_TargetList.itemRenderer = self.itemRenderer
  self:SetTargetList()
  self:AddListener()
end
function UISimCombatMythicTargetDialog:SetTargetList()
  NetCmdSimCombatRogueData:InitRogueTarget()
  self.targetList = NetCmdSimCombatRogueData.TargetList
  self.ui.mMonoScrollerFadeManager_Content.enabled = false
  self.ui.mMonoScrollerFadeManager_Content.enabled = true
  self.ui.mVirtualListEx_TargetList.numItems = self.targetList.Count
  self.ui.mVirtualListEx_TargetList:Refresh()
  self.ui.mTrans_Content.anchoredPosition = Vector2(self.ui.mTrans_Content.anchoredPosition.x, 0)
end
function UISimCombatMythicTargetDialog:ItemProvider()
  local itemView = SimCombatMythicTargetItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UISimCombatMythicTargetDialog:ItemRenderer(index, itemData)
  if self.targetList == nil or self.targetList.Count == 0 then
    return
  end
  local data = self.targetList[index]
  local item = itemData.data
  item:SetData(data.rogueTaskData, data.targetState)
end
function UISimCombatMythicTargetDialog:OnHide()
  self.isHide = true
  self:RemoveListener()
end
function UISimCombatMythicTargetDialog:OnClose()
  self.ui.mVirtualListEx_TargetList.numItems = 0
end
function UISimCombatMythicTargetDialog:OnClickReceiveTarget(message)
  local boolean = message.Sender
  self.ui.mCanvasGroup_Dialog.blocksRaycasts = not boolean
end
function UISimCombatMythicTargetDialog:AddListener()
  function self.setTargetList()
    self:SetTargetList()
  end
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.RogueEvent.SetTargetList, self.setTargetList)
  function self.onClickReceiveTarget(message)
    self:OnClickReceiveTarget(message)
  end
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.RogueEvent.OnClickReceiveTarget, self.onClickReceiveTarget)
end
function UISimCombatMythicTargetDialog:RemoveListener()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.RogueEvent.SetTargetList, self.setTargetList)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.RogueEvent.OnClickReceiveTarget, self.onClickReceiveTarget)
end
