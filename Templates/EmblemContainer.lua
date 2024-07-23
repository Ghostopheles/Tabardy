TabardyEmblemContainerMixin = {};

function TabardyEmblemContainerMixin:UpdateSize()
    local h = self:GetHeight();
    local heightOffset = 0.12 * h;

    self.TopLeft:SetPoint("TOPLEFT");
    self.TopLeft:SetPoint("BOTTOMRIGHT", self, "CENTER", 0, -heightOffset);

    self.TopRight:SetPoint("TOPRIGHT");
    self.TopRight:SetPoint("BOTTOMLEFT", self.TopLeft, "BOTTOMRIGHT");

    self.BottomLeft:SetPoint("BOTTOMLEFT");
    self.BottomLeft:SetPoint("TOPRIGHT", self.TopLeft, "BOTTOMRIGHT");

    self.BottomRight:SetPoint("BOTTOMRIGHT");
    self.BottomRight:SetPoint("TOPLEFT", self.TopLeft, "BOTTOMRIGHT");
end

function TabardyEmblemContainerMixin:SetEmblem(emblemID)
    local selectedColor = TabardyDesigner:GetSelectedEmblemColorID();
    local textures = Tabardy.GetTexturesForEmblemAndColor(emblemID, selectedColor);
    DevTools_Dump(textures);
end