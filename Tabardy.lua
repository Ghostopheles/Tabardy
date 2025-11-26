local Events = {
    PREVIEW_EMBLEM = "PREVIEW_EMBLEM",
    RESET_EMBLEM = "RESET_EMBLEM",
    PREVIEW_BORDER = "PREVIEW_BORDER",
    RESET_BORDER = "RESET_BORDER",
    PREVIEW_BACKGROUND = "PREVIEW_BACKGROUND",
    RESET_BACKGROUND = "RESET_BACKGROUND"
};

local Registry = CreateFromMixins(CallbackRegistryMixin);
Registry:OnLoad();
Registry:GenerateCallbackEvents(GetKeysArray(Events));

------------

local CUSTOMIZATION_TYPE = {
    EMBLEM = 1,
    EMBLEM_COLOR = 2,
    BORDER = 3,
    BORDER_COLOR = 4,
    BACKGROUND = 5,
};

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

    self.Model = self.CharacterModel.Model;

    self.Model:SetHitRectInsets(0, 0, 0, 30);
    self.Model:SetScript("OnMouseDown", function(model, button)
        if button ~= "RightButton" then
            ModelFrameMixin.OnMouseDown(model, button);
        end
    end);

    self.Model:SetScript("OnMouseUp", function(model, button)
        if button ~= "RightButton" then
            ModelFrameMixin.OnMouseUp(model, button);
        end
    end);

    RunNextFrame(function() tinsert(UISpecialFrames, self:GetName()) end);

    Registry:RegisterCallback(Events.PREVIEW_EMBLEM, self.PreviewEmblem, self);
    Registry:RegisterCallback(Events.RESET_EMBLEM, self.ResetEmblem, self);
    Registry:RegisterCallback(Events.PREVIEW_BORDER, self.PreviewBorder, self);
    Registry:RegisterCallback(Events.RESET_BORDER, self.ResetBorder, self);
    Registry:RegisterCallback(Events.PREVIEW_BACKGROUND, self.PreviewBackgroundColor, self);
    Registry:RegisterCallback(Events.RESET_BACKGROUND, self.ResetBackgroundColor, self);
end

function TabardyDesignerMixin:OnEvent(event, ...)
    if event == "TABARD_CANSAVE_CHANGED" or event == "TABARD_SAVE_PENDING" then
        self:UpdateButtons();
    elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" or event == "UNIT_MODEL_CHANGED" then
        self:RefreshModel();
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

    self:PreviewEmblem();
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
                return MenuResponse.Close;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
            buttonDescription:SetOnEnter(function()
                Registry:TriggerEvent(Events.PREVIEW_EMBLEM, data.EmblemID);
            end);
        end

        rootDescription:AddMenuReleasedCallback(function()
            Registry:TriggerEvent(Events.RESET_EMBLEM);
        end);
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
                return MenuResponse.Close;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
            buttonDescription:SetOnEnter(function()
                Registry:TriggerEvent(Events.PREVIEW_EMBLEM, nil, data.ColorID);
            end);
        end

        rootDescription:AddMenuReleasedCallback(function()
            Registry:TriggerEvent(Events.RESET_EMBLEM);
        end);
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
        self.StartingBackgroundColor = self:GetSelectedBackgroundColorID();

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
                self.StartingBackgroundColor = nil;
                return MenuResponse.Close;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
            buttonDescription:SetOnEnter(function()
                Registry:TriggerEvent(Events.PREVIEW_BACKGROUND, data.ColorID);
            end);
        end

        rootDescription:AddMenuReleasedCallback(function()
            Registry:TriggerEvent(Events.RESET_BACKGROUND);
        end);
    end

    backgroundPicker:SetupMenu(Generator);
end

