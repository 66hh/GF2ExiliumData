require("UI.UIBaseCtrl")
require("UI.UIDarkMainPanelInGame.UIGunAvatarItem")
require("UI.UIUnitInfoPanel.UIUnitInfoPanel")
require("UI.WeaponPanel.UIWeaponPanel")
UIGachaInfoItem = class("UIGachaInfoItem", UIBaseCtrl)
UIGachaInfoItem.__index = UIGachaInfoItem
UIGachaInfoItem.ItemInfoType = {
  Title = 0,
  Rate = 1,
  UpRate = 2
}
UIGachaInfoItem.upBgSprite = {
  [3] = "Icon_GashaponDialog_Purple",
  [4] = "Icon_GashaponDialog_Purple",
  [5] = "Icon_GashaponDialog_Golden"
}
UIGachaInfoItem.hintTable = {
  Chr = {
    [3] = 107035,
    [4] = 107036,
    [5] = 107037
  },
  Weapon = {
    [3] = 107040,
    [4] = 107039,
    [5] = 107038
  }
}
function UIGachaInfoItem:__InitCtrl()
  self.mText_Title = self:GetText("GrpTittle/Text_Details")
  self.mImg_UpLine = self:GetImage("Trans_GrpUp/GrpName/Img_Line")
  self.mImg_NormalLine = self:GetImage("Trans_GrpNormal/GrpName/Img_Line")
  self.mTrans_Title = self:GetRectTransform("GrpTittle")
  self.mTrans_GrpUp = self:GetRectTransform("Trans_GrpUp")
  self.mTrans_GrpNormal = self:GetRectTransform("Trans_GrpNormal")
  self.mText_NormalTitle = self:GetText("Trans_GrpNormal/GrpName/Text_Details")
  self.mText_NormalRate = self:GetText("Trans_GrpNormal/GrpName/Text_Up")
  self.mTrans_NormalLine = self:GetRectTransform("Trans_GrpNormal/ImgLine")
  self.mTrans_GrpNormalChr = self:GetRectTransform("Trans_GrpNormal/Trans_GrpChr")
  self.mTrans_GrpNormalWeapon = self:GetRectTransform("Trans_GrpNormal/Trans_GrpWeapon")
  self.mText_UpTitle = self:GetText("Trans_GrpUp/GrpName/Text_Details")
  self.mText_UpRate = self:GetText("Trans_GrpUp/GrpName/Text_Up")
  self.mTrans_UpContent = self:GetRectTransform("Trans_GrpUp/Trans_GrpChrWeaponUp")
end
function UIGachaInfoItem:InitCtrl(root)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Gashapon/GachaInfoItem.prefab", self))
  self:SetRoot(obj.transform)
  obj.transform:SetParent(root, false)
  obj.transform.localScale = vectorone
  self:__InitCtrl()
