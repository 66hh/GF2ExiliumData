require("UI.UIBaseCtrl")
GunFileItem = class("GunFileItem", UIBaseCtrl)
GunFileItem.__index = GunFileItem
function GunFileItem:__InitCtrl()
end
function GunFileItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function GunFileItem:SetData(Data)
  setactive(self.ui.mTrans_Text, false)
  setactive(self.ui.mTrans_FosterLevel, false)
  self.ui.mImg_Bg.sprite = ResSys:GetAtlasSprite("ArchivesCenter/" .. Data.RdrBg)
  self.ui.mImg_Chr.sprite = ResSys:GetAtlasSprite("ArchivesCenter/" .. Data.RdrImg)
  local str = "Icon_Character_{0}_W"
  self.ui.mImg_Icon.sprite = ResSys:GetAtlasSprite("Icon/CharacterIcon/" .. string_format(str, Data.EnName))
  self.ui.mText_Id.text = Data.BodyId.str
  self.ui.mText_Name.text = Data.Name.str
  local IsGunUnlock = false
  local gunId = 0
  IsGunUnlock, gunId = ArchivesUtils:JudgeGunUnLock(Data.unit_id)
  if gunId == 0 and IsGunUnlock == false then
    setactive(self.ui.mTrans_RedPoint, false)
    self.ui.mImg_Chr.color = ColorUtils.StringToColor("676767")
    setactive(self.ui.mTrans_Text, true)
    UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
      if IsGunUnlock then
        ArchivesUtils.EnterWay = 1
        UIManager.OpenUIByParam(UIDef.UIRoleFileDetailPanel, Data)
      else
        UIUtils.PopupHintMessage(110018)
      end
    end
    return
  end
  local Level = NetCmdTeamData:GetGunByID(gunId).mGun.GunClass
  if IsGunUnlock then
    self.ui.mImg_Chr.color = ColorUtils.WhiteColor
    setactive(self.ui.mTrans_FosterLevel, true)
    self.ui.mText_Num.text = Level
  else
    setactive(self.ui.mTrans_RedPoint, false)
    self.ui.mImg_Chr.color = ColorUtils.StringToColor("676767")
    setactive(self.ui.mTrans_Text, true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    if IsGunUnlock then
      ArchivesUtils.EnterWay = 1
      UIManager.OpenUIByParam(UIDef.UIRoleFileDetailPanel, Data)
    else
      UIUtils.PopupHintMessage(110018)
    end
  end
  self:UpdateRedPoint(Data, IsGunUnlock)
end
function GunFileItem:UpdateRedPoint(Data, isunlock)
  setactive(self.ui.mTrans_RedPoint, false)
  local charlist = Data.chat_list
  local audiolist = Data.audio_list
  local avgdic = {}
  local avlist = {}
  local uid = AccountNetCmdHandler.Uid
  local latestAvgId = NetCmdArchivesData:GetInt(uid .. Data.en_name .. "LastAvgId")
  local latestAudioId = NetCmdArchivesData:GetInt(uid .. Data.en_name .. "LastAudioId")
  if isunlock then
    local audioplot = "audioplot"
    for i = 0, Data.audio_list.Count - 1 do
      if NetCmdArchivesData:GetInt(uid .. Data.audio_list[i] .. audioplot) == 0 then
        setactive(self.ui.mTrans_RedPoint, true)
        break
      end
    end
    for i = 0, Data.chat_list.Count - 1 do
      local adjData = TableData.listAdjutantConversationDatas:GetDataById(Data.chat_list[i])
      if NetCmdArchivesData:GetInt(uid .. adjData.voice .. audioplot) == 0 then
        setactive(self.ui.mTrans_RedPoint, true)
        break
      end
    end
  else
    setactive(self.ui.mTrans_RedPoint, false)
  end
end
