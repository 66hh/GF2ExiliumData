require("UI.UIBaseCtrl")
ArchivesCenterCGPicturesItemV2 = class("ArchivesCenterCGPicturesItemV2", UIBaseCtrl)
ArchivesCenterCGPicturesItemV2.__index = ArchivesCenterCGPicturesItemV2
function ArchivesCenterCGPicturesItemV2:ctor()
end
function ArchivesCenterCGPicturesItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ArchivesCenterCGPicturesItemV2:SetData(data)
  setactive(self.ui.mTrans_Lock.gameObject, false)
  setactive(self.ui.mTrans_Unlock.gameObject, false)
  setactive(self.ui.mTrans_Text.gameObject, false)
  setactive(self.ui.mTrans_Locked.gameObject, false)
  self.ui.mText_Name.text = data.name.str
  self.ui.mImg_CGPicture.sprite = ResSys:GetCGSprte(data.img)
  local avgData = TableData.listAvgDatas:GetDataById(data.stageId)
  if avgData then
    if NetCmdArchivesData:MainStoryIsUnLock(avgData.condition) then
      self.ui.mBtn_Pic.interactable = true
      setactive(self.ui.mTrans_Text.gameObject, true)
      setactive(self.ui.mTrans_Unlock.gameObject, true)
      UIUtils.GetButtonListener(self.ui.mBtn_Pic.gameObject).onClick = function()
        self:OnClickPic(data)
      end
    else
      UIUtils.GetButtonListener(self.ui.mBtn_Pic.gameObject).onClick = function()
        UIUtils.PopupHintMessage(110016)
      end
      local stageData = TableData.listStageDatas:GetDataById(avgData.condition)
      if stageData then
        self.ui.mText_Detail.text = string_format(avgData.text, stageData.code)
      end
      setactive(self.ui.mTrans_Lock.gameObject, true)
      setactive(self.ui.mTrans_Locked.gameObject, true)
    end
  end
end
function ArchivesCenterCGPicturesItemV2:OnClickPic(data)
  UIManager.OpenUIByParam(UIDef.ArchivesCenterCGDialog, data)
end