end
function UIGachaInfoItem:SetNormalItem(instObj, itemData, isChr)
  local txtName = instObj:Find("Text_Name"):GetComponent(typeof(CS.UnityEngine.UI.Text))
  local imgRank = instObj:Find("GrpQulityBg/Img_Quality"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  local imgRankBg = instObj:Find("GrpQulityBg/Img_QualityBg"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  local btn = instObj.transform:GetComponent(typeof(CS.UnityEngine.UI.GFButton))
  txtName.text = itemData.name.str
  imgRank.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
  imgRank.color = Color(imgRank.color.r, imgRank.color.g, imgRank.color.b, 0.3058823529411765)
  imgRankBg.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
  setactive(instObj:Find("Trans_GrpChr"), isChr)
  setactive(instObj:Find("Trans_GrpWeapon"), not isChr)
  if isChr then
    local icon = instObj:Find("Trans_GrpChr/Img_Chr"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    icon.sprite = ResSys:GetAtlasSprite("Icon/Avatar/Avatar_Bust_" .. itemData.code)
    UIUtils.GetButtonListener(btn.gameObject).onClick = function()
      local listType = CS.System.Collections.Generic.List(CS.System.Int32)
      local mlist = listType()
      mlist:Add(itemData.id)
      mlist:Add(FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
      mlist:Add(self.gachaId)
      SceneSwitch:SwitchByID(4001, false, mlist)
    end
  else
    local icon = instObj:Find("Trans_GrpWeapon/Img_Weapon"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    icon.sprite = IconUtils.GetWeaponNormalSprite(itemData.res_code)
    UIUtils.GetButtonListener(btn.gameObject).onClick = function()
      local param = {
        itemData.id,
        UIWeaponGlobal.WeaponPanelTab.Info,
        true,
        UIWeaponPanel.OpenFromType.GachaPreview,
        needReplaceBtn = false
      }
      UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
    end
  end
end
function UIGachaInfoItem:SetUpItem(instObj, itemData, isChr)
  local txtName = instObj:Find("Text_Name"):GetComponent(typeof(CS.UnityEngine.UI.Text))
  local imgBg = instObj:Find("GrpBg/Img_Bg"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  local btn = instObj.transform:GetComponent(typeof(CS.UnityEngine.UI.GFButton))
  txtName.text = itemData.name.str
  setactive(instObj:Find("Trans_GrpChr"), isChr)
  setactive(instObj:Find("Trans_GrpWeapon"), not isChr)
  imgBg.sprite = IconUtils.GetAtlasV2("GashaponPic", self.upBgSprite[itemData.rank])
  if isChr then
    local icon = instObj:Find("Trans_GrpChr/Img_Chr"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    icon.sprite = ResSys:GetAtlasSprite("Icon/Avatar/Avatar_Bust_" .. itemData.code)
    UIUtils.GetButtonListener(btn.gameObject).onClick = function()
      local listType = CS.System.Collections.Generic.List(CS.System.Int32)
      local mlist = listType()
      mlist:Add(itemData.id)
      mlist:Add(FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
      mlist:Add(self.gachaId)
      SceneSwitch:SwitchByID(4001, false, mlist)
    end
  else
    local icon = instObj:Find("Trans_GrpWeapon/Img_Weapon"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    icon.sprite = IconUtils.GetWeaponNormalSprite(itemData.res_code)
    UIUtils.GetButtonListener(btn.gameObject).onClick = function()
      local param = {
        itemData.id,
        UIWeaponGlobal.WeaponPanelTab.Info,
        true,
        UIWeaponPanel.OpenFromType.GachaPreview,
        needReplaceBtn = false
      }
      UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
    end
  end
end
function UIGachaInfoItem:SetData(type, data)
  setactive(self.mTrans_Title, type ~= UIGachaInfoItem.ItemInfoType.Rate)
  setactive(self.mTrans_GrpUp, type == UIGachaInfoItem.ItemInfoType.UpRate)
  setactive(self.mTrans_GrpNormal, type == UIGachaInfoItem.ItemInfoType.Rate)
  if type == UIGachaInfoItem.ItemInfoType.Rate then
    self.gachaId = data.gachaId
    self.mImg_NormalLine.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    self.mText_NormalRate.text = data.rate * 100 .. "%"
    local titleStr = {}
    setactive(self.mTrans_GrpNormalChr, false)
    setactive(self.mTrans_GrpNormalWeapon, false)
    if data.chrTable[data.rank] then
      setactive(self.mTrans_GrpNormalChr, true)
      local itemPrefab = self.mTrans_GrpNormalChr:GetComponent(typeof(CS.ScrollListChild))
      table.insert(titleStr, self.hintTable.Chr[data.rank])
      for _, id in pairs(data.chrTable[data.rank]) do
        local instObj = instantiate(itemPrefab.childItem, self.mTrans_GrpNormalChr)
        local itemData = TableData.listGunDatas:GetDataById(id)
        self:SetNormalItem(instObj, itemData, true)
      end
    end
    if data.weaponTable[data.rank] then
      setactive(self.mTrans_GrpNormalWeapon, true)
      local itemPrefab = self.mTrans_GrpNormalWeapon:GetComponent(typeof(CS.ScrollListChild))
      table.insert(titleStr, self.hintTable.Weapon[data.rank])
      for _, id in pairs(data.weaponTable[data.rank]) do
        local instObj = instantiate(itemPrefab.childItem, self.mTrans_GrpNormalWeapon)
        local itemData = TableData.listGunWeaponDatas:GetDataById(id)
        self:SetNormalItem(instObj, itemData, false)
      end
    end
    setactive(self.mTrans_NormalLine, #titleStr == 2)
    if #titleStr == 1 then
      self.mText_NormalTitle.text = TableData.GetHintById(titleStr[1])
    else
      self.mText_NormalTitle.text = TableData.GetHintById(titleStr[1]) .. "/" .. TableData.GetHintById(titleStr[2])
    end
  elseif type == UIGachaInfoItem.ItemInfoType.UpRate then
    self.gachaId = data.gachaId
    self.mText_Title.text = "概率提升"
    self.mImg_UpLine.color = TableData.GetGlobalGun_Quality_Color2(data.rank)
    local title
    local itemPrefab = self.mTrans_UpContent:GetComponent(typeof(CS.ScrollListChild))
    if data.isChr then
      title = TableData.GetHintById(self.hintTable.Chr[data.rank])
      for _, id in pairs(data.items) do
        local itemData = TableData.listGunDatas:GetDataById(id)
        local instObj = instantiate(itemPrefab.childItem, self.mTrans_UpContent)
        self:SetUpItem(instObj, itemData, true)
      end
    else
      title = TableData.GetHintById(self.hintTable.Weapon[data.rank])
      for _, id in pairs(data.items) do
        local instObj = instantiate(itemPrefab.childItem, self.mTrans_UpContent)
        local itemData = TableData.listGunWeaponDatas:GetDataById(id)
        self:SetUpItem(instObj, itemData, false)
      end
    end
    self.mText_UpTitle.text = title
    self.mText_UpRate.text = string_format(TableData.GetHintById(107041), title, data.rate * 100 .. "%")
  else
    self.mText_Title.text = data.str
  end
end
