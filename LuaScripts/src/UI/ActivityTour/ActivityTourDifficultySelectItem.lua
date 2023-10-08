require("UI.UIBaseCtrl")
ActivityTourDifficultySelectItem = class("ActivityTourDifficultySelectItem", UIBaseCtrl)
ActivityTourDifficultySelectItem.__index = ActivityTourDifficultySelectItem
function ActivityTourDifficultySelectItem:ctor()
end
function ActivityTourDifficultySelectItem:InitCtrl(parent, hintId)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("ActivityTour/ActivityTourDifficultySelectItem.prefab", self))
  UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.ui.mText_Name.text = TableData.GetHintById(hintId)
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ActivityTourEnemyInfoDialog, {
      levelStageData = self.levelStageData
    })
  end
end
function ActivityTourDifficultySelectItem:SetData(iconName, desc, index, levelStageData)
  self.index = index
  self.levelStageData = levelStageData
  self.ui.mText_Describe.text = desc
  setactive(self.ui.mBtn_Detail.gameObject, index == 4)
  self.ui.mImg_Icon.sprite = IconUtils.GetActivityThemeSprite(iconName)
end
