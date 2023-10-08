require("UI.UIBaseCtrl")
Btn_ArchivesCenterDarkzoneItemV2 = class("Btn_ArchivesCenterDarkzoneItemV2", UIBaseCtrl)
Btn_ArchivesCenterDarkzoneItemV2.__index = Btn_ArchivesCenterDarkzoneItemV2
function Btn_ArchivesCenterDarkzoneItemV2:ctor(root)
end
function Btn_ArchivesCenterDarkzoneItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self.ui.itemUIList = {}
  self:SetRoot(instObj.transform)
end
function Btn_ArchivesCenterDarkzoneItemV2:SetData(data)
  if data == nil then
    setactive(self.ui.mTrans_None.gameObject, true)
    setactive(self.ui.mTrans_Record.gameObject, false)
  else
    local seasonData = TableData.listDarkzoneSeasonDatas:GetDataById(data.args[0])
    if seasonData then
      self.ui.mText_Name.text = seasonData.name.str
      self.ui.mImg_Pic.sprite = IconUtils.GetArchivesIcon(seasonData.mothly_img)
    end
    self.ui.mText_Old.text = CS.CGameTime.ConvertLongToDateTime(data.OpenTime):ToString("yyyy.MM.dd")
    self.ui.mText_Now.text = CS.CGameTime.ConvertLongToDateTime(data.CloseTime):ToString("yyyy.MM.dd")
    local isIncludeMe = NetCmdArchivesData:IsIncludeMe(data.id)
    setactive(self.ui.mTrans_ImgComplete.gameObject, isIncludeMe)
    setactive(self.ui.mTrans_UnRecord.gameObject, not isIncludeMe)
    setactive(self.ui.mTrans_None.gameObject, false)
    setactive(self.ui.mTrans_Record.gameObject, true)
    UIUtils.GetButtonListener(self.ui.mBtn_ArchivesCenterDarkzoneItemV2.gameObject).onClick = function()
      if not isIncludeMe then
        CS.PopupMessageManager.PopupString(TableData.GetHintById(120022))
        return
      end
      UIManager.OpenUIByParam(UIDef.ArchivesCenterDarkzoneDialogV2, {planData = data, seasonData = seasonData})
    end
  end
end
