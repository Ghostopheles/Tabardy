TabardySimpleForwardOrBackwardSmallButtonMixin = CreateFromMixins(WowStyle2IconButtonMixin);

TabardyButtonPairMixin = {};

function TabardyButtonPairMixin:OnLoad()
    self.DecrementButton:SetScript("OnClick", function(self, _)
        TabardyDesigner:CycleCustomization(self:GetParent():GetID(), -1);
    end);
    self.IncrementButton:SetScript("OnClick", function(self, _)
        TabardyDesigner:CycleCustomization(self:GetParent():GetID(), 1);
    end);
end