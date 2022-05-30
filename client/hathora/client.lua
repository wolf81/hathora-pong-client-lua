-- local luajwt = require "client.hathora.lib.luajwt.luajwt"

-- local https = require("https")
--[[
export const COORDINATOR_HOST = "coordinator.hathora.dev";


  public appId = "5a24ea699a1a67b303801e2cc9318dd4998ef957766b6b64d5a8cc3c3f626efd";
    const res = await axios.post(`https://${COORDINATOR_HOST}/${this.appId}/login/anonymous`);


// https://coordinator.hathora.dev/5a24ea699a1a67b303801e2cc9318dd4998ef957766b6b64d5a8cc3c3f626efd/login/anonymous



curl -X POST https://coordinator.hathora.dev/5a24ea699a1a67b303801e2cc9318dd4998ef957766b6b64d5a8cc3c3f626efd/login/anonymous

{   
    "token":
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYW5vbnltb3VzIiwiaWQiOiJkZG4wNW0wcGt2dCIsIm5hbWUiOiJyZXNwZWN0aXZlLWFtYmVyLW1hcmxpbiIsImlhdCI6MTY1MzgwOTYyMH0.Pysr_pwPCZyUTvJk-B4xAcu8JOsXItGqOyDGxHXMTrc"
}%

]]

local https = require "https"

local HathoraClient = {}
HathoraClient.appId = "5a24ea699a1a67b303801e2cc9318dd4998ef957766b6b64d5a8cc3c3f626efd"
HathoraClient.new = function()

    local function getUserFromToken()
        local code, body, headers = https.request('https://api.ipify.org/?format=json', {})
        print(code, body, headers)

        for k,v in pairs(headers) do
            print(k, v)
        end

       print("getUserFromToken")
    end

    return setmetatable({
        getUserFromToken = getUserFromToken,
    }, HathoraClient)
end

setmetatable(HathoraClient, {
    __call = HathoraClient.new,
})

return HathoraClient