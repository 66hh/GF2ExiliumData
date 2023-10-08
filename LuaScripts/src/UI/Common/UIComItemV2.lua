UIComItemV2 = class("UIComItemV2", UIBaseCtrl)
function UIComItemV2:ctor(transParent, itemTemplate)
  local comItemV2
  if itemTemplate then
    comItemV2 = instantiate(itemTemplate, transParent)
  else
    comItemV2 = self:Instantiate("UICommonFramework/ComItemV2.prefab", transParent)
  end
  self:SetRoot(comItemV2.transform)
  self.ui = UIUtils.GetUIBindTable(comItemV2)
  self.ui.mBtn_Select.onClick:AddListener(function()
    self:onClick()
  end)
  self.enableTips = true
end
function UIComItemV2:SetDataByKvPair(kvPair, clickCallback)
  self:SetData(kvPair.Key, kvPair.Value, clickCallback)
end
function UIComItemV2:SetData(itemId, num, clickCallback)
  self.itemId = itemId
  self.clickCallback = clickCallback
  if 1 < num then
    self.ui.mText_Num.text = num
  else
    setactive(self.ui.mTrans_Num, false)
  end
  self:Refresh()
end
function UIComItemV2:Init(itemId, cost, clickCallback)
  self.itemId = itemId
  self.clickCallback = clickCallback
  local hasCount = NetCmdItemData:GetNetItemCount(self.itemId)
  if cost > hasCount then
    self.ui.mText_Num.text = "<color=#FF5E41>" .. hasCount .. "</color>" .. "/" .. cost
  else
    self.ui.mText_Num.text = hasCount .. "/" .. cost
  end
  self:Refresh()
end
function UIComItemV2:Refresh()
  local data = TableDataBase.listItemDatas:GetDataById(self.itemId)
  if data then
    self.ui.mImage_Bg.sprite = IconUtils.GetQuiltyByRank(data.rank)
    self.ui.mImage_Icon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. data.icon)
  else
    gferror(self.itemId .. ": 道具表未找到对应数据!")
  end
end
function UIComItemV2:SetNumVisible(visible)
  setactive(self.ui.mText_Num, visible)
end
function UIComItemV2:OnRelease()
  self.clickCallback = nil
  self.ui = nil
  self.enableTips = nil
  self.itemId = nil
  self.super.OnRelease(self)
end
function UIComItemV2:EnableTips(enable)
  self.enableTips = enable
end
function UIComItemV2:onClick()
  if self.enableTips then
    local itemData = TableData.GetItemData(self.itemId)
    UITipsPanel.Open(itemData)
  end
  if self.clickCallback then
    self.clickCallback(self.itemId)
  end
end
