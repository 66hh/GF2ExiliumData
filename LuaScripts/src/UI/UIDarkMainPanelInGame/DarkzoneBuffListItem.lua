require("UI.UIBaseCtrl")
DarkzoneBuffListItem = class("DarkzoneBuffListItem", UIBaseCtrl)
DarkzoneBuffListItem.__index = DarkzoneBuffListItem
function DarkzoneBuffListItem:InitCtrl(prefab, parent)
  self.obj = instantiate(prefab, parent)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  setactive(self.obj, false)
  self.ui.mAni_Root.keepAnimatorControllerStateOnDisable = true
end
function DarkzoneBuffListItem:SetData(Data)
  setactive(self.obj, true)
  local image = IconUtils.GetDarkzoneBuffIcon(Data.DzBuffData.icon)
  self.ui.mImg_Icon.sprite = image
  self.ui.mText_Name.text = Data.DzBuffData.name.str
  self.ui.mText_Detail.text = Data.DzBuffData.description.str .. "(" .. Data:GetReason() .. ")"
  local switch, slgId = Data:TryGetSwitchSLGId()
  if switch then
    self.ui.mAni_Root:SetBool("Bool", true)
    local slgBuffData = TableData.listBattleBuffPerformDatas:GetDataById(slgId)
    self.ui.mText_ChangeDetail.text = string_format(TableData.GetHintById(903493), slgBuffData.description.str)
  else
    self.ui.mAni_Root:SetBool("Bool", false)
  end
  if Data.Forever then
    self.ui.mText_Countdown.text = TableData.GetHintById(903470)
  else
    self.ui.mText_Countdown.text = Data:GetTimeStr()
  end
  self.ui.mText_Count.text = Data.BuffCount
end
function DarkzoneBuffListItem:SetNull(Data)
  setactive(self.obj, false)
end
function DarkzoneBuffListItem:OnClose()
  self.ui = nil
  if not CS.LuaUtils.IsNullOrDestroyed(self.obj) then
    gfdestroy(self.obj)
  end
  self.obj = nil
end
