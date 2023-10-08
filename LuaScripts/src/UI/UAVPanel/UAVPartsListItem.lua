require("UI.UIBaseCtrl")
UAVPartsListItem = class("UAVPartsListItem", UIBaseCtrl)
function UAVPartsListItem:__InitCtrl()
  self.mBtn_Unique = self:GetSelfButton()
  self.mTrans_Equiped = self:GetRectTransform("Trans_GrpNowEquiped")
  self.mTrans_Set = self:GetRectTransform("GrpSel")
  self.mImage_LeftIcon = self:GetImage("GrpNor/GrpUAVInfo/Grp3DModel/Img_3DModelIcon")
  self.mText_CostNum = self:GetText("GrpNor/GrpUAVInfo/GrpCost/Text_Num")
  self.mTrans_Lock = self:GetRectTransform("GrpNor/GrpUAVInfo/Trans_GrpLock")
  self.mText_SkillName = self:GetText("GrpNor/GrpName/Text_Name")
  self.mText_SkillLevelNum = self:GetText("GrpNor/GrpLevel/Text_Level")
  self.mImage_RightIcon = self:GetImage("GrpNor/GrpTacticSkillIcon/GrpIcon/ImgIcon")
  self.mText_CostOilNum = self:GetText("GrpNor/GrpTacticSkillIcon/GrpText/Text_Num")
  self.mTrans_RedPointParent = self:GetRectTransform("GrpNor/Trans_RedPoint")
  self.mTrans_RightUpEquiped = self:GetRectTransform("GrpNor/Trans_GrpNowEquiped")
  self.uavarmdic = NetCmdUavData:GetUavArmData()
  self.arminstall = NetCmdUavData:GetArmEquipState()
end
function UAVPartsListItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function UAVPartsListItem:InitData(tablearmid, armid, IsShowRedPoint, uavPanel)
  self.uavPanel = uavPanel
  self.tabledata = TableData.GetUavArmsData()
  for i = 0, self.arminstall.Count - 1 do
    if tablearmid == self.arminstall[i] then
      setactive(self.mTrans_Equiped.gameObject, true)
      setactive(self.mTrans_RightUpEquiped, true)
      break
    end
  end
  if tablearmid == armid then
    setactive(self.mTrans_Set, true)
  else
    setactive(self.mTrans_Set, false)
  end
  if IsShowRedPoint then
    setactive(self.mTrans_RedPointParent, true)
    local script = self.mTrans_RedPointParent:GetComponent(typeof(CS.ScrollListChild))
    local itemobj = instantiate(script.childItem.gameObject, self.mTrans_RedPointParent)
  end
  self.mImage_LeftIcon.sprite = UIUtils.GetIconSprite("Icon/UAV3DModelIcon", "Icon_UAV3DModelIcon_" .. self.tabledata[tablearmid].ResCode)
  self.mText_SkillName.text = self.tabledata[tablearmid].Name.str
  if self.uavarmdic:ContainsKey(tablearmid) then
    self.mText_SkillLevelNum.text = "Lv." .. self.uavarmdic[tablearmid].Level
  else
    setactive(self.mTrans_Lock.gameObject, true)
    self.mText_SkillLevelNum.text = "Lv.1"
  end
  local smallicondata = TableData.GetUarArmRevelantData(tonumber(self.tabledata[tablearmid].SkillSet))
  local armtabledata = TableData.GetUavArmsData()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local subid = string.sub(armtabledata[tablearmid].SkillSet, 1, 3)
  local battleskilldata
  if uavarmdic:ContainsKey(tablearmid) == false then
    battleskilldata = TableData.GetUarArmRevelantData(subid .. 1)
  else
    battleskilldata = TableData.GetUarArmRevelantData(subid .. uavarmdic[tablearmid].Level)
  end
  self.mText_CostNum.text = armtabledata[tablearmid].Cost
  self.mImage_RightIcon.sprite = UIUtils.GetIconSprite("Icon/Skill", smallicondata.Icon)
  self.mText_CostOilNum.text = battleskilldata.TeCost
  UIUtils.GetButtonListener(self.mBtn_Unique.gameObject).onClick = function()
    self:OnClickBtn(armid, tablearmid)
  end
end
function UAVPartsListItem:OnClickBtn(armid, tablearmid)
  local hasunlockarmdata = NetCmdUavData:GetUavArmData()
  UAVUtility.NowArmId = tablearmid
  UAVUtility.AniState = 1
  self.uavPanel:SetAnim()
  if CS.LuaUtils.IsNullOrDestroyed(self.uavPanel.contrastdialog) == false then
    gfdestroy(self.uavPanel.contrastdialog)
    self.uavPanel.mView.mToggle_Contrast.isOn = false
  end
  setactive(self.uavPanel.mView.mTrans_SkillRange, false)
  self.uavPanel.mView.mToggle_Range.isOn = false
  self.uavPanel:UpdateRightAreaInfo()
  self.uavPanel:UpdateLeftAreaInfo()
  self.uavPanel:UpdateRightBtnState()
  self.uavPanel:UpdateBottomSkillState(true)
  UAVUtility.IsClickUninstall = false
end
