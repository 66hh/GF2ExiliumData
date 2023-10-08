require("UI.FacilityBarrackPanel.Item.ChrBarrackSkillItem")
require("UI.Repository.Item.UIRepositoryLeftTab2ItemV3")
require("UI.BattlePass.Item.BpCollectGunItem")
require("UI.BattlePass.Item.BpCollectWeaponItem")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.WeaponPanel.UIWeaponGlobal")
require("UI.WeaponPanel.UIWeaponPanel")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UICollectionPanel = class("UICollectionPanel", UIBaseCtrl)
UICollectionPanel.__index = UICollectionPanel
function UICollectionPanel:ctor()
  self.itemList = {}
end
function UICollectionPanel:__InitCtrl()
end
function UICollectionPanel:InitCtrl(prefab, parent)
  self.obj = instantiate(prefab, parent)
  CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject)
  self:SetRoot(self.obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:__InitCtrl()
  self.mGunCollectItems = {}
  self.mWeaponCollectItems = {}
  self.skillList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.transform).onClick = function()
    if self.mStoreGoodData.Itemtype == GlobalConfig.ItemType.GunType and self.mGunCmdData ~= nil then
      local parm = {}
      parm[1] = self.mGunCmdData
      parm[2] = FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
      UIManager.OpenUIByParam(UIDef.UIChrPowerUpPanel, parm)
      BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Base, false, self.mGunCmdData.id)
      TimerSys:DelayCall(0.5, function()
        UIManager.EnableBattlePass(false)
      end)
    elseif self.mStoreGoodData.Itemtype == GlobalConfig.ItemType.Weapon and self.weaponCmdData ~= nil then
      local param = {
        self.weaponCmdData.stc_id,
        UIWeaponGlobal.WeaponPanelTab.Info,
        true,
        UIWeaponPanel.OpenFromType.BattlePassCollection,
        needReplaceBtn = false
      }
      UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
      TimerSys:DelayCall(0.5, function()
        UIManager.EnableBattlePass(false)
      end)
    end
    TimerSys:DelayCall(0.5, function()
      if self.mModel ~= nil then
        self.mModel:Show(false)
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.transform).onClick = function()
    local costItemNum = NetCmdItemData:GetItemCountById(self.mStoreGoodData.price_type)
    if costItemNum < self.mStoreGoodData.price then
      local itemData = TableData.GetItemData(self.mStoreGoodData.price_type)
      local hint = TableData.GetHintById(225)
      CS.PopupMessageManager.PopupString(string_format(hint, itemData.name))
      return
    end
    if self.mStoreGoodData.Itemtype == GlobalConfig.ItemType.GunType and self.mGunCmdData ~= nil then
      NetCmdStoreData:SendStoreBuy(self.mStoreGoodData.id, 1, function(ret)
        if ret == ErrorCodeSuc then
          local data = {}
          data.ItemId = self.mGunCmdData.id
          UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
          MessageSys:SendMessage(UIEvent.BpResfresh, nil)
          self:ShowGun(self.mStoreGoodData.Frame)
          for _, v in pairs(self.mGunCollectItems) do
            v:Refresh()
          end
        end
      end)
    elseif self.mStoreGoodData.Itemtype == GlobalConfig.ItemType.Weapon and self.weaponCmdData ~= nil then
      NetCmdStoreData:SendStoreBuy(self.mStoreGoodData.id, 1, function(ret)
        if ret == ErrorCodeSuc then
          local hint = TableData.GetHintById(106013)
          UIManager.OpenUIByParam(UIDef.UICommonReceivePanel)
          MessageSys:SendMessage(UIEvent.BpResfresh, nil)
          self:ShowWeapon(self.mStoreGoodData.Frame)
          for _, v in pairs(self.mWeaponCollectItems) do
            v:Refresh()
          end
        end
      end)
    end
  end
  self.mTabBtns = {}
  self.mGunTabBtn = UIRepositoryLeftTab2ItemV3.New()
  self.mGunTabBtn:InitCtrl(self.ui.mSListChild_GrpTabBtnList.transform)
  self.mGunTabBtn:SetName(UIBattlePassGlobal.BpCollectionTabId.Gun, TableData.GetHintById(1004))
  self.mGunTabBtn:SetCallBack(function(tempItem)
    self:OnTabBtnClick(tempItem)
  end)
  table.insert(self.mTabBtns, self.mGunTabBtn)
  self.mWeaponTabBtn = UIRepositoryLeftTab2ItemV3.New()
  self.mWeaponTabBtn:InitCtrl(self.ui.mSListChild_GrpTabBtnList.transform)
  self.mWeaponTabBtn:SetName(UIBattlePassGlobal.BpCollectionTabId.Weapon, TableData.GetHintById(1008))
  self.mWeaponTabBtn:SetCallBack(function(tempItem)
    self:OnTabBtnClick(tempItem)
  end)
  table.insert(self.mTabBtns, self.mWeaponTabBtn)
  self:SetData()
  setactive(self.mGunTabBtn:GetRoot(), #self.mGunCollectItems ~= 0)
  setactive(self.mWeaponTabBtn:GetRoot(), #self.mWeaponCollectItems ~= 0)
end
function UICollectionPanel:SetData()
  local bpSeasonDatas = TableData.listBpSeasonDatas:GetList()
  local gunIndex = 1
  local weaponIndex = 1
  for i = 0, bpSeasonDatas.Count - 1 do
    local tempSeasonData = bpSeasonDatas[i]
    if tempSeasonData.Id < NetCmdBattlePassData.CurSeason.Id then
      local storeGoodData = TableData.listStoreGoodDatas:GetDataById(tempSeasonData.MaxReward)
      if storeGoodData ~= nil and storeGoodData.Itemtype == GlobalConfig.ItemType.GunType then
        local bpCollectGunItem = self.mGunCollectItems[gunIndex]
        if bpCollectGunItem == nil then
          bpCollectGunItem = BpCollectGunItem.New(self.ui.mSListChild_Content.transform)
          table.insert(self.mGunCollectItems, bpCollectGunItem)
        end
        bpCollectGunItem:InitByGunCmdData(tempSeasonData.MaxReward)
        bpCollectGunItem:AddBtnClickListener(function()
          self.mStoreId = storeGoodData.id
          self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(self.mStoreId, true)
          self:ShowGun(self.mStoreGoodData.Frame)
        end)
        gunIndex = gunIndex + 1
      end
      if storeGoodData ~= nil and storeGoodData.Itemtype == GlobalConfig.ItemType.Weapon then
        do
          local bpCollectWeaponItem = self.mWeaponCollectItems[weaponIndex]
          if bpCollectWeaponItem == nil then
            bpCollectWeaponItem = BpCollectWeaponItem.New()
            bpCollectWeaponItem:InitCtrl(self.ui.mSListChild_Content1.transform)
            table.insert(self.mWeaponCollectItems, bpCollectWeaponItem)
          end
          bpCollectWeaponItem:SetData(tempSeasonData.MaxReward, function()
            self.mStoreId = storeGoodData.id
            self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(self.mStoreId, true)
            self:ShowWeapon(self.mStoreGoodData.Frame)
          end)
          weaponIndex = weaponIndex + 1
        end
      end
    end
  end
end
function UICollectionPanel:GetCollectNum()
  return #self.mWeaponCollectItems + #self.mGunCollectItems
end
function UICollectionPanel:OnTabBtnClick(tempItem)
  self.mCurTabBtn = tempItem
  for _, v in pairs(self.mTabBtns) do
    v:SetItemState(false)
  end
  tempItem:SetItemState(true)
  if tempItem.tagId == UIBattlePassGlobal.BpCollectionTabId.Gun then
    setactive(self.ui.mTrans_GunItemsRoot, true)
    setactive(self.ui.mTrans_WeaponItemsRoot, false)
    setactive(self.ui.mSListChild_Content, false)
    setactive(self.ui.mSListChild_Content, true)
    self.mStoreId = self.mGunCollectItems[1].mStoreId
    self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(self.mStoreId, true)
    self:ShowGun(self.mStoreGoodData.Frame)
  elseif tempItem.tagId == UIBattlePassGlobal.BpCollectionTabId.Weapon then
    setactive(self.ui.mTrans_GunItemsRoot, false)
    setactive(self.ui.mTrans_WeaponItemsRoot, true)
    setactive(self.ui.mSListChild_Content1, false)
    setactive(self.ui.mSListChild_Content1, true)
    self.mStoreId = self.mWeaponCollectItems[1].mStoreId
    self.mStoreGoodData = TableData.listStoreGoodDatas:GetDataById(self.mStoreId, true)
    self:ShowWeapon(self.mStoreGoodData.Frame)
  end
end
function UICollectionPanel:Show()
  self.mTabBtns[UIBattlePassGlobal.BpCollectionTabId.Gun]:SetItemState(true)
  if self.mCurTabBtn ~= nil then
    self:OnTabBtnClick(self.mCurTabBtn)
  elseif #self.mGunCollectItems ~= 0 then
    self:OnTabBtnClick(self.mGunTabBtn)
  elseif #self.mWeaponCollectItems ~= 0 then
    self:OnTabBtnClick(self.mWeaponTabBtn)
  end
  if self.mGunCollectItems ~= nil then
    for i, v in pairs(self.mGunCollectItems) do
      v:Refresh()
    end
  end
  if self.mWeaponCollectItems ~= nil then
    for i, v in pairs(self.mWeaponCollectItems) do
      v:Refresh()
    end
  end
end
function UICollectionPanel:OnRefresh()
  if self.mModel ~= nil then
    self.mModel:Show(true)
  end
end
function UICollectionPanel:OnBackFrom()
end
function UICollectionPanel:ShowGun(gunId)
  for i, v in pairs(self.mGunCollectItems) do
    if v.mStoreId == self.mStoreId then
      v.ui.mBtn_Self.interactable = false
    else
      v.ui.mBtn_Self.interactable = true
    end
  end
  setactive(self.ui.mTrans_GunInfo, true)
  setactive(self.ui.mTrans_WeaponInfo, false)
  self.mGunCmdData = NetCmdTeamData:GetLockGunData(gunId, true)
  if self.mGunCmdData == nil then
    return
  end
  local dutyData = TableData.listGunDutyDatas:GetDataById(self.mGunCmdData.TabGunData.duty)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeWhiteIcon(dutyData.icon)
  self.ui.mText_ChrName.text = self.mGunCmdData.TabGunData.name.str
  self.ui.mText_Quality.text = TableData.GetHintById(80042 + self.mGunCmdData.TabGunData.rank)
  self.ui.mText_Quality.color = TableData.GetGlobalGun_Quality_Color2(self.mGunCmdData.TabGunData.rank, self.ui.mText_Quality.color.a)
  self.ui.mImg_Line.color = TableData.GetGlobalGun_Quality_Color2(self.mGunCmdData.TabGunData.rank, self.ui.mImg_Line.color.a)
  self.ui.mText_Name.text = TableData.listGunDutyDatas:GetDataById(self.mGunCmdData.TabGunData.duty).name.str
  self:InitSkillList()
  self.mIsLock = NetCmdTeamData:GetGunByStcId(gunId) == nil
  setactive(self.ui.mTrans_GrpBuy, self.mIsLock)
  setactive(self.ui.mTrans_Collected, not self.mIsLock)
  for i, v in pairs(UIBattlePassGlobal.ModelList) do
    v:Show(false)
  end
  if UIBattlePassGlobal.ModelList[gunId] == nil then
    CS.UIBattlePassGunModelManager.Instance:GetBattlePassGunModel(gunId, gunId, true, function(model)
      self.mModel = model
      UIBattlePassGlobal.ModelList[gunId] = model
      self:SetGunAndLightPos(true)
      if UIBattlePassGlobal.TabIndx ~= UIBattlePassGlobal.ButtonType.Collection then
        model:Show(false)
      end
    end, false)
  else
    self.mModel = UIBattlePassGlobal.ModelList[gunId]
    self.mModel:Show(true)
    self:SetGunAndLightPos(true)
  end
  local stcData = TableData.GetItemData(self.mStoreGoodData.price_type)
  self.ui.mImg_Item.sprite = IconUtils.GetItemIcon(stcData.icon)
  self.ui.mText_Num.text = FormatNum(self.mStoreGoodData.price)
  local costItemNum = NetCmdItemData:GetItemCountById(stcData.Id)
  self.ui.mText_Num.color = costItemNum < self.mStoreGoodData.price and ColorUtils.RedColor or ColorUtils.WhiteColor
end
function UICollectionPanel:InitSkillList()
  for i = 1, 5 do
    local skillItem = self.skillList[i]
    if skillItem == nil then
      local skillItem = ChrBarrackSkillItem.New()
      skillItem:InitCtrl(self.ui.mSListChild_Content2.transform)
      table.insert(self.skillList, skillItem)
    end
  end
  if self.skillList then
    local data = self.mGunCmdData.CurAbbr
    for i = 0, data.Count - 1 do
      do
        local skill = self.skillList[i + 1]
        local battleSkillData = TableData.listBattleSkillDatas:GetDataById(data[i])
        local onClickSkill = function()
          UIManager.OpenUIByParam(UIDef.UIChrSkillInfoDialog, {
            skillData = battleSkillData,
            gunCmdData = self.mGunCmdData,
            isGunLock = self.mIsLock,
            showBottomBtn = false,
            showTag = 2
          })
        end
        skill:SetData(data[i], onClickSkill)
      end
    end
  end
  setactive(self.ui.mSListChild_Content2, false)
  setactive(self.ui.mSListChild_Content2, true)
end
function UICollectionPanel:ShowWeapon(weaponId)
  for i, v in pairs(self.mWeaponCollectItems) do
    if v.mStoreId == self.mStoreId then
      v.ui.mBtn_ChrWeaponListItemV3.interactable = false
    else
      v.ui.mBtn_ChrWeaponListItemV3.interactable = true
    end
  end
  setactive(self.ui.mTrans_GunInfo, false)
  setactive(self.ui.mTrans_WeaponInfo, true)
  self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponId)
  self.ui.mText_Name1.text = self.weaponCmdData.Name
  self.ui.mText_WeaponType.text = self.weaponCmdData.Name
  local weaponTypeData = TableData.listGunWeaponTypeDatas:GetDataById(self.weaponCmdData.Type)
  self.ui.mText_WeaponType.text = weaponTypeData.Name.str
  local skillData = self.weaponCmdData.Skill
  if skillData then
    self.ui.mText_SkillName.text = skillData.name.str
    self.ui.mText_WeaponDes.text = skillData.description.str
    self.ui.mText_Lv.text = GlobalConfig.SetLvText(skillData.Level)
  end
  local isLocked = NetCmdWeaponData:GetWeaponListByStcId(self.weaponCmdData.stc_id).Count == 0
  setactive(self.ui.mTrans_GrpBuy, isLocked)
  setactive(self.ui.mTrans_Collected, not isLocked)
  for i, v in pairs(UIBattlePassGlobal.ModelList) do
    v:Show(false)
  end
  if UIBattlePassGlobal.ModelList[weaponId] == nil then
    CS.UIBattlePassGunModelManager.Instance:GetBattlePassWeaponModel(weaponId, true, function(model)
      self.mModel = model
      self:SetGunAndLightPos(false)
      UIBattlePassGlobal.ModelList[weaponId] = model
      if UIBattlePassGlobal.TabIndx ~= UIBattlePassGlobal.ButtonType.Collection then
        model:Show(false)
      end
    end, false)
  else
    self.mModel = UIBattlePassGlobal.ModelList[weaponId]
    self:SetGunAndLightPos(false)
    self.mModel:Show(true)
  end
  local stcData = TableData.GetItemData(self.mStoreGoodData.price_type)
  self.ui.mImg_Item.sprite = IconUtils.GetItemIcon(stcData.icon)
  self.ui.mText_Num.text = FormatNum(self.mStoreGoodData.price)
  local costItemNum = NetCmdItemData:GetItemCountById(stcData.Id)
  self.ui.mText_Num.color = costItemNum < self.mStoreGoodData.price and ColorUtils.RedColor or ColorUtils.WhiteColor
end
function UICollectionPanel:SetGunAndLightPos(isGun)
  CS.LuaUIUtils.SetParent(self.mModel.gameObject, UIBattlePassGlobal.ModelRoot.gameObject, true)
  local bpRewardShow = TableData.listBpRerardShowDatas:GetDataById(self.mStoreGoodData.id)
  if bpRewardShow ~= nil then
    local pos = string.split(bpRewardShow.position2, ",")
    local rotation = string.split(bpRewardShow.rotation2, ",")
    setposition(self.mModel.transform, Vector3(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3])))
    setrotation(self.mModel.transform, CS.UnityEngine.Quaternion.Euler(Vector3(tonumber(rotation[1]), tonumber(rotation[2]), tonumber(rotation[3]))))
    local canvas = UISystem.BpCharacterCanvas
    local bpLight = canvas:GetComponent(typeof(CS.BPLight))
    if bpLight ~= nil then
      bpLight:SetGun(isGun)
      local light_rocation = string.split(bpRewardShow.light_rocation2, ",")
      bpLight:SetRation(tonumber(light_rocation[1]), tonumber(light_rocation[2]), tonumber(light_rocation[3]))
      bpLight:SetLightColAnIntensity(bpRewardShow.light_colour2, bpRewardShow.light_intensity2)
    end
  end
  if self.mModel ~= nil then
    self.mModel:PlayEffect()
  end
end
function UICollectionPanel:OnUpdate()
end
function UICollectionPanel:Hide()
  if self.mModel ~= nil then
    self.mModel:Show(false)
  end
end
function UICollectionPanel:Release()
  gfdestroy(self.obj)
  for i, v in pairs(UIBattlePassGlobal.ModelList) do
    v:Destroy()
  end
  UIBattlePassGlobal.ModelList = {}
  for _, item in pairs(self.mGunCollectItems) do
    item:OnRelease()
  end
  for _, item in pairs(self.mWeaponCollectItems) do
    gfdestroy(item:GetRoot())
  end
end
