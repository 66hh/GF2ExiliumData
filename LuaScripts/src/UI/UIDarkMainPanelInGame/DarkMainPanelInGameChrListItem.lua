require("UI.UIBaseCtrl")
DarkMainPanelInGameChrListItem = class("DarkMainPanelInGameChrListItem", UIBaseCtrl)
DarkMainPanelInGameChrListItem.__index = DarkMainPanelInGameChrListItem
local HpShowType = {
  Normal = CS.NameplateDefiner.HpShowType[CS.HpBarShowType.Normal],
  Light = CS.NameplateDefiner.HpShowType[CS.HpBarShowType.Light],
  Result = CS.NameplateDefiner.HpShowType[CS.HpBarShowType.Result]
}
local ShaderPropertyId = {
  Normal = CS.NameplateDefiner.HpShowID[CS.HpBarShowType.Normal],
  Light = CS.NameplateDefiner.HpShowID[CS.HpBarShowType.Light],
  Result = CS.NameplateDefiner.HpShowID[CS.HpBarShowType.Result]
}
local WillType = {
  Empty = 0,
  Half = 1,
  Full = 2
}
function DarkMainPanelInGameChrListItem:InitCtrl(root, parentPanel)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.parentPanel = parentPanel
  self.ui.willType = WillType.Empty
  self.WillIcon = {}
  local fullWillIcon = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_2")
  self.WillIcon[WillType.Full] = fullWillIcon
  local halfWillIcon = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_1")
  self.WillIcon[WillType.Half] = halfWillIcon
  local emptyWillIcon = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_0")
  self.WillIcon[WillType.Empty] = emptyWillIcon
  self.ui.mImg_WillIcon.sprite = self.WillIcon[self.ui.willType]
  local hpReduceGraphic = self.ui.mTran_HpReduce.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Graphic))
  local hpReduceOriginMat = hpReduceGraphic.material
  local hpReduceCopyMat = CS.UnityEngine.Object.Instantiate(hpReduceOriginMat)
  hpReduceGraphic.material = hpReduceCopyMat
  self.ui.hpReduceMat = hpReduceCopyMat
  self:SetBarMode(self.ui.hpReduceMat, HpShowType.Normal)
  self:SetFillAmountBarByType(self.ui.hpReduceMat, ShaderPropertyId.Normal, 0)
  local shieldReduceGraphic = self.ui.mTran_ShieldReduce.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Graphic))
  local shieldReduceOriginMat = shieldReduceGraphic.material
  local shieldReduceCopyMat = CS.UnityEngine.Object.Instantiate(shieldReduceOriginMat)
  shieldReduceGraphic.material = shieldReduceCopyMat
  self.ui.shieldReduceMat = shieldReduceCopyMat
  self:SetBarMode(self.ui.shieldReduceMat, HpShowType.Normal)
  self:SetFillAmountBarByType(self.ui.shieldReduceMat, ShaderPropertyId.Normal, 0)
  local deepObj = instantiate(self.ui.mTrans_Deep.childItem, self.ui.mTrans_Deep.transform)
  self.ui.DeepUI = {}
  self:LuaUIBindTable(deepObj, self.ui.DeepUI)
  self.ui.DeepChilds = {}
  local deepChild = self.ui.DeepUI.mTran_DeepChild
  self.ui.DeepChilds[1] = getcomponent(deepChild, typeof(CS.UnityEngine.Animator))
  self.ui.DeepChilds[1].keepAnimatorControllerStateOnDisable = true
  self.material = self.ui.mImg_Avatar.material
  self.ui.mText_WillValue.text = "0"
