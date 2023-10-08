require("UI.UIBaseCtrl")
UIDarkZoneRepoItem = class("UIDarkZoneRepoItem", UIBaseCtrl)
UIDarkZoneRepoItem.__index = UIDarkZoneRepoItem
function UIDarkZoneRepoItem:ctor()
end
function UIDarkZoneRepoItem:__InitCtrl()
end
function UIDarkZoneRepoItem:InitCtrl(parent, clickCallback)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/DarkZoneRepoItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self.clickCallback = clickCallback
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
end
function UIDarkZoneRepoItem:InitItem()
  if self.item == nil then
    local container = self.ui.mTrans_Item:GetComponent(typeof(CS.UICommonContainer))
    self.item = UICommonItem.New()
    self.item:InitObj(container:InstantiateObj())
  end
end
function UIDarkZoneRepoItem:SetData(data)
  if data ~= nil then
    self.data = data
    self.item = nil
    self.emptyItem = nil
    if data.IsItem then
      self:InitItem()
      self.item:SetDarkZoneItemData(data.ItemData.id, data.ItemCount, function()
        self.clickCallback(data)
      end)
    elseif data.IsEquip or data.isMod then
      self:InitItem()
      self.item:SetDarkZoneEquipData(data.ItemData.id, data.Equipped, function()
        self.clickCallback(data)
      end)
    elseif data.IsEmpty then
      if self.emptyItem == nil then
        local container = self.ui.mTrans_EmptyItem:GetComponent(typeof(CS.UICommonContainer))
        local obj = container:InstantiateObj()
        self.emptyItem = {}
        self:LuaUIBindTable(obj, self.emptyItem)
        UIUtils.GetButtonListener(self.emptyItem.mBtn_Self.gameObject).onClick = function()
          if self.data.Locked then
            UIManager.OpenUI(UIDef.UIDarkZoneRepositoryBuyDialog)
          else
            self.clickCallback(data)
          end
        end
        self.emptyItem.mAnimator_Self.enabled = data.Locked
        setactive(self.emptyItem.mTrans_ImgHL, data.Locked)
      end
      setactive(self.emptyItem.mTrans_ImgLock, data.Locked)
    end
    setactive(self.ui.mTrans_Item, not data.IsEmpty)
    setactive(self.ui.mTrans_EmptyItem, data.IsEmpty)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
