require("UI.Common.UICommonSimpleView")
require("UI.Repository.Item.UIRepositoryBoxSelectItem")
UIRepositoryUnSelectItemBoxDialog = class("UIRepositoryUnSelectItemBoxDialog", UIBasePanel)
UIRepositoryUnSelectItemBoxDialog.__index = UIRepositoryUnSelectItemBoxDialog
function UIRepositoryUnSelectItemBoxDialog:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.mCSPanel = csPanel
end
function UIRepositoryUnSelectItemBoxDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.mData = data
  self.mview = UICommonSimpleView.New()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self.itemList = {}
  self.itemTableList = {}
  self:InitData()
end
function UIRepositoryUnSelectItemBoxDialog:OnClose()
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
  self.ui = nil
  self.mview = nil
  self.itemTableList = nil
end
function UIRepositoryUnSelectItemBoxDialog:OnRelease()
end
function UIRepositoryUnSelectItemBoxDialog:InitData()
  self.ui.mText_Title.text = self.mData.name.str
  local dropID = tonumber(self.mData.ArgsStr)
  local itemDataTable = {}
  local dropTableData = TableData.listDropPackageDatas:GetDataById(dropID, true)
  if dropTableData then
    local count = dropTableData.args.Count
    for i = 0, count - 1 do
      local args = dropTableData.args[i]
      local splitArgs = string.split(args, ":")
      if #splitArgs == 3 then
        local itemId = tonumber(splitArgs[1])
        local num = tonumber(splitArgs[2])
        if itemDataTable[itemId] then
          itemDataTable[itemId] = itemDataTable[itemId] + num
        else
          itemDataTable[itemId] = num
        end
      end
    end
  end
  for i, v in pairs(itemDataTable) do
    local t = {i, v}
    table.insert(self.itemTableList, t)
  end
  for i = 1, #self.itemTableList do
    local splitItem = self.itemTableList[i]
    local itemId = splitItem[1]
    local itemNum = splitItem[2]
    local itemTableData = TableData.GetItemData(itemId)
    local item = UIRepositoryBoxSelectItem.New()
    item:InitCtrl(self.ui.mScrollListChild_Content)
    item:SetData(itemId, itemNum, itemTableData)
    table.insert(self.itemList, item)
  end
end
function UIRepositoryUnSelectItemBoxDialog:AddBtnListen()
  local f = function()
    UIManager.CloseUI(UIDef.UIRepositoryUnSelectItemBoxDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = f
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = f
  UIUtils.GetButtonListener(self.ui.mBtn_BGClose.gameObject).onClick = f
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    self:OnConfirmClick()
  end
end
function UIRepositoryUnSelectItemBoxDialog:OnConfirmClick()
  if TipsManager.CheckItemIsOverflowAndStop(self.mData.id, 1) then
    return
  end
  NetCmdItemData:SendItemUse(self.mData.id, 1, function()
    UIManager.CloseUI(UIDef.UIRepositoryUnSelectItemBoxDialog)
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
  end)
end
