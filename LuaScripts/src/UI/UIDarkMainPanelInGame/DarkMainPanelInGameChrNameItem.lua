require("UI.UIBaseCtrl")
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
local EnumDevelopProperty = require("UI.UIDarkMainPanelInGame.DevelopProperty")
DarkMainPanelInGameChrNameItem = class("DarkMainPanelInGameChrNameItem", UIBaseCtrl)
DarkMainPanelInGameChrNameItem.__index = DarkMainPanelInGameChrNameItem
function DarkMainPanelInGameChrNameItem:InitCtrl(root)
  self.obj = instantiate(root.childItem)
  self.parent = root.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self.trans = self.obj.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  self:SetRoot(self.obj.transform)
  self.hasHost = false
  self.isNpc = nil
  self.isTarget = false
  self.isAim = false
  self.ShowItemIcon = nil
  self.ui.mTran_VigiBarRoot = self.ui.mImg_VigilantBar.transform.parent
  setactive(self.ui.mTran_VigiBarRoot.gameObject, false)
end
function DarkMainPanelInGameChrNameItem:SetHost(host, type)
  self.mHost = host
  self.hasHost = true
  self.type = type
  if type == tonumber(CS.DarkUnitWorld.NameType.MainPlayer) then
    self:InitMainPlayer()
  else
    self:InitMonster(self.type)
  end
  self.ui.mHelp_Pos:SetHost(host, 1)
end
function DarkMainPanelInGameChrNameItem:UpdatePos()
  if self.mHost == nil then
    self:SetNull()
    return
  end
end
function DarkMainPanelInGameChrNameItem:InitMonster(type)
  self.isNpc = true
  setactive(self.ui.mTran_Npc.gameObject, true)
  setactive(self.ui.mTrans_Chr.gameObject, false)
  setactive(self.ui.mImg_Difficulties.gameObject, type == tonumber(CS.DarkUnitWorld.NameType.Difficulties))
  setactive(self.ui.mImg_Boss.gameObject, type == tonumber(CS.DarkUnitWorld.NameType.Boss))
  setactive(self.ui.mAni_GetBuff.gameObject, false)
  self.ui.mText_NpcGayValue.text = self.mHost.OriginName
  setactive(self.ui.mImg_NpcGay.gameObject, false)
  local proId = self.mHost:GetMonsterDropItemToProperty()
  if proId == EnumDarkzoneProperty.Property.DzEnergy1Now then
    setactive(self.ui.mImg_Red.transform.parent.gameObject, true)
    setactive(self.ui.mImg_Red.gameObject, true)
    setactive(self.ui.mImg_Blue.gameObject, false)
  elseif proId == EnumDarkzoneProperty.Property.DzEnergy2Now then
    setactive(self.ui.mImg_Red.transform.parent.gameObject, true)
    setactive(self.ui.mImg_Red.gameObject, false)
    setactive(self.ui.mImg_Blue.gameObject, true)
  else
    setactive(self.ui.mImg_Red.transform.parent.gameObject, false)
  end
  self.trans:SetAsFirstSibling()
end
function DarkMainPanelInGameChrNameItem:InitMainPlayer()
  setactive(self.ui.mTran_Npc.gameObject, false)
  setactive(self.ui.mTrans_Chr.gameObject, true)
  setactive(self.ui.mTran_ItemRoot.gameObject, false)
  function self.MainPalyerBuffBanner(msg)
    local buff = msg.Sender
    if self.buffFadeDelay ~= nil then
      self.buffFadeDelay:Stop()
      setactive(self.ui.mAni_GetBuff.gameObject, false)
      self.buffFadeDelay = nil
    end
    setactive(self.ui.mAni_GetBuff.gameObject, true)
    local image = IconUtils.GetDarkzoneBuffIcon(buff.DzBuffData.icon)
    self.ui.mText_BuffName.text = buff.DzBuffData.name.str
    self.ui.mImg_BuffIcon.sprite = image
    self.ui.mAni_GetBuff:SetBool("Buff", buff.DzBuffData.buff_type == 1)
    self.buffFadeDelay = TimerSys:DelayCall(1.7, function()
      setactive(self.ui.mAni_GetBuff.gameObject, false)
      self.buffFadeDelay = nil
    end)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.MainPalyerBuffBanner, self.MainPalyerBuffBanner)
  setactive(self.ui.mAni_GetBuff.gameObject, false)
  self.trans:SetAsLastSibling()
