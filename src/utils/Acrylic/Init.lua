-- Credits: Fluent - Dawid

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local Acrylic = {
	-- Keep Blur/Paint unloaded unless a window actually enables acrylic.
	AcrylicBlur = function(...)
		return require("./Blur")(...)
	end,
	AcrylicPaint = function(...)
		return require("./Paint")(...)
	end,
}

local baseEffect
local depthOfFieldDefaults = {}
local enabled = false

local function ensureBaseEffect()
	if not baseEffect then
		baseEffect = Instance.new("DepthOfFieldEffect")
		baseEffect.FarIntensity = 0
		baseEffect.InFocusRadius = 0.1
		baseEffect.NearIntensity = 1
	end
end

local function registerDefaults()
	local function register(object)
		if object:IsA("DepthOfFieldEffect") and object ~= baseEffect and depthOfFieldDefaults[object] == nil then
			depthOfFieldDefaults[object] = object.Enabled
		end
	end

	for _, child in pairs(cloneref(game:GetService("Lighting")):GetChildren()) do
		register(child)
	end

	if cloneref(game:GetService("Workspace")).CurrentCamera then
		for _, child in pairs(cloneref(game:GetService("Workspace")).CurrentCamera:GetChildren()) do
			register(child)
		end
	end
end

function Acrylic.Enable()
	if enabled then
		return
	end
	ensureBaseEffect()
	registerDefaults()
	enabled = true
	for effect in pairs(depthOfFieldDefaults) do
		if effect.Parent then
			effect.Enabled = false
		end
	end
	baseEffect.Parent = cloneref(game:GetService("Lighting"))
end

function Acrylic.Disable()
	if not enabled then
		return
	end
	enabled = false
	for effect, wasEnabled in pairs(depthOfFieldDefaults) do
		if effect.Parent then
			effect.Enabled = wasEnabled
		end
	end
	baseEffect.Parent = nil
end

function Acrylic.init()
	Acrylic.Enable()
end

return Acrylic
