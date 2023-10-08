require("UI.UIBasePanel")
require("UI.Common.UICommonDutyItem")
require("UI.Common.UICommonArrowBtnItem")
ArchivesCenterChrPanelV2 = class("ArchivesCenterChrPanelV2", UIBasePanel)
ArchivesCenterChrPanelV2.__index = ArchivesCenterChrPanelV2
function ArchivesCenterChrPanelV2:ctor(root)
  self.super.ctor(self, root)
  root.Type = UIBasePanelType.Panel
end
function ArchivesCenterChrPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterChrPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnDorm.gameObject).onClick = function()
    if not NetCmdTeamData:IsDormSystemUnlock() then
      local unlockData = TableData.listUnlockDatas:GetDataById(15100)
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      PopupMessageManager.PopupString(str)
      return
    end
    local gun = NetCmdTeamData:GetGunByID(self.data.unit_id[0])
    if gun == nil then
      gun = NetCmdTeamData:GetLockGunByStcId(self.data.unit_id[0])
    end
    if gun == nil then
      return
    end
    if gun.isDormLockGun then
      local unlockDesc = ""
      for i = 0, gun.UnlockDorm.Count - 1 do
        local id = gun.UnlockDorm[i]
        local achieve = TableData.listAchievementDetailDatas:GetDataById(id)
        if achieve ~= nil then
          unlockDesc = unlockDesc .. achieve.des.str
        end
      end
      PopupMessageManager.PopupString(unlockDesc)
    else
      NetCmdLoungeData:SetGunId(self.data.unit_id[0])
      NetCmdLoungeData:SetEnterSceneType(EnumSceneType.CommandCenter)
      SceneSys:OpenLoungeScene(function()
        UIManager.OpenUI(UIDef.DormMainPanel)
      end)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Plot.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ArchivesCenterChrPlotPanelV2, {
      currData = self.data
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Clothes.gameObject).onClick = function()
    local list = new_array(typeof(CS.System.Int32), 2)
    list[0] = self.data.unit_id[0]
    list[1] = FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
    FacilityBarrackGlobal.CurSkinShowContentType = FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
    local jumpParam = CS.BarrackPresetJumpParam(1, self.data.unit_id[0], list)
    JumpSystem:Jump(EnumSceneType.Barrack, jumpParam)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Animation.gameObject).onClick = function()
    if self.data.gacha_get_timeline ~= "" then
      local gunData = TableData.listGunDatas:GetDataById(self.data.unit_id[0])
      CS.CriWareVideoController.StartPlay(gunData.gacha_get_timeline .. ".usm", CS.CriWareVideoType.eVideoPath, function()
        CS.CriWareAudioController.PauseBGM(false)
        if self.ossGunPlotInfo == nil then
          self.ossGunPlotInfo = CS.OssGunPlotInfo()
        end
        local gunType = self.data.type.value__
        local gunId = 0
        if 0 < self.data.unit_id.Count then
          gunId = self.data.unit_id[0]
        else
          gferror("[Oss] GunId is null!!!")
        end
        local plotType = 2
        local characterId = self.data.id
        local isSkip = false
        self.ossGunPlotInfo:SetInfo(gunType, gunId, plotType, characterId, isSkip)
        MessageSys:SendMessage(OssEvent.GunPlotLog, nil, self.ossGunPlotInfo)
        CS.CriWareVideoController.PlayFadeOut()
      end, true, 1, false, -1, 0, {
        gunData.gacha_get_audio,
        gunData.gacha_get_voice
      })
      CS.CriWareAudioController.PauseBGM(true)
    end
  end
  self.grayColor = Color(0.396078431372549, 0.4745098039215686, 0.5098039215686274, 0.9725490196078431)
  self.whiteColor = Color(1, 1, 1, 1)
end
function ArchivesCenterChrPanelV2:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self.ui.mAnimator_Root:SetBool("Previous", true)
    self:OnClickArrow(-1)
    self:RefreshBtnState()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self.ui.mAnimator_Root:SetBool("Next", true)
    self:OnClickArrow(1)
    self:RefreshBtnState()
  end
  self.arrowBtn:SetLeftArrowActiveFunction(function()
    return self.currIndex > 0
  end)
  self.arrowBtn:SetRightArrowActiveFunction(function()
    return self.currIndex < self.maxIndex - 1
  end)
end
function ArchivesCenterChrPanelV2:RefreshBtnState()
  setactive(self.ui.mBtn_PreGun.gameObject, self.currIndex > 0)
  setactive(self.ui.mBtn_NextGun.gameObject, self.currIndex < self.maxIndex - 1)
end
function ArchivesCenterChrPanelV2:OnClickArrow(changeNum)
  self.currIndex = self.currIndex + changeNum
  if self.currIndex < 0 then
    self.currIndex = 0
  end
  if self.currIndex > self.maxIndex - 1 then
    self.currIndex = self.maxIndex - 1
  end
  self.data = self.characterList[self.currIndex]
  self:UpdateInfo()
