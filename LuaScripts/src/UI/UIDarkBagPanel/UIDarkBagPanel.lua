require("UI.UIDarkBagPanel.UIDarkBagPanelView")
require("UI.UIDarkBagPanel.DarkBagItemUpdateItem")
require("UI.FacilityBarrackPanel.Item.UIBarrackBriefItem")
require("UI.UniTopbar.Item.ResourcesCommonItem")
require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.Item.UIDarkZoneComEquipItem")
require("UI.UIDarkMainPanelInGame.UIDarkMainPanelInGame")
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
UIDarkBagPanel = class("UIDarkBagPanel", UIBasePanel)
UIDarkBagPanel.__index = UIDarkBagPanel
UIDarkBagPanel.mView = nil
UIDarkBagPanel.warWeight = 0
UIDarkBagPanel.nowarWeight = 0
UIDarkBagPanel.equipType = false
UIDarkBagPanel.warNum = 0
UIDarkBagPanel.noWarNum = 0
local self = UIDarkBagPanel
function UIDarkBagPanel:ctor(csPanel)
  UIDarkBagPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkBagPanel:OnHide()
  self:CloseDes(nil)
end
function UIDarkBagPanel:OnInit(root, data)
  UIDarkBagPanel.super.SetRoot(UIDarkBagPanel, root)
  self.mView = UIDarkBagPanelView.New()
  self.BagMgr = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag
  self.UI = {}
  self.equippedItem = {}
  self.paneldes = nil
  self.panelskill = nil
  self.fadein = false
  self.first = false
  self.firstFull = false
  self.batchDoing = false
  self.rect = nil
  self.equippanel = nil
  self.otherpanel = nil
  self.equippaneltwo = nil
  self.maskon = nil
  self.maskin = nil
  self.LastPow = 0
  self.showtime = 0
  self.UpdateShowTip = false
  self.ShowTipsTime = 0
  self.typeBtnTbl = {}
  self.weapon = nil
  self.TempList = nil
  self.moneyText = nil
  self.ResItem = nil
  function self.closeFunction()
    UIManager.CloseUI(UIDef.UIDarkBagPanel)
  end
  self.mView:InitCtrl(root, self.UI)
  function self.SetTrueFullEffect(msg)
    local activeParm = msg.Sender
    local animSwitch
    if activeParm then
      animSwitch = 0
    else
      animSwitch = 1
    end
    self.UI.mTran_FullEquip:SetInteger("Switch", animSwitch)
  end
  self.UI.mAnim_Equip:SetInteger("SwitchMyself", -1)
  self.UI.mAnim_Equip:SetInteger("SwitchLight", -1)
  ComPropsDetailsHelper:InitComPropsDetailsItemObjNum(2)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.BagEquipType, self.BagEquipType)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeWarNum, self.ChangeWarNum)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ChangeNoWarNum, self.ChangeNoWarNum)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkBagRedEquip, self.UpdateRedPoint)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkBagShowEquip, self.UpdateShowEquip)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkCloseDes, self.CloseDes)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshBattleLevel, self.SetRolePow)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.BagLightLayer, self.PlayerLayer)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkShowWeapon, self.ShowWeaponDes)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.GoToDarkSLGView, self.closeFunction)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ShowSwitchSelf, self.ShowSwitchSelf)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.ShowLightNum, self.UpdateLightNum)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DzBagEquipedFull, self.SetTrueFullEffect)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DzUpdateBagList, self.UpdateBagList)
  self.UI.mViList_Bag_War.itemProvider = self.ItemProvider
  self.UI.mViList_Bag_War.itemRenderer = self.ItemRenderer
  self.UI.mViList_Bag_NoWar.itemProvider = self.ItemProvider
  self.UI.mViList_Bag_NoWar.itemRenderer = self.ItemRenderer
  MessageSys:SendMessage(CS.GF2.Message.DarkMsg.OpenBag, self.UI.mViList_Bag_War, self.UI.mViList_Bag_NoWar)
  self:InitBag()
  UIUtils.GetButtonListener(self.UI.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkBagPanel)
  end
