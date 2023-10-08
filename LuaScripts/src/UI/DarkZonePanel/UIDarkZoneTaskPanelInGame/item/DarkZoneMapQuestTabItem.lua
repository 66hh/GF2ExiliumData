require("UI.UIBaseCtrl")
DarkZoneMapQuestTabItem = class("DarkZoneMapQuestTabItem", UIBaseCtrl)
DarkZoneMapQuestTabItem.__index = DarkZoneMapQuestTabItem
function DarkZoneMapQuestTabItem:__InitCtrl()
end
function DarkZoneMapQuestTabItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.ui.mAnimator_Root.keepAnimatorControllerStateOnDisable = true
end
function DarkZoneMapQuestTabItem:SetData(num, groupID)
  self.mQuestID = num
  self.searchType = 1
  self.groupID = groupID
  local data = TableData.listDarkzoneQuestContentDatas:GetDataById(num)
  for i, v in pairs(data.target_args) do
    self.mQuestNeedNum = v
    break
  end
  self:SetActive(true)
  self.mData = data
  self.ui.mText_Target.text = self.mData.target_name.str
  self:SetServerData(num)
end
function DarkZoneMapQuestTabItem:SetRoomData(num, groupID)
  self.mQuestID = num
  self.searchType = 2
  self.groupID = groupID
  local data = TableData.listDarkzoneRoomNoticeDatas:GetDataById(num)
  for i, v in pairs(data.target_param) do
    self.mQuestNeedNum = v
    break
  end
  self:SetActive(true)
  self.mData = data
  self.ui.mText_Target.text = data.text.str
  self:SetServerData(num)
end
function DarkZoneMapQuestTabItem:SetServerData(targetID)
  local curNum = 0
  local needNum = 1
  local countData = DarkNetCmdStoreData:GetCountByID(self.searchType, self.groupID, targetID)
  if countData and 0 < countData.Count then
    local d = countData[0]
    curNum = d.Num or 0
    needNum = d.NeedNum or self.mQuestNeedNum or 1
  end
  self.isFinish = curNum >= needNum
  if curNum > needNum then
    curNum = needNum
  end
  self.ui.mText_Progress.text = string_format(TableData.GetHintById(112016), curNum, needNum)
  if self.isFinish == true then
    local s = self.ui.mText_Target.text
    s = CS.LuaUIUtils.RemoveRichTextSize(s)
    self.ui.mText_Target.text = s
  end
  self.ui.mAnimator_Root:SetBool("Bool", self.isFinish)
end
function DarkZoneMapQuestTabItem:SetLineActive(isShow)
  setactive(self.ui.mTrans_ImgLine, isShow == true)
end
function DarkZoneMapQuestTabItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.isFinish = nil
  self.groupID = nil
  self.searchType = nil
  self.mQuestNeedNum = nil
  self.mQuestID = nil
  self.super.OnRelease(self, true)
end