function TabardyDesignerMixin:PopulateBorders()
    local allBorders = Tabardy.GetAllBorders();
    local choices = {};

    local bordersAdded = {};
    for borderFileID, borderInfo in pairs(allBorders) do
        local borderID = borderInfo.BorderID;
        if borderInfo.Component == 3 and not bordersAdded[borderID] and borderID < 6 then
            local choice = {
                FileID = borderFileID,
                BorderID = borderID
            };
            tinsert(choices, choice);
            bordersAdded[borderID] = true;
        end
    end

    table.sort(choices, function(a, b) return a.BorderID > b.BorderID end);

    local borderPicker = self.Customizations.BorderPicker;
    borderPicker:SetLabel("Border");

    local function Generator(dropdown, rootDescription)
        self.StartingBorder = self:GetSelectedBorderID();
        for i, choice in ipairs(choices) do
            local data = {
                Index = i, -- used for the number text on the menu entries
                FileID = choice.FileID,
                BorderID = choice.BorderID,
                Type = CUSTOMIZATION_TYPE.BORDER,
            };

            local function IsSelected(elementData)
                return elementData.BorderID == self:GetSelectedBorderID();
            end

            local buttonDescription = rootDescription:CreateTemplate("TabardyEmblemEntryTemplate", data);
            buttonDescription:AddInitializer(function(button, elementDescription, menu)
                local isSelected = IsSelected(data);
                button:Init(data, elementDescription, isSelected);
            end);
            buttonDescription:SetResponder(function(elementData, menuInputData, menu)
                self:SetCustomization(elementData.Type, elementData.BorderID);
                self.StartingBorder = nil;
                return MenuResponse.Close;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
            buttonDescription:SetOnEnter(function()
                Registry:TriggerEvent(Events.PREVIEW_BORDER, data.BorderID);
            end);
        end

        rootDescription:AddMenuReleasedCallback(function()
            Registry:TriggerEvent(Events.RESET_BORDER);
        end);
    end

    borderPicker:SetupMenu(Generator);
end

function TabardyDesignerMixin:PopulateBorderColors()
    local allBorderColors = Tabardy.GetAllBorderColors();
    local choices = {};

    for borderColorID, _ in ipairs(allBorderColors) do
        local choice = {
            Name = "",
            Color = Tabardy.GetBorderColor(borderColorID),
            ColorID = borderColorID,
        };
        tinsert(choices, choice);
    end

    table.sort(choices, SortColors);

    local borderColorPicker = self.Customizations.BorderColorPicker;
    borderColorPicker:SetLabel("Border Color");

    local function Generator(dropdown, rootDescription)
        self.StartingBorderColor = self:GetSelectedBorderColorID();
        for i, choice in ipairs(choices) do
            local data = {
                Index = i, -- used for the number text on the menu entries
                Color = choice.Color, -- color mixin
                ColorID = choice.ColorID, -- used for lookups
                Type = CUSTOMIZATION_TYPE.BORDER_COLOR,
            };

            local function IsSelected(elementData)
                return elementData.ColorID == self:GetSelectedBorderColorID();
            end

            local buttonDescription = rootDescription:CreateTemplate("TabardyNumberedColorSwatchTemplate", data);
            buttonDescription:AddInitializer(function(button, elementDescription, menu)
                local isSelected = IsSelected(data);
                button:Init(data, elementDescription, isSelected);
            end);
            buttonDescription:SetResponder(function(elementData, menuInputData, menu)
                self:SetCustomization(elementData.Type, elementData.ColorID);
                self.StartingBorderColor = nil;
                return MenuResponse.Close;
            end);
            buttonDescription:SetData(data);
            buttonDescription:SetIsSelected(IsSelected);
            buttonDescription:SetOnEnter(function()
                Registry:TriggerEvent(Events.PREVIEW_BORDER, nil, data.ColorID);
            end);
        end

        rootDescription:AddMenuReleasedCallback(function()
            Registry:TriggerEvent(Events.RESET_BORDER);
        end);
    end

    borderColorPicker:SetupMenu(Generator);
end

function TabardyDesignerMixin:SetupCustomizationOptions()
    self:PopulateEmblems();
    self:PopulateEmblemColors();
    self:PopulateBackgrounds();
    self:PopulateBorders();
    self:PopulateBorderColors();
end

function TabardyDesignerMixin:CycleCustomization(id, amount)
    PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
    self.Model:CycleVariation(id, amount);
    self:PreviewEmblem();
end

function TabardyDesignerMixin:SetCustomization(id, target)
    local distance;
    if id == CUSTOMIZATION_TYPE.EMBLEM then
        distance = self:GetEmblemDistance(target);
    elseif id == CUSTOMIZATION_TYPE.EMBLEM_COLOR then
        distance = self:GetEmblemColorDistance(target);
    elseif id == CUSTOMIZATION_TYPE.BORDER then
        distance = self:GetBorderDistance(target);
    elseif id == CUSTOMIZATION_TYPE.BORDER_COLOR then
        distance = self:GetBorderColorDistance(target);
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

function TabardyDesignerMixin:GetSelectedBorderID()
    local borderFile = self.Model:GetUpperBorderFile();
    return Tabardy.GetBorderID(borderFile);
end

function TabardyDesignerMixin:GetSelectedBorderColorID()
    local borderFile = self.Model:GetUpperBorderFile();
    return Tabardy.GetColorIDForBorder(borderFile);
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

--TODO: this does not work
function TabardyDesignerMixin:GetBorderDistance(target)
    local current = self:GetSelectedBorderID();
    local distance = target - current;
    return distance;
end

function TabardyDesignerMixin:GetBorderColorDistance(target)
    local current = self.Model:GetUpperBorderFile();
    local currentID = Tabardy.GetColorIDForBorder(current);
    local distance = target - currentID;
    return distance;
end

function TabardyDesignerMixin:ShouldUseNativeForm()
    local _, raceFileName = UnitRace("player");
    local useNativeForm = raceFileName ~= "Dracthyr";
    return useNativeForm;
end

function TabardyDesignerMixin:LoadPortrait()
    local unit = UnitExists("npc") and "npc" or "player";
    SetPortraitTexture(self.PortraitContainer.portrait, unit);
end

function TabardyDesignerMixin:LoadModel()
    self.Model:InitializeTabardColors();
    self.Model:SetPosition(0, 0.5, 0);
end

function TabardyDesignerMixin:RefreshModel()
    local blend = true;
    local useNativeForm = self:ShouldUseNativeForm();
    self.Model:SetUnit("player", blend, useNativeForm);
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

function TabardyDesignerMixin:PreviewEmblem(emblemID, colorID)
    emblemID = emblemID or self:GetSelectedEmblemID();
    colorID = colorID or self:GetSelectedEmblemColorID();
    local textures = Tabardy.GetTexturesForEmblemAndColor(emblemID, colorID);
    table.sort(textures); -- why does this fix display problems? who knows, man - I'm not gonna bother figuring it out

    local container = self.EmblemContainer;
    container.TopLeft:SetTexture(textures[2]);
    container.BottomLeft:SetTexture(textures[1]);

    container.TopRight:SetTexture(textures[2]);
    container.BottomRight:SetTexture(textures[1]);
end

function TabardyDesignerMixin:ResetEmblem()
    self:PreviewEmblem();
end

function TabardyDesignerMixin:PreviewBorder(borderID, colorID)
    borderID = borderID or self:GetSelectedBorderID();
    colorID = colorID or self:GetSelectedBorderColorID();
    self:SetCustomization(CUSTOMIZATION_TYPE.BORDER, borderID);
    self:SetCustomization(CUSTOMIZATION_TYPE.BORDER_COLOR, colorID);
end

function TabardyDesignerMixin:ResetBorder()
    if self.StartingBorder then
        self:SetCustomization(CUSTOMIZATION_TYPE.BORDER, self.StartingBorder);
    end

    if self.StartingBorderColor then
        self:SetCustomization(CUSTOMIZATION_TYPE.BORDER_COLOR, self.StartingBorderColor);
    end

    self.StartingBorder = nil;
    self.StartingBorderColor = nil;
end

function TabardyDesignerMixin:PreviewBackgroundColor(colorID)
    colorID = colorID or self:GetSelectedBackgroundColorID();
    self:SetCustomization(CUSTOMIZATION_TYPE.BACKGROUND, colorID);
end

function TabardyDesignerMixin:ResetBackgroundColor()
    if self.StartingBackgroundColor then
        self:SetCustomization(CUSTOMIZATION_TYPE.BACKGROUND, self.StartingBackgroundColor);
    end

    self.StartingBackgroundColor = nil;
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