end
function ArchivesCenterChrPanelV2:OnInit(root, data)
  setactive(self.ui.mTrans_BGVideo.gameObject, false)
  self.data = data.currData
  self.currIndex = data.currIndex
  setactive(self.ui.mBtn_Animation.gameObject, data.currData.gacha_get_timeline ~= "")
  self.characterList = NetCmdArchivesData:GetCharacterList()
  self.maxIndex = self.characterList.Count
  self.arrowBtn = UICommonArrowBtnItem.New()
  self.arrowBtn:InitObj(self.ui.mObj_ViewSwitch)
  self:UpdateInfo()
  self:AddBtnListener()
  self.arrowBtn:RefreshArrowActive()
  setactivewithcheck(self.ui.mBtn_BtnDorm, NetCmdTeamData:GetGunByID(self.data.unit_id[0]) ~= nil)
end
function ArchivesCenterChrPanelV2:UpdateInfo()
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterWholeSprite("Avatar", self.data.uien_name)
  self.ui.mText_Name.text = self.data.name.str
  if self.data.unit_id.Count > 0 then
    if NetCmdArchivesData:GetTypeIndex(self.data.type) == 1 then
      setactive(self.ui.mTrans_IconMeiling.gameObject, false)
      if self.dutyItem == nil then
        self.dutyItem = UICommonDutyItem.New()
        self.dutyItem:InitCtrl(self.ui.mTrans_Duty)
      end
      local gunData = TableData.listGunDatas:GetDataById(self.data.unit_id[0])
      if gunData then
        local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
        self.dutyItem:UpdateIconState(true)
        self.dutyItem:SetData(dutyData)
        self.ui.mText_Type.text = dutyData.name.str
      end
    else
      if self.dutyItem then
        self.dutyItem:UpdateIconState(false)
      end
      setactive(self.ui.mTrans_IconMeiling.gameObject, true)
      self.ui.mText_Type.text = ""
    end
  else
    setactive(self.ui.mTrans_IconMeiling.gameObject, false)
    self.ui.mText_Type.text = ""
  end
  self.ui.mText_JPName.text = self.data.cv_jp.str
  self.ui.mText_CNName.text = self.data.cv_cn.str
  self.ui.mText_Num.text = self.data.body_id.str
  self.ui.mText_Model.text = self.data.brand.str
  self.ui.mText_City.text = self.data.belong.str
  setactive(self.ui.mTrans_Type.gameObject, self.data.body_id.str ~= "")
  setactive(self.ui.mTrans_ID.gameObject, self.data.brand.str ~= "")
  setactive(self.ui.mTrans_Root.gameObject, self.data.belong.str ~= "")
  setactive(self.ui.mTrans_Info.gameObject, self.data.body_id.str ~= "" or self.data.brand.str ~= "" or self.data.belong.str ~= "")
  local characterLock = false
  if self.data.unit_id.Count > 0 then
    setactive(self.ui.mTrans_PlotRedPoint.gameObject, self.data.story_open and NetCmdArchivesData:CharacterPlotIsRead(self.data.unit_id[0], self.data.type))
    if self.data.type == CS.GF2.Data.RoleType.Gun then
      characterLock = NetCmdArchivesData:CharacterIsLock(self.data.unit_id[0])
      if characterLock then
        self.ui.mImg_Avatar.color = self.grayColor
        setactive(self.ui.mTrans_None.gameObject, true)
      else
        self.ui.mImg_Avatar.color = self.whiteColor
        setactive(self.ui.mTrans_None.gameObject, false)
      end
    else
      self.ui.mImg_Avatar.color = self.whiteColor
      setactive(self.ui.mTrans_None.gameObject, false)
    end
  else
    setactive(self.ui.mTrans_PlotRedPoint.gameObject, false)
  end
  setactive(self.ui.mBtn_Plot.gameObject, self.data.story_open and not characterLock)
  setactive(self.ui.mBtn_Clothes.gameObject, self.data.skin_open and not characterLock)
  setactive(self.ui.mBtn_Animation.gameObject, self.data.show_open and not characterLock)
  setactive(self.ui.mTrans_ClothsRedPoint.gameObject, false)
  setactive(self.ui.mTrans_AnimRedPoint.gameObject, false)
  setactive(self.ui.mTrans_DormRedPoint.gameObject, false)
  self.ui.mTextFit_Details.text = self.data.char_info.str
  setactivewithcheck(self.ui.mBtn_BtnDorm, NetCmdTeamData:GetGunByID(self.data.unit_id[0]) ~= nil)
  self.ui.mAnimator_Dorm:SetBool("Unlock", NetCmdTeamData:IsDormSystemUnlock() and NetCmdTeamData:GetGunDormUnlockByUnlockedID(self.data.unit_id[0]) ~= nil)
end
function ArchivesCenterChrPanelV2:OnShowStart()
end
function ArchivesCenterChrPanelV2:OnShowFinish()
  local gunid = self.data.unit_id[0]
  self.ui.mAnimator_Dorm:SetBool("Unlock", NetCmdTeamData:IsDormSystemUnlock() and NetCmdTeamData:GetGunDormUnlockByUnlockedID(gunid) ~= nil)
end
function ArchivesCenterChrPanelV2:OnBackFrom()
  self:UpdateInfo()
end
function ArchivesCenterChrPanelV2:OnClose()
end
function ArchivesCenterChrPanelV2:OnHide()
end
function ArchivesCenterChrPanelV2:OnHideFinish()
end
function ArchivesCenterChrPanelV2:OnRelease()
end
