local _, internal = ...;

local Events = internal.Events;
local Registry = internal.Registry;

------------

local SCROLLBOX_STRIDE = 5;
local SCROLLBOX_SPACING = 4;

---@enum TabardyGalleryEntryType
local ENTRY_TYPE = {
    EMBLEM = 1,
    EMBLEM_COLOR = 2,
    BORDER = 3,
    BORDER_COLOR = 4,
    BACKGROUND = 5,
};

------------

TabardyGalleryMixin = {};
TabardyGalleryMixin.GalleryEntryType = ENTRY_TYPE;

function TabardyGalleryMixin:OnLoad()
    ButtonFrameTemplate_HidePortrait(self);

    self:SetupScrollBox();
    self:SetupSelectionBehavior();
    self:SetupDecorations();
    self:SetTitle("Tabardy Gallery");
end

function TabardyGalleryMixin:SetupScrollBox()
    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 10, -30),
        CreateAnchor("TOPRIGHT", self.ScrollBar, "TOPLEFT", -5, 0),
        CreateAnchor("BOTTOM", self, "BOTTOM");
    };

    local anchorsWithoutScrollBar = {
        anchorsWithScrollBar[1],
        CreateAnchor("TOPRIGHT", self, "TOPRIGHT", -5, -30),
        anchorsWithScrollBar[3],
    };

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar);

    self.ScrollView = CreateScrollBoxListGridView(SCROLLBOX_STRIDE, 5, 5, 5, 5, SCROLLBOX_SPACING, SCROLLBOX_SPACING);

    local function Initializer(frame, data)
        frame:Init(data);

        if self.SelectedHighlight.Target == frame and not self.SelectionBehavior:IsElementDataSelected(data) then
            self:ClearSelectionHighlight();
        end
    end
    self.ScrollView:SetElementInitializer("TabardyGalleryEntryTemplate", Initializer);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBox:SetLowerShadowAtlas("QuestBG-Shadow-bottom", false);
    self.ScrollBox:SetUseShadowsForEdgeFade(true);
end

function TabardyGalleryMixin:SetupSelectionBehavior()
    self.SelectedHighlight = CreateFrame("Frame", nil, self.ScrollBox, "TabardyGallerySelectionTemplate");
    self.SelectedHighlight.Center:SetAlpha(0);

    self.SelectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
    self.SelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, self.OnSelectionChanged, self);
end

function TabardyGalleryMixin:OnSelectionChanged(elementData, selected)
    local frame = self.ScrollBox:FindFrame(elementData);
    if frame then
        if selected then
            self:AttachSelectionHighlight(frame);
            return;
        end
    end
    self:ClearSelectionHighlight();
end

function TabardyGalleryMixin:AttachSelectionHighlight(target)
    self.SelectedHighlight.Target = target;
    self.SelectedHighlight:SetAllPoints(target);
    self.SelectedHighlight:Show();
end

function TabardyGalleryMixin:ClearSelectionHighlight()
    self.SelectedHighlight.Target = nil;
    self.SelectedHighlight:ClearAllPoints();
    self.SelectedHighlight:Hide();
end

function TabardyGalleryMixin:SetupDecorations()

end

function TabardyGalleryMixin:CollectEmblemChoices()
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

    return choices;
end

function Test()
    local DataProvider = CreateDataProvider();
    TabardyGallery.ScrollView:SetDataProvider(DataProvider);

    local choices = TabardyGallery:CollectEmblemChoices();
    for i, choice in ipairs(choices) do
        local data = {
            Index = i,
            FileID = choice.FileID,
            EmblemID = choice.EmblemID,
            EntryType = ENTRY_TYPE.EMBLEM
        };
        DataProvider:Insert(data);
    end

    C_Timer.NewTicker(3, function()
        local colorID = random(1, 16);
        Registry:TriggerEvent(Events.PREVIEW_EMBLEM_COLOR, colorID);
    end);

    DevTool:AddData(TabardyGallery, "TabardyGallery");
end