end
function DarkMainPanelInGameChrListItem:SetData(Data, isLeader, index)
  self.mData = Data
  self:InstantiateDeep()
  self.curHp = 0
  self.curShieldHp = 0
  self.curPotential = 0
  self.curWillValue = 0
  self:SetLeader(isLeader)
  self.ui.mImg_Avatar.sprite = IconUtils.GetTourCharacterSpriteWithCloth(self.mData.Id)
  function self.ChangeLeader()
    self.parentPanel:ShowWindow(0)
    CS.SysMgr.dzPlayerMgr.MainPlayer.receiveInputComp:UIClick(CS.DarkUnitWorld.UIClickType.ChangeLeader, self.mData)
  end
  self.ui.mBtn_Change.onClick:AddListener(self.ChangeLeader)
  if not CS.LuaUtils.IsNullOrDestroyed(self.ui.mHint_Id) then
    local id = 0
    if index == 1 then
      id = 903298
    elseif index == 2 then
      id = 903299
    elseif index == 3 then
      id = 903300
    elseif index == 4 then
      id = 903301
    end
    CS.LuaUIUtils.GetUIPCKey(self.ui.mHint_Id).text = TableData.listHintDatas:GetDataById(id).Chars.str
  end
  setactive(self.ui.DeepUI.mTran_DeepRoot.gameObject, true)
  function self.Fun(msg)
    self:UpdateMainUIRoleState(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.UpdateMainUIRoleState, self.Fun)
end
function DarkMainPanelInGameChrListItem:SetLeader(isLeader)
  self.ui.mBtn_Change.interactable = isLeader == false
  if not CS.LuaUtils.IsNullOrDestroyed(self.ui.mHint_Id) then
    setactive(self.ui.mHint_Id.gameObject, isLeader == false)
  end
end
function DarkMainPanelInGameChrListItem:OnRelease()
  if self.tweenHp ~= nil then
    LuaDOTweenUtils.Kill(self.tweenHp, false)
    self.tweenHp = nil
  end
  if self.tweenShield ~= nil then
    LuaDOTweenUtils.Kill(self.tweenShield, false)
    self.tweenShield = nil
  end
  if self.delaySetWillIcon ~= nil then
    self.delaySetWillIcon:Stop()
    self.delaySetWillIcon = nil
  end
  for i = WillType.Empty, WillType.Full do
    ResourceManager:UnloadAssetFromLua(self.WillIcon[i])
  end
  self.WillIcon = nil
  self.curHp = nil
  self.curShieldHp = nil
  self.curPotential = nil
  self.curWillValue = nil
  self.ui.mBtn_Change.onClick:RemoveListener(self.ChangeLeader)
  self.ChangeLeader = nil
  self.ui = nil
  self.mview = nil
  self.mData = nil
  self.buffData = nil
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.UpdateMainUIRoleState, self.Fun)
  self.Fun = nil
  self.material = nil
  self.parentPanel = nil
end
function DarkMainPanelInGameChrListItem:UpdateData(Data)
  local hp = self.mData.HP
  if hp <= 0 then
    self:ShowDetah()
  else
    self:ShowAlive()
  end
end
function DarkMainPanelInGameChrListItem:UpdateMainUIRoleState(msg)
  if msg.Sender == self.mData then
    self:ShowAlive()
  end
end
function DarkMainPanelInGameChrListItem:GetPotentialChild(index)
  local deepChild = self.ui.DeepChilds[index]
  if deepChild == nil then
    deepChild = instantiate(self.ui.DeepUI.mTran_DeepChild.gameObject, self.ui.DeepUI.mTran_DeepRoot.transform, false)
    self.ui.DeepChilds[index] = getcomponent(deepChild, typeof(CS.UnityEngine.Animator))
    self.ui.DeepChilds[index].keepAnimatorControllerStateOnDisable = true
    self.ui.DeepChilds[index]:SetInteger("Switch", 0)
    setactive(deepChild.gameObject, true)
  end
  return deepChild
end
function DarkMainPanelInGameChrListItem:InstantiateDeep()
  local propertyId = TableData.GetGunData(self.mData.Id).property_id
  local max = TableData.listPropertyDatas:GetDataById(propertyId).max_potential
  for i = 2, max do
    local deepChild = instantiate(self.ui.DeepUI.mTran_DeepChild.gameObject, self.ui.DeepUI.mTran_DeepRoot.transform, false)
    self.ui.DeepChilds[i] = getcomponent(deepChild, typeof(CS.UnityEngine.Animator))
    self.ui.DeepChilds[i].keepAnimatorControllerStateOnDisable = true
    self.ui.DeepChilds[i]:SetInteger("Switch", 0)
    setactive(deepChild.gameObject, true)
  end