end
function UIDarkBagPanel.UpdateBagList(msg)
  self = UIDarkBagPanel
  self.TempList = msg.Sender
end
function UIDarkBagPanel.ItemProvider()
  local item = CS.RenderDataItem()
  local obj = ResSys:GetDarkItem("ComItem.prefab")
  item.renderItem = GameObject.Instantiate(obj)
  local darkBagItem = DarkBagItemUpdateItem.New()
  darkBagItem:InitCtrl(item.renderItem.transform)
  item.data = darkBagItem
  return item
end
function UIDarkBagPanel.ItemRenderer(index, item)
  local temp = self.TempList[index]
  local bagitem = item.data
  bagitem:Init(temp, self)
end
function UIDarkBagPanel.ShowSwitchSelf(msg)
  self = UIDarkBagPanel
  local indexSelf = msg.Sender
  self.BagMgr:ShowSwitchAnim(self.UI.mAnim_Equip, indexSelf)
end
function UIDarkBagPanel.PlayerLayer(msg)
  self = UIDarkBagPanel
  local item = msg.Sender
  self.BagMgr:ShowEquipType(self.UI.mAnim_Equip, item)
end
function UIDarkBagPanel.SetRolePow(msg)
  self = UIDarkBagPanel
  local data = msg.Sender
  self.UpdateShowTip = true
  self.UI.mText_Pow.text = data.PowRoleCount
  if self.LastPow == data.PowRoleCount then
    return
  end
  self.showtime = 0
  self.LastPow = data.PowRoleCount
end
function UIDarkBagPanel.CloseDes(msg)
  self = UIDarkBagPanel
  ComPropsDetailsHelper:Close(0)
  ComPropsDetailsHelper:Close(1)
  GameObject.Destroy(self.maskon)
  GameObject.Destroy(self.maskin)
  self.maskon = nil
  self.maskin = nil
  if self.equippanel ~= nil then
    self.equippanel:Des()
    self.equippanel = nil
  end
  if self.otherpanel ~= nil then
    self.otherpanel:Des()
    self.otherpanel = nil
  end
  if self.equippaneltwo ~= nil then
    self.equippaneltwo:Des()
    self.equippaneltwo = nil
  end
  if self.weapon ~= nil then
    GameObject.Destroy(self.weapon.mUIRoot.gameObject)
    self.weapon = nil
  end
end
function UIDarkBagPanel.ShowWeaponDes(msg)
  self = UIDarkBagPanel
  local data = msg.Sender
  self.rect = msg.Content
  if self.weapon ~= nil then
    GameObject.Destroy(self.weapon.mUIRoot.gameObject)
    self.weapon = nil
  end
  self.weapon = UIBarrackBriefItem.New()
  self.weapon:InitCtrl(self.UI.mTran_Left)
  self.weapon:SetDarkData(3, data.gunweaponModData, data)
  ComPropsDetailsHelper:InitDarkWeaponPartsData(self.UI.mTran_Left, data.gunweaponModData)
  self:SetItemDesShow(data, nil)
end
function UIDarkBagPanel.ShowItemDes(msg)
  self = UIDarkBagPanel
  local itemdata = msg.Sender[0]
  local itemhas = msg.Sender[1]
  self.rect = msg.Content
  self:SetItemDesShow(itemdata, itemhas)
