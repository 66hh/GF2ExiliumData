require("UI.UIBaseCtrl")
DarkzoneReliabilityDetailLeftTabItem = class("DarkzoneReliabilityDetailLeftTabItem", UIBaseCtrl)
DarkzoneReliabilityDetailLeftTabItem.__index = DarkzoneReliabilityDetailLeftTabItem
function DarkzoneReliabilityDetailLeftTabItem:__InitCtrl()
end
function DarkzoneReliabilityDetailLeftTabItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Darkzone/DarkzoneReliabilityDetailLeftTabItem.prefab", self))
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function DarkzoneReliabilityDetailLeftTabItem:SetTable(panelData)
  self.panelData = panelData
end
function DarkzoneReliabilityDetailLeftTabItem:SetData(Data)
  setactive(self.ui.mTrans_RedPoint, false)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if self.panelData.LastLeftTabItem ~= nil then
      self.panelData.LastLeftTabItem.interactable = true
    end
    self.ui.mBtn_Self.interactable = false
    self.panelData.LastLeftTabItem = self.ui.mBtn_Self
    self.panelData.ChooseNpcFavorLevel = self.FavorLevel
    self.panelData.ChooseNpc = Data.id
    self.panelData:UpdateData()
  end
  self.ui.mImg_Avatar.sprite = ResSys:GetAtlasSprite("DarkzoneAvatarPic/" .. Data.npc_head_img)
  self.ui.mText_ChrName.text = Data.name.str
  local unlock = DZStoreUtils.NpcStateDic[Data.id]
  setactive(self.ui.mTrans_Lock, not unlock)
  if unlock then
    self.ui.mAnim_Self:SetBool("Unlock", true)
    local NpcNetData = DarkNetCmdStoreData:GetNpcDataById(Data.id)
    if NpcNetData == nil then
      local FavorLevel, FavorExp, NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(Data.id, 0)
      self.ui.mText_Level.text = string_format(TableData.GetHintById(80057), FavorLevel)
      self.ui.mText_ExpNum.text = FavorExp .. "/" .. NextFavor
      self.ui.mSlider_AddLevel.FillAmount = FavorExp / NextFavor
      self.FavorLevel = FavorLevel
    else
      local FavorLevel, FavorExp, NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(Data.id, NpcNetData.Favor)
      self.ui.mText_Level.text = string_format(TableData.GetHintById(80057), FavorLevel)
      self.ui.mText_ExpNum.text = FavorExp .. "/" .. NextFavor
      self.ui.mSlider_AddLevel.FillAmount = FavorExp / NextFavor
      self.FavorLevel = FavorLevel
    end
  else
    self.ui.mAnim_Self:SetBool("Unlock", false)
    local NpcNetData = DarkNetCmdStoreData:GetNpcDataById(Data.id)
    local FavorLevel, FavorExp, NextFavor = 0
    if NpcNetData == nil then
      FavorLevel, FavorExp, NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(Data.id, 0)
    else
      FavorLevel, FavorExp, NextFavor = DZStoreUtils:GetCurFavorLevelAndExp(Data.id, NpcNetData.Favor)
    end
    self.ui.mText_Level.text = string_format(TableData.GetHintById(80057), FavorLevel - 1)
    self.ui.mText_ExpNum.text = FavorExp .. "/" .. NextFavor
    self.ui.mSlider_AddLevel.FillAmount = FavorExp / NextFavor
    self.FavorLevel = FavorLevel - 1
  end
end
