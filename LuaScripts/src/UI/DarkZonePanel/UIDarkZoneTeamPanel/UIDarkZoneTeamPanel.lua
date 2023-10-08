require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.Item.UIDarkZoneComEquipItem")
require("UI.DarkZonePanel.UIDarkZoneTeamPanel.UIDarkZoneTeamPanelView")
require("UI.UIBasePanel")
UIDarkZoneTeamPanel = class("UIDarkZoneTeamPanel", UIBasePanel)
UIDarkZoneTeamPanel.__index = UIDarkZoneTeamPanel
function UIDarkZoneTeamPanel:ctor(csPanel)
  UIDarkZoneTeamPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
  self.mCSPanel = csPanel
end
function UIDarkZoneTeamPanel:OnInit(root, data)
  UIDarkZoneTeamPanel.super.SetRoot(self, root)
  self:InitBaseData()
  self:InitData()
  self.mView:InitCtrl(root, self.ui)
  self.root = root
  self:InitTwiceInfo(data)
  self:AddBtnListen()
  function self.ui.mVirtualListEx.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  function self.onGunModelClickFunction(message)
    self:OnClickGunModel(message)
  end
  function self.onEnterDarkZoneFunction(message)
    self:OnEnterDarkZone(message)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.ZoomCamera, self.onGunModelClickFunction)
  MessageSys:AddListener(CS.GF2.Message.BattleUIEvent.EmbattleStartBattle, self.onEnterDarkZoneFunction)
  UIManager.EnableDarkZoneTeam(true)
  SceneSys:SwitchVisible(EnumSceneType.DarkZoneTeam)
  self.Camera = UISystem.CharacterCamera
  self.Camera.transform.position = Vector3(0, 0, 0)
  self.uiCamera = GameObject.Find("UICanvasCamera"):GetComponent("Camera")
  self.CMTeam = self.Camera.transform.parent:Find("CM/CM_FocusTeam")
  self.CMModel = self.Camera.transform.parent:Find("CM/CM_FocusModel")
  self.CMEmpty = self.Camera.transform.parent:Find("CM/CM_FocusEmpty")
  self.CMBrain = self.Camera.transform:GetComponent("CinemachineBrain")
  self.EmptyPoint = self.Camera.transform.parent:Find("FocusEmptyPoint")
  self.TeamToModelAnimTime = 0.6
  self.ModelToTeamAnimTime = 0.6
  self.TeamToEmptyAnimTime = 0.6
  self.EmptyToTeamAnimTime = 0.6
  setactive(self.ui.mBtn_QuicklyFleet.gameObject.transform.parent, false)
  self:SetEquipedList()
end
function UIDarkZoneTeamPanel:OnShowFinish()
  if self.IsOpen then
    self:UpdateTeamList(self.curTeam)
    self:InitTeamNameList()
    self.IsOpen = false
  end
end
function UIDarkZoneTeamPanel:OnHide()
  for i = 0, self.ui.mTrans_GrpChrList.childCount - 1 do
    setactive(self.ui.mTrans_GrpChrList:GetChild(i), false)
  end
end
function UIDarkZoneTeamPanel:OnBackFrom()
  for i = 0, self.ui.mTrans_GrpChrList.childCount - 1 do
    setactive(self.ui.mTrans_GrpChrList:GetChild(i), true)
  end
  self:SetEquipedList()
end
function UIDarkZoneTeamPanel:OnUpdate(deltatime)
  if self.isOpenGunList == true then
    self.uiLoopTime = self.uiLoopTime + deltatime
  end
end
function UIDarkZoneTeamPanel:CloseFunction()
  if self.TwiceInfo then
    setactive(self.ui.mBtn_Start.gameObject.transform.parent, true)
  end
  if self.QuicklyTeam == true then
    self.ui.mAnim_Fleet:SetTrigger("GrpTeamInfo_FadeIn")
    self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeOut")
    self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeIn")
    self.ui.mAnim_ChrList:SetTrigger("FadeOut")
    TimerSys:DelayCall(0.53, function()
      setactive(self.ui.mAnim_ChrList.gameObject, false)
      setactive(self.ui.mBtn_Left.gameObject, true)
      setactive(self.ui.mBtn_Right.gameObject, true)
    end)
    setactive(self.ui.mTrans_BtnOverWrite, true)
    setactive(self.ui.mTrans_BtnScreen, true)
    self.QuicklyTeam = false
  else
    UIManager.CloseUI(UIDef.UIDarkZoneTeamPanel)
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
  end
end
function UIDarkZoneTeamPanel:OnClose()
  self:ReleaseTimers()
  self.mCSPanel.FadeOutTime = self.FadeOutTime
  for i = 0, self.ui.mTrans_GrpChrList.childCount - 1 do
    setactive(self.ui.mTrans_GrpChrList:GetChild(i), true)
  end
  setactive(self.ui.mBtn_Start.gameObject.transform.parent, false)
  for i = 1, #self.TeamDataDic do
    local data = DarkZoneTeamData(i - 1, self.TeamDataDic[i].guns, self.TeamDataDic[i].leader)
    DarkNetCmdTeamData.Teams[i - 1].Leader = self.TeamDataDic[i].leader
    DarkNetCmdTeamData:SetTeamInfo(data)
  end
  self.ui = nil
  self.mView = nil
  self.curTeam = nil
  for _, v in pairs(self.TeamObj) do
    gfdestroy(v.obj)
  end
  self.TeamObj = nil
  gfdestroy(self.teamObjRoot)
  self.teamObjRoot = nil
  self.TeamDataDic = nil
  self.TeamData = nil
  self.ItemDataList = nil
  self.GunListFilter = nil
  self.CurGunId = nil
  self.Camera = nil
  self.IsZoom = nil
  self.uiCamera = nil
  self.CurBtn = nil
  self.LastGunBtn = nil
  self.IsOpen = nil
  self.CurFoucs = nil
  self.IsDefaultChose = nil
  self.LookGunId = nil
  self.TeamToModelAnimTime = nil
  self.ModelToTeamAnimTime = nil
  self.TeamToEmptyAnimTime = nil
  self.EmptyToTeamAnimTime = nil
  self.QuicklyTeam = nil
  self.QuicklyTeamList = nil
  self.QuicklyTeamClickGunID = nil
  self.QuicklyTeamItemData = nil
  self.ClickGunOrAddBtn = nil
  self.LastClickGunId = nil
  self.LastItem = nil
  self.TeamItem = nil
  self.FirstLoadTotalCount = nil
  self.LoadCount = nil
  self.TwiceInfo = false
  self.mCurMapId = nil
  self.uiLoopTime = nil
  self.isOpenGunList = nil
  self.FocusModel = nil
  self.IsInCardList = nil
  self.modelPosDic = nil
  self.HPPointDic = nil
  self.equippedDict = nil
  self.itemUIList = nil
  self.firstInIt = nil
  UIManager.EnableDarkZoneTeam(false)
  UIDarkZoneTeamModelManager:Release()
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.ZoomCamera, self.onGunModelClickFunction)
  MessageSys:RemoveListener(CS.GF2.Message.BattleUIEvent.EmbattleStartBattle, self.onEnterDarkZoneFunction)
  self.onGunModelClickFunction = nil
  self.onEnterDarkZoneFunction = nil
  self:UnRegistrationKeyboard(nil)
  for k, v in pairs(self.equippedItem) do
    if v ~= nil then
      v:DestroySelf()
    end
  end
  self.equippedItem = nil
