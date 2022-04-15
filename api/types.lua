local _PATH = (...):match("(.-)[^%.]+$") 

local serde = require(_PATH .. "lib.bin-serde")
local Writer = serde.Writer
local Reader = serde.Reader

local Base = require(_PATH .. "base")
local Response = Base.Response
local Message = Base.Message
local NO_DIFF = Base.NO_DIFF

function isArray(t)
	return #t > 0 and next(t, #t) == nil
end

local function isView(buf)
	return getmetatable(buf) == serde.DataView
end

local function push(arr, val)
	arr[#arr + 1] = val
end

local function flatMap(arr, fn)
	local results = {}

	for _, val in ipairs(arr) do
		local r = fn(val)
		if r ~= nil then
			print("ADD RESULT")
			results[#results + 1] = r
		end
	end

	return results
end

local function map(arr, fn)
	local results = {}

	for _, val in ipairs(arr) do
		results[#results + 1] = fn(val)
	end

	return results
end

local function spread(arr, fn)
	return fn(unpack(arr))
end

local function shift(arr)
	return table.remove(arr, 1)
end

local function writeUInt8(buf, x)
	buf.writeUInt8(x)
end

local function writeBoolean(buf, x)
	buf.writeUInt8(x and 1 or 0)
end

local function writeInt(buf, x)
	buf.writeVarint(x)
end

local function writeFloat(buf, x)
	buf.writeFloat(x)
end

local function writeString(buf, x)
	buf.writeString(x)
end

local function writeOptional(buf, x, innerWrite)
	writeBoolean(buf, x ~= nil)
	if x ~= nil then
		innerWrite(x)
	end
end

local function writeArray(buf, x, innerWrite)
	buf.writeUVarint(#x)
	for _, ix in ipairs(x) do
		innerWrite(ix)
	end
end

local function writeArrayDiff(buf, x, innerWrite)
	buf.writeUVarint(#x)
	local tracker = {}
	for _, val in ipairs(x) do
		push(tracker, x ~= NO_DIFF)
	end
	buf.writeBits(tracker)
	for _, val in ipairs(x) do
		if val ~= NO_DIFF then
			innerWrite(val)
		end
	end
end

local function parseUInt8(buf)
	return buf.readUInt8()
end

local function parseBoolean(buf)
	return buf.readUInt8() > 0
end

local function parseInt(buf)
	return buf.readVarint()
end

local function parseFloat(buf)
	return buf.readFloat()
end

local function parseString(buf)
	return buf.readString()
end

local function parseOptional(buf, innerParse)
	return parseBoolean(buf) and innerParse(buf) or nil
end

local function parseArray(buf, innerParse)
	local len = buf.readUVarInt()
	local arr = {}
	for i = 1, len do
		push(arr, innerParse())
	end
	return arr
end

local function parseArrayDiff(buf, innerParse)
	local len = buf.readUVarInt()
	local tracker = buf.readBits(len)
	local arr = {}
	for i = 1, len do
		if shift(tracker) then
			push(arr, innerParse())
		else
			push(arr, NO_DIFF)
		end
	end
	return arr
end

local Direction = {
	NONE = 0,
	UP = 1,
	DOWN = 2
}

-- POINT

local Point = {}
Point.__index = Point

function Point:new(x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0,
	}, Point)
end

function Point.encode(obj, writer)
	local buf = writer or Writer()
	writeFloat(buf, obj.x)
	writeFloat(buf, obj.y)
	return buf
end

function Point.encodeDiff(obj, writer)
	local buf = writer or Writer()
	local tracker = {}
	push(tracker, obj.x ~= NO_DIFF)
	push(tracker, obj.y ~= NO_DIFF)
	buf.writeBits(tracker)
	if obj.x ~= NO_DIFF then writeFloat(buf, obj.x) end
	if obj.y ~= NO_DIFF then writeFloat(buf, obj.y) end
	return buf
end

function Point.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return Point(
		parseFloat(sb), 
		parseFloat(sb)
	)
end

function Point.decodeDiff(buf)
	local sb = isView(buf) and Reader(buf) or buf	
	local tracker = sb.readBits(2)	
	return Point(
		shift(tracker) and parseFloat(sb) or NO_DIFF,
		shift(tracker) and parseFloat(sb) or NO_DIFF
	)
end

setmetatable(Point, {
	__call = Point.new,
})

-- PLAYER 

local Player = {}
Player.__index = Player

function Player:new(paddle, score)
	return setmetatable({
		paddle = paddle or 0.0,
		score = score or 0,
	}, Player)
end

function Player.encode(obj, writer)	
	local buf = writer or Writer()
	writeFloat(buf, obj.paddle)
	writeInt(buf, obj.score)
	return buf
end

function Player.encodeDiff(obj, writer)
	local buf = writer or Writer()
	local tracker = {}
	push(tracker, obj.paddle ~= NO_DIFF)
	push(tracker, obj.score ~= NO_DIFF)
	buf.writeBits(tracker)
	if obj.paddle ~= NO_DIFF then
		writeFloat(buf, obj.paddle)
	end
	if obj.score ~= NO_DIFF then
		writeInt(buf, obj.score)
	end
	return buf
end

function Player.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return Player(
		parseFloat(sb),
		parseInt(sb)
	)
end

function Player.decodeDiff(buf)
	local sb = isView(buf) and Reader(buf) or buf
	local tracker = sb.readBits(2)
	return Player(
		shift(tracker) and parseFloat(sb) or NO_DIFF,
		shift(tracker) and parseInt(sb) or NO_DIFF
	)
end

setmetatable(Player, {
	__call = Player.new,
})

-- PLAYER STATE

local PlayerState = {}
PlayerState.__index = PlayerState

function PlayerState:new(playerA, playerB, ball)
	return setmetatable({
		playerA = playerA or Player(),
		playerB = playerB or Player(),
		ball = ball or Point(),
	}, PlayerState)
end

function PlayerState.encode(obj, writer)
	local buf = writer or Writer()
	Player.encode(obj.playerA, buf)
	Player.encode(obj.playerB, buf)
	Point.encode(obj.ball, buf)
	return buf
end

function PlayerState.encodeDiff(obj, writers)
	local buf = writer or Writer()
	local tracker = {}
	push(tracker, obj.playerA ~= NO_DIFF)
	push(tracker, obj.playerB ~= NO_DIFF)
	push(tracker, obj.ball ~= NO_DIFF)
	buf.writeBits(tracker)
	if obj.playerA ~= NO_DIFF then
		Player.encodeDiff(obj.playerA, buf)
	end
	if obj.playerB ~= NO_DIFF then
		Player.encodeDiff(obj.playerB, buf)
	end
	if obj.ball ~= NO_DIFF then
		Point.encodeDiff(obj.ball, buf)
	end
	return buf
end

function PlayerState.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return PlayerState(
		Player.decode(sb),
		Player.decode(sb),
		Point.decode(sb)
	)
end

function PlayerState.decodeDiff(buf)
	local sb = isView(buf) and Reader(buf) or buf
	local tracker = sb.readBits(3)
	return PlayerState(
		shift(tracker) and Player.decodeDiff(sb) or NO_DIFF,
		shift(tracker) and Player.decodeDiff(sb) or NO_DIFF,
		shift(tracker) and Point.decodeDiff(sb) or NO_DIFF
	)
end

setmetatable(PlayerState, {
	__call = PlayerState.new,
})

-- SET DIRECTION REQUEST

local SetDirectionRequest = {}
SetDirectionRequest.__index = SetDirectionRequest

function SetDirectionRequest:new(direction)
	return setmetatable({
		direction = direction or 0, -- Direction.NONE
	}, SetDirectionRequest)
end

function SetDirectionRequest.encode(obj, writer)
	local buf = writer or Writer()
	writeUInt8(buf, obj.direction)
	return buf
end

function SetDirectionRequest.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return SetDirectionRequest(
		parseUInt8(sb)
	)
end

setmetatable(SetDirectionRequest, {
	__call = SetDirectionRequest.new,
})

-- INITIALIZE REQUEST

local InitializeRequest = {}
InitializeRequest.__index = InitializeRequest

function InitializeRequest:new()
	return setmetatable({}, InitializeRequest)
end

function InitializeRequest.encode(x, buf)
	return buf or Writer()
end

function InitializeRequest.decode(buf)
	return InitializeRequest()
end

setmetatable(InitializeRequest, {
	__call = InitializeRequest.new,
})

-- STATE SNAPSHOT

local function encodeStateSnapshot(x)
	local buf = Writer()
	buf.writeUInt8(0)

	local status, result = pcall(function()
		return PlayerState.encode(x, buf)
	end)

	if not status then
		print("Invalid user state", x)
		error(result)
	end

	return result.toBuffer()	
end

-- STATE UPDATE

local function encodeStateUpdate(x, changedAtDiff, messages)
	local buf = Writer()
	buf.writeUInt8(1)
	buf.writeUVarint(changedAtDiff)
	local responses = flatMap(messages, function(msg)
		return msg.type == "response" and msg or nil
	end)
	buf.writeUVarint(#responses)
	print("#r", #responses)
	for _, response in ipairs(responses) do
		print("encode msgId", response.msgId)
		buf.writeUInt32(response.msgId) 
		writeOptional(
			buf, 
			response.type == "error" and response.error or nil, 
			function(x) writeString(buf, x) end
		)
	end
	local events = flatMap(messages, function(msg)
		return msg.type == "event" and msg.event or nil
	end)
	buf.writeUVarint(#events)
	print("#e", #events)
	for _, event in ipairs(events) do
		print("evt", event)
		buf.writeString(event)
	end
	if x ~= nil then
		PlayerState.encodeDiff(x, buf)
	end
	return buf -- buf.toBuffer() -- TODO: should be buf.toBuffer()
end

--[[
result:
{
  stateDiff?: _DeepPartial<PlayerState>;
  changedAtDiff: number;
  responses: _ResponseMessage[];
  events: _EventMessage[];
}
--]]

local function decodeStateUpdate(buf)
	local sb = isView(buf) and Reader(buf) or buf
	
	-- TODO: remove this (value: 0) as when we have a 0 value, we know we need 
	-- to decode the state update
	sb.readUVarint()

	local changedAtDiff = sb.readUVarint()

	local responseCount = sb.readUVarint()
	local responses = {}
	for i = 1, responseCount do
		local msgId = sb.readUInt32()
		local maybeError = parseOptional(sb, function()
			return parseString(sb)
		end)
		responses[#responses + 1] = Message.response(msgId, maybeError == nil, Response.ok(), Response.error(maybeError))		
	end

	local eventCount = sb.readUVarint()
	local events = {}
	for i = 1, eventCount do
		events[#events + 1] = Message.event(sb.readString())
	end

	local stateDiff = sb.remaining() > 0 and PlayerState.decodeDiff(sb) or nil
	return stateDiff, changedAtDiff, responses, events
end

-- USER ID

local UserID = ""

-- MODULE

return {
	Direction = Direction,
	Point = Point,
	Player = Player,
	PlayerState = PlayerState,

	SetDirectionRequest = SetDirectionRequest,
	InitializeRequest = InitializeRequest,

	encodeStateSnapshot = encodeStateSnapshot,
	encodeStateUpdate = encodeStateUpdate,
	decodeStateUpdate = decodeStateUpdate,

	UserID = UserID,
}