QuickStorePurchase = {}
local this = QuickStorePurchase
QuickStorePurchase.mCurRedirectTag = 0
function QuickStorePurchase:QuickPurchase(good_id, num, hint_id, cur_panel, OnBuyCallback, OnCancel, ...)
  local goodPrice = "-"
  local storeGoods = NetCmdStoreData:GetStoreGoodById(good_id)
  if storeGoods ~= nil then
    goodPrice = formatnum(tonumber(storeGoods.price))
  else
    gferror("未知的商品ID：" .. good_id .. "!!")
    return
  end
  local totalPrice = goodPrice * num
  local diamond = NetTeamHandle:GetMaintainResDiomandNum()
  local isOutOfDiamond = false
  if totalPrice > diamond then
    isOutOfDiamond = true
  end
  local params = {}
  params[1] = good_id
  params[2] = num
  params[3] = OnBuyCallback
  params[4] = isOutOfDiamond
  params[5] = cur_panel
  params[6] = OnCancel
  local hint = TableData.GetHintById(hint_id)
  local msg = string_format(hint, totalPrice, TableData.GetItemData(1).name.str, num, TableData.GetItemData(self.mCurGachaData.CostItemID).name.str, ...)
  MessageBox.Show("注意", msg, params, QuickStorePurchase.OnBuyTicket, OnCancel)
end
function QuickStorePurchase.RedirectToStoreTag(tag_id, cur_panel)
  gfdebug("RedirectToStoreTag")
  self = QuickStorePurchase
  self.mCurRedirectTag = tag_id
  UIManager.OpenUI(UIDef.UIStoreMainPanel)
  self.mCurRedirectTag = 0
end
function QuickStorePurchase.OnBuyTicket(params)
  local isOutOfDiamond = params[4]
  if isOutOfDiamond == true then
    local msg = TableData.GetHintById(225)
    local name = TableData.GetItemData(1).Name.str
    local msg = UIUtils.StringFormat(msg, name)
    CS.PopupMessageManager.PopupString(msg)
    return
  end
  NetCmdStoreData:SendStoreBuy(params[1], params[2], params[3])
end
function QuickStorePurchase.OnGoToStore(cur_panel)
  self = QuickStorePurchase
  UIManager.OpenUI(UIDef.UIStoreMainPanel)
end