end
function UIDarkBagPanel:SetItemDesShow(itemdata, itemhas)
  local maskclose = ResSys:GetDarkPrefab("prefab/MaskClose.prefab")
  local ShowItemDetail = function()
    UITipsPanel.Open(itemdata.itemdata, 0, true, nil, nil, nil, nil, true)
  end
  ComPropsDetailsHelper:Close(0)
  ComPropsDetailsHelper:Close(1)
  if self.maskon ~= nil then
    GameObject.Destroy(self.maskon)
    GameObject.Destroy(self.maskin)
    self.maskon = nil
    self.maskin = nil
  end
  if itemdata:GetType() == 90 and self.BagMgr.NowShowBag ~= 92 then
    self.maskin = GameObject.Instantiate(maskclose, self.UI.mTran_Viewport)
    self.maskon = GameObject.Instantiate(maskclose, self.UI.mTran_Viewport.parent)
  else
    self.maskin = GameObject.Instantiate(maskclose, self.UI.mTran_supViewPort)
    self.maskon = GameObject.Instantiate(maskclose, self.UI.mTran_supViewPort.parent.parent)
  end
  self.maskin.transform:GetComponent(typeof(CS.UnityEngine.UI.Button)).onClick:RemoveAllListeners()
  self.maskon.transform:GetComponent(typeof(CS.UnityEngine.UI.Button)).onClick:RemoveAllListeners()
  self.maskin.transform:SetAsFirstSibling()
  self.maskon.transform:SetAsFirstSibling()
  self.maskin.transform:GetComponent(typeof(CS.UnityEngine.UI.Button)).onClick:AddListener(function()
    if self.rect ~= nil then
      self.rect = nil
    end
    MessageSys:SendMessage(CS.GF2.Message.DarkMsg.DarkCloseDes, nil)
  end)
  self.maskon.transform:GetComponent(typeof(CS.UnityEngine.UI.Button)).onClick:AddListener(function()
    if self.rect ~= nil then
      self.rect = nil
    end
    MessageSys:SendMessage(CS.GF2.Message.DarkMsg.DarkCloseDes, nil)
  end)
  if itemdata:GetType() == 90 then
    local onlyid = self.BagMgr:GetBuffEquip(itemdata.buffData.BuffType - 1)
    if onlyid == 0 then
      ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Left, 1, itemdata, ShowItemDetail, 0)
      ComPropsDetailsHelper:OnClickEquipedBtn(function()
        self.BagMgr:OperateBag(CS.UIBagClickType.Equip, itemdata)
      end, 0)
    elseif onlyid == itemdata.onlyID then
      ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Left, 5, itemdata, ShowItemDetail, 0)
      ComPropsDetailsHelper:OnClickUninstallBtn(function()
        self.BagMgr:OperateBag(CS.UIBagClickType.UnLoad, itemdata)
      end, 0)
    else
      ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Left, 4, itemdata, ShowItemDetail, 0)
      ComPropsDetailsHelper:OnClickReplaceBtn(function()
        self.BagMgr:OperateBag(CS.UIBagClickType.Replace, itemdata)
      end, 0)
    end
  elseif itemdata:GetType() == 21 then
    ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Left, 5, itemdata, ShowItemDetail, 0)
  elseif itemdata:GetType() == 91 then
    ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Left, 2, itemdata, ShowItemDetail, 0)
    ComPropsDetailsHelper:OnClickEquipedBtn(function()
      UIDarkMainPanelInGame.SetQuickItem(itemdata)
    end, 0)
  else
    ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Left, 4, itemdata, ShowItemDetail, 0)
  end
  ComPropsDetailsHelper:OnClickDisCardBtn(function()
    if itemdata:GetType() == 90 and onlyid ~= 0 then
      self.BagMgr:OperateBag(CS.UIBagClickType.DisCard, itemdata)
    else
      self.BagMgr:OperateBag(CS.UIBagClickType.ResDisCard, itemdata)
    end
  end, 0)
  self:ClearEquipTwo()
  if itemhas ~= nil then
    ComPropsDetailsHelper:InitDarkItemEquipData(self.UI.mTran_Right, 3, itemhas, nil, 1)
  end
end
function UIDarkBagPanel:ClearEquipTwo()
  if self.equippaneltwo ~= nil then
    self.equippaneltwo:Des()
    self.equippaneltwo = nil
  end
end
function UIDarkBagPanel:OnUpdate()
end
function UIDarkBagPanel:OnShowStart()
  self:RefreshLightNum()
  local moneyText = self.UI.mTran_GrpCurrency:GetChild(0)
  self.ResItem = ResourcesCommonItem.New()
  self.ResItem:InitCtrl(moneyText, false)
  self.ResItem:UpdateDarkIcon(self.BagMgr:GetNowMoney())
