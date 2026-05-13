-- Orbit bounds
local MODEL_MIN_DISTANCE = 0.5;
local MODEL_MAX_DISTANCE = 4.0;
local MODEL_INITIAL_DISTANCE = 2.0;
local MODEL_INITIAL_PIVOT_Z = 0.5;

local MODEL_ZOOM_WHEEL_STEP = 1.15;
local MODEL_PITCH_LIMIT = 1.4;
local MODEL_PAN_FACTOR = 0.0015;
local MODEL_PAN_XY_LIMIT = 0.75;
local MODEL_PAN_Z_MIN = -0.5;
local MODEL_PAN_Z_MAX = 1.5;

local ROTATE_SMOOTH = 30;
local ZOOM_SMOOTH = 10;
local PAN_SMOOTH = 20;

local ROTATE_SENSITIVITY = 0.085;

local MOMENTUM_DECAY = 3.5;
local MOMENTUM_EPSILON = 0.01;
local VELOCITY_EMA_RATE = 15;

local DRAG_MODE_ROTATE = "rotate";
local DRAG_MODE_PAN = "pan";

------------

local CameraState = {
    yaw = { current = 0, target = 0, velocity = 0 },
    pitch = { current = 0, target = 0, velocity = 0 },
    distance = { current = MODEL_INITIAL_DISTANCE, target = MODEL_INITIAL_DISTANCE, velocity = 0 },
    pivotX = { current = 0, target = 0, velocity = 0 },
    pivotY = { current = 0, target = 0, velocity = 0 },
    pivotZ = { current = MODEL_INITIAL_PIVOT_Z, target = MODEL_INITIAL_PIVOT_Z, velocity = 0 },
};

local DragState = {
    active = false,
    mode = nil,
    button = nil,
    prevX = 0,
    prevY = 0,
    velX = 0,
    velY = 0,
};

local function Smooth(current, target, speed, deltaTime)
    return current + (target - current) * (1 - exp(-speed * deltaTime));
end

local function Clamp(v, lo, hi)
    return max(lo, min(hi, v));
end

------------

TabardyModelFrameMixin = {};

function TabardyModelFrameMixin:OnLoad()
    self:SetTitle("Tabardy Model Frame");

    local events = {
        "TABARD_CANSAVE_CHANGED",
        "TABARD_SAVE_PENDING",
        "UI_SCALE_CHANGED",
        "DISPLAY_SIZE_CHANGED",
        "UNIT_MODEL_CHANGED"
    };
    FrameUtil.RegisterFrameForEvents(self, events);

    local resetButton = self.ResetModelButton;
    resetButton:SetTooltipInfo(MODEL, RESET_POSITION);
    resetButton:SetScript("OnClick", function()
        self:Recenter();
    end);
end

function TabardyModelFrameMixin:OnShow()
    --if not UnitExists("npc") then
    --    return;
    --end
end

function TabardyModelFrameMixin:OnHide()
    DragState.active = false;
    DragState.mode = nil;
    DragState.button = nil;
    CameraState.yaw.velocity = 0;
    CameraState.pitch.velocity = 0;

    CloseTabardCreation();
end

function TabardyModelFrameMixin:OnEvent(event, ...)
    if event == "TABARD_CANSAVE_CHANGED" or event == "TABARD_SAVE_PENDING" then
        self:UpdateButtons();
    elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" or event == "UNIT_MODEL_CHANGED" then
        self:RefreshModel();
    end
end

