require("UI.StorePanel.UIStoreConfirmPanel")
require("UI.UIBaseCtrl")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UIStoreBuySkinItem = class("UIStoreBuySkinItem", UIBaseCtrl)
UIStoreBuySkinItem.__index = UIStoreBuySkinItem
function UIStoreBuySkinItem:__InitCtrl()
end
function UIStoreBuySkinItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("StoreExchange/Btn_StoreSkinItem.prefab", self))
  setparent(parent, obj.transform)
  obj.transform.localScale = vectorone
  obj.transform.localPosition = vectorzero
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function UIStoreBuySkinItem:SetData(data, parent)
  if data == nil then
    setactive(self.mUIRoot, false)
    return
  end
  setactive(self.mUIRoot, true)
  self.mData = data
  self.stcData = data:GetStoreGoodData()
  if self.stcData.price_type == UIStoreConfirmPanel.REAL_MONEY_ID then
    self.ui.mText_CostNewNum.text = "¥ " .. data.price
  else
    self.ui.mText_CostNewNum.text = data.price
  end
  setactive(self.ui.mTrans_Text, self.stcData.price_args_type == 3 and tonumber(data.price) < data.base_price)
  if self.stcData.price_args_type == 3 then
    self.ui.mText_Text.text = math.floor(data.base_price)
  end
  if data.price_args_type == 3 and data.price ~= data.base_price then
    local discount = math.floor((data.base_price - tonumber(data.price)) / data.base_price * 100 + 0.5)
    setactive(self.ui.mTrans_GrpDiscount.gameObject, discount < 100 and not self.isLocked)
    self.ui.mText_Num2.text = data.base_price
    if data.price == 0 then
      self.ui.mText_Num2.text = "-" .. 100 .. "%"
    else
      self.ui.mText_Num2.text = "-" .. discount .. "%"
    end
  end
  self.ui.mText_Name.text = self.stcData.name.str
  local itemId = self.mData.ItemNumList[0].itemid
  local itemData = TableData.GetItemData(itemId)
  if itemData ~= nil then
    self.mClothesData = TableDataBase.listClothesDatas:GetDataById(tonumber(itemData.args[0]))
    self.ui.mImg_Bg.sprite = IconUtils.GetSkinSprite("Img_ChrSkinPic_" .. self.mClothesData.code)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Root.transform).onClick = function()
    if self.mClothesData ~= nil then
      if self.mData.IsShowTime == true then
        local list = new_array(typeof(CS.System.Int32), 4)
        list[0] = self.mClothesData.gun
        list[1] = FacilityBarrackGlobal.ShowContentType.UIShopClothes
        list[2] = self.mClothesData.id
        list[3] = self.mData.id
        local jumpParam = CS.BarrackPresetJumpParam(1, self.mClothesData.gun, list)
        JumpSystem:Jump(EnumSceneType.Barrack, jumpParam)
      else
        UIUtils.PopupHintMessage(260048)
      end
    end
  end
  self:Refresh()
end
function UIStoreBuySkinItem:Refresh()
  local itemId = self.mData.ItemNumList[0].itemid
  local itemData = TableData.GetItemData(itemId)
  if itemData == nil then
    return
  end
  local skinCount = NetCmdIllustrationData:GetCountByTypeAndItemId(tonumber(GlobalConfig.ItemType.Costume), tonumber(itemData.args[0]))
  setactive(self.ui.mImg_Icon, skinCount == 0)
  setactive(self.ui.mTrans_Text, skinCount == 0 and self.stcData.price_args_type == 3 and tonumber(self.mData.price) < self.mData.base_price)
  setactive(self.ui.mText_CostNewNum, skinCount == 0)
  setactive(self.ui.mTrans_TextHave, skinCount ~= 0)
  setactive(self.ui.mTrans_New, self.mData.IsNew and skinCount == 0)
  setactive(self.ui.mTrans_GrpLimitTime, false)
  if self.mData.IsToOutStock == true then
    setactive(self.ui.mTrans_GrpLimitTime, skinCount == 0)
    self.ui.mText_Time.text = self.mData.left_time
  end
  setactive(self.ui.mTrans_State, skinCount == 0)
  self.ui.mImg_BottomLine.color = TableData.GetGlobalGun_Quality_Color2(self.mClothesData.rare)
  setactive(self.ui.mTrans_Several, self.mClothesData.clothes_type == 1)
  setactive(self.ui.mTrans_All, self.mClothesData.clothes_type == 2)
end
function UIStoreBuySkinItem:Update()
  if self.mData ~= nil and self.mData.IsToOutStock == true then
    self.ui.mText_Time.text = self.mData.left_time
  end
end
