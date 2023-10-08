require("UI.UIBaseCtrl")
DarkZoneTeamItemV2 = class("DarkZoneTeamItemV2", UIBaseCtrl)
DarkZoneTeamItemV2.__index = DarkZoneTeamItemV2
function DarkZoneTeamItemV2:__InitCtrl()
end
function DarkZoneTeamItemV2:InitCtrl(root)
  local com = ResSys:GetUIGizmos("UICommonFramework/ComChrInfoItemV2.prefab", false)
  local obj = instantiate(com)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self.defaultAnim = CS.LuaUIUtils.GetAnimationStateByAnimation(self.ui.mAnimation_ImgLine, self.ui.mAnimation_ImgLine.clip.name)
  self.animLength = self.defaultAnim.length
  self:SetRoot(obj.transform)
  self.clickFunction = nil
  setactive(self.ui.mTrans_DarkzoneFleetTip, true)
  setactive(self.ui.mTrans_EffectTip, false)
end
function DarkZoneTeamItemV2:SetTable(panel)
  self.teamPanel = panel
end
function DarkZoneTeamItemV2:SetData(Data, index)
  self.mData = Data
  self.mIndex = index
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickGunCard()
  end
  setactive(self.ui.mTrans_GrpIcon, false)
  setactive(self.ui.mTrans_GrpChoose, false)
  local avatarCode = self.mData.clothCode
  self.ui.mImg_Icon.sprite = IconUtils.GetCharacterBustSprite(IconUtils.cCharacterAvatarType_Avatar, avatarCode)
  self.ui.mText_Level.text = tostring(Data.Level)
  self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(Data.TabGunData.rank)
  local sign = self.teamPanel:CheckInTeam(Data.id)
  self.isInTeam = sign ~= nil
  if sign ~= nil then
    setactive(self.ui.mTrans_GrpIcon, true)
    self.ui.mText_Num.text = sign
    if sign == 1 then
      setactive(self.ui.mTrans_IconMember, false)
      setactive(self.ui.mTrans_IconCaptain, true)
    else
      setactive(self.ui.mTrans_IconMember, true)
      setactive(self.ui.mTrans_IconCaptain, false)
    end
  else
    setactive(self.ui.mTrans_GrpIcon, false)
  end
  setactive(self.ui.mTrans_GrpSelBlack, false)
  setactive(self.ui.mTrans_GrpChoose, false)
end
function DarkZoneTeamItemV2:OnClickGunCard()
  if self.clickFunction then
    self.clickFunction()
  end
end
function DarkZoneTeamItemV2:SetIsSelect(gunID)
  local isSelect = gunID == self.mData.id
  setactive(self.ui.mTrans_GrpChoose, isSelect == true)
end
function DarkZoneTeamItemV2:SetIsSelectTeamGun(gunID)
  local isSelect = gunID == self.mData.id
  setactive(self.ui.mTrans_GrpSelBlack, isSelect)
end
function DarkZoneTeamItemV2:SetClickFunction(func)
  self.clickFunction = func
end
