require("UI.UIBaseCtrl")
DarkzoneReliabilityDetailFuncItem = class("DarkzoneReliabilityDetailFuncItem", UIBaseCtrl)
DarkzoneReliabilityDetailFuncItem.__index = DarkzoneReliabilityDetailFuncItem
function DarkzoneReliabilityDetailFuncItem:__InitCtrl()
end
function DarkzoneReliabilityDetailFuncItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/DarkzoneReliabilityDetailFunctionItem.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkzoneReliabilityDetailFuncItem:SetData(Data, ChooseNpcFavorLevel)
  self.ui.mText_TrustNum.text = Data.need_favor_point
  self.ui.mText_Declare.text = TableData.GetHintById(903255)
  if ChooseNpcFavorLevel < Data.favor_level then
    self.ui.mAnim_Self:SetBool("unlock", false)
    if Data.favor_effect.str == "" then
      self.ui.mText_Content.text = TableData.GetHintById(903259)
    else
      self.ui.mText_Content.text = Data.favor_effect.str
    end
  else
    self.ui.mAnim_Self:SetBool("unlock", true)
    self.ui.mText_Num.text = DZStoreUtils:SetIndex(Data.favor_level)
    if Data.favor_effect.str == "" then
      self.ui.mText_Content.text = TableData.GetHintById(903259)
    else
      self.ui.mText_Content.text = Data.favor_effect.str
    end
  end
end
