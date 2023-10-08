require("UI.UIBaseView")
UICommonGetView = class("UICommonGetView", UIBaseView)
UICommonGetView.__index = UICommonGetView
function UICommonGetView:ctor()
  self.contentList = {}
end
function UICommonGetView:__InitCtrl()
  self.mBtn_Close = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpTop/GrpClose"))
  self.mBtn_BGClose = self:GetButton("Root/GrpBg/Btn_Close")
  self.mBtn_Confirm = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpAction/BtnConfirm"))
  self.mBtn_Cancel = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpAction/BtnCancel"))
  self.mTextTitle = self:GetText("Root/GrpDialog/GrpCenter/GrpTextTittle/TextName")
  self.mTextInfo = self:GetText("Root/GrpDialog/GrpCenter/GrpTextInfo/Text_Description")
  self.mTrans_PriceDetails = self:GetRectTransform("Root/GrpDialog/GrpCenter/Trans_Btn_PriceDetails")
  self.mImg_PriceDetailsImageIcon = self:GetImage("Root/GrpDialog/GrpCenter/Trans_Btn_PriceDetails/GrpItemIcon/Img_Icon")
  self.mTxt_PriceSetailsNum = self:GetText("Root/GrpDialog/GrpCenter/Trans_Btn_PriceDetails/Text_Num")
  self.mBtn_PriceDetails = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpCenter/Trans_Btn_PriceDetails/BtnInfo"))
  self.mTrans_GrpPriceDetails = self:GetRectTransform("Root/GrpDialog/GrpCenter/Trans_GrpPriceDetails")
  self.mTrans_GrpPriceDetailsContent = self:GetRectTransform("Root/GrpDialog/GrpCenter/Trans_GrpPriceDetails/GrpAllSkillDescription/GrpDescribe/Viewport/Content")
  self.mBtn_GrpPriceDetails = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpCenter/Trans_GrpPriceDetails/BtnInfo"))
  self.mTxt_TextNum = self:GetText("Root/GrpDialog/GrpCenter/GrpTextInfo/Trans_GrpTextNum/Text_Num")
  self.mTrans_TextNum = self:GetRectTransform("Root/GrpDialog/GrpCenter/GrpTextInfo/Trans_GrpTextNum")
  for i = 1, 2 do
    local obj = self:GetRectTransform("Root/GrpDialog/GrpCenter/GrpItemList/Content/ComItem_" .. i)
    local contetn = self:InitContent(obj, i)
    table.insert(self.contentList, contetn)
  end
end
function UICommonGetView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
function UICommonGetView:InitContent(obj, index)
  local content = {}
  local transItem = obj
  content.type = index
  content.item = transItem
  content.imgIcon = UIUtils.GetImage(obj, "GrpItem/Icon")
  content.txtRemainItem = UIUtils.GetText(obj, "GrpQualityNum/GrpText_Num等级文字和数量共用（还带Icon）/Text")
  content.transChoose = UIUtils.GetRectTransform(obj, "Trans_ChooseIcon选择的勾（通用勾选）")
  content.tranSel = UIUtils.GetRectTransform(obj, "ImgSel")
  content.imgRank = UIUtils.GetImage(obj, "GrpQualityNum/GrpQualityLine品质色条")
  content.btnSelect = CS.LuaUIUtils.GetButton(transItem)
  return content
end
