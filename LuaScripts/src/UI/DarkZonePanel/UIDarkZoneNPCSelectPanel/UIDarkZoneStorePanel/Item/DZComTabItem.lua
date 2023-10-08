require("UI.UIBaseCtrl")
DZComTabItem = class("DZComTabItem", UIBaseCtrl)
DZComTabItem.__index = DZComTabItem
function DZComTabItem:__InitCtrl()
end
function DZComTabItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self.callBack = nil
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DZComTabItem:SetTable(panelTable)
  self.tableData = panelTable
end
function DZComTabItem:SetData(Data, type)
  self.ui.mText_Name.text = Data
  if type == 1 then
    function self.callBack()
      if DZStoreUtils.LastTab ~= nil then
        DZStoreUtils.LastTab.interactable = true
      end
      if self.tableData.ClickMultiSell then
        self.tableData:CancleSell()
      end
      DZStoreUtils.LastTab = self.ui.mBtn_ComTab1ItemV2
      self.ui.mBtn_ComTab1ItemV2.interactable = false
      self.tableData.CurTab = type
      self.tableData:UpdateBuyData()
      setactive(self.tableData.ui.mTrans_GrpBottom, false)
    end
  elseif type == 2 then
    function self.callBack()
      if DZStoreUtils.LastTab ~= nil then
        DZStoreUtils.LastTab.interactable = true
      end
      DZStoreUtils.LastTab = self.ui.mBtn_ComTab1ItemV2
      self.ui.mBtn_ComTab1ItemV2.interactable = false
      self.tableData.CurTab = type
      if self.tableData.SortWay == 1 then
        setactive(self.tableData.ScreenItem.mBtn_Ascend.gameObject, false)
      else
        setactive(self.tableData.ScreenItem.mBtn_Ascend.gameObject, true)
      end
      self.tableData:UpdateSellData()
      setactive(self.tableData.ui.mTrans_GrpBottom, true)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ComTab1ItemV2.gameObject).onClick = self.callBack
end
