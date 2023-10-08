require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneTaskPanelInGame.item.DarkZoneMapQuestTabItem")
DarkZoneMapRoomTabItem = class("DarkZoneMapRoomTabItem", UIBaseCtrl)
DarkZoneMapRoomTabItem.__index = DarkZoneMapRoomTabItem
function DarkZoneMapRoomTabItem:__InitCtrl()
end
function DarkZoneMapRoomTabItem:InitCtrl(obj)
  if obj == nil then
    return
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.isSelect = false
  self.isOpen = false
  self.clickFunc = nil
  self.itemList = {}
end
function DarkZoneMapRoomTabItem:SetData(num)
  local mapList = DarkNetCmdStoreData:GetRoomQuestListByAreaID(num)
  local str
  local listCount = mapList.Count
  self:SetActive(0 < listCount)
  if 0 < listCount then
    for i = 0, listCount - 1 do
      local id = mapList[i]
      local index = i + 1
      if not self.itemList[index] then
        self.itemList[index] = DarkZoneMapQuestTabItem.New()
        self.itemList[index]:InitCtrl(self.ui.mTrans_Target)
      end
      local item = self.itemList[index]
      item:SetRoomData(id, 0)
      if item.isFinish == false and self.showItem == nil then
        self.showItem = item
        local d = TableData.listDarkzoneRoomNoticeDatas:GetDataById(id)
        str = CS.LuaUIUtils.RemoveRichTextSize(d.text.str)
      end
      item:SetLineActive(listCount > index)
    end
    if self.showItem == nil then
      local item = self.itemList[1]
      local d = TableData.listDarkzoneRoomNoticeDatas:GetDataById(item.mQuestID)
      str = CS.LuaUIUtils.RemoveRichTextSize(d.text.str)
    end
    self.ui.mText_Describe.text = str
  end
end
function DarkZoneMapRoomTabItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.isOpen = nil
  self.isSelect = nil
  self.clickFunc = nil
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
  self.isFinish = nil
  self.panel = nil
  self.selectTargetItem = nil
  self.showItem = nil
  self.super.OnRelease(self)
end
