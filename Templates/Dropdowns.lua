TabardyNumberedColorSwatchMixin = {};

function TabardyNumberedColorSwatchMixin:Init(data)
    self.Selected = data.Selected;
    self.Index = data.Index;
    self.Color = data.Color;
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

TabardyDropdownButtonMixin = CreateFromMixins(WowStyle2DropdownMixin);

function TabardyDropdownButtonMixin:OnLoad()
    self.Text = self.SelectedDisplay.Text; -- alias Text key to our replacement
    self.resizeToText = false;

    self.EnabledTextColor = WHITE_FONT_COLOR;
    self.DisabledTextColor = DISABLED_FONT_COLOR;

    WowStyle2DropdownMixin.OnLoad(self); -- call original OnLoad

    self:SetDefaultText(1);
    self:SetLabel("Icon Color");

    self.SelectedDisplay:SetSwatchColor(TRANSMOGRIFY_FONT_COLOR);
    self.SelectedDisplay:SetSelectedTextureShown(false);
end

function TabardyDropdownButtonMixin:SetLabel(text)
    self.Label:SetText(text);
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