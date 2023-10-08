UIStoreGlobal = {}
UIStoreGlobal.ExchangeDiamondId = 7
UIStoreGlobal.ExchangeFreeCreditId = 99
UIStoreGlobal.MaylingModel = null
function UIStoreGlobal:OpenCharge()
  MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(106023), nil, function()
    if self ~= nil then
      self.Close()
    end
    local toppanel = UISystem:GetTopPanelUI()
    if toppanel ~= nil then
      if toppanel.UIDefine.UIType == UIDef.UIStorePanel then
        MessageSys:SendMessage(UIEvent.JumpCreditCoin, nil)
      else
        UIManager.JumpUIByParam(UIDef.UIStorePanel, 12)
      end
    end
  end, function()
  end)
end
function UIStoreGlobal:SendBuy(goodData, selectedItems, num, callback)
  local id = goodData:GetStoreGoodData().id
  function self.buyCallback(ret)
    self.Close()
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
      nil,
      function()
        if goodData.price_type == 0 then
          self.parent.AddPoint = tonumber(goodData.price)
        end
      end
    })
    if callback ~= nil then
      callback(ret)
    end
    MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BuySuccess, self.buyCallback)
    self.buyCallback = nil
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.BuySuccess, self.buyCallback)
  if selectedItems ~= nil then
    NetCmdStoreData:SendStoreBuy(id, selectedItems, function(ret)
    end)
  elseif num ~= nil and 1 < num then
    NetCmdStoreData:SendStoreBuy(id, num, function(ret)
    end)
  else
    NetCmdStoreData:SendStoreBuy(id, 1, function(ret)
    end)
  end
end
function UIStoreGlobal:OnBuyClick(good, selectedItems, num, callback)
  local stcData = good:GetStoreGoodData()
  local priceType = TableData.GetItemData(stcData.price_type)
  if stcData.price_type == GlobalConfig.ResourceType.CreditFree or stcData.price_type == GlobalConfig.ResourceType.Diamond or stcData.price_type == GlobalConfig.ResourceType.CreditPay and good.price ~= "0" then
    if TableData.SystemVersionOpenData.FreePayCredit > 0 then
      UIStoreGlobal.OnConfirmJapan(self, good, selectedItems, num, callback)
    else
      UIStoreGlobal.OnConfirm(self, good, selectedItems, num, callback)
    end
  elseif stcData.price_type == 0 then
    NetCmdStoreData:SendStoreOrder(stcData.id, function(ret)
      if self ~= nil then
        self.Close()
      end
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
    end)
  else
    UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
  end
end
function UIStoreGlobal:OnConfirmJapan(good, selectedItems, num, callback)
  local stcData = good:GetStoreGoodData()
  local price = tonumber(self.mData.price)
  if stcData.price_type == GlobalConfig.ResourceType.CreditFree then
    if price > GlobalData.credit_all then
      UIStoreGlobal.OpenCharge(self)
      return
    end
    local need = GlobalData.credit_free - price
    if need < 0 then
      UIManager.OpenUIByParam(UIDef.UIJapanCreditConsumeDialog, {
        price = tonumber(self.mData.price),
        price_type = stcData.price_type,
        callback = function()
          NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeFreeCreditId, math.abs(need), function(ret)
            UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
          end)
        end
      })
      return
    else
      UIManager.OpenUIByParam(UIDef.UIJapanCreditConsumeDialog, {
        price = tonumber(self.mData.price),
        price_type = stcData.price_type,
        callback = function()
          UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
        end
      })
      return
    end
  elseif stcData.price_type == GlobalConfig.ResourceType.CreditPay then
    if price > GlobalData.credit_pay then
      UIStoreGlobal.OpenCharge(self)
      return
    end
    UIManager.OpenUIByParam(UIDef.UIJapanCreditConsumeDialog, {
      price = tonumber(self.mData.price),
      price_type = stcData.price_type,
      callback = function()
        UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
      end
    })
    return
  elseif stcData.price_type == UIStoreGlobal.Diamond and price > GlobalData.diamond then
    local needCredit = price - GlobalData.diamond
    local needPay = GlobalData.credit_free - needCredit
    MessageBox.Show(TableData.GetHintById(64), TableData.GetHintReplaceById(106043, needCredit), nil, function()
      if GlobalData.diamond + GlobalData.credit_all < price then
        UIStoreGlobal.OpenCharge(self)
        return
      end
      UIManager.OpenUIByParam(UIDef.UIJapanCreditConsumeDialog, {
        price = tonumber(self.mData.price),
        price_type = stcData.price_type,
        callback = function()
          if needPay < 0 then
            NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeFreeCreditId, math.abs(needPay), function(ret)
              NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeDiamondId, needCredit, function(ret1)
                UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
              end)
            end)
          else
            NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeDiamondId, math.abs(needCredit), function(ret)
              UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
            end)
          end
        end
      })
    end, function()
    end)
    return
  end
  UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
end
function UIStoreGlobal:OnConfirm(good, selectedItems, num, callback)
  local stcData = good:GetStoreGoodData()
  local price = tonumber(self.mData.price)
  if stcData.price_type == GlobalConfig.ResourceType.CreditFree then
    if price > GlobalData.credit_all then
      UIStoreGlobal.OpenCharge(self)
      return
    end
    local need = GlobalData.credit_free - price
    if need < 0 then
      NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeFreeCreditId, math.abs(need), function(ret)
        UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
      end)
      return
    end
  elseif stcData.price_type == UIStoreGlobal.Diamond and price > GlobalData.diamond then
    local needCredit = price - GlobalData.diamond
    local needPay = GlobalData.credit_free - needCredit
    MessageBox.Show(TableData.GetHintById(64), TableData.GetHintReplaceById(106043, needCredit), nil, function()
      if GlobalData.diamond + GlobalData.credit_all < price then
        UIStoreGlobal.OpenCharge(self)
        return
      end
      if needPay < 0 then
        NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeFreeCreditId, math.abs(needPay), function(ret)
          NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeDiamondId, needCredit, function(ret1)
            UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
          end)
        end)
      else
        NetCmdStoreData:SendStoreBuy(UIStoreGlobal.ExchangeDiamondId, math.abs(needCredit), function(ret)
          UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
        end)
      end
    end, function()
    end)
    return
  end
  UIStoreGlobal.SendBuy(self, good, selectedItems, num, callback)
end
UIStoreGlobal.LastSceneSceneType = nil
function UIStoreGlobal.SetLastSceneSceneType(sceneType)
  if UIStoreGlobal.LastSceneSceneType == sceneType or sceneType == EnumSceneType.Store then
    return
  end
  UIStoreGlobal.LastSceneSceneType = sceneType
end
function UIStoreGlobal.GetLastSceneSceneType()
  return UIStoreGlobal.LastSceneSceneType
end
