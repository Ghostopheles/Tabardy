------------

TabardyNumberedColorSwatchMixin = {};

function TabardyNumberedColorSwatchMixin:Init(data, elementDescription, isSelected)
    self.ElementDescription = elementDescription;
    self.Selected = isSelected;
    self.Index = data.Index;
    self.Color = data.Color;
    self:Update();
end

function TabardyNumberedColorSwatchMixin:OnClick(buttonName)
    if self.ElementDescription then
        local inputContext = MenuInputContext.MouseButton;
        self.ElementDescription:Pick(inputContext, buttonName);
    end
end

function TabardyNumberedColorSwatchMixin:Update()
    self:SetNumber(self.Index);
    self:SetSwatchColor(self.Color);
    self:SetSelectedTextureShown(self.Selected);
end

function TabardyNumberedColorSwatchMixin:SetNumber(number)
    self.Text:SetText(number);
end

function TabardyNumberedColorSwatchMixin:SetSwatchColor(color)
    self.ColorSwatch:SetVertexColor(color:GetRGB());
end

function TabardyNumberedColorSwatchMixin:SetSwatchShown(show)
    self.ColorSwatch:SetShown(show);
end

function TabardyNumberedColorSwatchMixin:SetSelectedTextureShown(show)
    self.ColorSelected:SetShown(show);
end

------------

TabardyNumberedEntryMixin = {};

function TabardyNumberedEntryMixin:Init(data, elementDescription, isSelected)
    self.ElementDescription = elementDescription;
    self.Index = data.Index;
    self.IsSelected = isSelected;
    self:Update();
end

function TabardyNumberedEntryMixin:OnClick(buttonName)
    if self.ElementDescription then
        local inputContext = MenuInputContext.MouseButton;
        self.ElementDescription:Pick(inputContext, buttonName);
    end
end

function TabardyNumberedEntryMixin:Update()
    self:SetNumber(self.Index);
    self:SetSelectedTextureShown(self.Selected);
end

function TabardyNumberedEntryMixin:SetNumber(number)
    self.Text:SetText(number);
end

function TabardyNumberedEntryMixin:SetSelectedTextureShown(show)
    self.SelectedTexture:SetShown(show);
end

------------

TabardyEmblemEntryMixin = {};

function TabardyEmblemEntryMixin:Init(data, elementDescription, isSelected)
    self.ElementDescription = elementDescription;
    self.Index = data.Index;
    self.EmblemID = data.EmblemID;
    self.IsSelected = isSelected;
    self:Update();
end

function TabardyEmblemEntryMixin:OnClick(buttonName)
    if self.ElementDescription then
        local inputContext = MenuInputContext.MouseButton;
        self.ElementDescription:Pick(inputContext, buttonName);
    end
end

function TabardyEmblemEntryMixin:Update()
    self:SetNumber(self.Index);
    self:SetEmblem(self.EmblemID);
    self.SelectedTexture:SetShown(self.IsSelected);
end

function TabardyEmblemEntryMixin:SetNumber(number)
    self.Text:SetText(number);
end

function TabardyEmblemEntryMixin:SetEmblem(emblemID)
    self.Emblem:SetEmblem(emblemID);
    self.Emblem:SetSize(50, 48);
    self.Emblem:UpdateSize();
end

------------

TabardyDropdownButtonMixin = CreateFromMixins(WowStyle2DropdownMixin);

function TabardyDropdownButtonMixin:OnLoad()
    if self.SelectedDisplay then
        self.Text = self.SelectedDisplay.Text; -- alias Text key to our replacement
        self.SelectedDisplay:SetSelectedTextureShown(false);
        self.SelectedDisplay:SetMouseClickEnabled(false);
        self.SelectedDisplay:SetMouseMotionEnabled(false);
    end
    self.resizeToText = false;

    self.EnabledTextColor = WHITE_FONT_COLOR;
    self.DisabledTextColor = DISABLED_FONT_COLOR;

    self.ResetButton = {
        SetScript = nop,
        Hide = nop
    };

    WowStyle2DropdownMixin.OnLoad(self); -- call original OnLoad
end

function TabardyDropdownButtonMixin:OnButtonStateChanged()
    local enabled = self:IsEnabled();
    if enabled then
		self.Text:SetTextColor(self.EnabledTextColor:GetRGB());
	else
		self.Text:SetTextColor(self.DisabledTextColor:GetRGB());
	end

	self.Arrow:SetDesaturated(not enabled);

	self.Background:SetAtlas(self:GetBackgroundAtlas(), TextureKitConstants.UseAtlasSize);
end

function TabardyDropdownButtonMixin:SetLabel(text)
    self.Label:SetText(text);
end

function TabardyDropdownButtonMixin:UpdateToMenuSelections(menuDescription, selection)
    if not selection then
        return;
    end

    local data = selection[1].data;

    if self.SelectedDisplay then
        local text = data.Index;
        local color = data.Color;

        self.SelectedDisplay:SetNumber(text);
        self.SelectedDisplay:SetSwatchColor(color);
    else
        self.Text:SetText(data.Index);
    end
end