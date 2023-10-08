require("UI.PVP.UIPVPGlobal")
require("UI.UIBaseCtrl")
ExchangeTagItem = class("ExchangeTagItem", UIBaseCtrl)
ExchangeTagItem.__index = ExchangeTagItem
ExchangeTagItem.mText_Off_TagName = nil
ExchangeTagItem.mText_On_TagName = nil
ExchangeTagItem.mText_Locked_TagName = nil
ExchangeTagItem.mTrans_Off = nil
ExchangeTagItem.mTrans_On = nil
ExchangeTagItem.mTrans_Locked = nil
ExchangeTagItem.mBtnSelf = nil
function ExchangeTagItem:__InitCtrl()
  self.mText_On_TagName = self:GetText("Text_Name")
  self.mTrans_Off = self:GetRectTransform("UI_Trans_Off")
  self.mTrans_On = self:GetRectTransform("UI_Trans_On")
  self.mTrans_Locked = self:GetRectTransform("Trans_GrpLocked")
  self.mText_Num = self:GetText("GrpBg/GrpText/TextNum")
  self.mBtnSelf = self:GetSelfButton()
end
ExchangeTagItem.mIsLocked = false
ExchangeTagItem.mData = nil
function ExchangeTagItem:InitCtrl(parent, isWhite)
  local tabName = "UICommonFramework/ComLeftTab1ItemV2.prefab"
  if isWhite ~= nil and isWhite == true then
    tabName = "UICommonFramework/ComLeftTab1ItemV2_W.prefab"
  end
  local obj = instantiate(UIUtils.GetGizmosPrefab(tabName, self))
  setparent(parent, obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  setscale(obj.transform, vectorone)
  setposition(obj.transform, vectorzero)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
  self.uid = AccountNetCmdHandler.Uid
  function self.refreshRed()
    self:UpdateRedPoint()
  end
  MessageSys:AddListener(UIEvent.PVPStoreRedPointRefresh, self.refreshRed)
end
function ExchangeTagItem:InitData(data)
  self.mData = data
  self.ui.mText_Name.text = data.name.str
  self.mIsLocked = true
  local flagRedPoint = false
  local strArr = data.IncludeTag
  for i = 0, strArr.Count - 1 do
    local storeTagData = TableData.listStoreTagDatas:GetDataById(strArr[i])
    if storeTagData ~= nil and storeTagData.unlock ~= 0 and AccountNetCmdHandler:CheckSystemIsUnLock(storeTagData.unlock) then
      self.mIsLocked = false
    end
    if storeTagData.unlock == 0 then
      self.mIsLocked = false
    end
    if PlayerPrefs.GetInt(self.uid .. UIPVPGlobal.RedPointKey .. storeTagData.Id) == 1 then
      flagRedPoint = true
    end
  end
  if data.unlock ~= 0 and not AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock) then
    self.mIsLocked = true
  end
  if self.mIsLocked then
    self:SetLocked()
    self:SetRedPoint(false)
  else
    local exchangeLicenseData = NetCmdStoreData:GetStoreGoodById(CS.CommonDefine.Exchange_Store_License_Id)
    local IsExchangeLicense = false
    if exchangeLicenseData ~= nil then
      local storeSidetagData = TableData.listStoreSidetagDatas:GetDataById(self.mData.id)
      IsExchangeLicense = storeSidetagData ~= nil and storeSidetagData.include_tag:Contains(exchangeLicenseData:GetStoreGoodData().tag) and not exchangeLicenseData:IsSellout()
    end
    self:SetRedPoint(flagRedPoint or IsExchangeLicense)
  end
  if self.mIsLocked == true then
    self.ui.mText_Name.color = Color(self.ui.mText_Name.color.r, self.ui.mText_Name.color.g, self.ui.mText_Name.color.b, 0.6274509803921569)
  else
    self.ui.mText_Name.color = Color(self.ui.mText_Name.color.r, self.ui.mText_Name.color.g, self.ui.mText_Name.color.b, 1)
  end
end
function ExchangeTagItem:SetSelect(isSelect)
  if self.mIsLocked then
    return
  end
  self.ui.mBtn_Self.interactable = not isSelect
end
function ExchangeTagItem:SetLocked()
  setactive(self.ui.mTrans_Locked.gameObject, true)
end
function ExchangeTagItem:GetRandomNum()
  local num1 = math.random(100, 999)
  local num2 = math.random(100, 999)
  local num3 = math.random(100, 999)
  return num1 .. "-" .. num2 .. "-" .. num3
end
function ExchangeTagItem:UpdateRedPoint()
  self:InitData(self.mData)
end
function ExchangeTagItem:SetRedPoint(IsShowRedPoint)
  setactive(self.ui.mTrans_RedPoint, IsShowRedPoint)
end
function ExchangeTagItem:OnClose()
  MessageSys:RemoveListener(UIEvent.PVPStoreRedPointRefresh, self.refreshRed)
end
