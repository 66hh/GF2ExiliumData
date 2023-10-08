require("UI.UIBaseCtrl")
require("UI.UIDarkMainPanelInGame.UIDarkBoxItemItem")
UIDarkBoxItem = class("UIDarkBoxItem", UIBaseCtrl)
UIDarkBoxItem.__index = UIDarkBoxItem
local self = UIDarkBoxItem
function UIDarkBoxItem:__InitCtrl()
end
function UIDarkBoxItem:InitCtrl(parent, parentPanel, comItemPrefab)
  local instObj = instantiate(UIUtils.GetDarkPanelBoxItem("", self))
  if root then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(instObj.transform)
  self.parentPanel = parentPanel
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.inddd = -1
  local item = GameObject.Instantiate(comItemPrefab, self.ui.mBtn_Con.transform.parent)
  local boxItem = UIDarkBoxItemItem.New()
  boxItem:InitCtrl(self.ui.mBtn_Con.transform.parent, item)
  self.itemIcon = boxItem
  function self.EnterItem()
    self.parentPanel:PointEnterItem(self)
  end
  function self.ExitItem()
    self.parentPanel:PointExitItem(self)
  end
  self.BagMgr = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag
end
function UIDarkBoxItem:Enter(flag)
  if flag then
    self.parentPanel:RegistrationKeyboard(KeyCode.F, self.ui.mBtn_Self)
  else
    self.parentPanel:UnRegistrationKeyboard(KeyCode.F)
  end
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    self.ui.mBtn_PCEPick.gameObject:SetActive(flag)
  end
end
function UIDarkBoxItem:SetOffset()
  self.ui.mText_name.text = CS.UIDarkZoneUtils.CheckTextByMinSize(self.ui.mText_name, 126)
end
function UIDarkBoxItem:SetData(data, index)
  self.ui.mBtn_Self.PointEnterEvent:AddListener(self.EnterItem)
  self.ui.mBtn_Self.PointExitEvent:AddListener(self.ExitItem)
  self.inddd = index
  self.itemIcon:SetData(data)
  self.ui.mBtn_Con.gameObject:SetActive(false)
  if CS.GameRoot.Instance.AdapterPlatform == CS.PlatformSetting.PlatformType.PC then
    CS.LuaUIUtils.GetUIPCKey(self.ui.mBtn_PCEPick).text = TableData.listHintDatas:GetDataById(903304).Chars.str
    self.ui.mBtn_PCEPick.gameObject:SetActive(false)
  end
  if self.inddd == 0 then
    self.parentPanel:InitSelectItem(self)
  end
  self.ui.mText_name.text = data.itemdata.name.str
  self.ui.mText_Des.text = data.itemdata.Introduction.str
  if data.num <= 1 then
    self.ui.mText_Num.transform.parent.parent.gameObject:SetActive(false)
  else
    self.ui.mText_Num.transform.parent.parent.gameObject:SetActive(true)
    self.ui.mText_Num.text = data.num
  end
  self.ui.mText_NumBox.gameObject:SetActive(false)
  self.ui.mTran_Money.gameObject:SetActive(false)
  self.ui.mBtn_Self.onClick:RemoveAllListeners()
  self.ui.mBtn_Self.onClick:AddListener(function()
    if self.BagMgr:CheckBagMaxNum(data) then
      CS.PbProxyMgr.dzOpProxy:SendPickupppCS_DarkZoneOp(data)
      self.parentPanel:ClickItem(self)
    else
      CS.PopupMessageManager.PopupString(TableData.listHintDatas:GetDataById(903018).chars.str)
    end
  end)
end
function UIDarkBoxItem:OnRelease()
  self.ui.mBtn_Self.PointEnterEvent:RemoveListener(self.EnterItem)
  self.ui.mBtn_Self.PointExitEvent:RemoveListener(self.ExitItem)
  self.inddd = nil
end