end
function DarkMainPanelInGameChrListItem:ShowDetah()
  if self.tweenHp ~= nil then
    LuaDOTweenUtils.Kill(self.tweenHp, false)
    self.tweenHp = nil
  end
  if self.tweenShield ~= nil then
    LuaDOTweenUtils.Kill(self.tweenShield, false)
    self.tweenShield = nil
  end
  local preShieldHp = self.curShieldHp
  local prePotential = self.curPotential
  local preWillValue = self.curWillValue
  self.curShieldHp = 0
  self.curPotential = 0
  self.curWillValue = 0
  if preShieldHp ~= self.curShieldHp then
    self:ShowShieldHp(preShieldHp, self.curShieldHp)
  end
  for i = 1, #self.ui.DeepChilds do
    local deepChild = self.ui.DeepChilds[i]
    deepChild:SetInteger("Switch", 2)
  end
  local curWillType = WillType.Empty
  self.ui.willType = curWillType
  self.ui.mImg_WillIcon.sprite = self.WillIcon[self.ui.willType]
  setactive(self.ui.mText_WillChange.transform.parent.gameObject, false)
  self.ui.mText_WillValue.text = tostring(0)
  self.ui.mImg_Avatar.material = CS.SysMgr.dzUIElemMgr._DesaturationMat
end
function DarkMainPanelInGameChrListItem:ShowAlive()
  local preHp = self.curHp
  local preShieldHp = self.curShieldHp
  local prePotential = self.curPotential
  local preWillValue = self.curWillValue
  self.curHp = self.mData.HP
  self.curShieldHp = self.mData.ShieldHp
  self.curPotential = self.mData.Potential
  self.curWillValue = self.mData.WillValue
  if preHp ~= self.curHp then
    self:ShowHp(preHp, self.curHp)
  end
  if self.curHp <= 0 then
    return
  end
  if preShieldHp ~= self.curShieldHp then
    self:ShowShieldHp(preShieldHp, self.curShieldHp)
  end
  if prePotential ~= self.curPotential then
    self:ShowPotential(prePotential, self.curPotential)
  end
  if preWillValue ~= self.curWillValue then
    self:ShowWillValue(preWillValue, self.curWillValue)
  end
  self.ui.mImg_Avatar.material = self.material
end
function DarkMainPanelInGameChrListItem:ShowHp(pre, cur)
  self:PlayHp(pre, cur, self.mData.MaxHp)
end
function DarkMainPanelInGameChrListItem:ShowShieldHp(pre, cur)
  self:PlayShield(pre, cur, self.mData.MaxShieldHp)
end
function DarkMainPanelInGameChrListItem:ShowPotential(pre, cur)
  local beginIndex = 0
  local endIndex = 0
  local switch = 0
  if cur < pre then
    beginIndex = cur + 1
    endIndex = pre
    switch = 2
  else
    beginIndex = pre + 1
    endIndex = cur
    switch = 3
  end
  for i = 1, beginIndex do
    local deepChild = self.ui.DeepChilds[i]
    deepChild:SetInteger("Switch", 0)
  end
  for i = beginIndex, endIndex do
    local deepChild = self:GetPotentialChild(i)
    deepChild:SetInteger("Switch", switch)
  end
end
function DarkMainPanelInGameChrListItem:ShowWillValue(pre, cur)
  local maxWill = self.mData.MaxWillValue
  local curWillType = WillType.Half
  if cur == 0 then
    curWillType = WillType.Empty
  elseif cur == maxWill then
    curWillType = WillType.Full
  end
  if curWillType ~= self.ui.willType then
    self.ui.willType = curWillType
    if self.delaySetWillIcon ~= nil then
      self.delaySetWillIcon:Stop()
      self.delaySetWillIcon = nil
    end
    self.delaySetWillIcon = TimerSys:DelayFrameCall(7, function()
      self.ui.mImg_WillIcon.sprite = self.WillIcon[self.ui.willType]
    end)
  end
  local add = pre < cur
  self.ui.mAnim_Switch:SetBool("Buff", add)
  local willChange = 0
  if add then
    willChange = "+" .. cur - pre
  else
    willChange = "-" .. pre - cur
  end
  self.ui.mText_WillChange.text = tostring(willChange)
  self.ui.mText_WillValue.text = tostring(cur)
  if pre ~= 0 then
    self.ui.mAni_WillChange:Play()
  end