end
function UIDarkZoneTeamPanel:OnRelease()
  self.super.OnRelease(self)
end
function UIDarkZoneTeamPanel:InitBaseData()
  self.mView = UIDarkZoneTeamPanelView.New()
  self.ui = {}
  self.curTeam = 0
  self.TeamObj = {}
  self.TeamDataDic = {}
  self.TeamData = {}
  self.ItemDataList = {}
  self.Camera = {}
  self.IsZoom = false
  self.uiCamera = {}
  self.CurBtn = -1
  self.IsOpen = true
  self.IsDefaultChose = false
  self.LookGunId = 0
  self.TeamToModelAnimTime = 0
  self.ModelToTeamAnimTime = 0
  self.TeamToEmptyAnimTime = 0
  self.EmptyToTeamAnimTime = 0
  self.QuicklyTeam = false
  self.QuicklyTeamList = {}
  self.QuicklyTeamClickGunID = 0
  self.QuicklyTeamItemData = {}
  self.ClickGunOrAddBtn = false
  self.LastClickGunId = 0
  self.LastItem = nil
  self.TeamItem = {}
  self.FirstLoadTotalCount = 0
  self.LoadCount = 0
  self.TwiceInfo = nil
  self.mCurMapId = 0
  self.FocusModel = nil
  self.IsInCardList = nil
  self.modelPosDic = {}
  self.HPPointDic = {}
  self.uiLoopTime = 0
  self.isOpenGunList = false
  self.equippedItem = {}
  self.equippedDict = nil
  self.itemUIList = {}
  self.firstInIt = true
  local prefab = instantiate(ResSys:GetUIGizmos("UICommonFramework/ComChrChangeItem.prefab", false))
  self.gunListItem = CS.UICommonEmbattleChrItem(prefab.transform)
  function self.gunListItem.GunList.itemProvider()
    return self:GunItemProvider()
  end
  function self.gunListItem.GunList.itemRenderer(index, renderData)
    self:GunItemRenderer(index, renderData)
  end
  function self.gunListItem.mRefreshAction(dutyID)
    self:ReFreshListByDutyID(dutyID)
  end
end
function UIDarkZoneTeamPanel:InitData()
  local Data = DarkNetCmdTeamData.Teams
  for i = 0, Data.Count - 1 do
    local data = {}
    data.name = Data[i].Name
    data.guns = Data[i].Guns
    data.leader = Data[i].Leader
    for j = data.guns.Count, 3 do
      data.guns:Add(0)
    end
    table.insert(self.TeamDataDic, data)
  end
  self:InitQuiclkTeamListData()
end
function UIDarkZoneTeamPanel:InitQuiclkTeamListData()
  DarkNetCmdTeamData.QuicklyTeamList:Clear()
  for i = 0, 3 do
    DarkNetCmdTeamData.QuicklyTeamList:Add(0)
  end
end
function UIDarkZoneTeamPanel:ItemProvider()
  local itemView = DarkZoneTeamItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  self.ui.mTrans_GrpEmpty:SetAsLastSibling()
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneTeamPanel:ItemRenderer(index, renderData)
  local data = self.ItemDataList[index + 1]
  local item = renderData.data
  item:SetTable(self)
  item:SetData(data, index)
  if self.IsDefaultChose == true and data.id == self.tempId then
    item:OnClickGunCard()
    self.IsDefaultChose = false
  end
end
function UIDarkZoneTeamPanel:InitTwiceInfo(data)
  if data then
    self.QuicklyTeam = nil
    self.TwiceInfo = true
    setactive(self.ui.mBtn_Start.gameObject.transform.parent, true)
    self.ui.mText_MapName.text = data.MapName
    self.ui.mText_Cost.text = data.Energy
    UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
      for i = 0, self.TeamDataDic[self.curTeam + 1].guns.Count - 1 do
        if self.TeamDataDic[self.curTeam + 1].guns[i] == 0 then
          UIUtils.PopupHintMessage(903108)
          return
        end
      end
      self.mCurMapId = data.MapId
      if SupplyHelper:CheckSupplyRepeated(self.TeamDataDic[self.curTeam + 1].guns) == true then
        self:EnterDarkZone()
      end
    end
  else
  end
end
function UIDarkZoneTeamPanel:OnEnterDarkZone(message)
  self:EnterDarkZone()
end
function UIDarkZoneTeamPanel:EnterDarkZone()
  local Ddata = DarkZoneTeamData(self.curTeam, self.TeamDataDic[self.curTeam + 1].guns, self.TeamDataDic[self.curTeam + 1].leader)
  DarkNetCmdTeamData.Teams[self.curTeam].Leader = self.TeamDataDic[self.curTeam + 1].leader
  DarkNetCmdTeamData:SetTeamInfo(Ddata, function()
    if MapSelectUtils.currentQuestID then
      CS.DzMatchUtils.RequireDarkMatchQuest(MapSelectUtils.currentQuestID, self.mCurMapId, MapSelectUtils.currentQuestGroupID)
    else
      CS.DzMatchUtils.RequireDarkMatchDefault(self.mCurMapId)
    end
  end)
end
function UIDarkZoneTeamPanel:ShowMessageBoxPanel(desstr, data)
  local OpenData = {}
  OpenData.Content = desstr
  function OpenData.GotoCallBack()
    SceneSwitch:SwitchByID(10001)
  end
  function OpenData.CancleCallBack()
    self.mCurMapId = data.MapId
    self:EnterDarkZone()
  end
  OpenData.Title = TableData.GetHintById(208)
  OpenData.GoToText = TableData.GetHintById(903205)
  OpenData.CancleText = TableData.GetHintById(903204)
  UIManager.OpenUIByParam(UIDef.UIDarkZoneMessageDialog, OpenData)
