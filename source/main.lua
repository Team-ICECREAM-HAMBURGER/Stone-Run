import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- Env.
local pd = playdate
local gfx = pd.graphics

-- Player
local playerStartPosX = 40
local playerStartPosY = 120
local playerSpeed = 3
local playerImage = gfx.image.new("images/car.png")
local playerSprite = gfx.sprite.new(playerImage)

-- Obstacle
local obstacleStartPosX = 450
local obstacleStartPosY = 240
local obstacleImage = gfx.image.new("images/rock.png")
local obstacleSprite = gfx.sprite.new(obstacleImage)
local obstacleSpeed = 5

-- Road
local roadStartPosX = 200
local roadStartPosY = 120
local roadImage = gfx.image.new("images/road.png")
local roadSprites = {gfx.sprite.new(roadImage), gfx.sprite.new(roadImage)}
local roadSpeed = 5

-- GuardRail
local guardRailStartPosX = 200
local guardRailStartPosY = 0
local guardRailImage = gfx.image.new("images/guard.png")
local guardRailSprites = {gfx.sprite.new(guardRailImage), gfx.sprite.new(guardRailImage)}

-- Game State
local gameState = "STOPPED"
local gameScore = 0

-- Game UI
local gameScoreUIText = "Score: 0"



-- Init
local function init()
    roadSprites[1]:moveTo(roadStartPosX, roadStartPosY)
    roadSprites[1]:add()
    roadSprites[2]:moveTo(roadStartPosX+444, roadStartPosY)
    roadSprites[2]:add()

    guardRailSprites[1]:moveTo(guardRailStartPosX, guardRailStartPosY+10)
    guardRailSprites[1]:add()
    guardRailSprites[1].collisionResponse = gfx.sprite.kCollisionTypeOverlap
    guardRailSprites[1]:setCollideRect(0, 0, 400, 20)

    playerSprite:setCollideRect(0, 0, 28, 26) -- (posX, posY, width, height) 
    playerSprite:moveTo(playerStartPosX, playerStartPosY)
    playerSprite:add()

    guardRailSprites[2]:moveTo(guardRailStartPosX, guardRailStartPosY+230)
    guardRailSprites[2]:add()
    guardRailSprites[2].collisionResponse = gfx.sprite.kCollisionTypeOverlap
    guardRailSprites[2]:setCollideRect(0, 20, 400, 20)

    obstacleSprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    obstacleSprite:setCollideRect(0, 0, 48, 48)
    obstacleSprite:moveTo(obstacleStartPosX, obstacleStartPosY)
    obstacleSprite:add()
end


-- Update Score
local function updateScore(amount)
    gameScore = gameScore + amount
    gameScoreUIText = string.format("Score: %d", gameScore)
end


-- Update Event Func.
function pd.update()
    gfx.sprite.update()

    if gameState == "STOPPED" then  -- Game STOPPED
        gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)
        gfx.drawTextAligned(gameScoreUIText, 200, 70, kTextAlignment.center)

        if pd.buttonJustPressed(pd.kButtonA) then  -- Game Start
            gameState = "ACTIVE"
            updateScore(-gameScore)
            obstacleSpeed = 5

            playerSprite:moveTo(playerStartPosX, playerStartPosY)
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200))

            roadSprites[1]:moveTo(roadStartPosX, roadStartPosY)
            roadSprites[2]:moveTo(roadStartPosX+444, roadStartPosY)
        end
    elseif gameState == "ACTIVE" then  -- Game ACTIVATED
        local crankPosition = pd.getCrankPosition() -- Clockwise; 0 ~ 270

        if crankPosition <= 90 or crankPosition >= 270 then
            playerSprite:moveBy(0, -playerSpeed) -- posX, posY
        else
            playerSprite:moveBy(0, playerSpeed) -- posX, posY 
        end

        local actualX, actualY, collisions, obstacleLength = obstacleSprite:moveWithCollisions(obstacleSprite.x - obstacleSpeed, obstacleSprite.y)

        if obstacleSprite.x < -20 then
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200)) -- obstacle reset

            updateScore(1)
            obstacleSpeed = obstacleSpeed + 0.5
            roadSpeed = roadSpeed + 0.5
        end

        local playerCollider = playerSprite:overlappingSprites()

        roadSprites[1]:moveBy(-roadSpeed, 0)
        roadSprites[2]:moveBy(-roadSpeed, 0)

        if roadSprites[1].x < -200 then
            roadSprites[1]:moveTo(roadSprites[2].x+444, roadStartPosY)
        end
        if roadSprites[2].x < -200 then
            roadSprites[2]:moveTo(roadSprites[1].x+444, roadStartPosY)
        end

        -- gfx.drawTextAligned(gameScoreUIText, 390, 10, kTextAlignment.right)

        -- Gameover; length of collisions array; D = y - 30
        if #playerCollider > 0 then
            gameState = "STOPPED"
        end
    end
end








init()
