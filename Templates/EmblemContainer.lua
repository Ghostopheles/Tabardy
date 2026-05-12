TabardyEmblemContainerMixin = {};

function TabardyEmblemContainerMixin:UpdateSize()
    local h = self:GetHeight();

    self.TopLeft:SetPoint("TOPLEFT");
    self.TopLeft:SetPoint("BOTTOMRIGHT", self, "CENTER", 0, 0);

    self.TopRight:SetPoint("TOPRIGHT");
    self.TopRight:SetPoint("BOTTOMLEFT", self.TopLeft, "BOTTOMRIGHT");

    self.BottomLeft:SetPoint("BOTTOMLEFT");
    self.BottomLeft:SetPoint("TOPRIGHT", self.TopLeft, "BOTTOMRIGHT");

    self.BottomRight:SetPoint("BOTTOMRIGHT");
    self.BottomRight:SetPoint("TOPLEFT", self.TopLeft, "BOTTOMRIGHT");
end

function TabardyEmblemContainerMixin:SetEmblem(emblemID, colorID)
    colorID = colorID or TabardyDesigner:GetSelectedEmblemColorID();
    local textures = Tabardy.GetTexturesForEmblemAndColor(emblemID, colorID);
    table.sort(textures);

    self.TopLeft:SetTexture(textures[2]);
    self.BottomLeft:SetTexture(textures[1]);

    self.TopRight:SetTexture(textures[2]);
    self.BottomRight:SetTexture(textures[1]);

    self:UpdateSize();
end