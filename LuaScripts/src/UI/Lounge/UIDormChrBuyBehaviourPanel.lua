require("UI.UIBasePanel")
UIDormChrBuyBehaviourPanel = class("UIDormChrBuyBehaviourPanel", UIBasePanel)
UIDormChrBuyBehaviourPanel.__index = UIDormChrBuyBehaviourPanel
function UIDormChrBuyBehaviourPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.Is3DPanel = true
end
function UIDormChrBuyBehaviourPanel:OnAwake(root, data)
  self:SetRoot(root)
end
function UIDormChrBuyBehaviourPanel:OnInit(root, data)
  self.mData = data[1]
  self.callback = data[2]
  self:SetBaseData()
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnLister()
end
function UIDormChrBuyBehaviourPanel:OnShowStart()
  self.ui.mText_Content.text = string_format(self.formatStr, self.mData.name.str)
  local iconName = "Item_Icon_DormAct_%s"
  local s = string.format(iconName, self.mData.uiicon)
  self.ui.mImg_Icon.sprite = IconUtils.GetIconV2("Item", s)
  local itemID, itemNum
  for i, v in pairs(self.mData.unlock_item) do
    itemID = i
    itemNum = v
  end
  self.ui.mImg_CostItem.sprite = IconUtils.GetItemIconSprite(itemID)
  self.ui.mText_CostNum.text = tostring(itemNum)
end
function UIDormChrBuyBehaviourPanel:OnShowFinish()
end
function UIDormChrBuyBehaviourPanel:OnTop()
end
function UIDormChrBuyBehaviourPanel:OnBackFrom()
end
function UIDormChrBuyBehaviourPanel:OnClose()
  self.isShowUI = true
  self.ui = nil
  self.mData = nil
end
function UIDormChrBuyBehaviourPanel:OnHide()
end
function UIDormChrBuyBehaviourPanel:OnHideFinish()
end
function UIDormChrBuyBehaviourPanel:OnRelease()
end
function UIDormChrBuyBehaviourPanel:SetBaseData()
  self.formatStr = TableData.GetHintById(280024)
  self.ui = {}
end
function UIDormChrBuyBehaviourPanel:AddBtnLister()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BGClose.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    self:OnClickBuy()
  end
end
function UIDormChrBuyBehaviourPanel:OnClickClose()
  UIManager.CloseUI(UIDef.UIDormChrBuyBehaviourPanel)
end
function UIDormChrBuyBehaviourPanel:OnClickBuy()
  local itemIsEnough = true
  local itemID = 0
  for i, v in pairs(self.mData.unlock_item) do
    local curNum = NetCmdItemData:GetItemCount(i)
    if v > curNum then
      itemIsEnough = false
      itemID = i
      break
    end
  end
  if itemIsEnough == false then
    local itemData = TableData.GetItemData(itemID)
    local str = itemData.name.str
    CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), str))
    return
  end
  NetCmdLoungeData:SendBuyGunPerformance(self.mData.id, function()
    UIManager.CloseUI(UIDef.UIDormChrBuyBehaviourPanel)
    self.callback()
  end)
end
