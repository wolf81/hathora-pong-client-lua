local jwtdec = require "client.hathora.lib.jwtdec"
local json = require "client.hathora.lib.json.json"
local https = require "https"

local base = require "api.base"
local COORDINATOR_HOST = base.COORDINATOR_HOST

local types = require "api.types"
local InitializeRequest = types.InitializeRequest

local socket = require("socket") -- bundled with LÖVE


-- HathoraConnection

local HathoraConnection = {}
HathoraConnection.new = function(stateId, socket, onUpdate)
    return setmetatable({

    }, HathoraConnection)
end

setmetatable(HathoraConnection, {
    __call = HathoraConnection.new,
})


-- HathoraClient

local HathoraClient = {}
HathoraClient.appId = "5a24ea699a1a67b303801e2cc9318dd4998ef957766b6b64d5a8cc3c3f626efd"
HathoraClient.new = function()

    local function getUserFromToken(token)
        local _, body, _ = jwtdec(token)
        return body
    end

    -- TODO: implement as promise?
    local function loginAnonymous()
        local path = 'https://' .. COORDINATOR_HOST .. '/' .. HathoraClient.appId .. '/login/anonymous'
        local _, body, _ = https.request(path, { method = 'post' })
        local data = json.decode(body)
        return data.token
    end

    local function create(token, request)
        -- TODO: assert token is defined

        local path = 'https://' .. COORDINATOR_HOST .. '/' .. HathoraClient.appId .. '/create'
        local code, body, headers = https.request(path, {
            method = 'post',
            headers = {
                ["Authorization"] = token,
                ["Content-Type"] = "application/octet-stream",
            },
            data = InitializeRequest.encode(request).toBuffer(),
        })

        local data = json.decode(body)

        return data.stateId
    end

    local function connect(token, stateId, onUpdate, onConnectionFailure)
        local udp = socket.udp()

        return HathoraConnection(stateId, udp, onUpdate)
    end

    return setmetatable({
        getUserFromToken = getUserFromToken,
        loginAnonymous = loginAnonymous,
        create = create,
        connect = connect,
    }, HathoraClient)
end

setmetatable(HathoraClient, {
    __call = HathoraClient.new,
})


-- the module 

return {
    HathoraClient = HathoraClient,
    HathoraConnection = HathoraConnection,
}