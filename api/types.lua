local _PATH = (...):match("(.-)[^%.]+$") 

local serde = require(_PATH .. "lib.bin-serde")
local Writer = serde.Writer
local Reader = serde.Reader

local Base = require(_PATH .. "base")
local NO_DIFF = Base.NO_DIFF

local function isView(buf)
	return getmetatable(buf) == serde.DataView
end

local function push(tbl, val)
	tbl[#tbl + 1] = val
end

local function shift(tbl)
	return table.remove(tbl, 1)
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

function PlayerState.encodeDiff(obj, writers)
	local buf = writer or Writer()
	local tracker = {}
	push(tracker, obj.playerA ~= NO_DIFF)
	push(tracker, obj.playerB ~= NO_DIFF)
	push(tracker, obj.ball ~= NO_DIFF)
	buf.writeBits(tracker)
	print(buf.dataView().toHex())
	if obj.playerA ~= NO_DIFF then
		Player.encodeDiff(obj.playerA, buf)
	end
	print(buf.dataView().toHex())
	if obj.playerB ~= NO_DIFF then
		Player.encodeDiff(obj.playerB, buf)
	end
	print(buf.dataView().toHex())
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

-- USERID

local UserID = ""

-- MODULE

return {
	Direction = Direction,
	Point = Point,
	Player = Player,
	PlayerState = PlayerState,
	UserID = UserID,
}