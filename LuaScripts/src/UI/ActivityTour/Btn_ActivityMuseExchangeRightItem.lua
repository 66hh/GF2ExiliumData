require("UI.UIBaseCtrl")
require("UI.Common.UICommonPlayerAvatarItem")
require("UI.Common.UICommonItem")
Btn_ActivityMuseExchangeRightItem = class("Btn_ActivityMuseExchangeRightItem", UIBaseCtrl)
Btn_ActivityMuseExchangeRightItem.__index = Btn_ActivityMuseExchangeRightItem
function Btn_ActivityMuseExchangeRightItem:ctor()
end
function Btn_ActivityMuseExchangeRightItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function Btn_ActivityMuseExchangeRightItem:SetData(data, themeId)
  self.data = data
  self.themeId = themeId
  UIUtils.GetButtonListener(self.ui.mBtn_ActivityMuseExchangeRightItem.gameObject).onClick = function()
    self.themeId = NetCmdRecentActivityData:GetNowOpenThemeId(self.themeId)
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    if self.needItemCount <= 0 then
      CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), UIUtils.GetItemName(self.data.Need)))
      return
    end
    UIManager.OpenUIByParam(UIDef.ActivityMuseExchangeDialog, {
      exchangeData = self.data,
      themeId = self.themeId
    })
  end
  self.needItemCount = NetCmdItemData:GetItemCountById(self.data.Need)
  self.roleData = NetCmdThemeData:GetRoleUser(data.Base)
  setactive(self.ui.mTrans_ImgMask.gameObject, self.needItemCount <= 0)
  if self.roleData then
    UIUtils.GetButtonListener(self.ui.mBtn_PlayerAvatarItem.gameObject).onClick = function()
      self:OnClickUserAvatar()
    end
    self.ui.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(TableData.GetPlayerAvatarIconById(self.roleData.Portrait, self.roleData.Sex.value__))
    if self.roleData.ReputationTitle ~= 0 then
      local titleData = TableData.listIdcardTitleDatas:GetDataById(self.roleData.ReputationTitle)
      if titleData.title.str ~= "" and titleData.icon ~= "" then
        setactive(self.ui.mTrans_S.gameObject, true)
        if self.mReputationTitle == nil then
          local prefab = self.ui.mTrans_S:GetComponent(typeof(CS.ScrollListChild))
          self.mReputationTitle = instantiate(prefab.childItem, self.ui.mTrans_S)
          local titleText = self.mReputationTitle:Find("Text_Name"):GetComponent(typeof(CS.UnityEngine.UI.Text))
          local titleImg = self.mReputationTitle:Find("Img_Bg"):GetComponent(typeof(CS.UnityEngine.UI.Image))
          titleText.text = titleData.title.str
          titleImg.sprite = IconUtils.GetPlayerTitlePic(titleData.icon)
        end
      else
        setactive(self.ui.mTrans_S.gameObject, false)
      end
    else
      setactive(self.ui.mTrans_S.gameObject, false)
    end
    self.ui.mText_Name.text = self.roleData.Name
  end
  if self.offerItem == nil then
    self.offerItem = UICommonItem.New()
    self.offerItem:InitCtrl(self.ui.mTrans_ImgItem)
  end
  setactive(self.offerItem.ui.mBtn_Select.gameObject, true)
  self.offerItem:SetItemData(data.Offer, nil, nil, nil, nil, nil, nil, function()
    UITipsPanel.Open(TableData.GetItemData(data.Offer))
  end)
  if self.needItem == nil then
    self.needItem = UICommonItem.New()
    self.needItem:InitCtrl(self.ui.mTrans_ImgItem1)
  end
  setactive(self.needItem.ui.mBtn_Select.gameObject, true)
  self.needItem:SetItemData(data.Need, nil, nil, nil, nil, nil, nil, function()
    UITipsPanel.Open(TableData.GetItemData(data.Need))
  end)
end
function Btn_ActivityMuseExchangeRightItem:OnClickUserAvatar()
  UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
    self.roleData
  })
end
function Btn_ActivityMuseExchangeRightItem:CleanItem()
  if self.playerAvatarItem then
    ResourceDestroy(self.playerAvatarItem)
    self.playerAvatarItem = nil
  end
  if self.mReputationTitle then
    ResourceDestroy(self.mReputationTitle)
    self.mReputationTitle = nil
  end
  if self.offerItem then
    ResourceDestroy(self.offerItem)
    self.offerItem = nil
  end
  if self.needItem then
    ResourceDestroy(self.needItem)
    self.needItem = nil
  end
end
