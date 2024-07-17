------------

Tabardy.Debug = true;

local CUSTOMIZATION_TYPE = {
    EMBLEM = 1,
    EMBLEM_COLOR = 2,
    BORDER = 3,
    BORDER_COLOR = 4,
    BACKGROUND = 5,
};

------------

TabardyDesignerPopoutDetailsMixin = {};

function TabardyDesignerPopoutDetailsMixin:AdjustWidth(multipleColumns, defaultWidth)
	local width = defaultWidth;

	if self.ColorSwatch:IsShown() then
		if multipleColumns then
			width = self.SelectionNumber:GetWidth() + self.ColorSwatch:GetWidth() + 18;
		end
	elseif self.SelectionName:IsShown() then
		if multipleColumns then
			width = 108;
		end
	else
		if multipleColumns then
			width = 42;
		end
	end

	self:SetWidth(Round(width));
end

local function GetNormalSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	else
		return DISABLED_FONT_COLOR;
	end
end

function TabardyDesignerPopoutDetailsMixin:GetFontColors(selectionData, isSelected)
	if self.selectable then
		local fontColor = GetNormalSelectionTextFontColor(selectionData, isSelected);
		return fontColor, fontColor;
	else
		return NORMAL_FONT_COLOR, NORMAL_FONT_COLOR;
	end
end

function TabardyDesignerPopoutDetailsMixin:UpdateFontColors(selectionData, isSelected)
	local nameColor, numberColor = self:GetFontColors(selectionData, isSelected);
	self.SelectionName:SetTextColor(nameColor:GetRGB());
	self.SelectionNumber:SetTextColor(numberColor:GetRGB());
end

function TabardyDesignerPopoutDetailsMixin:UpdateText(selectionData, isSelected, hideNumber, hasColors)
	self:UpdateFontColors(selectionData, isSelected);

	self.SelectionNumber:SetText(self.index);
	self.SelectionNumberBG:SetText(self.index);

	if hasColors then
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	elseif selectionData.Name ~= "" then
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetText(selectionData.Name);
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	else
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(0);
		self.SelectionNumberBG:SetWidth(0);
	end

	self.SelectionNumber:SetShown(not hideNumber);
end

function TabardyDesignerPopoutDetailsMixin:SetupDetails(selectionData, index, isSelected)
	if not index then
		self.SelectionName:SetText(CHARACTER_CUSTOMIZE_POPOUT_UNSELECTED_OPTION);
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.SelectionNumber:Hide();
		self.SelectionNumberBG:Hide();
		self.ColorSwatch:Hide();
		self.ColorSwatchGlow:Hide();
		return;
	end
	self.name = selectionData.Name;
	self.index = index;

	local color = selectionData.Color;
	if color then
		self.ColorSwatch:Show();
		self.ColorSwatchGlow:Show();
		self.ColorSwatch:SetVertexColor(color:GetRGB());
	elseif selectionData.Name ~= "" then
		self.ColorSwatch:Hide();
		self.ColorSwatchGlow:Hide();
	else
		self.ColorSwatch:Hide();
		self.ColorSwatchGlow:Hide();
	end

	self.ColorSelected:SetShown(self.selectable and color and isSelected);

	local hideNumber = false;
	if hideNumber then
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch:SetPoint("LEFT", self, "LEFT", 0, 0);
	else
		self.SelectionName:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
	end

	if self.selectable then
		self.SelectionName:SetPoint("RIGHT", 0, 0);
	end

	self:UpdateText(selectionData, isSelected, hideNumber, color);
end

------------

TabardyDesignerPopoutEntryMixin = {};

function TabardyDesignerPopoutEntryMixin:OnLoad()
	SelectionPopoutEntryMixin.OnLoad(self);

	self.SelectionDetails.SelectionName:SetPoint("RIGHT");
end

