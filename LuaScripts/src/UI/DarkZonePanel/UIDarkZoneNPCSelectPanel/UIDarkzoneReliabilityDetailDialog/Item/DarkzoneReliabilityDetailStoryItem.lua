require("UI.UIBaseCtrl")
DarkzoneReliabilityDetailStoryItem = class("DarkzoneReliabilityDetailStoryItem", UIBaseCtrl)
DarkzoneReliabilityDetailStoryItem.__index = DarkzoneReliabilityDetailStoryItem
function DarkzoneReliabilityDetailStoryItem:__InitCtrl()
end
function DarkzoneReliabilityDetailStoryItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/DarkzoneReliabilityDetailStoryItem.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkzoneReliabilityDetailStoryItem:SetData(Data, ChooseNpcFavorLevel)
  if ChooseNpcFavorLevel < Data.favor_level then
    self.ui.mAnim_Self:SetBool("Unlock", false)
    local str = ""
    if Data.need_favor_point > 0 then
      str = string_format(TableData.GetHintById(903258), Data.need_favor_point)
    else
      str = TableData.GetHintById(903349)
    end
    self.ui.mText_Description.text = str
  else
    self.ui.mAnim_Self:SetBool("Unlock", true)
    self.ui.mText_Content.text = Data.npc_story.str
  end
end
