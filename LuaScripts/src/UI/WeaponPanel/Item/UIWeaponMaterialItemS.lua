require("UI.UIBaseCtrl")
UIWeaponMaterialItemS = class("UIWeaponMaterialItemS", UIBaseCtrl)
UIWeaponMaterialItemS.__index = UIWeaponMaterialItemS
function UIWeaponMaterialItemS:ctor()
  self.mData = nil
  self.elementItem = nil
end
function UIWeaponMaterialItemS:__InitCtrl()
  self.mBtn_Item = self:GetSelfButton()
  self.mImage_Icon = self:GetImage("GrpContent/GrpIcon/Img_Icon")
  self.mText_Count = self:GetText("GrpContent/GrpLevel/Text_Level")
  self.mImage_Rank = self:GetImage("GrpContent/GrpQualityLine/ImgLine")
  self.mImage_Rank2 = self:GetImage("GrpContent/GrpIcon/Img_Bg")
end
function UIWeaponMaterialItemS:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComWeaponInfoItem.prefab", self))
  setparent(parent, obj.transform)
  obj.transform.localScale = vectorone
  obj.transform.localPosition = vectorzero
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIWeaponMaterialItemS:SetData(data)
  if data then
    self.mData = data
    if data.type == UIWeaponGlobal.MaterialType.Item then
      self.mImage_Icon.sprite = IconUtils.GetItemIconSprite(data.id)
      self.mText_Count.text = 1
    elseif data.type == UIWeaponGlobal.MaterialType.Weapon then
      local weaponData = TableData.listGunWeaponDatas:GetDataById(data.stcId)
      self.mImage_Icon.sprite = IconUtils.GetWeaponSprite(data.icon)
      self.mText_Count.text = GlobalConfig.SetLvText(data.level)
    end
    self.mImage_Rank2.sprite = IconUtils.GetWeaponQuiltyByRank(data.rank)
    self.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    setactive(self.mUIRoot, true)
  else
    setactive(self.mUIRoot, false)
  end
end
