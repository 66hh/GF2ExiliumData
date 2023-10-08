require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneTaskPanelInGame.item.DarkZoneMapQuestTabItem")
DarkZoneMapQuestTargetItem = class("DarkZoneMapQuestTargetItem", UIBaseCtrl)
DarkZoneMapQuestTargetItem.__index = DarkZoneMapQuestTargetItem
function DarkZoneMapQuestTargetItem:__InitCtrl()
end
function DarkZoneMapQuestTargetItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self.subTargetList = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  self.ui.mAnimator_Root.keepAnimatorControllerStateOnDisable = true
  self.clickFunc = nil
end
function DarkZoneMapQuestTargetItem:SetData(data, num)
  self:SetActive(true)
  self.mData = TableData.listDarkzoneQuestTargetGroupDatas:GetDataById(num)
  local str
  str = CS.LuaUIUtils.RemoveRichTextSize(self.mData.target_group_desc.str)
  self.ui.mText_Describe.text = str
  local finishNum = 0
  local listCount = self.mData.target_list.Count
  for i = 0, listCount - 1 do
    local id = self.mData.target_list[i]
    local index = i + 1
    if self.subTargetList[index] == nil then
      self.subTargetList[index] = DarkZoneMapQuestTabItem.New()
      self.subTargetList[index]:InitCtrl(self.ui.mTrans_Target)
    end
    self.subTargetList[index]:SetData(id, self.mData.target_group_id)
    if self.subTargetList[index].isFinish == true then
      finishNum = finishNum + 1
    end
    self.subTargetList[index]:SetLineActive(listCount > index)
  end
end
function DarkZoneMapQuestTargetItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self:ReleaseCtrlTable(self.subTargetList, true)
  self.subTargetList = nil
  self.super.OnRelease(self, true)
end
function DarkZoneMapQuestTargetItem:SetIsFinalQuest(isFinal)
  self.ui.mAnimator_Root:SetBool("Bool", isFinal == false)
  for i, v in ipairs(self.subTargetList) do
    v:SetActive(isFinal == false)
  end
end
function DarkZoneMapQuestTargetItem:RemoveSelect()
end