end
function UIDarkZoneTeamPanel:InitTeamNameList()
  local obj = self:InstanceUIPrefab("UICommonFramework/ComScreenDropdownListItemV2.prefab", self.ui.mTrans_Name)
  self.teamObjRoot = obj
  for i = 1, GlobalConfig.TeamCount do
    if obj then
      do
        local childparent = obj.transform:Find("Content")
        local childobj = self:InstanceUIPrefab("Character/ChrEquipSuitDropdownItemV2.prefab", childparent)
        local sort = {}
        sort.index = i
        sort.obj = childobj
        sort.btnself = UIUtils.GetButton(childobj)
        sort.txtName = UIUtils.GetText(childobj, "GrpText/Text_SuitName")
        sort.hintID = 903001 + i
        sort.grpset = childobj.transform:Find("GrpSel")
        if self.TeamDataDic[i] == nil or self.TeamDataDic[i].name == "" then
          sort.txtName.text = TableData.GetHintById(sort.hintID)
        else
          sort.txtName.text = self.TeamDataDic[i].name
        end
        UIUtils.GetButtonListener(sort.btnself.gameObject).onClick = function()
          self:OnClickDrop(i - 1)
        end
        self.textcolor = childobj.transform:GetComponent("TextImgColor")
        self.beforecolor = self.textcolor.BeforeSelected
        self.aftercolor = self.textcolor.AfterSelected
        if sort.index ~= self.curTeam + 1 then
          sort.txtName.color = self.textcolor.BeforeSelected
          setactive(sort.grpset, false)
        else
          sort.txtName.color = self.textcolor.AfterSelected
          setactive(sort.grpset, true)
        end
        table.insert(self.TeamObj, sort)
      end
    end
  end
  UIUtils.GetUIBlockHelper(self.mView.mUIRoot, self.ui.mTrans_Name, function()
    setactive(self.ui.mTrans_Name, false)
  end)
  setactive(self.ui.mTrans_Name, false)
end
function UIDarkZoneTeamPanel:Rename()
  UIManager.OpenUIByParam(UIDef.UIDarkZoneTeamReNameDialog, self)
end
function UIDarkZoneTeamPanel:OnClickDrop(TeamIndex)
  local data = DarkZoneTeamData(self.curTeam, self.TeamDataDic[self.curTeam + 1].guns, self.TeamDataDic[self.curTeam + 1].leader)
  DarkNetCmdTeamData.Teams[self.curTeam].Leader = self.TeamDataDic[self.curTeam + 1].leader
  DarkNetCmdTeamData:SetTeamInfo(data, function()
    local sort = self.TeamObj[self.curTeam + 1]
    sort.txtName.color = self.textcolor.BeforeSelected
    setactive(sort.grpset, false)
    self.curTeam = TeamIndex
    setactive(self.ui.mTrans_Name, false)
    local sort = self.TeamObj[TeamIndex + 1]
    sort.txtName.color = self.textcolor.AfterSelected
    setactive(sort.grpset, true)
    UIDarkZoneTeamModelManager:HideOrShowModel(false)
    UIDarkZoneTeamModelManager.gunlist = self.TeamDataDic[self.curTeam + 1].guns
    self:UpdateTeamList(TeamIndex)
  end)
end
function UIDarkZoneTeamPanel:UpdateTeamList(TeamIndex, showTeamInfo)
  setactive(self.ui.mTrans_TeamInfo2, showTeamInfo ~= false)
  DarkNetCmdTeamData.CurTeamIndex = TeamIndex
  local TeamData = self.TeamDataDic[TeamIndex + 1]
  if TeamData.name == "" then
    self.ui.mText_TeamName.text = TableData.GetHintById(903002 + TeamIndex)
    self.ui.mText_TeamName2.text = TableData.GetHintById(903002 + TeamIndex)
    setactive(self.ui.mTrans_GrpNumN, false)
  else
    setactive(self.ui.mTrans_GrpNumN, true)
    self.ui.mText_TeamName.text = TeamData.name
    self.ui.mText_TeamName2.text = TeamData.name
  end
  setactive(self.ui.mTrans_GrpNumN, true)
  setactive(self.ui.mText_PowerNum.gameObject, true)
  setactive(self.ui.mTrans_Text, true)
  setactive(self.ui.mTrans_bg, true)
  UIDarkZoneTeamModelManager.gunlist = TeamData.guns
  DarkNetCmdTeamData.QuicklyTeamList:Clear()
  for i = 0, 3 do
    DarkNetCmdTeamData.QuicklyTeamList:Add(TeamData.guns[i])
    do
      local trans = self.ui.mTrans_Add:GetChild(i)
      if self.itemUIList[i] == nil then
        local uiList = {}
        local LuaUIBindScript = trans:GetComponent(UIBaseCtrl.LuaBindUi)
        local vars = LuaUIBindScript.BindingNameList
        for j = 0, vars.Count - 1 do
          uiList[vars[j]] = LuaUIBindScript:GetBindingComponent(vars[j])
        end
        self.itemUIList[i] = uiList
      end
      local GrpItemUi = self.itemUIList[i]
      if TeamData.guns[i] ~= 0 then
        setactive(GrpItemUi.mTrans_GrpChrInfo, true)
        setactive(GrpItemUi.mTrans_BtnAdd, false)
        setactive(GrpItemUi.mImg_Bar.gameObject, true)
        UIUtils.GetButtonListener(GrpItemUi.mBtn_Energe.gameObject).onClick = function()
          UIUtils.PopupHintMessage(903297)
        end
        if self.firstInIt == true then
          self:DelayCall(0.15, function()
            for i = 1, 3 do
              self:SetModelDicPos(i)
            end
            self:UpdateModel(TeamData.guns[i], i)
            self.firstInIt = false
          end)
        else
          self:UpdateModel(TeamData.guns[i], i)
        end
        local gundata = NetCmdTeamData:GetGunByID(TeamData.guns[i])
        GrpItemUi.mText_Lv.text = string_format(TableData.GetHintById(80057), gundata.mGun.Level)
        if self.TwiceInfo then
        end
        if TeamData.guns[i] == TeamData.leader then
          setactive(GrpItemUi.mTrans_IconCaptain, true)
          setactive(GrpItemUi.mTrans_IconMember, false)
          GrpItemUi.mText_Name.text = gundata.TabGunData.Name.str
          GrpItemUi.mImg_Bar.fillAmount = gundata.DarkZoneEnergy / TableData.GlobalDarkzoneData.DarkzoneEnergylimit
          GrpItemUi.mText_Num.text = tostring(gundata.DarkZoneEnergy) .. "/" .. tostring(TableData.GlobalDarkzoneData.DarkzoneEnergylimit)
        else
          setactive(GrpItemUi.mTrans_IconCaptain, false)
          setactive(GrpItemUi.mTrans_IconMember, true)
          GrpItemUi.mText_Name.text = gundata.TabGunData.Name.str
          GrpItemUi.mImg_Bar.fillAmount = gundata.DarkZoneEnergy / TableData.GlobalDarkzoneData.DarkzoneEnergylimit
          GrpItemUi.mText_MemberNum.text = i + 1
          GrpItemUi.mText_Num.text = tostring(gundata.DarkZoneEnergy) .. "/" .. tostring(TableData.GlobalDarkzoneData.DarkzoneEnergylimit)
        end
      else
        setactive(GrpItemUi.mTrans_GrpTip, false)
        setactive(GrpItemUi.mTrans_EffectTip, false)
        GrpItemUi.mImg_Bar.color = ColorUtils.StringToColor("6BF1C6")
        setactive(GrpItemUi.mImg_Bar.gameObject, false)
        setactive(GrpItemUi.mTrans_GrpChrInfo, false)
        setactive(GrpItemUi.mTrans_BtnAdd, true)
      end
    end
  end