function TabardyModelFrameMixin:OnUpdate(deltaTime)
    deltaTime = min(deltaTime, 0.05);

    local drag = DragState;
    local state = CameraState;

    if drag.active and not IsMouseButtonDown(drag.button) then
        self:ModelEndDrag();
    end

    if drag.active then
        local cx, cy = GetScaledCursorPosition();
        local dx = cx - drag.prevX;
        local dy = cy - drag.prevY;
        drag.prevX, drag.prevY = cx, cy;

        local ivx = deltaTime > 0 and (dx / deltaTime) or 0;
        local ivy = deltaTime > 0 and (dy / deltaTime) or 0;
        local a = 1 - exp(-VELOCITY_EMA_RATE * deltaTime);
        drag.velX = drag.velX + (ivx - drag.velX) * a;
        drag.velY = drag.velY + (ivy - drag.velY) * a;

        if drag.mode == DRAG_MODE_ROTATE then
            state.yaw.target = state.yaw.target - dx * ROTATE_SENSITIVITY;
            state.pitch.target = state.pitch.target - dy * ROTATE_SENSITIVITY;
            state.pitch.target = Clamp(state.pitch.target, -MODEL_PITCH_LIMIT, MODEL_PITCH_LIMIT);

        elseif drag.mode == DRAG_MODE_PAN then
            local panRate = state.distance.current * MODEL_PAN_FACTOR;
            local sinY, cosY = sin(state.yaw.current), cos(state.yaw.current);
            local sinP, cosP = sin(state.pitch.current), cos(state.pitch.current);

            state.pivotX.target = Clamp(state.pivotX.target - dx * panRate * (-sinY) - dy * panRate * (-cosY * sinP), -MODEL_PAN_XY_LIMIT, MODEL_PAN_XY_LIMIT);
            state.pivotY.target = Clamp(state.pivotY.target - dx * panRate * cosY - dy * panRate * (-sinY * sinP), -MODEL_PAN_XY_LIMIT, MODEL_PAN_XY_LIMIT);
            state.pivotZ.target = Clamp(state.pivotZ.target - dy * panRate * cosP, MODEL_PAN_Z_MIN, MODEL_PAN_Z_MAX);
        end
    else
        if abs(state.yaw.velocity) > MOMENTUM_EPSILON
           or abs(state.pitch.velocity) > MOMENTUM_EPSILON then

            state.yaw.target = state.yaw.target + state.yaw.velocity * deltaTime;
            state.pitch.target = state.pitch.target + state.pitch.velocity * deltaTime;
            state.pitch.target = Clamp(state.pitch.target, -MODEL_PITCH_LIMIT, MODEL_PITCH_LIMIT);

            local decay = exp(-MOMENTUM_DECAY * deltaTime);
            state.yaw.velocity = state.yaw.velocity * decay;
            state.pitch.velocity = state.pitch.velocity * decay;

            if abs(state.yaw.velocity) < MOMENTUM_EPSILON then
                state.yaw.velocity = 0;
            end
            if abs(state.pitch.velocity) < MOMENTUM_EPSILON then
                state.pitch.velocity = 0;
            end
        end
    end

    state.yaw.current = Smooth(state.yaw.current, state.yaw.target, ROTATE_SMOOTH, deltaTime);
    state.pitch.current = Smooth(state.pitch.current, state.pitch.target, ROTATE_SMOOTH, deltaTime);
    state.distance.current = Smooth(state.distance.current, state.distance.target, ZOOM_SMOOTH, deltaTime);
    state.pivotX.current = Smooth(state.pivotX.current, state.pivotX.target, PAN_SMOOTH, deltaTime);
    state.pivotY.current = Smooth(state.pivotY.current, state.pivotY.target, PAN_SMOOTH, deltaTime);
    state.pivotZ.current = Smooth(state.pivotZ.current, state.pivotZ.target, PAN_SMOOTH, deltaTime);

    self:ApplyCamera();
end

function TabardyModelFrameMixin:OnModelMouseDown(button)
    self:ModelBeginDrag(button);
end
 
function TabardyModelFrameMixin:OnModelMouseUp(button)
    if DragState.active and DragState.button == button then
        self:ModelEndDrag();
    end
end

function TabardyModelFrameMixin:OnModelMouseWheel(delta)
    local state = CameraState;
    state.distance.target = state.distance.target * (MODEL_ZOOM_WHEEL_STEP ^ -delta);
    state.distance.target = Clamp(state.distance.target, MODEL_MIN_DISTANCE, MODEL_MAX_DISTANCE);
end

function TabardyModelFrameMixin:ModelBeginDrag(button)
    local mode;
    if button == "LeftButton" then
        mode = DRAG_MODE_ROTATE;
    elseif button == "RightButton" then
        mode = DRAG_MODE_PAN;
    else
        return;
    end

    DragState.active = true;
    DragState.mode = mode;
    DragState.button = button;
    DragState.prevX, DragState.prevY = GetScaledCursorPosition();
    DragState.velX, DragState.velY = 0, 0;

    CameraState.yaw.velocity = 0;
    CameraState.pitch.velocity = 0;
