local Base = {}

Base.COORDINATOR_HOST = "coordinator.hathora.dev"
Base.NO_DIFF = {}

local DeepPartial = {} -- T: string | number | boolean | undefined

-- local OkResponse = { type = "ok" }
-- local ErrorResponse = { type = "error", error = "" }
-- local Response = function(type, arg)
-- 	if type == "ok" then return OkResponse() end
-- 	if type == "error" then return ErrorResponse(arg)
-- end
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