end
function UIDarkZoneTeamPanel:AddBtnListen()
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    self:BtnOffFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    if not pcall(function()
      DarkNetCmdStoreData.questCacheGroupId = 0
    end) then
      gfwarning("UIDarkZoneQuestInfoPanelItem位置缓存出现异常")
    end
    DarkNetCmdTeamData:UnloadTeamAssets()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Left.gameObject).onClick = function()
    self:LeftArrow()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Right.gameObject).onClick = function()
    self:RightArrow()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Rename.gameObject).onClick = function()
    self:Rename()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Down.gameObject).onClick = function()
    setactive(self.ui.mTrans_Name, not self.ui.mTrans_Name.gameObject.activeSelf)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Filter.gameObject).onClick = function()
    self:OpenGunListFilter()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Info.gameObject).onClick = function()
    self:GunInfo()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_SecondBack.gameObject).onClick = function()
    self:BtnOffFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Off.gameObject).onClick = function()
    self:BtnOffFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GoWar.gameObject).onClick = function()
    self:GoWar()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Replace.gameObject).onClick = function()
    self:RePlace()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Add1.gameObject).onClick = function()
    self:OnClickAddBtn(1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Add2.gameObject).onClick = function()
    self:OnClickAddBtn(2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Add3.gameObject).onClick = function()
    self:OnClickAddBtn(3)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Add4.gameObject).onClick = function()
    self:OnClickAddBtn(4)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_QuicklyFleet.gameObject).onClick = function()
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Off)
    self:OpenQuicklyTeam()
    self.ui.mAnim_Fleet:SetTrigger("FadeOut")
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Save.gameObject).onClick = function()
    self:QuickSave()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpRepository.gameObject).onClick = function()
    self:OpenRepository()
  end
end
function UIDarkZoneTeamPanel:BtnOffFunction()
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
  if self.QuicklyTeam ~= nil or self.TwiceInfo == true then
    self:InitQuiclkTeamListData()
    self.QuicklyTeamItemData = {}
    if not self.QuicklyTeam then
      setactive(self.ui.mTrans_GrpChrList, false)
      setactive(self.ui.mTrans_GrpChrList, true)
    end
    self.QuicklyTeam = false
    self.ui.mAnim_Fleet:SetTrigger("GrpTeamInfo_FadeIn")
    self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeOut")
    self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeIn")
    self.ui.mAnim_ChrList:SetTrigger("FadeOut")
    self.ui.mAnim_Fleet:SetTrigger("FadeIn")
    setactive(self.ui.mTrans_BtnOverWrite, true)
    setactive(self.ui.mTrans_BtnScreen, true)
    setactive(self.ui.mBtn_Replace.gameObject, true)
    setactive(self.ui.mBtn_GoWar.gameObject, true)
    setactive(self.ui.mBtn_Save.gameObject.transform.parent, false)
    setactive(self.ui.mBtn_SecondBack.gameObject, false)
    setactive(self.ui.mBtn_Left.gameObject, true)
    setactive(self.ui.mBtn_Right.gameObject, true)
  end
  if self.TwiceInfo then
    setactive(self.ui.mBtn_Start.gameObject.transform.parent, true)
  end
  UIDarkZoneTeamModelManager:HideOrShowModel(false)
  if self.ClickGunOrAddBtn == false then
    setactive(self.ui.mBtn_Left.gameObject, false)
    setactive(self.ui.mBtn_Right.gameObject, false)
    self:CloseGunListForQuicklyTeam()
    self:UpdateTeamList(self.curTeam)
  else
    self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeOut")
    self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeIn")
    self:CloseGunList()
    self:UpdateTeamList(self.curTeam, false)
  end
  self.ClickGunOrAddBtn = false
end
function UIDarkZoneTeamPanel:OpenQuicklyTeam()
  self.ui.mAnim_Fleet:SetTrigger("GrpTeamInfo_FadeOut")
  self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeOut")
  self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeIn")
  self.QuicklyTeam = true
  if self.TwiceInfo then
    setactive(self.ui.mBtn_Start.gameObject.transform.parent, false)
  end
  setactive(self.ui.mTrans_BtnOverWrite, false)
  setactive(self.ui.mTrans_BtnScreen, false)
  TimerSys:DelayCall(0.2, function()
    setactive(self.ui.mAnim_ChrList.gameObject, true)
    setactive(self.ui.mBtn_BgClose.gameObject, true)
  end)
  setactive(self.ui.mBtn_Replace.gameObject, false)
  setactive(self.ui.mBtn_GoWar.gameObject, false)
  setactive(self.ui.mBtn_Save.gameObject.transform.parent, true)
  setactive(self.ui.mTrans_GrpName.gameObject, false)
  setactive(self.ui.mTrans_NoGun, false)
  setactive(self.ui.mBtn_SecondBack.gameObject, true)
  setactive(self.ui.mBtn_Left.gameObject, false)
  setactive(self.ui.mBtn_Right.gameObject, false)
  self:ShowGunList()
end
function UIDarkZoneTeamPanel:QuickSave()
  for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
    local gunId = DarkNetCmdTeamData.QuicklyTeamList[i]
    if gunId ~= 0 then
      local charId = TableData.listGunDatas:GetDataById(gunId).character_id
      for j = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
        if DarkNetCmdTeamData.QuicklyTeamList[j] == gunId then
        else
          local childGunId = DarkNetCmdTeamData.QuicklyTeamList[j]
          if childGunId ~= 0 then
            local childCharId = TableData.listGunDatas:GetDataById(childGunId).character_id
            if childCharId == charId then
              UIUtils.PopupHintMessage(903136)
              return
            end
          end
        end
      end
    end
  end
  self.ui.mAnim_Fleet:SetTrigger("GrpTeamInfo_FadeIn")
  self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeOut")
  self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeIn")
  self.ui.mAnim_Fleet:SetTrigger("FadeIn")
  self.QuicklyTeam = false
  local TeamData = self.TeamDataDic[self.curTeam + 1]
  for i = 0, TeamData.guns.Count - 1 do
    TeamData.guns[i] = DarkNetCmdTeamData.QuicklyTeamList[i]
    TeamData.leader = DarkNetCmdTeamData.QuicklyTeamList[0]
  end
  if self.TwiceInfo then
    setactive(self.ui.mBtn_Start.gameObject.transform.parent, true)
  end
  setactive(self.ui.mBtn_Left.gameObject, false)
  setactive(self.ui.mBtn_Right.gameObject, false)
  self:CloseGunListForQuicklyTeam()
  setactive(self.ui.mTrans_BtnOverWrite, true)
  setactive(self.ui.mTrans_BtnScreen, true)
  setactive(self.ui.mBtn_Replace.gameObject, true)
  setactive(self.ui.mBtn_GoWar.gameObject, true)
  setactive(self.ui.mBtn_Save.gameObject.transform.parent, false)
  setactive(self.ui.mBtn_SecondBack.gameObject, false)
  UIDarkZoneTeamModelManager:HideOrShowModel(false)
  self:UpdateTeamList(self.curTeam)
  UIUtils.PopupPositiveHintMessage(903229)
  self.QuicklyTeamItemData = {}
