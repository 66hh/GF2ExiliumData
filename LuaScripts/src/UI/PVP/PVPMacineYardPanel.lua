require("UI.UIBasePanel")
require("UI.Common.ComChrInfoItemV2")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
PVPMacineYardPanel = class("PVPMacineYardPanel", UIBasePanel)
PVPMacineYardPanel.__index = PVPMacineYardPanel
function PVPMacineYardPanel:ctor(obj)
  PVPMacineYardPanel.super.ctor(self)
  obj.Is3DPanel = true
end
function PVPMacineYardPanel:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.robotData = nil
  self.currSelectData = nil
  self.macineUIList = {}
  local iconPathList = {
    "Icon_Pow_64",
    "Icon_Hp_64",
    "Icon_Armor_64",
    "Icon_Mult_64",
    "Icon_Will_64"
  }
  self.ShowAttribute = {
    "pow",
    "max_hp",
    "shield_armor",
    "suppress_value",
    "max_will_value"
  }
  self.attrUIList = {}
  for i = 1, self.ui.mTrans_AttributeList.childCount do
    local trans = self.ui.mTrans_AttributeList:GetChild(i - 1)
    trans:Find("Icon"):GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite = IconUtils.GetAttributeIcon(iconPathList[i])
    self.attrUIList[i] = {
      textNum = trans:Find("TextNum"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    }
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.PVPMacineYardPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  local detailPrefab = UIUtils.GetGizmosPrefab("UICommonFramework/ComBtnInfo_W.prefab", self)
  UIUtils:CloneGo(detailPrefab, self.ui.mTrans_Detail, 1, function(item, index)
    local trans = UIUtils.GetTransform(item)
    UIUtils.GetButtonListener(trans.gameObject).onClick = function()
      local param = {
        attributeShowType = FacilityBarrackGlobal.AttributeShowType.Robot,
        robotData = self.robotData
      }
      UIManager.OpenUIByParam(UIDef.UIChrAttributeDetailsDialogV3, param)
    end
  end)
  self:OnShowData()
  if NetCmdPVPData.seasonData.season_id == 1 then
    self.ui.mText_Tips.text = TableData.GetHintById(120176)
  else
    self.ui.mText_Tips.text = TableData.GetHintById(120108)
  end
end
function PVPMacineYardPanel:InitRobotPartList()
  if self.robotPartsList.Count == 0 then
    return
  end
  self.ui.mVirtualListExNew_List.itemProvider = self.ItemProvider
  self.ui.mVirtualListExNew_List.itemRenderer = self.ItemRenderer
  self.comScreenItemV2 = ComScreenItemHelper:InitRobot(self.ui.mScrollListChild_Screen.gameObject, self.robotPartsList, function()
    self:RefreshItemList()
  end, nil, true)
  self:RefreshItemList()
end
function PVPMacineYardPanel:OnShowData()
  BarrackHelper.CameraMgr:LoadCanvas()
  self.robotPartsList = NetCmdPVPData.pvpRobotsList
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  self:InitRobotPartList()
  self:RefreshMacineList()
  self:RehreshBtn()
  CS.RobotModelManager.Instance:SetDragParam()
end
function PVPMacineYardPanel:RefreshItemList()
  if self.comScreenItemV2 == nil then
    return
  else
    self.robotPartsList = self.comScreenItemV2:GetResultList()
  end
  self.ui.mVirtualListExNew_List.numItems = self.robotPartsList.Count
  self.ui.mVirtualListExNew_List:Refresh()
  if self.currSelectData == nil then
    self:RefreshMacineAttr(self.robotPartsList[0])
  else
    self:RefreshMacineAttr(self.currSelectData.data)
  end
end
function PVPMacineYardPanel:RefreshMacineList()
  if self.robotPartsList.Count > 0 then
    setactive(self.ui.mTrans_Info.gameObject, true)
    setactive(self.ui.mTrans_MacineSelectList.gameObject, true)
    setactive(self.ui.mTrans_Right.gameObject, true)
    setactive(self.ui.mTrans_TextTips.gameObject, true)
    setactive(self.ui.mTrans_TextNoRobot.gameObject, false)
    setactive(self.ui.mTrans_None.gameObject, false)
  else
    setactive(self.ui.mTrans_Info.gameObject, false)
    setactive(self.ui.mTrans_MacineSelectList.gameObject, false)
    setactive(self.ui.mTrans_Right.gameObject, false)
    setactive(self.ui.mTrans_TextTips.gameObject, false)
    setactive(self.ui.mTrans_TextNoRobot.gameObject, true)
    setactive(self.ui.mTrans_None.gameObject, true)
    BarrackHelper.CameraMgr:SetWeaponRT()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
    BarrackHelper.CameraMgr:ShowRobotCanvas(true)
  end
end
function PVPMacineYardPanel.ItemProvider()
  local itemView = ComChrInfoItemV2.New()
  itemView:InitCtrl(PVPMacineYardPanel.ui.mTrans_Content, PVPMacineYardPanel.robotPartsList)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function PVPMacineYardPanel.ItemRenderer(index, itemData)
  local data = PVPMacineYardPanel.robotPartsList[index]
  local item = itemData.data
  item:RefreshData(data)
  if PVPMacineYardPanel.currSelectData == nil then
    PVPMacineYardPanel.currSelectData = {data = data, item = item}
    PVPMacineYardPanel:RefreshMacineAttr(PVPMacineYardPanel.currSelectData.data)
  end
  setactive(item.ui.mTrans_GrpChoose.gameObject, PVPMacineYardPanel.currSelectData.data.Uid == data.Uid)
  UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
    if PVPMacineYardPanel.currSelectData.data.Uid == data.Uid then
      return
    end
    if PVPMacineYardPanel.currSelectData then
      setactive(PVPMacineYardPanel.currSelectData.item.ui.mTrans_GrpChoose.gameObject, false)
    end
    setactive(item.ui.mTrans_GrpChoose.gameObject, true)
    PVPMacineYardPanel:RefreshMacineAttr(data)
    PVPMacineYardPanel.currSelectData = {data = data, item = item}
  end
end
function PVPMacineYardPanel:OnBackFrom()
  NetCmdPVPData:ReqNrtPvpRobots(function(ret)
    if ret == ErrorCodeSuc then
      self:OnShowData()
    end
  end)
end
function PVPMacineYardPanel:RefreshMacineAttr(data)
  self.ui.mText_Name.text = data.RobotTableData.Name
  self.ui.mText_Lv.text = string_format(TableData.GetHintById(80057), data.Level)
  self.ui.mText_Attribute.text = data.potency
  self.ui.mText_Type.text = data.RobotTableData.robot_type
  local color = TableData.GetGlobalGun_Quality_Color2(data.Rank)
  self.ui.mImg_QualityLine.color = color
  self:LoadAvatar(data.RobotId)
  local levelAttrData = TableDataBase.listRobotLevelDatas:GetDataById(data.Level)
  if levelAttrData == nil then
    return
  end
  local robotLevelData = TableDataBase.listPropertyDatas:GetDataById(levelAttrData.property_id)
  if robotLevelData == nil then
    return
  end
  local robotNormalData = TableDataBase.listPropertyDatas:GetDataById(data.RobotTableData.robot_property)
  if robotNormalData == nil then
    return
  end
  self.robotData = data
  local attrList = {}
  for k, v in ipairs(self.ShowAttribute) do
    table.insert(attrList, data:GetRobotBaseValue(v))
  end
  for k, v in ipairs(self.attrUIList) do
    v.textNum.text = attrList[k]
  end
  local skillPrefab = UIUtils.GetGizmosPrefab("Character/ChrBarrackSkillItemV2.prefab", self)
  UIUtils:CloneGo(skillPrefab, self.ui.mTrans_Skill, data.skillList.Count, function(item, index)
    local itemUI = UIUtils.GetUIBindTable(item)
    local info = TableDataBase.listBattleSkillDisplayDatas:GetDataById(data.skillList[index - 1])
    if itemUI == nil or info == nil then
      return
    end
    itemUI.mText_SkillLevel.text = "1"
    itemUI.mImg_SkillIcon.sprite = IconUtils.GetSkillIconSprite(info.icon)
    UIUtils.GetButtonListener(itemUI.mBtn_ChrBarrackSkillItemV2.gameObject).onClick = function()
      UIManager.OpenUIByParam(UIDef.UIChrSkillInfoDialog, {
        skillData = TableData.listBattleSkillDatas:GetDataById(data.skillList[index - 1]),
        gunCmdData = nil,
        isGunLock = false,
        showBottomBtn = false,
        showTag = 1,
        ispvpType = true
      })
    end
  end)
end
function PVPMacineYardPanel:LoadAvatar(robotId)
  UIUtils.GetRobotModel(robotId)
  BarrackHelper.CameraMgr:SetWeaponRT()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  BarrackHelper.CameraMgr:ShowRobotCanvas(true)
  TimerSys:DelayCall(0.5, function()
    CS.RobotModelManager.Instance:AddDragEvent()
  end)
end
function PVPMacineYardPanel:RehreshBtn()
  local prefab = UIUtils.GetGizmosPrefab("UICommonFramework/ComBtn2ItemV2_W.prefab", self)
  if self.robotPartsList.Count == 0 then
    UIUtils:CloneGo(prefab, self.ui.mTrans_BtnGoto, 1, function(item, index)
      local itemUI = UIUtils.GetUIBindTable(item)
      if itemUI == nil then
        return
      end
      itemUI.mText_Name.text = TableData.GetHintById(120142)
      UIUtils.GetButtonListener(itemUI.mBtn_W.gameObject).onClick = function()
        UIManager.OpenUIByParam(UIDef.UIPVPStoreExchangePanel, {
          CS.GF2.Data.StoreTagType.Pvp,
          28
        })
      end
    end)
    setactive(self.ui.mTrans_Tips.gameObject, false)
  else
    UIUtils:CloneGo(prefab, self.ui.mTrans_BtnArray, 1, function(item, index)
      local itemUI = UIUtils.GetUIBindTable(item)
      if itemUI == nil then
        return
      end
      itemUI.mText_Name.text = TableData.GetHintById(120141)
      UIUtils.GetButtonListener(itemUI.mBtn_W.gameObject).onClick = function()
        UIManager.OpenUI(UIDef.UIPVPDefenseTeamDialog)
      end
    end)
    setactive(self.ui.mTrans_Tips.gameObject, true)
  end
end
function PVPMacineYardPanel:OnClose()
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  CS.RobotModelManager.Instance:Release()
  SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  BarrackHelper.CameraMgr:ShowRobotCanvas(false)
  self.currSelectIndex = 0
  CS.RobotModelManager.Instance:ReSetDragParam()
end
