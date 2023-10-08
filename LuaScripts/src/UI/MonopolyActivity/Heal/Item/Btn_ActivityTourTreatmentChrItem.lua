require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.ActivityTourGlobal")
Btn_ActivityTourTreatmentChrItem = class("Btn_ActivityTourTreatmentChrItem", UIBaseCtrl)
Btn_ActivityTourTreatmentChrItem.__index = Btn_ActivityTourTreatmentChrItem
Btn_ActivityTourTreatmentChrItem.ui = nil
Btn_ActivityTourTreatmentChrItem.mData = nil
local WillType = {
  Empty = 0,
  Half = 1,
  Full = 2
}
function Btn_ActivityTourTreatmentChrItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function Btn_ActivityTourTreatmentChrItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self.uiType = nil
  self.bSelect = false
  self:LuaUIBindTable(obj, self.ui)
  self:InitSteady()
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnBtnSelect()
  end
  self.ui.mText_AddSteady.color = CS.GF2.UI.UITool.StringToColor("5BDC83")
end
function Btn_ActivityTourTreatmentChrItem:InitSteady()
  self.mWillIcon = {}
  self.mWillIcon[WillType.Full] = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_2")
  self.mWillIcon[WillType.Half] = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_1")
  self.mWillIcon[WillType.Empty] = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_0")
end
function Btn_ActivityTourTreatmentChrItem:SetData(index, uiType, selCallBack, gunInfo, healNum)
  self.uiType = uiType
  self.selCallBack = selCallBack
  self.index = index
  self.bSelect = false
  self.gunInfo = gunInfo
  self.healNum = healNum
  local data = NetCmdTeamData:GetGunByID(self.gunInfo.Id)
  self.ui.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(data.gunData.rank)
  self.ui.mImg_HeadIcon.sprite = IconUtils.GetCharacterHeadSprite(data.gunData.Code)
  self.ui.mText_Name.text = data.gunData.name.str
  local level = data.level
  self.ui.mText_Level.text = level
  if not self.dutyItem then
    self.dutyItem = UICommonDutyItem.New()
    self.dutyItem:InitCtrl(self.ui.mScrollListChild_Duty)
  end
  local dutyData = TableData.listGunDutyDatas:GetDataById(data.gunData.duty)
  self.dutyItem:SetData(dutyData)
  self.ui.mText_Steady.text = TableData.GetHintById(270239)
  self:ShowWillValue(self.gunInfo.Ip.WillValue, self.gunInfo.Id)
  self.ui.mText_Hp.text = TableData.GetHintById(270240)
  setactive(self.ui.mImg_AddHpProgress.gameObject, false)
  self:RefreshContent()
end
function Btn_ActivityTourTreatmentChrItem:ShowWillValue(cur, id)
  local maxWill = ActivityTourGlobal.GetMaxWillValue(id)
  local curWillType = WillType.Half
  if cur == 0 then
    curWillType = WillType.Empty
  elseif cur == maxWill then
    curWillType = WillType.Full
  end
  self.ui.mImg_Steady.sprite = self.mWillIcon[curWillType]
  self.ui.mText_SteadyNum.text = tostring(self.gunInfo.Ip.WillValue)
end
function Btn_ActivityTourTreatmentChrItem:RefreshContent()
  self.ui.mImg_HpProgress.fillAmount = self.gunInfo.HpPercent / ActivityTourGlobal.MaxHp
  if self.uiType == ActivityTourGlobal.TreatmentSelectDialog_UIType.Heal then
    setactive(self.ui.mImg_AddHpProgress.gameObject, self.bSelect)
    self:PlayProgressAnimation()
  else
    setactive(self.ui.mText_AddSteady.gameObject, self.bSelect)
    self.ui.mText_AddSteady.text = "+" .. self.healNum
  end
end
function Btn_ActivityTourTreatmentChrItem:PlayProgressAnimation()
  if not self.bSelect then
    return
  end
  local totalValue = self.uiType == ActivityTourGlobal.TreatmentSelectDialog_UIType.Heal and ActivityTourGlobal.MaxHp or ActivityTourGlobal.GetMaxWillValue(self.gunInfo.Id)
  local curValue = self.uiType == ActivityTourGlobal.TreatmentSelectDialog_UIType.Heal and self.gunInfo.HpPercent or self.gunInfo.Ip.WillValue
  local addValue = self.uiType == ActivityTourGlobal.TreatmentSelectDialog_UIType.Heal and ActivityTourGlobal.MonopolyDefine.GetHealHpValue(self.healNum) or self.healNum
  local newValue = curValue + addValue
  curValue = math.min(curValue, totalValue)
  newValue = math.min(newValue, totalValue)
  self.ui.mImg_HpProgress.fillAmount = curValue / totalValue
  self.ui.mImg_AddHpProgress.fillAmount = newValue / totalValue
  if self.tween then
    LuaDOTweenUtils.Kill(self.tween, false)
  end
  local getter = function(tempSelf)
    return tempSelf.ui.mImg_AddHpProgress.fillAmount
  end
  local setter = function(tempSelf, value)
    tempSelf.ui.mImg_AddHpProgress.fillAmount = value
  end
  local percent = newValue / totalValue
  self.listTween = LuaDOTweenUtils.ToOfFloat(self, getter, setter, percent, 0.5, nil)
end
function Btn_ActivityTourTreatmentChrItem:OnBtnSelect()
  if self.selCallBack then
    self.selCallBack(self.gunInfo.Id)
  end
end
function Btn_ActivityTourTreatmentChrItem:SetSelect(gunId)
  local bSelect = gunId == self.gunInfo.Id
  if bSelect then
    self.bSelect = not self.bSelect
  end
  setactive(self.ui.mTrans_Sel.gameObject, self.bSelect)
  setactive(self.ui.mTrans_UnSel.gameObject, not self.bSelect)
  self.ui.mAni_Root:SetBool("Selected", self.bSelect)
  if bSelect then
    self:RefreshContent()
  end
end
function Btn_ActivityTourTreatmentChrItem:OnRelease()
  if self.tween then
    LuaDOTweenUtils.Kill(self.tween, false)
  end
  self.tween = nil
  self.super.OnRelease(self, true)
end
