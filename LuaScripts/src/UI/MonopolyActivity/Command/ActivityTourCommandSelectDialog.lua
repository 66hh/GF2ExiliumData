require("UI.UIBasePanel")
require("UI.MonopolyActivity.Store.Item.ActivityTourStoreItem")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourCommandSelectDialog = class("ActivityTourCommandSelectDialog", UIBasePanel)
ActivityTourCommandSelectDialog.__index = ActivityTourCommandSelectDialog
function ActivityTourCommandSelectDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourCommandSelectDialog:OnInit(root, param)
  self.super.SetRoot(self, root)
  self.mCommandItems = {}
  self.mClickIndex = -1
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:RegisterEvent()
  self.mSelectCommandIndex = -1
  if param.selectCommandIndex ~= nil then
    self.mSelectCommandIndex = param.selectCommandIndex + 1
  end
  self.mOnSelectCallBack = param.onSelectCallBack
  self:UpdateAll()
  if not self.mSelectCommandIndex or self.mSelectCommandIndex < 1 then
    self:OnClick(1)
  else
    self:OnClick(self.mSelectCommandIndex)
  end
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourCommandSelectDialog.CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourCommandSelectDialog)
end
function ActivityTourCommandSelectDialog:RegisterEvent()
  UIUtils.AddBtnClickListener(self.ui.mBtnClose, function()
    self.CloseSelf()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close, function()
    self.CloseSelf()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Select, function()
    local selectStoreData = self.mCommandItems[self.mClickIndex]
    if not selectStoreData then
      print_error("选择的指令不存在")
      return
    end
    if self.mOnSelectCallBack then
      self.mOnSelectCallBack(self.mClickIndex - 1, selectStoreData.data)
    end
    self.CloseSelf()
  end)
end
function ActivityTourCommandSelectDialog:UpdateAll()
  local commandList = MonopolyWorld.MpData.commandList
  if not commandList then
    return
  end
  local showCount = commandList.Count
  for i = 1, showCount do
    local commandItem = self.mCommandItems[i]
    if not commandItem then
      commandItem = ActivityTourStoreItem.New()
      commandItem:InitCtrl(self.ui.mSCL_CommandItem.childItem, self.ui.mSCL_CommandItem.transform, function()
        self:OnClick(i)
      end)
      self.mCommandItems[i] = commandItem
    end
    commandItem:SetData(commandList[i - 1], commandList[i - 1], i)
    commandItem.mUIRoot:SetAsLastSibling()
  end
  if showCount <= #self.mCommandItems then
    return
  end
  for i = showCount, #self.mCommandItems do
    local commandItem = self.mCommandItems[i]
    if commandItem then
      commandItem:Hide()
    end
  end
end
function ActivityTourCommandSelectDialog:OnClick(index)
  self.mClickIndex = index
  for i = 1, #self.mCommandItems do
    local commandItem = self.mCommandItems[i]
    if commandItem then
      local isSelect = index == i
      commandItem:EnableBtn(not isSelect)
    end
  end
  self:RefreshSelectInfo(index)
end
function ActivityTourCommandSelectDialog:RefreshSelectInfo(index)
  local selectStoreData = self.mCommandItems[index]
  if not selectStoreData then
    print_error("选择的指令不存在：" .. tostring(index))
    return
  end
  setactive(self.ui.mTrans_Select, index == self.mSelectCommandIndex)
  setactive(self.ui.mBtn_Select, index ~= self.mSelectCommandIndex)
  local data = selectStoreData.data
  self.ui.mText_CommandName.text = data.name.str
  self.ui.mImage_Quality.color = ActivityTourGlobal.GetCommandItemQualityColor(data.level)
  self.ui.mText_CommandDesc.text = data.order_desc.str
  self.ui.mText_CommandIntroduction.text = data.order_desc2.str
  if data.section.Count == 1 then
    self.ui.mText_MoveDesc.text = tostring(data.section.Count)
  else
    self.ui.mText_MoveDesc.text = UIUtils.StringFormatWithHintId(270164, data.section[0], data.section[1])
  end
end
function ActivityTourCommandSelectDialog:OnRelease()
end
function ActivityTourCommandSelectDialog:OnClose()
  self:ReleaseCtrlTable(self.mCommandItems, true)
  self.mCommandItems = nil
end
