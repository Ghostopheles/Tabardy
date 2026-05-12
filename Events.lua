local _, internal = ...;

local Events = {
    PREVIEW_EMBLEM_COLOR = "PREVIEW_EMBLEM_COLOR",
    RESET_EMBLEM_COLOR = "RESET_EMBLEM_COLOR",
    PREVIEW_EMBLEM = "PREVIEW_EMBLEM",
    RESET_EMBLEM = "RESET_EMBLEM",
    PREVIEW_BORDER = "PREVIEW_BORDER",
    RESET_BORDER = "RESET_BORDER",
    PREVIEW_BACKGROUND = "PREVIEW_BACKGROUND",
    RESET_BACKGROUND = "RESET_BACKGROUND"
};
internal.Events = Events;

local Registry = CreateFromMixins(CallbackRegistryMixin);
Registry:OnLoad();
Registry:GenerateCallbackEvents(GetKeysArray(Events));
internal.Registry = Registry;