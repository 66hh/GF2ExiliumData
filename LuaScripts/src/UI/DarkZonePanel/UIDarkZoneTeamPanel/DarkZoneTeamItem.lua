require("UI.UIBaseCtrl")
DarkZoneTeamItem = class("DarkZoneTeamItem", UIBaseCtrl)
DarkZoneTeamItem.__index = DarkZoneTeamItem
function DarkZoneTeamItem:__InitCtrl()
end
function DarkZoneTeamItem:InitCtrl(root)
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
  setactive(self.ui.mTrans_DarkzoneFleetTip, true)
  setactive(self.ui.mTrans_EffectTip, false)
end
function DarkZoneTeamItem:SetTable(panel)
  self.teamPanel = panel
end
function DarkZoneTeamItem:SetData(Data, index)
  self.mData = Data
  self.mIndex = index
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickGunCard()
  end
  setactive(self.ui.mTrans_GrpIcon, false)
  setactive(self.ui.mTrans_GrpChoose, false)
  setactive(self.ui.mTrans_hpbar, true)
  self.ui.mImg_Icon.sprite = IconUtils.GetCharacterBustSprite(IconUtils.cCharacterAvatarType_Avatar, Data.config.code)
  self.ui.mText_Level.text = tostring(Data.level)
  self.ui.mImg_Rank.color = TableData.GetGlobalGun_Quality_Color2(Data.config.rank)
  self.ui.mText_Energy.text = tostring(Data.curenergy) .. "/" .. tostring(Data.maxenergy)
  self.ui.mImg_Progress.fillAmount = Data.curenergy / Data.maxenergy
  if Data.sign ~= nil and self.teamPanel.QuicklyTeam ~= true then
    setactive(self.ui.mTrans_GrpIcon, true)
    self.ui.mText_Num.text = Data.sign
    if Data.sign == 1 then
      setactive(self.ui.mTrans_IconMember, false)
      setactive(self.ui.mTrans_IconCaptain, true)
    else
      setactive(self.ui.mTrans_IconMember, true)
      setactive(self.ui.mTrans_IconCaptain, false)
    end
  else
    setactive(self.ui.mTrans_GrpIcon, false)
  end
  if self.teamPanel.TwiceInfo == true then
  end
  self.ui.mImg_Progress.color = ColorUtils.StringToColor("6BF1C6")
  if index == 2 then
    gfdebug(1)
  end
  setactive(self.ui.mTrans_GrpSelBlack, false)
  setactive(self.ui.mTrans_GrpChoose, false)
  if self.teamPanel.QuicklyTeam == true then
    setactive(self.ui.mTrans_GrpIcon, false)
    for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
      if DarkNetCmdTeamData.QuicklyTeamList[i] == Data.id then
        setactive(self.ui.mTrans_GrpIcon, true)
        self.defaultAnim.time = self.teamPanel.uiLoopTime % self.animLength
        setactive(self.ui.mTrans_GrpSelBlack, true)
        if i == 0 then
          setactive(self.ui.mTrans_IconMember, false)
          setactive(self.ui.mTrans_IconCaptain, true)
        else
          setactive(self.ui.mTrans_IconMember, true)
          setactive(self.ui.mTrans_IconCaptain, false)
        end
        self.ui.mText_Num.text = i + 1
        break
      end
    end
  else
    if Data.id == self.teamPanel.CurGunId then
      self.ui.mBtn_Self.interactable = false
    else
      self.ui.mBtn_Self.interactable = true
    end
    if self.teamPanel:CheckInTeam(Data.id) ~= nil then
      self.defaultAnim.time = self.teamPanel.uiLoopTime % self.animLength
      setactive(self.ui.mTrans_GrpSelBlack, true)
    else
      setactive(self.ui.mTrans_GrpSelBlack, false)
    end
  end
end
function DarkZoneTeamItem:OnClickGunCard()
  if self.teamPanel.QuicklyTeam == true then
    self:QuicklyTeamClick()
  else
    self:NormalClick()
  end
