local _, Data = ...;

Tabardy = {};

---@param fdid number BackgroundFileID
function Tabardy.GetColorForBackground(fdid)
    local bg = Data.Backgrounds[fdid];
    local color = Data.BackgroundColors[bg.Color].Color;
    return color.Red / 255, color.Green / 255, color.Blue / 255;
end

---@param colorID number BackgroundColorID
---@return ColorMixin
function Tabardy.GetBackgroundColor(colorID)
    local color = Data.BackgroundColors[colorID].Color;
    return CreateColor(color.Red / 255, color.Green / 255, color.Blue / 255);
end

---@param fdid number BackgroundFileID
function Tabardy.GetColorIDForBackground(fdid)
    local bg = Data.Backgrounds[fdid];
    return bg.Color;
end

---@param fdid number EmblemFileID
function Tabardy.GetColorForEmblem(fdid)
    local emblem = Data.Emblems[fdid];
    local color = Data.EmblemColors[emblem.Color].Color;
    return color.Red / 255, color.Green / 255, color.Blue / 255;
end

---@param fdid number EmblemFileID
function Tabardy.GetColorIDForEmblem(fdid)
    local emblem = Data.Emblems[fdid];
    return emblem.Color;
end

---@param colorID number EmblemColorID
---@return ColorMixin
function Tabardy.GetEmblemColor(colorID)
    local color = Data.EmblemColors[colorID].Color;
    return CreateColor(color.Red / 255, color.Green / 255, color.Blue / 255);
end

function Tabardy.GetFileIDForEmblemAndColor(emblemID, colorID)
    local emblems = Data.Emblems;
    for fdid, emblemInfo in pairs(emblems) do
        if emblemInfo.EmblemID == emblemID and emblemInfo.Color == colorID then
            return fdid;
        end
    end
end

---@param fdid number EmblemFileID
function Tabardy.GetEmblemID(fdid)
    local emblem = Data.Emblems[fdid];
    return emblem.EmblemID;
end

function Tabardy.GetAllBackgroundColors()
    return Data.BackgroundColors;
end

function Tabardy.GetAllBackgrounds()
    return Data.Backgrounds;
end

function Tabardy.GetAllEmblemColors()
    return Data.EmblemColors;
end

function Tabardy.GetAllEmblems()
    return Data.Emblems;
end