end
function UIDarkBagPanel:HideTips()
  local self = UIDarkBagPanel
  self.ShowTipsTime = self.ShowTipsTime + CS.UnityEngine.Time.deltaTime
  if self.ShowTipsTime >= 1 then
    self.ShowTipsTime = 0
    self.UpdateShowTip = false
  end
end
function UIDarkBagPanel.UpdateShowEquip(msg)
  local self = UIDarkBagPanel
  local equipList = msg.Sender
  for i = 1, 7 do
    self.equippedItem[i]:RemoveDarkZoneEquip()
  end
  for i = 0, equipList.Count - 1 do
    do
      local equipData = equipList[i]
      local item = self.equippedItem[equipData.buffData.BuffType]
      item:SetDarkZoneEquipData(equipData, nil, function(data)
        self:SetItemDesShow(equipData)
      end)
    end
  end
end
function UIDarkBagPanel.UpdateRedPoint(msg)
  local self = UIDarkBagPanel
  local indexList = msg.Sender
  for i = 1, #self.equippedItem do
    self.equippedItem[i]:SetRedDot(false)
  end
  if indexList ~= nil then
    for i = 0, indexList.Count - 1 do
      local num = indexList[i] + 1
      self.equippedItem[num]:SetRedDot(true)
    end
  end