end
function UIDarkZoneTeamPanel:CloseGunList()
  setactive(self.CMModel, false)
  setactive(self.CMEmpty, false)
  setactive(self.CMTeam, true)
  self.isOpenGunList = false
  self.uiLoopTime = 0
  self:PlayAnim(false)
  self.CurGunId = nil
  self.CurFoucs = nil
  self.FocusModel = nil
  if self.LastGunBtn ~= nil then
    self.LastGunBtn.interactable = true
  end
  if self.GunListFilter then
    GunListFilter.ResetFilter()
    self.GunListFilter = nil
  end
end
function UIDarkZoneTeamPanel:CloseGunListForQuicklyTeam()
  setactive(self.CMModel, false)
  setactive(self.CMEmpty, false)
  setactive(self.CMTeam, true)
  self.isOpenGunList = false
  self.uiLoopTime = 0
  self:PlayAnimForQuicklyTeam(false)
  self.CurGunId = nil
  self.CurFoucs = nil
  self.FocusModel = nil
  if self.LastGunBtn ~= nil then
    self.LastGunBtn.interactable = true
  end
  if self.GunListFilter then
    GunListFilter.ResetFilter()
    self.GunListFilter = nil
  end
end
function UIDarkZoneTeamPanel:GoWar()
  if self.CurGunId == nil then
    UIUtils.PopupHintMessage(903011)
    return
  end
  local NowcharId = TableData.listGunDatas:GetDataById(self.CurGunId).character_id
  for i = 0, self.TeamDataDic[self.curTeam + 1].guns.Count - 1 do
    local gunId = self.TeamDataDic[self.curTeam + 1].guns[i]
    if gunId ~= 0 then
      local charId = TableData.listGunDatas:GetDataById(gunId).character_id
      if charId == NowcharId and gunId ~= self.CurGunId then
        UIUtils.PopupHintMessage(903136)
        return
      end
    end
  end
  local temp = self.TeamDataDic[self.curTeam + 1].guns
  local setleader
  for i = 0, temp.Count - 1 do
    if temp[i] ~= 0 then
      setleader = 1
    end
  end
  if setleader == nil then
    self.TeamDataDic[self.curTeam + 1].guns[0] = self.CurGunId
    self.TeamDataDic[self.curTeam + 1].leader = self.CurGunId
  else
    local index = self:CheckInTeam(self.CurGunId)
    if index ~= nil then
      if self.TeamDataDic[self.curTeam + 1].leader == self.TeamDataDic[self.curTeam + 1].guns[index - 1] then
        self.TeamDataDic[self.curTeam + 1].leader = self.CurGunId
      end
      self.TeamDataDic[self.curTeam + 1].guns[index - 1] = 0
      self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    else
      self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    end
  end
  self.TeamDataDic[self.curTeam + 1].leader = self.TeamDataDic[self.curTeam + 1].guns[0]
  UIDarkZoneTeamModelManager:HideOrShowModel(false)
  self:CloseGunList()
  if self.QuicklyTeam ~= nil or self.TwiceInfo then
    self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeOut")
    self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeIn")
  end
  setactive(self.ui.mBtn_Left.gameObject, true)
  setactive(self.ui.mBtn_Right.gameObject, true)
  self:UpdateTeamList(self.curTeam)
  UIUtils.PopupPositiveHintMessage(903012)
  self.ui.mBtn_GoWar.interactable = false
  self.CurGunId = nil
end
function UIDarkZoneTeamPanel:RePlace()
  if self.CurGunId == nil then
    UIUtils.PopupHintMessage(903011)
    return
  end
  local index = self:CheckInTeam(self.CurGunId)
  if index ~= nil then
    local temp = self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1]
    self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    self.TeamDataDic[self.curTeam + 1].guns[index - 1] = temp
    self.TeamDataDic[self.curTeam + 1].leader = self.TeamDataDic[self.curTeam + 1].guns[0]
  else
    local NowcharId = TableData.listGunDatas:GetDataById(self.CurGunId).character_id
    for i = 0, self.TeamDataDic[self.curTeam + 1].guns.Count - 1 do
      local gunId = self.TeamDataDic[self.curTeam + 1].guns[i]
      if gunId ~= 0 then
        local charId = TableData.listGunDatas:GetDataById(gunId).character_id
        if charId == NowcharId and gunId ~= self.CurGunId and i ~= self.CurBtn - 1 then
          UIUtils.PopupHintMessage(903136)
          return
        end
      end
    end
    self.TeamDataDic[self.curTeam + 1].guns[self.CurBtn - 1] = self.CurGunId
    self.TeamDataDic[self.curTeam + 1].leader = self.TeamDataDic[self.curTeam + 1].guns[0]
  end
  UIDarkZoneTeamModelManager:HideOrShowModel(false)
  self:CloseGunList()
  if self.QuicklyTeam ~= nil or self.TwiceInfo then
    self.ui.mAnim_QuicklyTeam:SetTrigger("GrpTeamInfo_FadeOut")
    self.ui.mAnim_NormalTeam:SetTrigger("GrpTeamInfo_FadeIn")
  end
  setactive(self.ui.mBtn_Left.gameObject, true)
  setactive(self.ui.mBtn_Right.gameObject, true)
  self:UpdateTeamList(self.curTeam)
  UIUtils.PopupPositiveHintMessage(903013)
  self.ui.mBtn_Replace.interactable = false
  self.CurGunId = nil
end
function UIDarkZoneTeamPanel:CheckBtnState()
  self.ui.mBtn_GoWar.interactable = true
  setactive(self.ui.mBtn_GoWar.gameObject, false)
  setactive(self.ui.mBtn_Replace.gameObject, false)
  if self.CurFoucs == nil then
    setactive(self.ui.mBtn_GoWar.gameObject, true)
  else
    setactive(self.ui.mBtn_Replace.gameObject, true)
    self.ui.mBtn_Replace.interactable = false
  end