end
function DarkMainPanelInGameChrNameItem:SetNull()
  if not CS.LuaUtils.IsNullOrDestroyed(self.obj) then
    setactive(self.obj, false)
  end
  self.hasHost = false
  self.mHost = nil
  self.ui.mHelp_Pos:SetHost(nil)
  self.isNpc = nil
  if self.MainPalyerBuffBanner ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPalyerBuffBanner, self.MainPalyerBuffBanner)
    self.MainPalyerBuffBanner = nil
  end
  self.ui.mAni_GetBuff.keepAnimatorControllerStateOnDisable = false
  self.showItemId = nil
  if self.buffFadeDelay ~= nil then
    self.buffFadeDelay:Stop()
    setactive(self.ui.mAni_GetBuff.gameObject, false)
    self.buffFadeDelay = nil
  end
end
function DarkMainPanelInGameChrNameItem:OnRelease()
  if self.buffFadeDelay ~= nil then
    self.buffFadeDelay:Stop()
    self.buffFadeDelay = nil
  end
  if self.MainPalyerBuffBanner ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.MainPalyerBuffBanner, self.MainPalyerBuffBanner)
    self.MainPalyerBuffBanner = nil
  end
  self.showItemId = nil
  self.ui.mHelp_Pos:SetHost(nil)
  self.ui = nil
  self.mview = nil
  self.mHost = nil
  self.parent = nil
  self.trans = nil
  self.hasHost = nil
  self.type = nil
  self.isNpc = nil
  self.isTarget = nil
  self.isAim = nil
end
function DarkMainPanelInGameChrNameItem:SetVisible(visible)
  self.obj.gameObject:SetActive(visible)
  setactive(self.ui.mAni_GetBuff.gameObject, false)
end
function DarkMainPanelInGameChrNameItem:EnterAim(enter)
  if self.isNpc then
    self.isAim = enter
    if enter then
      if self.isTarget then
        if CS.DarkUnitWorld.AttackHelper.CanAttack(self.mHost) then
          setactive(self.ui.mTran_Miss.gameObject, false)
          setactive(self.ui.mTran_AttackBenefit.gameObject, true)
          self.ui.mAni_Root:SetTrigger("Trans_AttackBenefit_FadeIn")
          local bestDis = CS.DarkUnitWorld.AttackHelper.IsOptimumRange(self.mHost)
          setactive(self.ui.mImg_BestDis.gameObject, bestDis)
          local isUnder = CS.DarkUnitWorld.AttackHelper.IsUnderBattle()
          setactive(self.ui.mImg_Cover.gameObject, isUnder)
          local isBehind = CS.DarkUnitWorld.AttackHelper.IsSneakAttack(self.mHost)
          setactive(self.ui.mImg_behind.gameObject, isBehind)
        else
          setactive(self.ui.mTran_AttackBenefit.gameObject, false)
          setactive(self.ui.mTran_Miss.gameObject, true)
          self.ui.mAni_Root:SetTrigger("Trans_Miss_FadeIn")
        end
      else
        if CS.DarkUnitWorld.AttackHelper.InMainPlayerAttackRange(self.mHost) then
          if CS.DarkUnitWorld.AttackHelper.CanAttack(self.mHost) then
            setactive(self.ui.mTran_Miss.gameObject, false)
          else
            setactive(self.ui.mTran_Miss.gameObject, true)
          end
        else
          setactive(self.ui.mTran_Miss.gameObject, false)
        end
        setactive(self.ui.mTran_AttackBenefit.gameObject, false)
      end
    else
      setactive(self.ui.mTran_Miss.gameObject, false)
      setactive(self.ui.mTran_AttackBenefit.gameObject, false)
    end
  end
end
function DarkMainPanelInGameChrNameItem:SetTarget(isTarget)
  if self.isNpc then
    self.isTarget = isTarget
    if self.isAim then
      if self.isTarget then
        if CS.DarkUnitWorld.AttackHelper.CanAttack(self.mHost) then
          setactive(self.ui.mTran_AttackBenefit.gameObject, true)
          self.ui.mAni_Root:SetTrigger("Trans_AttackBenefit_FadeIn")
          local bestDis = CS.DarkUnitWorld.AttackHelper.IsOptimumRange(self.mHost)
          setactive(self.ui.mImg_BestDis.gameObject, bestDis)
          local isUnder = CS.DarkUnitWorld.AttackHelper.IsUnderBattle()
          setactive(self.ui.mImg_Cover.gameObject, isUnder)
          local isBehind = CS.DarkUnitWorld.AttackHelper.IsSneakAttack(self.mHost)
          setactive(self.ui.mImg_behind.gameObject, isBehind)
        else
          setactive(self.ui.mTran_Miss.gameObject, true)
          self.ui.mAni_Root:SetTrigger("Trans_Miss_FadeIn")
        end
      elseif CS.DarkUnitWorld.AttackHelper.CanAttack(self.mHost) then
        self.ui.mAni_Root:SetTrigger("Trans_AttackBenefit_FadeOut")
      else
        self.ui.mAni_Root:SetTrigger("Trans_Miss_FadeOut")
      end
    end
  end
end
