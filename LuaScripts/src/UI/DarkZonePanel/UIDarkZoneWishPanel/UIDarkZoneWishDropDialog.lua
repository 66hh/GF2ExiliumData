require("UI.Common.UICommonSimpleView")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishDropItem")
require("UI.UIBasePanel")
UIDarkZoneWishDropDialog = class("UIDarkZoneWishDropDialog", UIBasePanel)
UIDarkZoneWishDropDialog.__index = UIDarkZoneWishDropDialog
function UIDarkZoneWishDropDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneWishDropDialog:OnInit(root, data)
  self:SetRoot(root)
  self.callback = data.callback
  self.dataList = data.dropData
  self.selectItemList = data.dataList
  self.needWish = data.needWish
  self.limitTime = data.limitTime
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self.ui.mText_Title.text = TableData.GetHintById(240082)
  if self.limitTime then
    self.ui.mUICountdown_TitleText:SetHitID(240080)
    self.ui.mUICountdown_TitleText:SetShowType(1)
    self.ui.mUICountdown_TitleText:StartCountdown(self.limitTime)
    self.ui.mUICountdown_TitleText:AddFinishCallback(function(suc)
      self:CloseFunction()
    end)
  end
  self.ui.mUICountdown_TitleText.enabled = self.limitTime ~= nil
  self:UpdateData()
end
function UIDarkZoneWishDropDialog:CloseFunction()
  UIManager.CloseUISelf(self)
end
function UIDarkZoneWishDropDialog:OnClose()
  if self.limitTime then
    self.ui.mUICountdown_TitleText:CleanFinishCallback()
  end
  self.ui = nil
  self.mView = nil
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
  self.callback = nil
  self.dataList = nil
  self.selectItemList = nil
  self.needWish = nil
  self.limitTime = nil
end
function UIDarkZoneWishDropDialog:InitBaseData()
  self.mView = UICommonSimpleView.New()
  self.ui = {}
  self.itemList = {}
end
function UIDarkZoneWishDropDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
end
function UIDarkZoneWishDropDialog:UpdateData()
  local weaponTypeData = {}
  local d = self.dataList
  local strs = string.split(d, ":")
  for j = 1, #strs do
    local drop = strs[j]
    local ss = string.split(drop, "|")
    local weaponModId = tonumber(ss[1])
    local weaponModData = TableData.listWeaponModDatas:GetDataById(weaponModId)
    local t = {}
    t.showNum = tonumber(ss[2])
    t.tbData = weaponModData
    if weaponTypeData[weaponModData.rank] == nil then
      weaponTypeData[weaponModData.rank] = {}
    end
    table.insert(weaponTypeData[weaponModData.rank], t)
  end
  local weaponModTypeHighLight = {}
  local weaponModEffectIDHighLight = {}
  local weaponModQualityHighLight = {}
  for i = 1, #self.selectItemList do
    local id = self.selectItemList[i]
    local wishItemData = TableData.listDarkzoneWishDatas:GetDataById(id, true)
    if wishItemData then
      for i, v in pairs(wishItemData.weight_type_show) do
        if i == 1 then
          weaponModTypeHighLight[v] = true
        elseif i == 2 then
          weaponModEffectIDHighLight[v] = true
        elseif i == 3 then
          weaponModQualityHighLight[v] = true
        end
      end
    end
  end
  local index = 1
  for k, v in pairs(weaponTypeData) do
    if self.itemList[index] == nil then
      self.itemList[index] = UIDarkZoneWishDropItem.New()
      self.itemList[index]:InitCtrl(self.ui.mTrans_Content)
    end
    local item = self.itemList[index]
    item:SetUpData(weaponModTypeHighLight, weaponModEffectIDHighLight, weaponModEffectIDHighLight)
    item:SetData(k, v)
    index = index + 1
  end
end