end
function UIDarkBagPanel:InitBag()
  local itemdataMone = TableData.listItemDatas:GetDataById(18)
  local btn = self.UI.mBtn_MoneyDes.childItem.gameObject
  self.LastPow = CS.SysMgr.dzPlayerMgr.MainPlayerData.PowRoleCount
  self.UI.mTran_FullEquip.gameObject:SetActive(true)
  self.UI.mTran_FullEquip:SetInteger("Switch", 1)
  self.UI.mBtn_War.interactable = false
  if self.BagMgr.NowShowBag == 10 then
    for i = 0, self.UI.mTran_TypeList.childCount - 1 do
      local btn = self.UI.mTran_TypeList:GetChild(i):Find("Btn_Tab1"):GetComponent(typeof(CS.UnityEngine.UI.Toggle))
      self.typeBtnTbl[i] = btn
      btn.onValueChanged:AddListener(function(ison)
        local type = i + 1
        self.BagMgr:SetBagStatus(type)
      end)
    end
  end
  self.BagMgr:SetBagStatus(0)
  local equipList = self.BagMgr:GetEquip()
  for i = 1, self.BagMgr.equipTypeCount do
    local item
    if self.equippedItem[i] == nil then
      item = UIDarkZoneComEquipItem.New()
      local rootName = string.format("GrpItem%d/Content", i)
      local root = self.UI.mTrans_ItemRoot:Find(rootName)
      item:InitCtrl(root)
      item:SetEquipTypeBg(i)
      self.equippedItem[i] = item
    else
      item = self.equippedItem[i]
    end
    local f = function()
      if self.BagMgr.NowShowBag ~= 8 then
        local btn = self.UI.mTran_TypeList:GetChild(i - 1):Find("Btn_Tab1"):GetComponent(typeof(CS.UnityEngine.UI.Toggle))
        btn.isOn = true
      end
    end
    item:SetBtnListener(f)
    item:RemoveDarkZoneEquip()
  end
  for i = 0, equipList.Count - 1 do
    do
      local equipData = equipList[i]
      local item = self.equippedItem[equipData.buffData.BuffType]
      item:SetDarkZoneEquipData(equipData, nil, function(data)
        self:SetItemDesShow(equipData)
      end)
    end
  end
  UIUtils.GetButtonListener(self.UI.mBtn_DisAll.gameObject).onClick = function()
    self.BagMgr:OperateBag(CS.UIBagClickType.OneClickDisCard)
    for i = 0, 6 do
      self.BagMgr:ShowSwitchAnimDis(self.UI.mAnim_Equip, i)
    end
  end
  UIUtils.GetButtonListener(self.UI.mBtn_EquipAll.gameObject).onClick = function()
    self.BagMgr:OperateBag(CS.UIBagClickType.OneClickEquipment)
  end
  UIUtils.GetButtonListener(self.UI.mBtn_EffectNum.gameObject).onClick = function()
    local list = {}
    local data = {}
    local equipList = self.BagMgr:GetEquip()
    for i = 0, equipList.Count - 1 do
      table.insert(list, equipList[i])
    end
    data.dataType = 1
    data.list = list
    UIManager.OpenUIByParam(UIDef.UIDarkZonePropertyDetailDialog, data)
  end
  UIUtils.GetButtonListener(self.UI.mBtn_Diss.gameObject).onClick = function()
    if self.warNum ~= 0 or self.noWarNum ~= 0 then
      self.BagMgr:StartBatchDis(true)
      self.UI.mTran_DisPanel.gameObject:SetActive(true)
    else
      CS.PopupMessageManager.PopupPositiveString(TableData.listHintDatas:GetDataById(903094).chars.str)
    end
    self.UI.mBtn_Diss.gameObject:SetActive(false)
  end
  UIUtils.GetButtonListener(self.UI.mBtn_DisCanel.gameObject).onClick = function()
    self.BagMgr:StartBatchDis(false)
    self.UI.mTran_DisPanel.gameObject:SetActive(false)
    self.UI.mBtn_Diss.gameObject:SetActive(true)
  end
  UIUtils.GetButtonListener(self.UI.mBtn_DisDis.gameObject).onClick = function()
    self.BagMgr:StartBatchDis(false)
    self.UI.mTran_DisPanel.gameObject:SetActive(false)
    CS.PbProxyMgr.dzOpProxy:SendPickDownCS_DarkZoneOp()
    self.UI.mBtn_Diss.gameObject:SetActive(true)
  end
  UIUtils.GetButtonListener(self.UI.mBtn_War.gameObject).onClick = function()
    self.UI.mAnim_Switch:SetInteger("Switch", 0)
    self.BagMgr:SetBagStatus(0)
    self:CheckNumEmpty()
    self:SetAnimStatus(0)
  end
  UIUtils.GetButtonListener(self.UI.mBtn_NoWar.gameObject).onClick = function()
    self.UI.mAnim_Switch:SetInteger("Switch", 1)
    self:ReleaseTypeList()
    self.BagMgr:SetBagStatus(8)
    self:ReleaseTypeList()
    self:CheckNumEmpty()
    self:SetAnimStatus(1)
  end
  local data = {
    [1] = TableData.listReadmeTagDatas:GetDataById(9).tag_name.str,
    [2] = TableData.listReadmeTagDatas:GetDataById(9).hint_detail.str
  }
  UIUtils.GetButtonListener(self.UI.mBtn_Info.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.SimpleMessageBoxPanel, data)
  end
  self.UI.mBtn_Diss.gameObject:SetActive(false)
  self.warNum = self.BagMgr.WarNum
  self.noWarNum = self.BagMgr.NoWarNum
  self:ShowNum()
  self:CheckNumEmpty()
  self.BagMgr:ShowRedInit()
end
function UIDarkBagPanel:SetAnimStatus(status)
  if status == 0 then
    self.UI.mBtn_War.interactable = false
    self.UI.mBtn_NoWar.interactable = true
  end
  if status == 1 then
    self.UI.mBtn_War.interactable = true
    self.UI.mBtn_NoWar.interactable = false
  end
end
function UIDarkBagPanel:ShowNum()
  local allnum = self.warNum + self.noWarNum
  if allnum == 0 then
    self.UI.mText_WarEmpty.transform.parent.gameObject:SetActive(true)
  end
  self.UI.mText_Num.text = allnum .. "/" .. CS.SysMgr.dzPlayerMgr.MainPlayer:GetProperty(EnumDarkzoneProperty.Property.DarkzoneChequer)
  self.UI.mText_warNum.text = TableData.listHintDatas:GetDataById(903035).chars.str .. "  " .. self.warNum
  self.UI.mText_nowarNum.text = TableData.listHintDatas:GetDataById(903036).chars.str .. "  " .. self.noWarNum
  self:CheckNumEmpty()