end

function TabardyModelFrameMixin:ModelEndDrag()
    if not DragState.active then
        return;
    end

    if DragState.mode == DRAG_MODE_ROTATE then
        CameraState.yaw.velocity   = -DragState.velX * ROTATE_SENSITIVITY;
        CameraState.pitch.velocity = -DragState.velY * ROTATE_SENSITIVITY;
    end

    DragState.active = false;
    DragState.mode = nil;
    DragState.button = nil;
    DragState.velX, DragState.velY = 0, 0;
end

function TabardyModelFrameMixin:Recenter()
    local state = CameraState;
    state.yaw.target = 0;
    state.pitch.target = 0;
    state.distance.target = MODEL_INITIAL_DISTANCE;
    state.pivotX.target = 0;
    state.pivotY.target = 0;
    state.pivotZ.target = MODEL_INITIAL_PIVOT_Z;
    state.yaw.velocity = 0;
    state.pitch.velocity = 0;
end

function TabardyModelFrameMixin:ApplyCamera()
    local state = CameraState;

    local tx = state.pivotX.current;
    local ty = state.pivotY.current;
    local tz = state.pivotZ.current;
    local r = state.distance.current;
    local y = state.yaw.current;
    local p = state.pitch.current;

    local cosP = cos(p);
    local cx = tx + r * cosP * cos(y);
    local cy = ty + r * cosP * sin(y);
    local cz = tz + r * sin(p);

    if not self.Model:HasCustomCamera() then
        self.Model:MakeCurrentCameraCustom();
    end

    self.Model:SetCameraTarget(tx, ty, tz);
    self.Model:SetCameraPosition(cx, cy, cz);
end

function TabardyModelFrameMixin:Setup()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    self:LoadPortrait();
    self:ConfigureModel();
    self:LoadModel();

    if self.Model:IsGuildTabard() then
        MoneyFrame_Update(self.CostFrame, GetTabardCreationCost());
        self.CostFrame:Show();
    else
        self.CostFrame:Hide();
    end
end

function TabardyModelFrameMixin:ConfigureModel()
    self.Model:SetCustomCamera(1);

    local enabled = true;
	local lightValues = {
		omnidirectional = false,
		point = CreateVector3D(-1, 1, -1),
		ambientIntensity = 1.05,
		ambientColor = CreateColor(1, 1, 1),
		diffuseIntensity = 0,
		diffuseColor = CreateColor(1, 1, 1)
	};
	self.Model:SetLight(enabled, lightValues);

    self.Model:EnableMouse(true);
    self.Model:EnableMouseWheel(true);

    self.Model:HookScript("OnMouseDown", function(_, ...) self:OnModelMouseDown(...); end);
    self.Model:HookScript("OnMouseUp", function(_, ...) self:OnModelMouseUp(...); end);
    self.Model:HookScript("OnMouseWheel", function(_, ...) self:OnModelMouseWheel(...); end);

    self.Model:SetPosition(0, 0, 0);
    self.Model:SetFacing(0);
    self.Model:SetPitch(0);
    self.Model:SetRoll(0);
end

function TabardyModelFrameMixin:LoadPortrait()
    local unit = UnitExists("npc") and "npc" or "player";
    SetPortraitTexture(self.PortraitContainer.portrait, unit);
end

function TabardyModelFrameMixin:LoadModel()
    self.Model:InitializeTabardColors();
    self:RefreshModel();
end

function TabardyModelFrameMixin:RefreshModel()
    local blend = true;
    local useNativeForm = self:ShouldUseNativeForm();
    self.Model:SetUnit("player", blend, useNativeForm);
end

function TabardyModelFrameMixin:ShouldUseNativeForm()
    local _, raceFileName = UnitRace("player");
    local useNativeForm = raceFileName ~= "Dracthyr";
    return useNativeForm;
end

function TabardyModelFrameMixin:SaveTabard()
    PlaySound(SOUNDKIT.RAF_RECRUIT_REWARD_CLAIM);
    self.Model:Save();
    self:UpdateButtons();
end

function TabardyModelFrameMixin:UpdateButtons()
end

------------

function ModelTest()
    TabardyModelFrame:Setup();
    DevTool:AddData(TabardyModelFrame, "TabardyModelFrame");
end