function TabardyDesignerPopoutEntryMixin:SetupEntry(selectionData, index, isSelected, multipleColumns)
	SelectionPopoutEntryMixin.SetupEntry(self, selectionData, index, isSelected, multipleColumns);
end

function TabardyDesignerPopoutEntryMixin:OnEnter()
	SelectionPopoutEntryMixin.OnEnter(self);

	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0.15);

		self.SelectionDetails.SelectionNumber:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
end

function TabardyDesignerPopoutEntryMixin:OnLeave()
	SelectionPopoutEntryMixin.OnLeave(self);

	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0);
		self.SelectionDetails:UpdateFontColors(self.selectionData, self.isSelected);
	end
end

------------

TabardyDesignerPopoutButtonMixin = {};

function TabardyDesignerPopoutButtonMixin:UpdateButtonDetails()
	local currentSelectedData = self:GetCurrentSelectedData();
	self.SelectionDetails:SetupDetails(currentSelectedData, self.selectedIndex);

	local maxNameWidth = 126;
	if self.SelectionDetails.SelectionName:GetWidth() > maxNameWidth then
		self.SelectionDetails.SelectionName:SetWidth(maxNameWidth);
	end

	self.SelectionDetails:Layout();
end

------------

TabardyDesignerCustomizationMixin = {};

function TabardyDesignerCustomizationMixin:OnLoad_Custom()
    SelectionPopoutWithButtonsAndLabelMixin.OnLoad(self);
    self.Label:SetPoint("RIGHT", self.DecrementButton, "LEFT", -10, 0);
end

function TabardyDesignerCustomizationMixin:SetLabel(label)
    self.Label:SetText(label);
end

function TabardyDesignerCustomizationMixin:SetupOption(optionData)
	self:SetOptionData(optionData);
	self:SetupSelections(optionData.Choices, optionData.CurrentChoiceIndex, optionData.Name);
end

function TabardyDesignerCustomizationMixin:SetOptionData(optionData)
	self.optionData = optionData;
end

function TabardyDesignerCustomizationMixin:GetOptionData()
	return self.optionData;
end

function TabardyDesignerCustomizationMixin:RefreshOption()
	self:SetupOption(self:GetOptionData());
end

function TabardyDesignerCustomizationMixin:GetCurrentChoiceIndex()
	return self:GetOptionData().currentChoiceIndex;
end

function TabardyDesignerCustomizationMixin:HasChoice()
	return self:GetCurrentChoice() ~= nil;
end

function TabardyDesignerCustomizationMixin:GetChoice(index)
	if index then
		return self:GetOptionData().choices[index];
	end
end

function TabardyDesignerCustomizationMixin:GetCurrentChoice()
	return self:GetChoice(self:GetCurrentChoiceIndex());
end

local POPOUT_CLEARANCE = 100;

function TabardyDesignerCustomizationMixin:GetMaxPopoutHeight()
	return self:GetBottom() - POPOUT_CLEARANCE;
end

function TabardyDesignerCustomizationMixin:OnEntrySelected(entryData)
    local designer = self:GetParent():GetParent();
    designer:SetCustomization(self:GetID(), entryData);
end

------------

local function ConvertRGBToHSL(r, g, b)
    local cmax = math.max(r, g, b);
    local cmin = math.min(r, g, b);
    local c = cmax - cmin;

    local h = 0;
    local s = 0;
    local l = (cmin + cmax) / 2;

    if c ~= 0 then
        s = (l == 0 or l == 1) and 0 or ((cmax - l) / math.min(l, 1 - l));

        if cmax == r then
            h = (g - b) / c + (g < b and 6 or 0);
        elseif cmax == g then
            h = (b - r) / c + 2;
        else
            h = (r - g) / c + 4;
        end

        h = h / 6;
    end

    return h, s, l;
end

