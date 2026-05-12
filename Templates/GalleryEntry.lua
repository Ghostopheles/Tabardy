local _, internal = ...;

local Events = internal.Events;
local Registry = internal.Registry;

------------

do
    local bCornerOffset = 4;
    local bCenterOffset = 8;
    NineSliceUtil.AddLayout("TabardyGoldHighlight", {
        mirrorLayout = true,
        TopLeftCorner =	{
            atlas = "editmode-actionbar-selected-nineslice-corner",
            x = -bCornerOffset,
            y = bCornerOffset,
        },
        TopRightCorner = {
            atlas = "editmode-actionbar-selected-nineslice-corner",
            x = bCornerOffset,
            y = bCornerOffset,
        },
        BottomLeftCorner = {
            atlas = "editmode-actionbar-selected-nineslice-corner",
            x = -bCornerOffset,
            y = -bCornerOffset,
        },
        BottomRightCorner = {
            atlas = "editmode-actionbar-selected-nineslice-corner",
            x = bCornerOffset,
            y = -bCornerOffset,
        },
        TopEdge = {
            atlas = "_editmode-actionbar-selected-nineslice-edgetop",
        },
        BottomEdge = {
            atlas = "_editmode-actionbar-selected-nineslice-edgebottom",
            mirrorLayout = false,
        },
        LeftEdge = {
            atlas = "!editmode-actionbar-selected-nineslice-edgeleft",
            mirrorLayout = false,
        },
        RightEdge = {
            atlas = "!editmode-actionbar-selected-nineslice-edgeright",
            mirrorLayout = false,
        },
        Center = {
            atlas = "editmode-actionbar-selected-nineslice-center",
            x = -bCenterOffset,
            y = bCenterOffset,
            x1 = bCenterOffset,
            y1 = -bCenterOffset
        },
    });
end

do
    local bCornerOffset = 4;
    local bCenterOffset = 8;
    NineSliceUtil.AddLayout("TabardyBlueHighlight", {
        mirrorLayout = true,
        TopLeftCorner =	{
            atlas = "editmode-actionbar-highlight-nineslice-corner",
            x = -bCornerOffset,
            y = bCornerOffset,
        },
        TopRightCorner = {
            atlas = "editmode-actionbar-highlight-nineslice-corner",
            x = bCornerOffset,
            y = bCornerOffset,
        },
        BottomLeftCorner = {
            atlas = "editmode-actionbar-highlight-nineslice-corner",
            x = -bCornerOffset,
            y = -bCornerOffset,
        },
        BottomRightCorner = {
            atlas = "editmode-actionbar-highlight-nineslice-corner",
            x = bCornerOffset,
            y = -bCornerOffset,
        },
        TopEdge = {
            atlas = "_editmode-actionbar-highlight-nineslice-edgetop",
        },
        BottomEdge = {
            atlas = "_editmode-actionbar-highlight-nineslice-edgebottom",
            mirrorLayout = false,
        },
        LeftEdge = {
            atlas = "!editmode-actionbar-highlight-nineslice-edgeleft",
            mirrorLayout = false,
        },
        RightEdge = {
            atlas = "!editmode-actionbar-highlight-nineslice-edgeright",
            mirrorLayout = false,
        },
        Center = {
            atlas = "editmode-actionbar-highlight-nineslice-center",
            x = -bCenterOffset,
            y = bCenterOffset,
            x1 = bCenterOffset,
            y1 = -bCenterOffset
        },
    });
end

---@class TabardyGalleryEntryData
---@field EntryType TabardyGalleryEntryType
---@field Index number
---@field EmblemID? number
---@field FileID? number
---@field Color? ColorMixin
---@field ColorID? number

------------

TabardyGalleryEntryMixin = {};

function TabardyGalleryEntryMixin:OnLoad()
    self.Highlight.Center:SetAlpha(0.25);

    Registry:RegisterCallback(Events.PREVIEW_EMBLEM_COLOR, self.OnPreviewEmblemColor, self);
    Registry:RegisterCallback(Events.RESET_EMBLEM_COLOR, self.OnResetEmblemColor, self);
end

---@param data TabardyGalleryEntryData
function TabardyGalleryEntryMixin:Init(data)
    self:SetEmblem(data.EmblemID);
    self:SetLabel(data.Index);
end

function TabardyGalleryEntryMixin:OnEnter()
    self.Highlight:Show();
end

function TabardyGalleryEntryMixin:OnLeave()
    self.Highlight:Hide();
end

function TabardyGalleryEntryMixin:OnMouseDown(button)
    if button ~= "LeftButton" then
        return;
    end

    self.Highlight.Center:SetAlpha(1);
end

function TabardyGalleryEntryMixin:OnMouseUp(button)
    if button ~= "LeftButton" then
        return;
    end

    self.Highlight.Center:SetAlpha(0.25);

    TabardyGallery.SelectionBehavior:Select(self);
end

function TabardyGalleryEntryMixin:OnPreviewEmblemColor(colorID)
    local data = self:GetData();
    if data.EmblemID then
        self.EmblemContainer:SetEmblem(data.EmblemID, colorID);
    end
end

function TabardyGalleryEntryMixin:OnResetEmblemColor()
    local data = self:GetData();
    if data.EmblemID then
        self.EmblemContainer:SetEmblem(data.EmblemID);
    end
end

function TabardyGalleryEntryMixin:SetEmblem(emblemID)
    if not emblemID then
        self.EmblemContainer:Hide();
    end

    self.EmblemContainer:SetEmblem(emblemID);
    self.EmblemContainer:Show();
end

function TabardyGalleryEntryMixin:SetLabel(label)
    self.Label:SetTextToFit(label);
end