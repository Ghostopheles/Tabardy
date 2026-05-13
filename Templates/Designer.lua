TabardyDesignerNewMixin = {};

function TabardyDesignerNewMixin:OnLoad()
end

function TabardyDesignerNewMixin:OnShow()
    self:TestGallery();
end

function TabardyDesignerNewMixin:TestGallery()
    local DataProvider = CreateDataProvider();
    self.Gallery.ScrollView:SetDataProvider(DataProvider);

    local choices = self.Gallery:CollectEmblemChoices();
    for i, choice in ipairs(choices) do
        local data = {
            Index = i,
            FileID = choice.FileID,
            EmblemID = choice.EmblemID,
            EntryType = TabardyGalleryMixin.GalleryEntryType.EMBLEM
        };
        DataProvider:Insert(data);
    end
end
