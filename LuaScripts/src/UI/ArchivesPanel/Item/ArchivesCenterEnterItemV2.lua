require("UI.UIBaseCtrl")
ArchivesCenterEnterItemV2 = class("ArchivesCenterEnterItemV2", UIBaseCtrl)
ArchivesCenterEnterItemV2.__index = ArchivesCenterEnterItemV2
function ArchivesCenterEnterItemV2:__InitCtrl()
end
function ArchivesCenterEnterItemV2:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
function ArchivesCenterEnterItemV2:SetData(data)
  self.mData = data
  local isunlock = data.unlock > 0 and AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock)
  if not isunlock then
    setactive(self.ui.mTrans_Lock, true)
    setactive(self.ui.mTrans_RedPoint, false)
  else
    setactive(self.ui.mTrans_Lock, false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnClickSelf()
  end
  self.ui.mImg_Bg.sprite = IconUtils.GetAtlasSprite("ArchivesCenter/" .. data.icon)
  self.ui.mText_Tittle.text = data.name.str
  self.ui.mText_Detail.text = data.des.str
  if data.Id == 1 then
    setactive(self.ui.mTrans_RedPoint, NetCmdArchivesData:CharacterHaveRed())
  elseif data.Id == 2 then
    setactive(self.ui.mTrans_RedPoint, NetCmdArchivesData:PlotBranchIsHaveRed())
  end
end
function ArchivesCenterEnterItemV2:OnClickSelf()
  if self.mData.unlock == 0 then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(111010))
    return
  elseif self.mData.unlock > 0 and not AccountNetCmdHandler:CheckSystemIsUnLock(self.mData.unlock) then
    local unlockData = TableDataBase.listUnlockDatas:GetDataById(self.mData.unlock)
    if unlockData then
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      PopupMessageManager.PopupString(str)
    end
    return
  elseif self.mData.Id == 1 then
    NetCmdArchivesData:SendCharacterAvgReadInfo(function(ret)
      if ret == ErrorCodeSuc then
        UIManager.OpenUI(UIDef.ArchivesCenterChrEnterPanelV2)
      end
    end)
  elseif self.mData.Id == 2 then
    UIManager.OpenUI(UIDef.ArchivesCenterAtlasPanelV2)
  elseif self.mData.Id == 3 then
  end
end
