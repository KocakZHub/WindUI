--[[

	Junkie Development SDK   |   https://docs.jnkie.com/roblox-sdk/inline-ui

]]

local JunkieDevelopment = {}

local SDK_URL = "https://jnkie.com/sdk/library.lua"

local function loadSDK()
	assert(type(loadstring) == "function", "Your executor does not provide loadstring")

	local source = game:HttpGet(SDK_URL)
	local chunk, compileError = loadstring(source)
	assert(chunk, "Failed to compile the Junkie SDK: " .. tostring(compileError))

	local Junkie = chunk()
	assert(type(Junkie) == "table", "Junkie SDK returned an invalid library")
	assert(type(Junkie.check_key) == "function", "Junkie SDK does not provide check_key")
	assert(type(Junkie.get_key_link) == "function", "Junkie SDK does not provide get_key_link")
	return Junkie
end

function JunkieDevelopment.New(Service, Identifier, Provider)
	local Junkie = loadSDK()
	Junkie.service = Service
	Junkie.identifier = tostring(Identifier)
	Junkie.provider = Provider

	local function validateKey(key)
		if type(key) ~= "string" or key == "" then
			return false, "KEY_INVALID"
		end

		local callOk, result = pcall(Junkie.check_key, key)
		if not callOk then
			return false, "Junkie SDK request failed: " .. tostring(result)
		end
		if type(result) ~= "table" then
			return false, "Junkie SDK returned an invalid response"
		end

		if result.valid == true or result.success == true then
			local env = (getgenv and getgenv()) or _G
			env.SCRIPT_KEY = key
			return true, tostring(result.message or "KEY_VALID")
		end

		return false, tostring(result.error or result.message or "KEY_INVALID")
	end

	local function getKeyLink()
		local callOk, link, err = pcall(Junkie.get_key_link)
		if not callOk then
			error("Junkie SDK request failed: " .. tostring(link))
		end
		if type(link) ~= "string" or link == "" then
			error(tostring(err or "Junkie SDK did not return a key link"))
		end
		return link
	end

	return {
		Verify = validateKey,
		Copy = getKeyLink,
	}
end

return JunkieDevelopment