local function SortColors(a, b)
    a = a.GetRGB and a or a.Color;
    b = b.GetRGB and b or b.Color;
    local h1, s1, l1 = ConvertRGBToHSL(a:GetRGB());
    local h2, s2, l2 = ConvertRGBToHSL(b:GetRGB());

    if h1 ~= h2 then
        return h1 < h2;
    elseif s1 ~= s2 then
        return s1 < s2;
    else
        return l1 < l2;
    end
end

local PERSONAL_TABARD_ITEM_ID = 210469;

TabardyDesignerMixin = {};

function TabardyDesignerMixin:OnLoad()
    self:RegisterEvent("TABARD_CANSAVE_CHANGED");
    self:RegisterEvent("TABARD_SAVE_PENDING");
    self:RegisterEvent("DISPLAY_SIZE_CHANGED");
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("UNIT_MODEL_CHANGED");

    self:SetTitle("Tabardy");

    self.Model:SetHitRectInsets(0, 0, 0, 30);

    RunNextFrame(function() tinsert(UISpecialFrames, self:GetName()) end);
end

function TabardyDesignerMixin:OnEvent(event, ...)
    if event == "TABARD_CANSAVE_CHANGED" or event == "TABARD_SAVE_PENDING" then
        self:UpdateButtons();
    elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" or event == "UNIT_MODEL_CHANGED" then
        self.Model:SetUnit("player");
    end
end

function TabardyDesignerMixin:OnShow()
    if not UnitExists("npc") and not Tabardy.Debug then
        self:Hide();
        return;
    end

    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    self:LoadPortrait();
    self:LoadModel();

    if self.Model:IsGuildTabard() then
        MoneyFrame_Update(self.CostFrame, GetTabardCreationCost());
        self.CostFrame:Show();
    else
        self.CostFrame:Hide();
    end

    self:UpdateTextures();
    self:UpdateButtons();

    self:SetupCustomizationOptions();
end

function TabardyDesignerMixin:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
    CloseTabardCreation();
end

function TabardyDesignerMixin:OnMouseDown(button)
    if button == "LeftButton" then
        self:StartMoving();
    end
end

function TabardyDesignerMixin:OnMouseUp(button)
    if button == "LeftButton" then
        self:StopMovingOrSizing();
    end
end

function TabardyDesignerMixin:Toggle()
    self:SetShown(not self:IsShown());
end

