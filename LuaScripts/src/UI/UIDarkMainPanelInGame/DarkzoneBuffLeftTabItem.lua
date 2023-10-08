require("UI.UIBaseCtrl")
DarkzoneBuffLeftTabItem = class("DarkzoneBuffLeftTabItem", UIBaseCtrl)
DarkzoneBuffLeftTabItem.__index = DarkzoneBuffLeftTabItem
function DarkzoneBuffLeftTabItem:InitCtrl(prefab, parent)
  self.obj = instantiate(prefab, parent)
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self.buffViewList = {}
  self.ui.mAnimator_Self.keepAnimatorControllerStateOnDisable = true
end
function DarkzoneBuffLeftTabItem:SetData(Data, buffDailog)
  self.mData = Data
  self.buffDailog = buffDailog
  setactive(self.obj.gameObject, true)
  local gunTableData = TableData.listGunDatas:GetDataById(self.mData.GunId)
  self.ui.mImg_Icon.sprite = IconUtils.GetTourCharacterSpriteWithCloth(self.mData.GunId)
  self.ui.mText_Title.text = gunTableData.name.str
  local gunData = CS.SysMgr.dzPlayerMgr.MainPlayerData:GetDarkPropertyDataById(self.mData.GunId)
  self.isDeath = gunData.HP <= 0
  if self.isDeath then
    self.ui.mImg_Icon.material = CS.SysMgr.dzUIElemMgr._DesaturationMat
    self.ui.mBtn_Self.enabled = false
  else
    self.ui.mBtn_Self.enabled = true
    function self.ClickFun()
      self.buffDailog:ShowTarget(self.mData.GunId)
    end
    self.ui.mBtn_Self.onClick:AddListener(self.ClickFun)
    local maxBuff = self.mData.ShowBuffMax
    for i = 1, maxBuff do
      local buffView = DarkMainPanelInGameBuffItem.New()
      buffView:InitCtrl(self.ui.mTrans_BuffRoot)
      self.buffViewList[i] = buffView
    end
    self:UpdateMainUIRoleBuff(Data)
  end
end
function DarkzoneBuffLeftTabItem:UpdateMainUIRoleBuff(buffData)
  local allShowBuff = buffData.ShowBuffLs
  local viewIndex = 1
  for i = allShowBuff.Count - 1, 0, -1 do
    local host = allShowBuff[i]
    local buffView = self.buffViewList[viewIndex]
    buffView:SetHost(host, nil, nil)
    setactive(buffView.obj, true)
    viewIndex = viewIndex + 1
    if viewIndex > buffData.ShowBuffMax then
      break
    end
  end
  for i = viewIndex, #self.buffViewList do
    local buffView = self.buffViewList[i]
    buffView:SetNull()
    setactive(buffView.obj, false)
  end
end
function DarkzoneBuffLeftTabItem:OnClose()
  for i = 1, #self.buffViewList do
    if not CS.LuaUtils.IsNullOrDestroyed(self.buffViewList[i]) then
      gfdestroy(self.buffViewList[i]:GetRoot())
    end
  end
  if self.ClickFun ~= nil then
    self.ui.mBtn_Self.onClick:RemoveListener(self.ClickFun)
    self.ClickFun = nil
  end
  self.buffDailog = nil
  self.mData = nil
  self.ui = nil
  if not CS.LuaUtils.IsNullOrDestroyed(self.obj) then
    gfdestroy(self.obj)
  end
  self.obj = nil
end
function DarkzoneBuffLeftTabItem:SetTarget(isTarget)
  if self.isDeath then
    self.ui.mAnimator_Self:SetInteger("Switch", 1)
    return
  end
  if isTarget then
    self.ui.mBtn_Self.interactable = false
  else
    self.ui.mBtn_Self.interactable = true
  end
end
