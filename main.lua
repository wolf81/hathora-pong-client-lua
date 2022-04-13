local types = require "api.types"
local Base = require "api.base"

local Point = types.Point
local Player = types.Player
local PlayerState = types.PlayerState

local EPSILON = 0.01

local function eq(x, y)
	return math.abs(x - y) < EPSILON
end

local function testPoint(p)
	local enc = Point.encode(p)
	local dec = Point.decode(enc.dataView())
	assert(eq(dec.x, p.x) and eq(dec.y, p.y), "points not equal")
end

local function testPointDiff(p)
	local enc = Point.encodeDiff(p)
	local dec = Point.decodeDiff(enc.dataView())

	print(p.x, p.y)
	print(dec.x, dec.y)

	if type(p.x) == "table" then
		assert(p.x == dec.x)
	else
		assert(eq(p.x, dec.x))
	end

	if type(p.y) == "table" then
		assert(p.y == dec.y)
	else
		assert(eq(p.y, dec.y))
	end
end

local function testPlayer(p)
	local enc = Player.encode(p)
	local dec = Player.decode(enc.dataView())
	assert(eq(dec.paddle, p.paddle), "paddle not equal")
	assert(dec.score == p.score, "score not equal")
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

	local playerState = PlayerState(playerA, playerB, point)
	testPlayerState(playerState)


end