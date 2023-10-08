require("UI.Common.UICommonLeftTabItemV2")
require("UI.UIBaseCtrl")
UIMailLeftTabItemV2 = class("UIMailLeftTabItemV2", UIBaseCtrl)
UIMailLeftTabItemV2.__index = UIMailLeftTabItemV2
UIMailLeftTabItemV2.mMailType = 0
UIMailLeftTabItemV2.mIsRead = false
UIMailLeftTabItemV2.mImg_Nor = nil
UIMailLeftTabItemV2.mText_Name = nil
UIMailLeftTabItemV2.mTrans_ImgNor = nil
UIMailLeftTabItemV2.mTrans_RedPoint = nil
function UIMailLeftTabItemV2:__InitCtrl()
end
function UIMailLeftTabItemV2:InitCtrl(root)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIMailLeftTabItemV2:InitData(data)
  self.mData = data
  self.ui.mText_Name.text = data.title
  if data.IsExpired == true then
    setactive(self:GetRoot().gameObject, false)
  end
  self.mMailType = 0
  if data.hasLink == true then
    self.mMailType = 2
  end
  if data.hasAttachment then
    local isTimeOut = false
    local attachments = self.mData.attachments
    local totalCount = self.mData.ttachmentNum
    local timeOutCount = 0
    for k, v in pairs(attachments) do
      local itemData = TableData.GetItemData(k)
      local itemTime = itemData.time_limit
      if 0 < itemTime and UIUtils.CheckIsTimeOut(itemTime) then
        timeOutCount = timeOutCount + 1
      end
    end
    isTimeOut = timeOutCount == totalCount
    self.mMailType = 1
    if isTimeOut then
      self.mIsRead = data.read == 1
    else
      self.mIsRead = 0 < self.mData.get_attachment
    end
  else
    self.mIsRead = data.read == 1
  end
  self.ui.mText_Num.text = UICommonLeftTabItemV2.GetRandomNum()
  self:ClearAttachment()
end
function UIMailLeftTabItemV2:SetData(data)
  self.mData = data
end
function UIMailLeftTabItemV2:Select()
  UIUtils.SetInteractive(self.mUIRoot, false)
end
function UIMailLeftTabItemV2:UnSelect()
  UIUtils.SetInteractive(self.mUIRoot, true)
end
function UIMailLeftTabItemV2:SetRead(isRead)
  local read = self.mIsRead
  local totalCount = 0
  if self.mMailType == 1 then
    local isTimeOut = false
    local attachments = self.mData.attachments
    local timeOutCount = 0
    totalCount = self.mData.attachmentNum
    for k, v in pairs(attachments) do
      gfwarning("1 attachment " .. k)
      local itemData = TableData.GetItemData(k)
      local itemTime = itemData.time_limit
      if 0 < itemTime and UIUtils.CheckIsTimeOut(itemTime) then
        timeOutCount = timeOutCount + 1
      end
    end
    isTimeOut = timeOutCount == totalCount
    if isTimeOut then
      self.mIsRead = isRead
    else
      self.mIsRead = 0 < self.mData.get_attachment
    end
  else
    self.mIsRead = isRead
  end
  if not read and self.mIsRead then
    RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.Mails)
  end
  self:ClearAttachment()
end
function UIMailLeftTabItemV2:ClearAttachment()
  setactive(self.ui.mTrans_RedPoint.gameObject, not self.mIsRead)
  self.ui.mAnimator:SetBool("Read", self.mIsRead)
end
