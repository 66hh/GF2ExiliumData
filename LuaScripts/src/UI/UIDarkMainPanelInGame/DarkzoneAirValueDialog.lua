require("UI.UIBaseCtrl")
local EnumDarkzoneProperty = require("UI.UIDarkMainPanelInGame.DarkzoneProperty")
DarkzoneAirValueDialog = class("DarkzoneAirValueDialog", UIBaseCtrl)
DarkzoneAirValueDialog.__index = DarkzoneAirValueDialog
function DarkzoneAirValueDialog:__InitCtrl()
end
function DarkzoneAirValueDialog:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  self.obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self.show = false
end
function DarkzoneAirValueDialog:SetData(data, closeFun)
  self.show = true
  self:InitBaseData(closeFun)
  self:InitUI(data)
  self:AddListen()
end
function DarkzoneAirValueDialog:InitBaseData(closeFun)
  self.CloseFun = closeFun
  function self.RefreshFun(msg)
    self:RefreshDarkzoneProperty(msg)
  end
  self.showIndex = nil
end
function DarkzoneAirValueDialog:AddListen()
  self.ui.mBtn_Close.onClick:AddListener(self.CloseFun)
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.RefreshDarkzoneProperty, self.RefreshFun)
end
function DarkzoneAirValueDialog:InitUI(data)
  self.questId = data[1]
  self.airMax = data[2]
  local endlessData = TableData.listDzEndlessModeDatas:GetDataById(self.questId)
  self.segmentNum = endlessData.result_divide
  self.segmentAirLs = {}
  self.segmentAirLs[1] = 0
  for i = 0, self.segmentNum - 1 do
    local segmentAir = endlessData.result_divide_num[i]
    self.segmentAirLs[i + 2] = segmentAir
  end
  self.maxWidth = 300
  self.valueBeginWidth = -(self.maxWidth / 2)
  self.TextLs = {}
  for i = 1, #self.segmentAirLs do
    local airValue = self.segmentAirLs[i]
    local prefabObj = self.ui.mText_AirSegment.gameObject
    local instObj = instantiate(prefabObj, prefabObj.transform.parent, false)
    instObj.gameObject.transform.localPosition = CS.UnityEngine.Vector3(self.valueBeginWidth + airValue / self.airMax * self.maxWidth, 0, 0)
    instObj.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text)).text = airValue
    setactive(instObj, true)
    self.TextLs[i] = instObj
  end
  self.LineLs = {}
  if self.segmentNum <= 3 then
    local count = #self.segmentAirLs
    self.ui.mLayout_Red.minWidth = (self.segmentAirLs[2] - self.segmentAirLs[1]) / self.airMax * self.maxWidth
    self.ui.mLayout_Blue.minWidth = (self.segmentAirLs[count] - self.segmentAirLs[count - 1]) / self.airMax * self.maxWidth
    self.ui.mLayout_Yellow.minWidth = (self.segmentAirLs[3] - self.segmentAirLs[2]) / self.airMax * self.maxWidth
    setactive(self.ui.mLayout_Yellow.gameObject, self.segmentNum == 3)
  else
    local addNum = self.segmentNum - 3
    for i = 1, addNum do
      local prefabObj = self.ui.mLayout_Yellow.gameObject
      local instObj = instantiate(prefabObj, prefabObj.transform.parent, false)
      instObj.gameObject:GetComponent(typeof(CS.UnityEngine.UI.LayoutElement)).minWidth = (self.segmentAirLs[2 + i] - self.segmentAirLs[1 + i]) / self.airMax * self.maxWidth
      self.LineLs[i] = instObj
    end
  end
  self.desItemLs = {}
  for i = self.segmentNum, 0, -1 do
    local prefabObj = self.ui.mTran_ItemRoot.childItem
    local instObj = instantiate(prefabObj, self.ui.mTran_ItemRoot.transform, false)
    local itemUI = {}
    self:LuaUIBindTable(instObj, itemUI)
    self:SetSegmentDes(endlessData, i, itemUI)
    self.desItemLs[self.segmentNum - i + 1] = itemUI
  end
  local cur = CS.SysMgr.dzPlayerMgr.MainPlayer:GetProperty(EnumDarkzoneProperty.Property.DzOxygen)
  self:SetAirValueChange(cur)