end
function DarkMainPanelInGameChrListItem:PlayHp(pre, cur, max)
  local finalValue = cur / max
  local curNormalValue = self:GetFillAmountBarByType(self.ui.hpReduceMat, ShaderPropertyId.Normal)
  local curResultValue = self:GetFillAmountBarByType(self.ui.hpReduceMat, ShaderPropertyId.Result)
  local hpReduceValue = curNormalValue - finalValue + curResultValue
  self:SetFillAmountBarByType(self.ui.hpReduceMat, ShaderPropertyId.Normal, finalValue)
  self:SetFillAmountBarByType(self.ui.hpReduceMat, ShaderPropertyId.Result, hpReduceValue)
  if self.tweenHp ~= nil then
    LuaDOTweenUtils.Kill(self.tweenHp, false)
  end
  self:SetBarMode(self.ui.hpReduceMat, HpShowType.Result)
  local getter = function(tempSelf)
    return tempSelf:GetFillAmountBarByType(tempSelf.ui.hpReduceMat, ShaderPropertyId.Result)
  end
  local setter = function(tempSelf, value)
    tempSelf:SetFillAmountBarByType(tempSelf.ui.hpReduceMat, ShaderPropertyId.Result, value)
  end
  self.tweenHp = LuaDOTweenUtils.ToOfFloat(self, getter, setter, 0, 0.3, function()
    self.tweenHp = nil
    self:SetBarMode(self.ui.hpReduceMat, HpShowType.Normal)
    if self.mData.HP <= 0 then
      self:ShowDetah()
    end
  end)
end
function DarkMainPanelInGameChrListItem:PlayShield(pre, cur, max)
  local finalValue = cur / max
  local curNormalValue = self:GetFillAmountBarByType(self.ui.shieldReduceMat, ShaderPropertyId.Normal)
  local curResultValue = self:GetFillAmountBarByType(self.ui.shieldReduceMat, ShaderPropertyId.Result)
  local hpReduceValue = curNormalValue - finalValue + curResultValue
  self:SetFillAmountBarByType(self.ui.shieldReduceMat, ShaderPropertyId.Normal, finalValue)
  self:SetFillAmountBarByType(self.ui.shieldReduceMat, ShaderPropertyId.Result, hpReduceValue)
  if self.tweenShield ~= nil then
    LuaDOTweenUtils.Kill(self.tweenShield, false)
  end
  self:SetBarMode(self.ui.shieldReduceMat, HpShowType.Result)
  local getter = function(tempSelf)
    return tempSelf:GetFillAmountBarByType(tempSelf.ui.shieldReduceMat, ShaderPropertyId.Result)
  end
  local setter = function(tempSelf, value)
    tempSelf:SetFillAmountBarByType(tempSelf.ui.shieldReduceMat, ShaderPropertyId.Result, value)
  end
  self.tweenShield = LuaDOTweenUtils.ToOfFloat(self, getter, setter, 0, 0.3, function()
    self.tweenShield = nil
    self:SetBarMode(self.ui.shieldReduceMat, HpShowType.Normal)
  end)
end
function DarkMainPanelInGameChrListItem:SetFillAmountBarByType(material, shaderPropertyId, value)
  CS.NameplateDefiner.SetShaderFloat(material, shaderPropertyId, value)
end
function DarkMainPanelInGameChrListItem:GetFillAmountBarByType(material, shaderPropertyId)
  return CS.NameplateDefiner.GetShaderFloat(material, shaderPropertyId)
end
function DarkMainPanelInGameChrListItem:SetBarMode(material, hpShowType)
  CS.NameplateDefiner.ShaderDisableKeyword(material, HpShowType.Normal)
  CS.NameplateDefiner.ShaderDisableKeyword(material, HpShowType.Light)
  CS.NameplateDefiner.ShaderDisableKeyword(material, HpShowType.Result)
  CS.NameplateDefiner.ShaderEnableKeyword(material, hpShowType)
end
