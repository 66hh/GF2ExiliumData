require("UI.UAVPanel.UAVUtility")
require("UI.UAVPanel.UIUAVPartsSkillUpDialogPanelView")
UIUAVPartsSkillUpDialogPanel = class("UIUAVPartsSkillUpDialogPanel", UIBasePanel)
function UIUAVPartsSkillUpDialogPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUAVPartsSkillUpDialogPanel:OnAwake(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root)
  self.mview.mText_Title.text = TableData.GetHintById(105020)
  UIUtils.GetButtonListener(self.mview.mBtn_Confirm.gameObject).onClick = function()
    self:OnClickLevelUp()
  end
  UIUtils.GetButtonListener(self.mview.mBtn_Cancle.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUAVPartsSkillUpDialogPanel)
  end
  UIUtils.GetButtonListener(self.mview.mBtn_DetailBgClose.gameObject).onClick = function()
    setactive(self.mview.mTrans_SkillDetail, false)
  end
  UIUtils.GetButtonListener(self.mview.mBtn_DetailClose.gameObject).onClick = function()
    setactive(self.mview.mTrans_SkillDetail, false)
  end
  UIUtils.GetButtonListener(self.mview.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUAVPartsSkillUpDialogPanel)
  end
  UIUtils.GetButtonListener(self.mview.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIUAVPartsSkillUpDialogPanel)
  end
end
function UIUAVPartsSkillUpDialogPanel:OnInit(root, data)
  local nowarmid = UAVUtility.NowArmId
  self:UpdateTextInfo(nowarmid)
  local armtabledata = TableData.GetUavArmsData()
  local armskilltabledata = TableData.GetUarArmRevelantData(tonumber(armtabledata[nowarmid].SkillSet))
  self.mview.mImage_LeftUpIcon.sprite = UIUtils.GetIconSprite("Icon/Skill", armskilltabledata.Icon)
  self.mview.mImage_ArmIcon.sprite = UIUtils.GetIconSprite("Icon/UAV3DModelIcon", "Icon_UAV3DModelIcon_" .. armtabledata[nowarmid].ResCode)
  self.mview.mText_CostNum.text = armtabledata[nowarmid].Cost
  self.mview.mText_ArmName.text = armtabledata[nowarmid].Name.str
  local armtabledata = TableData.GetUavArmsData()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local script = self.mview.mTrans_ItemScript:GetComponent(typeof(CS.ScrollListChild))
  local itemobj = instantiate(script.childItem.gameObject, self.mview.mTrans_ItemScript)
  local itembtn = UIUtils.GetButton(itemobj)
  local itemimg = UIUtils.GetImage(itemobj, "GrpItem/Img_Item")
  local uavArmLevelCostId = armtabledata[nowarmid].UavArmLevelCost
  local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, uavarmdic[nowarmid].Level)
  local levelUpCostItemId = costArr[0]
  local NowUpGradeCost = costArr[1]
  local itemData = TableData.GetItemData(levelUpCostItemId)
  TipsManager.Add(itemobj.gameObject, itemData, nil, true, nil, nil)
  local itemrankimg = UIUtils.GetImage(itemobj, "GrpBg/Img_Bg")
  itemrankimg.sprite = IconUtils.GetQuiltyByRank(itemData.rank)
  itemimg.sprite = UIUtils.GetIconSprite("Icon/" .. itemData.icon_path, itemData.icon)
  self.itemtext = UIUtils.GetText(itemobj, "Trans_GrpNum/ImgBg/Text_Num")
  local NowPartsNum = NetCmdItemData:GetNetItemCount(levelUpCostItemId)
  local uavarmdic = NetCmdUavData:GetUavArmData()
  if NowUpGradeCost > NowPartsNum then
    self.isItemEnough = false
    self.itemtext.text = string.format("<color=#FF5E41>%d</color>/<color=#FFFFFF>%d</color>", NowPartsNum, NowUpGradeCost)
  else
    self.isItemEnough = true
    self.itemtext.text = NowPartsNum .. "/" .. NowUpGradeCost
  end
  local armtabledata = TableData.GetUavArmsData()
  local subid = string.sub(armtabledata[nowarmid].SkillSet, 1, 3)
  local itemobjlist = List:New()
  for i = 2, UAVUtility.GetUavArmMaxLevel(armtabledata[nowarmid].uav_arm_level_cost) do
    itemobjlist:Add(tonumber(subid .. i))
  end
  UIUtils.GetButtonListener(self.mview.mBtn_info.gameObject).onClick = function()
    setactive(self.mview.mTrans_SkillDetail, true)
    local uavarmdic = NetCmdUavData:GetUavArmData()
    local armskilltabledata = TableData.GetUarArmRevelantData(tonumber(subid .. uavarmdic[nowarmid].Level))
    self.mview.mText_DetailSkillDes.text = armskilltabledata.Detail.str
    for i = 0, self.mview.mTrans_DetailLevelUpDes.childCount - 1 do
      gfdestroy(self.mview.mTrans_DetailLevelUpDes:GetChild(i))
    end
    for i = 0, itemobjlist:Count() - 1 do
      local instObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ChrSkillDescriptionItemV2.prefab", self), self.mview.mTrans_DetailLevelUpDes)
      local item = UAVChrSkillDescriptionItem.New()
      item:InitCtrl(instObj.transform)
      local num = i + 2
      item:InitData(itemobjlist[i + 1], uavarmdic[nowarmid].Level, num)
    end
  end
