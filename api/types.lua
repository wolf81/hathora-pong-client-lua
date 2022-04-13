local _PATH = (...):match("(.-)[^%.]+$") 

local serde = require(_PATH .. "lib.bin-serde")
local Writer = serde.Writer
local Reader = serde.Reader

local function isView(buf)
	--[[
	-- TODO: 
	-- ensure this function does the same as in TypeScript:
	-- const sb = ArrayBuffer.isView(buf) ? new _Reader(buf) : buf;
	--]]
	return 
		getmetatable(buf) == serde.DataView
end

local function writeFloat(buf, x)
	buf.writeFloat(x)
end

local function writeInt(buf, x)
	buf.writeVarint(x)
end

local function parseFloat(buf)
	return buf.readFloat()
end

local function parseInt(buf)
	return buf.readVarint(x)
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

function Point.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return Point(
		parseFloat(sb), 
		parseFloat(sb)
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

function Player.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return Player(
		parseFloat(sb),
		parseInt(sb)
	)
end

setmetatable(Player, {
	__call = Player.new,
})

-- PLAYER_STATE

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

function PlayerState.decode(buf)
	local sb = isView(buf) and Reader(buf) or buf
	return PlayerState(
		Player.decode(sb),
		Player.decode(sb),
		Point.decode(sb)
	)
end

setmetatable(PlayerState, {
	__call = PlayerState.new,
})

-- MODULE

return {
	Direction = Direction,
	Point = Point,
	Player = Player,
	PlayerState = PlayerState,
}