local types = require "api.types"
local Base = require "api.base"

local Point = types.Point
local Player = types.Player
local PlayerState = types.PlayerState

local EPSILON = 0.01

local function eq(x, y)
	return math.abs(x - y) < EPSILON
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

	if type(p1.score) ~= type(p2.score) then
		assert(false, "unequal types")
	else
		assert(p1.score == p2.score)
	end
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
end

local function testPlayer(p)
	local enc = Player.encode(p)
	local dec = Player.decode(enc.dataView())
	testPlayersEqual(p, dec)
end

local function testPlayerState(p)
	local enc = PlayerState.encode(p)
	local dec = PlayerState.decode(enc.dataView())

	assert(eq(dec.playerA.paddle, p.playerA.paddle), "playerA paddle not equal")
	assert(eq(dec.playerB.paddle, p.playerB.paddle), "playerB paddle not equal")
	assert(dec.playerA.score == p.playerA.score, "player A score not equal")
	assert(dec.playerB.score == p.playerB.score, "player B score not equal")
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
end