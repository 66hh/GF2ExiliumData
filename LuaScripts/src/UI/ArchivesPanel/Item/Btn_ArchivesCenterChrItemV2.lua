require("UI.UIBaseCtrl")
Btn_ArchivesCenterChrItemV2 = class("Btn_ArchivesCenterChrItemV2", UIBaseCtrl)
Btn_ArchivesCenterChrItemV2.__index = Btn_ArchivesCenterChrItemV2
function Btn_ArchivesCenterChrItemV2:ctor()
end
function Btn_ArchivesCenterChrItemV2:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function Btn_ArchivesCenterChrItemV2:SetData(data, index)
  if data.type == 1 and data.unit_id.Count > 0 then
    local gunData = TableData.listGunDatas:GetDataById(data.unit_id[0])
    if gunData then
      local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.duty)
      self.ui.mImg_Icon.sprite = IconUtils.GetGunTypeIcon(dutyData.icon)
      setactive(self.ui.mImg_Icon.gameObject, true)
    else
      setactive(self.ui.mImg_Icon.gameObject, false)
    end
  else
    setactive(self.ui.mImg_Icon.gameObject, false)
  end
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHalfSprite("Avatar", data.uien_name)
  self.ui.mText_Name.text = data.name.str
  setactive(self.ui.mImg_Icon.gameObject, data.id == 17)
  if data.unit_id.Count > 0 then
    setactive(self.ui.mTrans_RedPoint.gameObject, data.story_open and NetCmdArchivesData:CharacterPlotIsRead(data.unit_id[0], data.type))
    if data.type == CS.GF2.Data.RoleType.Gun then
      if NetCmdArchivesData:CharacterIsLock(data.unit_id[0]) then
        self.ui.mAnimator_ArchivesCenterChrItemV2:SetBool("Bool", true)
      else
        self.ui.mAnimator_ArchivesCenterChrItemV2:SetBool("Bool", false)
      end
    else
      self.ui.mAnimator_ArchivesCenterChrItemV2:SetBool("Bool", false)
    end
  else
    setactive(self.ui.mTrans_RedPoint.gameObject, false)
    self.ui.mAnimator_ArchivesCenterChrItemV2:SetBool("Bool", false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ArchivesCenterChrItemV2.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ArchivesCenterChrPanelV2, {currData = data, currIndex = index})
  end
end
