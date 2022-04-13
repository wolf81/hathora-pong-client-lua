local types = require "api.types"
local Point = types.Point
local Player = types.Player
local PlayerState = types.PlayerState

function love.load(args)
	local point = Point(0.123, 0.456)
	local enc = Point.encode(point)
	local dec = Point.decode(enc.dataView())

	local playerA = Player(0.555, 1)
	local playerB = Player(0.253, 5)

	local enc = Player.encode(playerA)
	local dec = Player.decode(enc.dataView())

	local playerState = PlayerState(playerA, playerB, point)
	local enc = PlayerState.encode(playerState)
	local dec = PlayerState.decode(enc.dataView())

	print("PADDLE A", 
		playerState.playerA.paddle,
		playerState.playerA.score)
	print("PADDLE B", 
		playerState.playerB.paddle,
		playerState.playerB.score)
	print("BALL",
		playerState.ball.x,
		playerState.ball.y)
end