end
function UIDarkBagPanel:CheckNumEmpty()
  if self.BagMgr.NowShowBag <= 7 then
    if self.warNum <= 0 then
      self.UI.mText_NoWarEmpty.transform.parent.gameObject:SetActive(false)
      self.UI.mText_WarEmpty.transform.parent.gameObject:SetActive(true)
    else
      self.UI.mText_WarEmpty.transform.parent.gameObject:SetActive(false)
    end
  elseif 0 >= self.noWarNum then
    self.UI.mText_WarEmpty.transform.parent.gameObject:SetActive(false)
    self.UI.mText_NoWarEmpty.transform.parent.gameObject:SetActive(true)
  else
    self.UI.mText_NoWarEmpty.transform.parent.gameObject:SetActive(false)
  end
end
function UIDarkBagPanel.ChangeWarNum(msg)
  local self = UIDarkBagPanel
  local num = msg.Sender
  self.warNum = num
  self:ShowNum()
end
function UIDarkBagPanel.ChangeNoWarNum(msg)
  local self = UIDarkBagPanel
  local num = msg.Sender
  self.noWarNum = num
  self:ShowNum()
end
function UIDarkBagPanel.BagEquipType(msg)
  local self = UIDarkBagPanel
  local type = msg.Sender
  if type == 0 then
    self.UI.mTran_War.gameObject:SetActive(true)
    self.UI.mTran_NoWar.gameObject:SetActive(false)
  else
    self.UI.mTran_War.gameObject:SetActive(false)
    self.UI.mTran_NoWar.gameObject:SetActive(true)
  end
end
function UIDarkBagPanel:RefreshLightNum()
  local lightNum = 0
  lightNum = CS.SysMgr.dzPlayerMgr.MainPlayer:GetDvProperty(CS.GF2.Data.DevelopProperty.DarkzoneLevel)
  self.UI.mText_AllEquipLightNum.text = lightNum
end
function UIDarkBagPanel.UpdateLightNum(msg)
  self:RefreshLightNum()
end
function UIDarkBagPanel:OnRelease()
end
function UIDarkBagPanel:ReleaseTypeList()
  for i = 0, self.UI.mTran_TypeList.childCount - 1 do
    local btn = self.UI.mTran_TypeList:GetChild(i):Find("Btn_Tab1"):GetComponent(typeof(CS.UnityEngine.UI.Toggle))
    btn.isOn = false
  end
end
function UIDarkBagPanel:OnClose()
  MessageSys:SendMessage(CS.GF2.Message.DarkMsg.OpenMainBagBtn, nil)
  self.BagMgr:SetBagStatus(9)
  self.UI.mBtn_NoWar.interactable = true
  self:ReleaseTypeList()
  self.BagMgr = nil
  self.moneyText = nil
  self.ResItem:OnRelease()
  self.ResItem = nil
  self.UI = {}
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ShowSwitchSelf, self.ShowSwitchSelf)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.BagEquipType, self.BagEquipType)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeWarNum, self.ChangeWarNum)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ChangeNoWarNum, self.ChangeNoWarNum)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkBagRedEquip, self.UpdateRedPoint)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkBagShowEquip, self.UpdateShowEquip)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkCloseDes, self.CloseDes)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshBattleLevel, self.SetRolePow)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.BagLightLayer, self.PlayerLayer)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkShowWeapon, self.ShowWeaponDes)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.GoToDarkSLGView, self.closeFunction)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.ShowLightNum, self.UpdateLightNum)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DzBagEquipedFull, self.SetTrueFullEffect)
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DzUpdateBagList, self.UpdateBagList)
  self.closeFunction = nil
  self:ReleaseCtrlTable(self.equippedItem, true)
end