end
function DarkZoneTeamItem:QuicklyTeamClick()
  local Data = self.mData
  local Num = 0
  for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
    if DarkNetCmdTeamData.QuicklyTeamList[i] ~= 0 and DarkNetCmdTeamData.QuicklyTeamList:Contains(Data.id) == false then
      Num = Num + 1
    end
  end
  if Num == 4 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(903230))
    return
  end
  if self.teamPanel.QuicklyTeamItemData[self.mIndex] == nil then
    self.teamPanel.QuicklyTeamItemData[self.mIndex] = 1
  else
    self.teamPanel.QuicklyTeamItemData[self.mIndex] = self.teamPanel.QuicklyTeamItemData[self.mIndex] + 1
  end
  local count = self.teamPanel.QuicklyTeamItemData[self.mIndex]
  if count % 2 == 0 then
    for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
      if DarkNetCmdTeamData.QuicklyTeamList[i] == Data.id then
        DarkNetCmdTeamData.QuicklyTeamList[i] = 0
        self.teamPanel.QuicklyTeamClickGunID = 0
        setactive(self.ui.mTrans_GrpChoose, false)
        setactive(self.ui.mTrans_GrpIcon, false)
        break
      end
    end
  elseif count % 2 == 1 then
    if self.teamPanel:CheckGunIDHasInTeam(self.mData.id) then
      return UIUtils.PopupHintMessage(903136)
    end
    if count == 1 then
      if self.teamPanel:CheckInTeam(Data.id) ~= nil then
        for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
          if DarkNetCmdTeamData.QuicklyTeamList[i] == Data.id then
            DarkNetCmdTeamData.QuicklyTeamList[i] = 0
            self.teamPanel.QuicklyTeamClickGunID = 0
            setactive(self.ui.mTrans_GrpIcon, false)
            self.teamPanel.QuicklyTeamItemData[self.mIndex] = 2
            break
          end
        end
      else
        for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
          if DarkNetCmdTeamData.QuicklyTeamList[i] == 0 then
            DarkNetCmdTeamData.QuicklyTeamList[i] = Data.id
            self.teamPanel.QuicklyTeamClickGunID = Data.id
            setactive(self.ui.mTrans_GrpChoose, true)
            setactive(self.ui.mTrans_GrpIcon, true)
            if i == 0 then
              setactive(self.ui.mTrans_IconMember, false)
              setactive(self.ui.mTrans_IconCaptain, true)
            else
              setactive(self.ui.mTrans_IconMember, true)
              setactive(self.ui.mTrans_IconCaptain, false)
            end
            self.ui.mText_Num.text = i + 1
            break
          end
        end
      end
    else
      for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
        if DarkNetCmdTeamData.QuicklyTeamList[i] == 0 then
          DarkNetCmdTeamData.QuicklyTeamList[i] = Data.id
          self.teamPanel.QuicklyTeamClickGunID = Data.id
          setactive(self.ui.mTrans_GrpChoose, true)
          setactive(self.ui.mTrans_GrpIcon, true)
          if i == 0 then
            setactive(self.ui.mTrans_IconMember, false)
            setactive(self.ui.mTrans_IconCaptain, true)
          else
            setactive(self.ui.mTrans_IconMember, true)
            setactive(self.ui.mTrans_IconCaptain, false)
          end
          self.ui.mText_Num.text = i + 1
          break
        end
      end
    end
  end
  self.teamPanel.LastClickGunId = Data.id
  self.teamPanel.LastItem = self
  self.teamPanel.LastClickGunId = Data.id
  local SCount = 0
  for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
    if DarkNetCmdTeamData.QuicklyTeamList[i] == 0 then
      SCount = SCount + 1
    end
  end
  if SCount == 4 then
    self.teamPanel.ui.mBtn_Save.interactable = false
  else
    self.teamPanel.ui.mBtn_Save.interactable = true
  end
end
function DarkZoneTeamItem:NormalClick()
  if self.teamPanel:CheckGunIDHasInTeam(self.mData.id, true) then
    return UIUtils.PopupHintMessage(903136)
  end
  local Data = self.mData
  self.teamPanel.CurGunId = Data.id
  self.teamPanel.LookGunId = Data.id
  if Data.sign ~= self.teamPanel.CurBtn then
    if self.teamPanel.ui.mBtn_Replace.interactable == false then
      self.teamPanel.ui.mBtn_Replace.interactable = true
    end
  elseif Data.sign == self.teamPanel.CurBtn and self.teamPanel.ui.mBtn_Replace.interactable == true then
    self.teamPanel.ui.mBtn_Replace.interactable = false
  end
  if self.teamPanel:CheckInTeam(Data.id) ~= nil then
    setactive(self.teamPanel.ui.mTrans_ChrGrpIcon, true)
  else
    setactive(self.teamPanel.ui.mTrans_ChrGrpIcon, false)
  end
  self.teamPanel:UpdateModel(Data.id, self.teamPanel.CurBtn - 1, true)
  AudioUtils.PlayByID(1020094)
  setactive(self.teamPanel.ui.mText_GunName.gameObject, true)
  self.teamPanel.ui.mText_GunName.text = Data.config.Name.str
  self.teamPanel.CurFoucs = true
  setactive(self.teamPanel.ui.mTrans_NoGun, false)
  if self.teamPanel.LastGunBtn ~= nil then
    self.teamPanel.LastGunBtn.interactable = true
  end
  self.teamPanel.LastGunBtn = self.ui.mBtn_Self
  self.ui.mBtn_Self.interactable = false
  self.teamPanel.LastClickGunId = Data.id
  self.teamPanel.LastItem = self
end
