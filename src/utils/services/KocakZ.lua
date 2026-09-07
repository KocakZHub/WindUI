--[[

	KocakZ website provider. Validation does not allocate a session or bind HWID.

]]

local KocakZ = {}
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local HttpService = cloneref(game:GetService("HttpService"))

function KocakZ.New(backendURL)
	assert(type(backendURL) == "string" and backendURL:match("^https://"), "Set the KocakZ HTTPS website URL")
	local origin = backendURL:gsub("/+$", "")
	local function post(path, body)
		local send = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
		assert(type(send) == "function", "This executor needs an HTTP request API")
		local response = send({
			Url = origin .. path,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode(body),
		})
		assert(type(response) == "table", "KocakZ returned no response")
		local status = tonumber(response.StatusCode or response.Status) or 0
		local ok, data = pcall(HttpService.JSONDecode, HttpService, response.Body or "")
		assert(ok and type(data) == "table", "KocakZ service is unavailable")
		assert(status >= 200 and status < 300, data.error or "KocakZ request failed")
		return data
	end
	return {
		Verify = function(key)
			if type(key) ~= "string" or key == "" then
				return false, "Enter your KocakZ key"
			end
			local ok, data = pcall(post, "/api/key/check", { key = key })
			if not ok then
				return false, tostring(data)
			end
			return data.valid == true, data.valid and "Key active" or "Key invalid"
		end,
		Copy = function()
			local data = post("/api/flow/create", {})
			assert(
				type(data.url) == "string" and data.url:sub(1, #origin + 6) == origin .. "/flow/",
				"Invalid claim link"
			)
			return data.url
		end,
		Post = post,
	}
end
return KocakZ
