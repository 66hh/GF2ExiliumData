UIWeaponPartPanel = class("UIWeaponPartPanel", UIBasePanel)
local self = UIWeaponPartPanel
function UIWeaponPartPanel:OnInit(root, data)
  self:SetRoot(root)
  self.mView = {}
  self:LuaUIBindTable(root, self.mView)
  local partId = data[1]
  local type = data[2]
  local needModel = data[3]
  self.gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(partId)
  self.curType = type or 0
  self.needModel = needModel
  self.tabList = {}
  self.partInfoContent = nil
  self.enhanceContent = nil
  self.costItem = nil
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:onClickClose()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CommandCenter.gameObject).onClick = function()
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
    UIManager.JumpToMainPanel()
  end
  function self.tempWeaponToucherBlendFinishCallback()
    self:onWeaponToucherBlendFinish()
  end
  if self.needModel then
    UIManager.EnableFacilityBarrack(true)
  end
  self:InitTabBtn()
end
function UIWeaponPartPanel:OnShowStart()
  if self.curType ~= 0 then
    self:UpdateTab(self.curType)
  else
    self:UpdateTab(UIWeaponGlobal.WeaponPartPanelTab.Info)
  end
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.WeaponToucher):FinishCallback("+", self.tempWeaponToucherBlendFinishCallback)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.WeaponToucher, false)
  self:UpdateWeaponInfo()
end
function UIWeaponPartPanel:OnHideFinish()
  UIWeaponGlobal:EnableWeaponModel(true)
end
function UIWeaponPartPanel:OnClose()
  for _, tabItem in pairs(self.tabList) do
    if tabItem then
      tabItem:OnRelease()
    end
  end
  self.tabList = {}
  if self.partInfoContent then
    self.partInfoContent:OnClose()
  end
  if self.enhanceContent then
    self.enhanceContent:OnClose()
  end
  self.partInfoContent = nil
  self.enhanceContent = nil
  self.curType = 1
  self.mView = nil
end
function UIWeaponPartPanel:onClickClose()
  setactive(self.mView.mImage_Icon.gameObject, false)
  UIWeaponGlobal:EnableWeaponModel(true)
  UIManager.CloseUI(UIDef.UIWeaponPartPanel)
  setactive(self.mView.mImage_Icon.gameObject, false)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.WeaponToucher):FinishCallback("-", self.tempWeaponToucherBlendFinishCallback)
  self.gunWeaponModData = nil
  self.curType = 0
  self.costItem = nil
  if self.needModel then
  end
  self.needModel = nil
end
function UIWeaponPartPanel:InitTabBtn()
  for i = 1, 2 do
    do
      local item = UIBarrackCommonTabItem.New()
      item:InitCtrl(self.mView.mTrans_TabList, true)
      item.tagId = i
      item.hintId = item:SetNameByHint(UIWeaponGlobal.WeaponPartTabHint[i])
      UIUtils.GetButtonListener(item.mBtn_ClickTab.gameObject).onClick = function()
        self:OnClickTab(item.tagId)
      end
      self.tabList[i] = item
    end
  end
end
function UIWeaponPartPanel:RefreshPanel()
  self:UpdateTab(self.curType)
end
function UIWeaponPartPanel:OnClickTab(id)
  if self.curType == id or id == nil or id <= 0 then
    return
  end
  self:UpdateTab(id)
end
function UIWeaponPartPanel:UpdateTab(id)
  if self.curType > 0 then
    local lastTab = self.tabList[self.curType]
    lastTab:SetItemState(false)
  end
  local curTab = self.tabList[id]
  curTab:SetItemState(true)
  self.curType = id
  self:UpdatePanelByType(id)
end
function UIWeaponPartPanel:UpdatePanelByType(type)
  if type == UIWeaponGlobal.WeaponPartPanelTab.Info then
    self:UpdateWeaponPartDetail()
  elseif type == UIWeaponGlobal.WeaponPartPanelTab.Enhance then
    self:UpdateEnhanceContent()
  end
  setactive(self.mView.mTrans_Detail, type == UIWeaponGlobal.WeaponPartPanelTab.Info)
  setactive(self.mView.mTrans_Enhance, type == UIWeaponGlobal.WeaponPartPanelTab.Enhance)
end
function UIWeaponPartPanel:UpdateWeaponPartDetail()
  if self.partInfoContent == nil then
    self.partInfoContent = UIBarrackWeaponPartInfoItem.New()
    self.partInfoContent:InitCtrl(self.mView.mTrans_PartInfo)
  end
  self.partInfoContent:SetData(self.gunWeaponModData)
  self.partInfoContent:SetWeaponPartsInfoVisible(true)
  local text = TableData.GetHintById(40014)
  local typeData = TableData.listWeaponModTypeDatas:GetDataById(self.gunWeaponModData.type)
  if typeData.weapon_mod_des ~= nil and typeData.weapon_mod_des.str ~= "" then
    text = text .. typeData.weapon_mod_des.str
  else
    for i = 0, typeData.weapon_id.Count - 1 do
      local weaponType = TableData.listGunWeaponDatas:GetDataById(typeData.weapon_id[i])
      if i < typeData.weapon_id.Count - 1 then
        text = text .. weaponType.name.str .. "/"
      else
        text = text .. weaponType.name.str
      end
    end
  end
  self.mView.mText_EquipWeapon.text = text
end
function UIWeaponPartPanel:UpdateWeaponInfo()
  if self.gunWeaponModData == nil then
    return
  end
  local icon = string.gsub(self.gunWeaponModData.icon, "_256", "_512")
  setactive(self.mView.mImage_Icon.gameObject, true)
  self.mView.mImage_Icon.sprite = IconUtils.GetWeaponPartIcon(icon)
  setactive(self.mView.mTrans_Weapon, self.gunWeaponModData.equipWeapon ~= 0)
end
function UIWeaponPartPanel:UpdateEnhanceContent()
  if self.enhanceContent == nil then
    self.enhanceContent = UIWeaponPartEnhanceContent.New(self)
    self.enhanceContent:InitCtrl(self.mView.mTrans_Enhance, self.mView.mTrans_PartList)
  end
  self.enhanceContent:SetData(self.gunWeaponModData)
end
function UIWeaponPartPanel:onWeaponToucherBlendFinish()
  self:UpdateWeaponInfo()
end