function TabardyDesignerMixin:PopulateEmblems()
    local allEmblems = Tabardy.GetAllEmblems();
    local choices = {};

    local emblemsAdded = {};
    for emblemFileID, emblemInfo in pairs(allEmblems) do
        local emblemID = emblemInfo.EmblemID;
        if emblemInfo.Component == 3 and not emblemsAdded[emblemID] then
            local choice = {
                FileID = emblemFileID,
                EmblemID = emblemID
            };
            tinsert(choices, choice);
            emblemsAdded[emblemID] = true;
        end
    end

    table.sort(choices, function(a, b) return a.EmblemID > b.EmblemID end);

    local emblemPicker = self.Customizations.EmblemPicker;
    emblemPicker:SetLabel("Emblem");

    local function Generator(dropdown, rootDescription)
        local columns = 10;
        rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns);

        for i, choice in ipairs(choices) do
            local data = {
                Index = i, -- used for the number text on the menu entries
                FileID = choice.FileID,
                EmblemID = choice.EmblemID,
                Type = CUSTOMIZATION_TYPE.EMBLEM,
            };

            local function IsSelected(elementData)
                return elementData.EmblemID == self:GetSelectedEmblemID();
            end

            local buttonDescription = rootDescription:CreateTemplate("TabardyEmblemEntryTemplate", data);
            buttonDescription:AddInitializer(function(button, elementDescription, menu)
                local isSelected = IsSelected(data);
                button:Init(data, elementDescription, isSelected);
            end);
            buttonDescription:SetResponder(function(elementData, menuInputData, menu)
                self:SetCustomization(elementData.Type, elementData.EmblemID);
                return MenuResponse.Refresh;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
        end
    end

    emblemPicker:SetupMenu(Generator);
end

function TabardyDesignerMixin:PopulateEmblemColors()
    local allEmblemColors = Tabardy.GetAllEmblemColors();
    local choices = {};

    for emblemColorID, _ in ipairs(allEmblemColors) do
        local choice = {
            Name = "",
            Color = Tabardy.GetEmblemColor(emblemColorID),
            ColorID = emblemColorID,
        };
        tinsert(choices, choice);
    end

    table.sort(choices, SortColors);

    local emblemColorPicker = self.Customizations.EmblemColorPicker;
    emblemColorPicker:SetLabel("Emblem Color");

    local function Generator(dropdown, rootDescription)
        for i, choice in ipairs(choices) do
            local data = {
                Index = i, -- used for the number text on the menu entries
                Color = choice.Color, -- color mixin
                ColorID = choice.ColorID, -- used for lookups
                Type = CUSTOMIZATION_TYPE.EMBLEM_COLOR,
            };

            local function IsSelected(elementData)
                return elementData.ColorID == self:GetSelectedEmblemColorID();
            end

            local buttonDescription = rootDescription:CreateTemplate("TabardyNumberedColorSwatchTemplate", data);
            buttonDescription:AddInitializer(function(button, elementDescription, menu)
                local isSelected = IsSelected(data);
                button:Init(data, elementDescription, isSelected);
            end);
            buttonDescription:SetResponder(function(elementData, menuInputData, menu)
                self:SetCustomization(elementData.Type, elementData.ColorID);
                return MenuResponse.Refresh;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
        end
    end

    emblemColorPicker:SetupMenu(Generator);
end

function TabardyDesignerMixin:PopulateBackgrounds()
    local allBackgrounds = Tabardy.GetAllBackgrounds();
    local choices = {};
    local added = {};

    for fdid, bg in pairs(allBackgrounds) do
        if not added[bg.Color] then
            local choice = {
                Name = "",
                FileID = fdid,
                ColorID = bg.Color,
                Color = Tabardy.GetBackgroundColor(bg.Color)
            };
            tinsert(choices, choice);
            added[bg.Color] = true;
        end
    end

    table.sort(choices, SortColors);

    local backgroundPicker = self.Customizations.BackgroundPicker;
    backgroundPicker:SetLabel("Background");

    local function Generator(dropdown, rootDescription)
        local columns = 4;
        rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns);

        for i, choice in ipairs(choices) do
            local data = {
                Index = i, -- used for the number text on the menu entries
                Color = choice.Color, -- color mixin
                ColorID = choice.ColorID,
                Type = CUSTOMIZATION_TYPE.BACKGROUND,
            };

            local function IsSelected(elementData)
                return elementData.ColorID == self:GetSelectedBackgroundColorID();
            end

            local buttonDescription = rootDescription:CreateTemplate("TabardyNumberedColorSwatchTemplate", data);
            buttonDescription:AddInitializer(function(button, elementDescription, menu)
                local isSelected = IsSelected(data);
                button:Init(data, elementDescription, isSelected);
            end);
            buttonDescription:SetResponder(function(elementData, menuInputData, menu)
                self:SetCustomization(elementData.Type, elementData.ColorID);
                return MenuResponse.Refresh;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
        end
    end

    backgroundPicker:SetupMenu(Generator);
end

function TabardyDesignerMixin:SetupCustomizationOptions()
    self:PopulateEmblems();
    self:PopulateEmblemColors();
    self:PopulateBackgrounds();
    self.Customizations.BorderPicker.Label:SetText("Border");
    self.Customizations.BorderColorPicker.Label:SetText("Border Color");
end

function TabardyDesignerMixin:CycleCustomization(id, amount)
    PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
    self.Model:CycleVariation(id, amount);
    self:UpdateTextures();
end

function TabardyDesignerMixin:SetCustomization(id, target)
    local distance;
    if id == CUSTOMIZATION_TYPE.EMBLEM then
        distance = self:GetEmblemDistance(target);
    elseif id == CUSTOMIZATION_TYPE.EMBLEM_COLOR then
        distance = self:GetEmblemColorDistance(target);
    elseif id == CUSTOMIZATION_TYPE.BORDER or id == CUSTOMIZATION_TYPE.BORDER_COLOR then
        return self:CycleCustomization(id, 1);
    elseif id == CUSTOMIZATION_TYPE.BACKGROUND then
        distance = self:GetBackgroundDistance(target);
    end
    self:CycleCustomization(id, distance);
end

function TabardyDesignerMixin:GetSelectedBackgroundColorID()
    local bgFile = self.Model:GetUpperBackgroundFileName();
    return Tabardy.GetColorIDForBackground(bgFile);
end

function TabardyDesignerMixin:GetSelectedEmblemID()
    local emblemFile = self.Model:GetUpperEmblemFile();
    return Tabardy.GetEmblemID(emblemFile);
end

function TabardyDesignerMixin:GetSelectedEmblemColorID()
    local emblemFile = self.Model:GetUpperEmblemFile();
    return Tabardy.GetColorIDForEmblem(emblemFile);
end

function TabardyDesignerMixin:GetBackgroundDistance(target)
    local current = self.Model:GetUpperBackgroundFileName();
    local currentID = Tabardy.GetColorIDForBackground(current);
    return target - currentID;
end

function TabardyDesignerMixin:GetEmblemDistance(targetEmblemID)
    local currentEmblemID = self:GetSelectedEmblemID();
    local distance = targetEmblemID - currentEmblemID;
    return distance;
end

function TabardyDesignerMixin:GetEmblemColorDistance(targetColorID)
    local currentColorID = self:GetSelectedEmblemColorID();
    local distance = targetColorID - currentColorID;
    return distance;
end

function TabardyDesignerMixin:LoadPortrait()
    local unit = UnitExists("npc") and "npc" or "player";
    SetPortraitTexture(self.PortraitContainer.portrait, unit);
end

function TabardyDesignerMixin:LoadModel()
    self.Model:InitializeTabardColors();
    self.Model:SetPosition(0, 0.3, 0);
end

function TabardyDesignerMixin:UpdateButtons()
    local guildName, guildRankName, guildRank = GetGuildInfo("player");
    if self.Model:IsGuildTabard() and (guildName == nil or guildRankName == nil or (guildRank > 0)) then
        self.GreetingText:SetText(TABARDVENDORNOGUILDGREETING);
        self.AcceptButton:Disable();
        return;
    elseif self.Model:IsGuildTabard() then
        self.GreetingText:SetText(TABARDVENDORGREETING);
    else
        local includeBank = true;
        local personalTabardCount = C_Item.GetItemCount(PERSONAL_TABARD_ITEM_ID, includeBank);
        if personalTabardCount == 0 then
            self.GreetingText:SetText(PERSONALTABARDVENDORUNOWNEDGREETING);
        else
            self.GreetingText:SetText(PERSONALTABARDVENDORGREETING);
        end
    end

    self.AcceptButton:SetEnabled(self.Model:CanSaveTabardNow());
end

function TabardyDesignerMixin:UpdateTextures()
    local container = self.EmblemContainer;

    self.Model:GetUpperEmblemTexture(container.TopLeft);
    self.Model:GetUpperEmblemTexture(container.TopRight);
    self.Model:GetLowerEmblemTexture(container.BottomLeft);
    self.Model:GetLowerEmblemTexture(container.BottomRight);
end

function TabardyDesignerMixin:SaveTabard()
    PlaySound(SOUNDKIT.RAF_RECRUIT_REWARD_CLAIM);
    self.Model:Save();
    self:UpdateButtons();
    self.SaveAnim:Play();
end

------------

function TabardFrame_Open()
    TabardyDesigner:Show();
end