end
function UIDarkZoneTeamPanel:OnClickAddBtn(Index)
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Off)
  self.IsZoom = true
  if self.QuicklyTeam == true then
    return
  end
  if self.QuicklyTeam ~= nil then
    self.QuicklyTeam = 1
  end
  self.LastClickGunId = 0
  self.LastItem = nil
  setactive(self.ui.mTrans_TeamInfo2, false)
  setactive(self.ui.mBtn_Save.gameObject.transform.parent, false)
  setactive(self.ui.mTrans_GrpName.gameObject, true)
  setactive(self.ui.mTrans_NoGun, true)
  setactive(self.ui.mBtn_SecondBack.gameObject, true)
  setactive(self.ui.mBtn_Left.gameObject, false)
  setactive(self.ui.mBtn_Right.gameObject, false)
  UIDarkZoneTeamModelManager:SetCaCheModelShow(false)
  self.LookGunId = nil
  self.ClickGunOrAddBtn = true
  setactive(self.CMModel, false)
  setactive(self.CMEmpty, true)
  setactive(self.CMTeam, false)
  self:PlayAnim(true, 0, true)
  setactive(self.ui.mTrans_ChrGrpIcon, false)
  self.CurBtn = Index
  self:ShowGunList()
  if self.CurFoucs == nil then
    setactive(self.ui.mTrans_NoGun, true)
  else
    setactive(self.ui.mTrans_NoGun, false)
  end
end
function UIDarkZoneTeamPanel:LeftArrow()
  local data = DarkZoneTeamData(self.curTeam, self.TeamDataDic[self.curTeam + 1].guns, self.TeamDataDic[self.curTeam + 1].leader)
  DarkNetCmdTeamData.Teams[self.curTeam].Leader = self.TeamDataDic[self.curTeam + 1].leader
  DarkNetCmdTeamData:SetTeamInfo(data, function()
    if self.curTeam == 0 then
      self.curTeam = GlobalConfig.TeamCount - 1
    else
      self.curTeam = self.curTeam - 1
    end
    for i = 1, #self.TeamObj do
      local sort = self.TeamObj[i]
      if sort.index ~= self.curTeam + 1 then
        sort.txtName.color = self.textcolor.BeforeSelected
        setactive(sort.grpset, false)
      else
        sort.txtName.color = self.textcolor.AfterSelected
        setactive(sort.grpset, true)
      end
    end
    UIDarkZoneTeamModelManager:HideOrShowModel(false)
    UIDarkZoneTeamModelManager.gunlist = self.TeamDataDic[self.curTeam + 1].guns
    self:UpdateTeamList(self.curTeam)
  end)
end
function UIDarkZoneTeamPanel:RightArrow()
  if self.curTeam == GlobalConfig.TeamCount - 1 then
    self.curTeam = 0
  else
    self.curTeam = self.curTeam + 1
  end
  for i = 1, #self.TeamObj do
    local sort = self.TeamObj[i]
    if sort.index ~= self.curTeam + 1 then
      sort.txtName.color = self.textcolor.BeforeSelected
      setactive(sort.grpset, false)
    else
      sort.txtName.color = self.textcolor.AfterSelected
      setactive(sort.grpset, true)
    end
  end
  UIDarkZoneTeamModelManager:HideOrShowModel(false)
  UIDarkZoneTeamModelManager.gunlist = self.TeamDataDic[self.curTeam + 1].guns
  self:UpdateTeamList(self.curTeam)
end
function UIDarkZoneTeamPanel:ShowGunList()
  self.ItemDataList = {}
  local tempbtn
  local orginpos = self.ui.mTrans_List.localPosition
  local TeamData = self.TeamDataDic[self.curTeam + 1]
  for i = 0, TeamData.guns.Count - 1 do
    if TeamData.guns[i] ~= 0 then
      local gunData = NetCmdTeamData:GetGunByID(TeamData.guns[i])
      if gunData ~= nil then
        local InfoData = {}
        InfoData.config = gunData.TabGunData
        if self:CheckFilterCondition(InfoData.config) ~= false then
          InfoData.level = gunData.level
          InfoData.id = gunData.id
          InfoData.curenergy = gunData.DarkZoneEnergy
          InfoData.Power = gunData.Power
          InfoData.maxenergy = TableData.GlobalDarkzoneData.DarkzoneEnergylimit
          InfoData.sign = self:CheckInTeam(gunData.id)
          table.insert(self.ItemDataList, InfoData)
        end
      end
    end
  end
  local gunlist = NetCmdTeamData.GunList
  for i = 0, gunlist.Count - 1 do
    for j = 0, TeamData.guns.Count - 1 do
      if TeamData.guns[j] == gunlist[i].id then
        goto lbl_113
      end
    end
    local InfoData = {}
    InfoData.config = gunlist[i].TabGunData
    if self:CheckFilterCondition(InfoData.config) ~= false then
      InfoData.level = gunlist[i].level
      InfoData.id = gunlist[i].id
      InfoData.Power = gunlist[i].Power
      InfoData.curenergy = gunlist[i].DarkZoneEnergy
      InfoData.maxenergy = TableData.GlobalDarkzoneData.DarkzoneEnergylimit
      InfoData.sign = self:CheckInTeam(gunlist[i].id)
      table.insert(self.ItemDataList, InfoData)
    end
    ::lbl_113::
  end
  self.isOpenGunList = true
  if self.ui.mVirtualListEx.numItems == #self.ItemDataList then
    self.ui.mVirtualListEx:Refresh()
  else
    self.ui.mVirtualListEx.numItems = #self.ItemDataList
  end
  if self.CurFoucs == nil and self.QuicklyTeam ~= true then
    setactive(self.ui.mTrans_NoGun, true)
    setactive(self.ui.mText_GunName.gameObject, false)
  elseif self.CurFoucs ~= nil and self.QuicklyTeam ~= true then
    setactive(self.ui.mTrans_NoGun, false)
    setactive(self.ui.mText_GunName.gameObject, true)
  end
  if self.CurBtn == 1 then
    setactive(self.ui.mTrans_ChrIconMember, false)
    setactive(self.ui.mTrans_ChrIconCaptain, true)
  else
    setactive(self.ui.mTrans_ChrIconMember, true)
    setactive(self.ui.mTrans_ChrIconCaptain, false)
  end
  self.ui.mText_GunIndex.text = tostring(self.CurBtn)
  self.gunListItem:ClickTabCallBack(0)
end
function UIDarkZoneTeamPanel:CheckInTeam(GunId)
  if self.TeamDataDic[self.curTeam + 1] == nil then
    return
  end
  local guns = self.TeamDataDic[self.curTeam + 1].guns
  for i = 0, guns.Count - 1 do
    if GunId == guns[i] then
      return i + 1
    end
  end
  return nil
end
function UIDarkZoneTeamPanel:GunInfo()
  if self.QuicklyTeam == true then
    if self.QuicklyTeamClickGunID == 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903011))
      return
    end
    local GunInfoDialog = CS.RoleInfoCtrlHelper.Instance
    local GunCmdData = NetCmdTeamData:GetGunByID(self.QuicklyTeamClickGunID)
    GunInfoDialog:InitDarkZoneTeamData(GunCmdData, true)
  else
    if self.LookGunId == nil then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903011))
      return
    end
    local GunInfoDialog = CS.RoleInfoCtrlHelper.Instance
    local GunCmdData = NetCmdTeamData:GetGunByID(self.LookGunId)
    GunInfoDialog:InitDarkZoneTeamData(GunCmdData, true)
  end
