require("UI.Common.UICommonItem")
require("UI.UIBaseCtrl")
UIRepositoryListItemV2 = class("UIRepositoryListItemV2", UIBaseCtrl)
UIRepositoryListItemV2.__index = UIRepositoryListItemV2
UIRepositoryListItemV2.mImg_Icon = nil
UIRepositoryListItemV2.mText_Name = nil
UIRepositoryListItemV2.mText_Sub = nil
function UIRepositoryListItemV2:__InitCtrl()
  self.mImg_Icon = self.ui.mImg_Icon
  self.mText_Name = self.ui.mText_Name
  self.mText_Sub = self.ui.mText_Sub
  self.mTrans_ItemList = self.ui.mTrans_ItemList
end
function UIRepositoryListItemV2:ctor()
  self.itemList = {}
end
function UIRepositoryListItemV2:InitCtrl(parent)
  self.parent = parent
  local obj
  local childItem = parent:GetComponent(typeof(CS.ScrollListChild))
  if childItem then
    obj = instantiate(childItem.childItem)
  else
    obj = instantiate(UIUtils.GetGizmosPrefab("Repository/RepositoryListItemV2.prefab", self))
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  obj.transform:SetParent(parent, false)
  obj.transform.localScale = vectorone
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIRepositoryListItemV2:SetData(data)
  self.mData = data
  if data then
    self.mText_Name.text = data.title.str
    self.mImg_Icon.sprite = IconUtils.GetRepositoryIcon(data.icon)
  end
end
function UIRepositoryListItemV2:UpdateItemList()
  local t = TableData.GlobalSystemData.BackpackJumpSwitch == 1
  if self.mData then
    local itemDataList = NetCmdItemData:GetRepositoryItemListByTypes(self.mData.item_type)
    for i = 1, #self.itemList do
      if i > itemDataList.Count then
        setactive(self.itemList[i]:GetRoot(), false)
      end
    end
    for i = 0, itemDataList.Count - 1 do
      local itemData = itemDataList[i]
      if 0 < itemData.item_num then
        local itemTableData = TableData.listItemDatas:GetDataById(itemData.item_id)
        local timeLimit = itemTableData.time_limit
        if timeLimit == 0 or timeLimit ~= 0 and timeLimit > CGameTime:GetTimestamp() then
          do
            local item
            if i + 1 > #self.itemList then
              item = UICommonItem.New()
              item:InitCtrl(self.mTrans_ItemList)
              table.insert(self.itemList, item)
            else
              item = self.itemList[i + 1]
            end
            local custOnclick
            if itemTableData.type == GlobalConfig.ItemType.GiftPick then
              function custOnclick()
                UIManager.OpenUIByParam(UIDef.UIRepositoryBoxDialog, itemTableData)
              end
            end
            if item.itemId ~= itemData.item_id or item.itemNum ~= itemData.item_num then
              item:SetItemData(itemData.item_id, itemData.item_num, false, t, itemData.item_num, nil, nil, custOnclick, nil, true)
              item:LimitNumTop(itemData.item_num)
            else
              setactive(item:GetRoot(), true)
            end
          end
        end
      end
    end
  end
end
function UIRepositoryListItemV2:OnRelease()
  self.itemList = {}
end
