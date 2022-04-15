local COORDINATOR_HOST = "coordinator.hathora.dev"
local NO_DIFF = {}

local Method = {
	SET_DIRECTION = 0,
}

local function OkResponse() 
	return { type = "ok", } 
end

local function ErrorResponse(error) 
	return { type = "error", error = error, } 
end

local Response = {
	ok = function() 
		return OkResponse() 
	end,
	error = function(error) 
		return ErrorResponse(error) 
	end,
}

local function ResponseMessage(msgId, response)
	return { 
		type = "response", 
		msgId = msgId, 
		response = response, 
	}
end

local function EventMessage(event)
	return { 
		type = "event", 
		event = event, 
	}
end

local Message = {
	response = function(msgId, response) 
		return ResponseMessage(msgId, response) 
	end,
	event = function(event)
		return EventMessage(event)
	end,
}

-- TODO: an interface in TypeScript code, should we use a different approach here?
local AnonymousUserData = {
	type = "anonymous",
	id = "",
	name = "",
}
-- TODO: a class should implement the interface, not just refer to interface
local UserData = AnonymousUserData 

local function lookupUser(userId, fn) 
	  -- return axios.get<UserData>(`https://${COORDINATOR_HOST}/users/${userId}`).then((res) => res.data);
	return fn()
end

local function getUserDisplayName(user)
	if user.type == "anonymous" then return user.name end

	return nil
end

return {
	COORDINATOR_HOST = COORDINATOR_HOST,
	NO_DIFF = NO_DIFF,

	OkResponse = OkResponse,
	ErrorResponse = ErrorResponse,
	Response = Response,

	ResponseMessage = ResponseMessage,
	EventMessage = EventMessage,
	Message = Message,

	AnonymousUserData = AnonymousUserData,
	lookupUser = lookupUser,
	getUserDisplayName = getUserDisplayName,
}



-- export type DeepPartial<T> = T extends string | number | boolean | undefined
--   ? T
--   : T extends Array<infer ArrayType>
--   ? Array<DeepPartial<ArrayType> | typeof NO_DIFF> | typeof NO_DIFF
--   : T extends { type: string; val: any }
--   ? { type: T["type"]; val: DeepPartial<T["val"] | typeof NO_DIFF> }
--   : { [K in keyof T]: DeepPartial<T[K]> | typeof NO_DIFF };


-- if T:is(Array) then
--     if Array.Type == 
-- end