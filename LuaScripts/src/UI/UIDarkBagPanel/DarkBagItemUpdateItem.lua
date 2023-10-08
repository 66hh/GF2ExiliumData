require("UI.UIBaseCtrl")
DarkBagItemUpdateItem = class("DarkBagItemUpdateItem", UIBaseCtrl)
DarkBagItemUpdateItem.__index = DarkBagItemUpdateItem
local self = DarkBagItemUpdateItem
function DarkBagItemUpdateItem:InitCtrl(item)
  self.rect = item
  self.temp = nil
  self:SetRoot(item)
  self.ui = {}
  self.BagMgr = CS.SysMgr.dzPlayerMgr.MainPlayer.DarkPlayerBag
  self:LuaUIBindTable(item, self.ui)
end
function DarkBagItemUpdateItem:Init(data, bagPanel)
  self.temp = data
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.itemdata.id)
  self.ui.mBtn_Select.onClick:RemoveAllListeners()
  print(data.itemdata.rank)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.itemdata.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(data.itemdata.rank)
  if data.type.value__ == 90 then
    self.ui.mEquip_Light.transform.parent.gameObject:SetActive(true)
    self.ui.mEquip_Light.gameObject:SetActive(true)
    self.ui.mEquip_Light.sprite = ResSys:GetUIResAIconSprite("BtnIcon/Icon_Btn_Darkzone_Energy.png")
    self.ui.mText_Num.text = data:GetLight()
  else
    self.ui.mEquip_Light.gameObject:SetActive(false)
    if data.num > 1 then
      self.ui.mText_Num.text = data.num
    else
      self.ui.mText_Num.text = ""
      self.ui.mEquip_Light.transform.parent.gameObject:SetActive(false)
    end
  end
  if self.BagMgr.batchDoing then
    self.ui.mTrans_Choose.gameObject:SetActive(false)
    self.ui.mBtn_Select.onClick:AddListener(function()
      if data.batchDoing.value__ == 1 then
        self.ui.mTrans_Choose.gameObject:SetActive(true)
        data.batchDoing.value__ = 0
        self.BagMgr.disList:Add(data)
      else
        self.ui.mTrans_Choose.gameObject:SetActive(false)
        data.batchDoing.value__ = 1
        self.BagMgr.disList:Remove(data)
      end
    end)
  else
    self.ui.mBtn_Select.onClick:AddListener(function()
      if data.type.value__ == 90 then
        local itemhas
        if self.BagMgr:CheckHasEquip(data) then
          itemhas = self.BagMgr:GetEquipByOnlyID(self.BagMgr.buffOnlyIdList[data.buffData.buff_type - 1], data)
        end
        bagPanel:SetItemDesShow(data, itemhas)
      else
        bagPanel:SetItemDesShow(data, nil)
      end
    end)
    self.ui.mTrans_Choose.gameObject:SetActive(false)
  end
end
function DarkBagItemUpdateItem:OnRelease()
end
