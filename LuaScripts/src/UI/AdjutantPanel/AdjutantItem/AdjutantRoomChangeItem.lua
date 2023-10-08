require("UI.UIBaseCtrl")
AdjutantRoomChangeItem = class("AdjutantRoomChangeItem", UIBaseCtrl)
local self = AdjutantRoomChangeItem
function AdjutantRoomChangeItem:ctor()
end
function AdjutantRoomChangeItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.commandBackground = nil
end
function AdjutantRoomChangeItem:SetCommandBackgroundData(commandBackground)
  self.commandBackground = commandBackground
  self.ui.mImg_Pic.sprite = UIAdjutantGlobal.GetAdjutantRoomPic(commandBackground.CommandBackgroundData.Pic)
  self.ui.mText_Name.text = commandBackground.CommandBackgroundData.Name.str
  self:UpdateItemRedPoint()
end
function AdjutantRoomChangeItem:SetSelected(boolean)
  self.ui.mBtn_Self.interactable = not boolean
  if boolean then
    if self.commandBackground.CommandBackgroundData.Type == 1 then
      UIAdjutantGlobal.CurInDoorId = self.commandBackground.CommandBackgroundData.Id
    else
      UIAdjutantGlobal.CurOutDoorId = self.commandBackground.CommandBackgroundData.Id
    end
  end
  if not self.commandBackground.IsRecive then
    NetCmdCommandCenterAdjutantData:ReciveBackground(self.commandBackground, function(ret)
      if ret == ErrorCodeSuc then
        self.commandBackground.IsRecive = true
        self:UpdateItemRedPoint()
      end
    end)
  end
end
function AdjutantRoomChangeItem:UpdateItemRedPoint()
  setactive(self.ui.mTrans_RedPoint, not self.commandBackground.IsRecive)
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.CommandCenterIndoor)
  RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.CommandCenterOutDoor)
end
function AdjutantRoomChangeItem:SetCurSelected(boolean)
  setactive(self.ui.mTrans_Selected.gameObject, boolean)
end
function AdjutantRoomChangeItem:OnRelease()
  RedPointSystem:GetInstance():RemoveRedPointListener(self.redPointType)
end