end
function DarkzoneAirValueDialog:SetSegmentDes(endlessData, index, itemUI)
  local desStr
  if index == 0 then
    desStr = string.split(endlessData.result_desc1, "|")
  elseif index == 1 then
    desStr = string.split(endlessData.result_desc2, "|")
  elseif index == 2 then
    desStr = string.split(endlessData.result_desc3, "|")
  elseif index == 3 then
    desStr = string.split(endlessData.result_desc4, "|")
  elseif index == 4 then
    desStr = string.split(endlessData.result_desc5, "|")
  elseif index == 5 then
    desStr = string.split(endlessData.result_desc6, "|")
  end
  if desStr == nil or #desStr ~= 2 then
    itemUI.mText_Name.text = "Error !"
    itemUI.mText_Desc.text = "Check Config !"
  else
    itemUI.mText_Name.text = desStr[1]
    itemUI.mText_Desc.text = desStr[2]
  end
end
function DarkzoneAirValueDialog:RefreshDarkzoneProperty(msg)
  local type = msg.Sender
  local value = type.value__
  local additon = math.floor(msg.Content)
  if value == EnumDarkzoneProperty.Property.DzOxygen then
    self:SetAirValueChange(additon)
  end
end
function DarkzoneAirValueDialog:SetAirValueChange(cur)
  local count = self.segmentNum + 1
  local curIndex = count
  if cur ~= 0 then
    for i = 2, #self.segmentAirLs do
      if cur <= self.segmentAirLs[i] then
        curIndex = count + 1 - i
        break
      end
    end
  end
  self.ui.mText_AirValue.text = cur
  local cuePos = self.ui.mTran_AirValueRoot.anchoredPosition
  self.ui.mTran_AirValueRoot.anchoredPosition = CS.UnityEngine.Vector2(self.valueBeginWidth + self.maxWidth * (cur / self.airMax), cuePos.y)
  if self.showIndex == nil then
    for i = 1, #self.desItemLs do
      self.desItemLs[i].mAni_Root:SetBool("Now", curIndex == i)
    end
  elseif self.showIndex ~= curIndex then
    self.desItemLs[self.showIndex].mAni_Root:SetBool("Now", false)
    self.desItemLs[curIndex].mAni_Root:SetBool("Now", true)
  end
  self.showIndex = curIndex
end
function DarkzoneAirValueDialog:OnClose()
  self.show = false
  if self.RefreshFun ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.RefreshDarkzoneProperty, self.RefreshFun)
    self.RefreshFun = nil
  end
  if self.CloseFun ~= nil then
    self.ui.mBtn_Close.onClick:RemoveListener(self.CloseFun)
    self.CloseFun = nil
  end
  self.questId = nil
  self.airMax = nil
  self.segmentAirLs = nil
  self.maxWidth = nil
  self.valueBeginWidth = nil
  self.valueStepWidth = nil
  self.segmentNum = nil
  if self.TextLs ~= nil then
    for i = 1, #self.TextLs do
      gfdestroy(self.TextLs[i].gameObject)
    end
    self.TextLs = nil
  end
  if self.LineLs ~= nil then
    for i = 1, #self.LineLs do
      gfdestroy(self.LineLs[i].gameObject)
    end
    self.LineLs = nil
  end
  if self.desItemLs ~= nil then
    for i = 1, #self.desItemLs do
      gfdestroy(self.desItemLs[i].mUIRoot.gameObject)
    end
    self.desItemLs = nil
  end
end
function DarkzoneAirValueDialog:OnRelease()
  self:OnClose()
  self.obj = nil
  self.ui = nil
  self.show = nil
end