end
function UIDarkZoneTeamPanel:OnClickGunModel(message)
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Off)
  if self.QuicklyTeam == true then
    return
  end
  if self.IsZoom == true then
    return
  end
  if self.QuicklyTeam ~= nil then
    self.QuicklyTeam = 1
  end
  local num = tonumber(message.Content)
  if num == nil then
    return
  end
  self.LastClickGunId = 0
  self.LastItem = nil
  setactive(self.ui.mTrans_TeamInfo2, false)
  setactive(self.ui.mBtn_Save.gameObject.transform.parent, false)
  setactive(self.ui.mTrans_GrpName.gameObject, true)
  setactive(self.ui.mTrans_NoGun, true)
  setactive(self.ui.mBtn_SecondBack.gameObject, true)
  setactive(self.ui.mBtn_Left.gameObject, false)
  setactive(self.ui.mBtn_Right.gameObject, false)
  self.ClickGunOrAddBtn = true
  self.LookGunId = num
  self.tempId = num
  self.CurFoucs = true
  self.IsZoom = true
  local index = -1
  local modellist = UIDarkZoneTeamModelManager.CachesList
  for i = 0, modellist.Count - 1 do
    if modellist[i].tableId == num then
      index = modellist[i].Index
      self.CurBtn = index + 1
    else
      modellist[i]:Show(false)
    end
  end
  self.FocusModel = UIDarkZoneTeamModelManager:GetCaCheModel(num)
  local cameraRoot = self.FocusModel.gameObject.transform:Find("CameraPointDzTeam")
  if cameraRoot == nil then
    cameraRoot = self.FocusModel.gameObject.transform:Find("CameraPoint")
  end
  local cine = self.CMModel:GetComponent("CinemachineVirtualCamera")
  cine.Follow = cameraRoot
  cine.LookAt = cameraRoot
  setactive(self.CMModel, true)
  setactive(self.CMEmpty, false)
  setactive(self.CMTeam, false)
  setactive(self.ui.mText_GunName.gameObject, true)
  setactive(self.ui.mTrans_ChrGrpIcon, true)
  local gunname = NetCmdTeamData:GetGunByID(num).TabGunData.Name.str
  self.ui.mText_GunName.text = gunname
  self:PlayAnim(true)
  self:PlayAnim(true)
  self:ShowGunList()
end
function UIDarkZoneTeamPanel:PlayAnimForQuicklyTeam(bool)
  if bool then
    setactive(self.ui.mBtn_BgClose.gameObject, true)
  else
    self.tempId = nil
    self.IsDefaultChose = false
    self.IsInCardList = false
    self.ui.mAnim_ChrList:SetTrigger("FadeOut")
    setactive(self.ui.mBtn_Left.gameObject, true)
    setactive(self.ui.mBtn_Right.gameObject, true)
    TimerSys:DelayCall(0.53, function()
      setactive(self.ui.mAnim_Fleet.gameObject, not bool)
      setactive(self.ui.mAnim_ChrList.gameObject, bool)
      setactive(self.ui.mBtn_BgClose.gameObject, false)
      setactive(self.ui.mTrans_GrpName.gameObject, true)
    end)
  end
  if bool then
    self:CheckBtnState()
  end
end
function UIDarkZoneTeamPanel:PlayAnim(bool)
  if bool then
    self.IsDefaultChose = true
    self.IsInCardList = true
    self.ui.mAnim_Fleet:SetTrigger("FadeOut")
    for i = 0, self.ui.mTrans_Add.childCount - 1 do
      setactive(self.ui.mTrans_Add:GetChild(i), false)
    end
    self:DelayCall(self.TeamToModelAnimTime - 0.2, function()
      setactive(self.ui.mAnim_Fleet.gameObject, not bool)
      setactive(self.ui.mAnim_ChrList.gameObject, bool)
    end)
    self:DelayCall(self.TeamToModelAnimTime, function()
      setactive(self.ui.mBtn_BgClose.gameObject, bool)
    end)
  else
    self.tempId = nil
    self.IsDefaultChose = false
    self.IsInCardList = false
    self.ui.mAnim_ChrList:SetTrigger("FadeOut")
    TimerSys:DelayCall(0.33, function()
      setactive(self.ui.mAnim_ChrList.gameObject, bool)
    end)
    for k, v in pairs(self.HPPointDic) do
      setactive(self.ui.mTrans_Add:GetChild(k), false)
    end
    TimerSys:DelayCall(self.TeamToModelAnimTime, function()
      setactive(self.ui.mAnim_Fleet.gameObject, not bool)
      for i = 0, self.ui.mTrans_Add.childCount - 1 do
        setactive(self.ui.mTrans_Add:GetChild(i), true)
      end
      self.IsZoom = false
    end)
    setactive(self.ui.mBtn_BgClose.gameObject, bool)
  end
  if bool then
    self:CheckBtnState()
  end
end
function UIDarkZoneTeamPanel:OpenGunListFilter()
  if self.GunListFilter == nil or CS.LuaUtils.IsNullOrDestroyed(self.GunListFilter) then
    local obj = ResSys:GetUIRes("Combat/CombatChrScreenDialogV2.prefab", true)
    obj.transform:SetParent(self.ui.mTrans_Root, false)
    self.GunListFilter = GunListFilter.Get(obj, function()
      self:ShowGunList()
    end)
  else
    setactive(self.GunListFilter.gameObject, not self.GunListFilter.gameObject.activeSelf)
  end
end
function UIDarkZoneTeamPanel:CheckFilterCondition(data)
  return self.GunListFilter == nil or CS.LuaUtils.IsNullOrDestroyed(self.GunListFilter) or self:CheckRank(data.rank) and self:CheckDuty(data.duty) and self:CheckElement(data.attack_type)
end
function UIDarkZoneTeamPanel:CheckRank(rank)
  return GunListFilter.CheckRank(rank)
end
function UIDarkZoneTeamPanel:CheckDuty(duty)
  return GunListFilter.CheckDuty(duty)
end
function UIDarkZoneTeamPanel:CheckElement(element)
  return GunListFilter.CheckElement(element)
end
function UIDarkZoneTeamPanel:CheckGunIDHasInTeam(gunID, needExceptID)
  local exceptID = -1
  if needExceptID then
    exceptID = self.tempId
  end
  local twoCharId = TableData.listGunDatas:GetDataById(gunID).character_id
  for i = 0, DarkNetCmdTeamData.QuicklyTeamList.Count - 1 do
    local gunId = DarkNetCmdTeamData.QuicklyTeamList[i]
    if gunId ~= 0 and gunId ~= exceptID then
      local charId = TableData.listGunDatas:GetDataById(gunId).character_id
      if charId == twoCharId and DarkNetCmdTeamData.QuicklyTeamList[i] ~= gunID then
        return true
      end
    end
  end
  return false
