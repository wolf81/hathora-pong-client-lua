local Base = {}

Base.COORDINATOR_HOST = "coordinator.hathora.dev"
Base.NO_DIFF = {}

local function OkResponse() 
	return { type = "ok" } 
end
local function ErrorResponse(error) 
	return { type = "error", error = error } 
end
local Response = {
	ok = function() 
		return OkResponse() 
	end,
	error = function(error) 
		return ErrorResponse(error) 
	end,
}

print(Response.ok().type)
print(Response.error("blaat").error)

local function ResponseMessage(msgId, response)
	return { 
		type = "response", 
		msgId = msgId, 
		response = response, 
	}
end

local function EventMessage(event)
	return { type = "event", event = event }
end

local Message = {
	response = function(msgId, response) 
		return ResponseMessage(msgId, response) 
	end,
	event = function(event)
		return EventMessage(event)
	end,
}

return Base



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