end
function UIUAVPartsSkillUpDialogPanel:OnShowStart()
  self.IsPanelOpen = true
end
function UIUAVPartsSkillUpDialogPanel:OnHide()
  self.IsPanelOpen = false
end
function UIUAVPartsSkillUpDialogPanel:OnClose()
end
function UIUAVPartsSkillUpDialogPanel:OnRelease()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
end
function UIUAVPartsSkillUpDialogPanel:UpdateTextInfo(nowarmid)
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local armtabledata = TableData.GetUavArmsData()
  local subid = string.sub(armtabledata[nowarmid].SkillSet, 1, 3)
  local armskilltabledata = TableData.GetUarArmRevelantData(subid .. uavarmdic[nowarmid].Level + 1)
  self.mview.mText_NowLevel.text = uavarmdic[nowarmid].Level
  self.mview.mText_NextLevel.text = uavarmdic[nowarmid].Level + 1
  self.mview.mText_SkillDes.text = armskilltabledata.Detail.str
end
function UIUAVPartsSkillUpDialogPanel:UpdateItemText(nowarmid)
  local armtabledata = TableData.GetUavArmsData()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local armDataRow = TableData.listUavArmsDatas:GetDataById(nowarmid)
  local uavArmLevelCostId = armDataRow.uav_arm_level_cost
  local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, uavarmdic[nowarmid].Level)
  local levelUpCostItemId = costArr[0]
  local NowUpGradeCost = costArr[1]
  local NowPartsNum = NetCmdItemData:GetNetItemCount(levelUpCostItemId)
  if NowUpGradeCost > NowPartsNum then
    self.isItemEnough = false
    self.itemtext.text = string.format("<color=#FF5E41>%d</color>/<color=#FFFFFF>%d</color>", NowPartsNum, NowUpGradeCost)
  else
    self.isItemEnough = true
    self.itemtext.text = NowPartsNum .. "/" .. NowUpGradeCost
  end
end
function UIUAVPartsSkillUpDialogPanel:OnClickLevelUp()
  local nowarmid = UAVUtility.NowArmId
  local armtabledata = TableData.GetUavArmsData()
  local uavarmdic = NetCmdUavData:GetUavArmData()
  local uavArmLevelCostId = armtabledata[nowarmid].UavArmLevelCost
  local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, uavarmdic[nowarmid].Level)
  local levelUpCostItemId = costArr[0]
  local NowUpGradeCost = costArr[1]
  local NowPartsNum = NetCmdItemData:GetNetItemCount(levelUpCostItemId)
  local isItemEnough = NowUpGradeCost <= NowPartsNum
  if isItemEnough then
    NetCmdUavData:SendUavArmLevelUpData(nowarmid, function(ret)
      self:OnSuccessLevelUpCallBack(ret, nowarmid, nowarmlevel)
    end)
  else
    local hint = TableData.GetHintById(225)
    local uavarmdic = NetCmdUavData:GetUavArmData()
    local armDataRow = TableData.listUavArmsDatas:GetDataById(nowarmid)
    local uavArmLevelCostId = armDataRow.uav_arm_level_cost
    local costArr = UAVUtility:GetLevelUpCost(uavArmLevelCostId, uavarmdic[nowarmid].Level)
    local levelUpCostItemId = costArr[0]
    local str = string_format(hint, TableData.GetItemData(levelUpCostItemId).Name.str)
    CS.PopupMessageManager.PopupString(str)
  end
end
function UIUAVPartsSkillUpDialogPanel:OnSuccessLevelUpCallBack(ret, nowarmid, oldLevel)
  if ret == ErrorCodeSuc then
    local uavarmdic = NetCmdUavData:GetUavArmData()
    local curLevel = uavarmdic[nowarmid].Level
    local uavarmdata = TableData.GetUavArmsData()
    local maxLevel = UAVUtility.GetUavArmMaxLevel(uavarmdata[nowarmid].uav_arm_level_cost)
    if curLevel == maxLevel then
      UIManager.CloseUI(UIDef.UIUAVPartsSkillUpDialogPanel)
      return
    end
    UIUtils.PopupPositiveHintMessage(105043)
    self:UpdateTextInfo(nowarmid)
    self:UpdateItemText(nowarmid)
  end
end
function UIUAVPartsSkillUpDialogPanel:InitBaseData()
  self.mview = UIUAVPartsSkillUpDialogPanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
end