end
function UIDarkZoneTeamPanel:CalcGunPower(guns)
  local power = 0
  for i = 0, guns.Count - 1 do
    if guns[i] ~= 0 then
      power = power + NetCmdTeamData:GetGunFightingCapacityByID(guns[i])
    end
  end
  return power
end
function UIDarkZoneTeamPanel:UpdateModel(GunId, Index, FocusModel)
  local Tabledata = TableData.listGunDatas:GetDataById(GunId)
  local GunCmdData = NetCmdTeamData:GetGunByID(GunId)
  local modelId = GunId
  local weaponModelId = GunCmdData.WeaponData ~= nil and GunCmdData.WeaponData.stc_id or Tabledata.weapon_default or Tabledata.weapon_default
  if UIDarkZoneTeamModelManager:IsCacheLoadedContains(modelId) >= 0 then
    local model = UIDarkZoneTeamModelManager:GetCaCheModel(modelId)
    model.Index = Index
    if self.FocusModel ~= nil then
      self.FocusModel:Show(false)
    end
    if FocusModel then
      self.FocusModel = model
    end
    self:SetGunModel(model)
    return
  end
  UIUtils.GetDarkZoneTeamUIModelAsyn(modelId, weaponModelId, Index, function(go)
    self:UpdateModelCallback(go)
    if FocusModel then
      if self.FocusModel ~= nil then
        self.FocusModel:Show(false)
      end
      self.FocusModel = go
    end
  end)
end
function UIDarkZoneTeamPanel:UpdateModelCallback(obj)
  obj.transform.parent = nil
  obj.transform.position = Vector3(0, 0, 0)
  if obj ~= nil and obj.gameObject ~= nil then
    obj.transform.localEulerAngles = Vector3(0, 180, 0)
    GFUtils.MoveToLayer(obj.transform, CS.UnityEngine.LayerMask.NameToLayer("Friend"))
    obj.transform.localScale = Vector3(0.96, 0.96, 0.96)
    self:SetGunModel(obj)
  end
end
function UIDarkZoneTeamPanel:SetGunModel(model)
  if self.IsInCardList == true then
    local cameraRoot = model.gameObject.transform:Find("CameraPointDzTeam")
    if cameraRoot == nil then
      cameraRoot = model.gameObject.transform:Find("CameraPoint")
    end
    local cine = self.CMModel:GetComponent("CinemachineVirtualCamera")
    cine.Follow = cameraRoot
    cine.LookAt = cameraRoot
    setactive(self.CMEmpty, false)
    setactive(self.CMModel, true)
    setactive(self.CMTeam, false)
  end
  local hppos = model.gameObject.transform:Find("HPPoint").position
  self:SetModelPos(model, model.Index)
  self.HPPointDic[model.Index] = hppos
  model:Show(true)
end
function UIDarkZoneTeamPanel:GetWorldPosByUIPos(trans)
  local v = CS.UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uiCamera, trans.position)
  local v1 = Vector3(v.x, v.y, 3.957)
  local worldPos = self.Camera:ScreenToWorldPoint(v1)
  return worldPos
end
function UIDarkZoneTeamPanel:SetModelPos(model, index)
  local temp = self.ui.mTrans_Add:GetChild(index)
  local offset = TableData.listModelConfigDatas:GetDataById(model.modelConfig.Id).Darkzone
  local y = offset[1]
  local x = offset[0]
  if self.modelPosDic[index] == nil then
    local w = self:GetWorldPosByUIPos(temp)
    self.modelPosDic[index] = w.x
  end
  model.transform.position = Vector3(self.modelPosDic[index] + x, y, 4.957)
end
function UIDarkZoneTeamPanel:SetModelDicPos(index)
  local temp = self.ui.mTrans_Add:GetChild(index)
  if self.modelPosDic[index] == nil then
    local w = self:GetWorldPosByUIPos(temp)
    self.modelPosDic[index] = w.x
  end
end
function UIDarkZoneTeamPanel:OpenRepository()
  self.FadeOutTime = self.mCSPanel.FadeOutTime
  self.mCSPanel.FadeOutTime = 0.1
  UIManager.OpenUI(UIDef.UIDarkZoneRepositoryPanel)
end
function UIDarkZoneTeamPanel:SetEquipedList()
  self.equippedDict = DarkZoneNetRepoCmdData.EquippedDict
  local lightLv = 0
  for i = 1, 7 do
    local item
    if self.equippedItem[i] == nil then
      item = UIDarkZoneComEquipItem.New()
      item:InitCtrl(self.ui.mTrans_GrpItem)
      item:SetEquipTypeBg(i)
      self.equippedItem[i] = item
    else
      item = self.equippedItem[i]
    end
    if self.equippedDict:ContainsKey(i) then
      local equipData = self.equippedDict[i]
      item:SetDarkZoneEquipData(equipData, i)
      setactive(item.mUIRoot, true)
      if i == 7 then
        item.ui.mText_EquipLightNum.text = "+" .. self.equippedDict[i].lightLv
        item.ui.mText_EquipLightNum.color = CS.GF2.UI.UITool.StringToColor("DF9E00")
      else
        lightLv = lightLv + equipData.lightLv
      end
    elseif self.equippedItem[i] ~= nil then
      self.equippedItem[i]:RemoveDarkZoneEquip()
    end
    if i == 6 then
      lightLv = lightLv // 6
    end
    if i == 7 and self.equippedDict:ContainsKey(i) then
      lightLv = lightLv + self.equippedDict[i].lightLv
    end
    item:SetRedDot(DarkZoneNetRepoCmdData:HasValidEquip(i))
  end
  self.ui.mText_PowerNum.text = tostring(lightLv)
  self.ui.mText_PowerNum2.text = tostring(lightLv)
end
function UIDarkZoneTeamPanel:GunItemProvider()
  local itemView = DarkZoneTeamItem.New()
  itemView:InitCtrl(self.gunListItem.GunList.content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneTeamPanel:GunItemRenderer(index, renderData)
  local data = self.showItemDataList[index + 1]
  local item = renderData.data
  item:SetTable(self)
  item:SetData(data, index)
  if self.IsDefaultChose == true and data.id == self.tempId then
    item:OnClickGunCard()
    self.IsDefaultChose = false
  end
end
function UIDarkZoneTeamPanel:ReFreshListByDutyID(dutyID)
  self.showItemDataList = {}
  for _, v in ipairs(self.ItemDataList) do
    local tData = v.config
    if dutyID == 0 or tData.duty == dutyID then
      table.insert(self.showItemDataList, v)
    end
  end
  if self.gunListItem.GunList.numItems == #self.showItemDataList then
    self.gunListItem.GunList:Refresh()
  else
    self.gunListItem.GunList.numItems = #self.showItemDataList
  end
end
