local types = require "api.types"
local Base = require "api.base"

local serde = require "api.lib.bin-serde"

local Point = types.Point
local Player = types.Player
local PlayerState = types.PlayerState
local Direction = types.Direction
local SetDirectionRequest = types.SetDirectionRequest
local InitializeRequest = types.InitializeRequest
local encodeStateSnapshot = types.encodeStateSnapshot
local encodeStateUpdate = types.encodeStateUpdate

local EPSILON = 0.01

local function eq(x, y)
	return math.abs(x - y) < EPSILON
end

local function testScoreEqual(x, y)
	if type(x) ~= type(y) then
		assert(false, "unequal types")
	else
		assert(x == y)
	end
end

local function testPointsEqual(p1, p2)
	if type(p1.x) ~= type(p2.x) then
		assert(false, "unequal types")
	elseif type(p1.x) == "table" then
		assert(p1.x == p2.x)
	else
		assert(eq(p1.x, p2.x))
	end

	if type(p1.y) ~= type(p2.y) then
		assert(false, "unequal types")
	elseif type(p1.y) == "table" then
		assert(p1.y == p2.y)
	else
		assert(eq(p1.y, p2.y))
	end
end

local function testPlayersEqual(p1, p2)
	if type(p1.paddle) ~= type(p2.paddle) then
		assert(false, "unequal types")
	elseif type(p1.paddle) == "table" then
		assert(p1.paddle == p2.paddle)
	else
		assert(eq(p1.paddle, p2.paddle))
	end

	testScoreEqual(p1.score, p2.score)
end

local function testPlayerStateEqual(p1, p2)
	testPlayersEqual(p1.playerA, p2.playerA)
	testPlayersEqual(p1.playerB, p2.playerB)
	testScoreEqual(p1.score, p2.score)
end

local function testPoint(p)
	local enc = Point.encode(p)
	local dec = Point.decode(enc.dataView())
	testPointsEqual(p, dec)
end

local function testPointDiff(p)
	local enc = Point.encodeDiff(p)
	local dec = Point.decodeDiff(enc.dataView())
	testPointsEqual(p, dec)
end

local function testPlayerDiff(p)
	local enc = Player.encodeDiff(p)
	local dec = Player.decodeDiff(enc.dataView())
	testPlayersEqual(p, dec)
end

local function testPlayer(p)
	local enc = Player.encode(p)
	local dec = Player.decode(enc.dataView())
	testPlayersEqual(p, dec)
end

local function testPlayerState(p)
	local enc = PlayerState.encode(p)
	local dec = PlayerState.decode(enc.dataView())
	testPlayerStateEqual(p, dec)
end

local function testPlayerStateDiff(p)
	local enc = PlayerState.encodeDiff(p)
	local dec = PlayerState.decodeDiff(enc.dataView())
	testPlayerStateEqual(p, dec)
end

local function testDirectionRequest(r)
	local enc = SetDirectionRequest.encode(r)
	local dec = SetDirectionRequest.decode(enc.dataView())
	assert(r.direction == dec.direction, "directions not equal")
end

local function testStateUpdate(p, messages)
	-- body
end

function love.load(args)
	local point = Point(0.345, 0.678)
	testPoint(point)

	testPointDiff(Point(Base.NO_DIFF, Base.NO_DIFF))
	testPointDiff(Point(Base.NO_DIFF, 0.5))

	local playerA = Player(0.555, 1)
	testPlayer(playerA)

	local playerB = Player(0.253, 5)
	testPlayer(playerB)

	testPlayerDiff(Player(NO_DIFF, NO_DIFF))

	local playerState = PlayerState(playerA, playerB, point)
	testPlayerState(playerState)

	local buf = encodeStateSnapshot(playerState)
	testPlayerStateDiff(PlayerState(NO_DIFF, playerA, point))

	testDirectionRequest(SetDirectionRequest(Direction.UP))

	testStateUpdate(playerState, 4, {})

	local playerState = PlayerState(
		Player(201.1, 2097151), 
		Player(46.78, 2097152), 
		Point(344.7, 255.9)
	)
	local p = PlayerState.encode(playerState)
	local r = serde.Reader(p.dataView())

	while true do
		local i = r.readUInt8()
		print(i)		
	end
	print(p.dataView().toHex())
end