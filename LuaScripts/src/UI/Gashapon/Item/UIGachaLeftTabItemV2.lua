require("UI.UIBaseCtrl")
UIGachaLeftTabItemV2 = class("UIGachaLeftTabItemV2", UIBaseCtrl)
UIGachaLeftTabItemV2.__index = UIGachaLeftTabItemV2
UIGachaLeftTabItemV2.mImg_Icon = nil
UIGachaLeftTabItemV2.mText_Name = nil
function UIGachaLeftTabItemV2:__InitCtrl()
  self.mImg_Icon = self:GetImage("GrpIcon/Img_Icon")
  self.mText_Name = self:GetText("GrpText/Text_Name")
  self.mTrans_Redpoint = self:GetRectTransform("Trans_RedPoint")
  self.mSoundController = self:GetRoot():GetComponent(typeof(CS.ButtonSoundController))
  self.mBtn_GachaEventBtn = self:GetSelfButton()
end
function UIGachaLeftTabItemV2:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Gashapon/GashaponMainLeftTabItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIGachaLeftTabItemV2:SetData(data)
  self.globalTab = GetOrAddComponent(self:GetRoot().gameObject, typeof(GlobalTab))
  self.globalTab:SetGlobalTabId(data.StcData.GlobalTab)
  self.mEventData = data
  self.mText_Name.text = data.Name
  self:UpdateRedPoint()
end
function UIGachaLeftTabItemV2:GetGlobalTab()
  return self.globalTab
end
function UIGachaLeftTabItemV2:UpdateRedPoint()
  setactive(self.mTrans_Redpoint, self.mEventData.StcData.Type == 3 and not GashaponNetCmdHandler:CheckPoolPreviewed(self.mEventData.GachaID))
end
function UIGachaLeftTabItemV2:SetSelect(isSelect)
  self.mBtn_GachaEventBtn.interactable = not isSelect
end
