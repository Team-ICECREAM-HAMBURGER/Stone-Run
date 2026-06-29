import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- Env.
local pd = playdate
local gfx = pd.graphics
TAG_OBSTACLE = 1

-- Player
local playerStartPosX = 40
local playerStartPosY = 120
local playerImage = gfx.image.new("images/car.png")
local playerSprite = gfx.sprite.new(playerImage)
local playerSpeed = 3

-- Obstacle
local obstacleStartPosX = 450
local obstacleStartPosY = 240
local obstacleImage = gfx.image.new("images/rock.png")
local obstacleSprite = gfx.sprite.new(obstacleImage)
obstacleSprite:setTag(TAG_OBSTACLE)

-- Road
local roadStartPosXs = {200, 644}
local roadStartPosY = 120
local roadStackPos = 444
local roadImage = gfx.image.new("images/road.png")
local roadSprites = {gfx.sprite.new(roadImage), gfx.sprite.new(roadImage)}
for i = 1, #roadSprites do
    roadSprites[i]:setTag(TAG_OBSTACLE)
end

-- Upper GuardRail
local guardRailStartPosX = 200
local guardRailStartPosYs = {10, 230}
local upperGuardRailImage = gfx.image.new("images/guard_u.png")
local lowerGuardRailImage = gfx.image.new("images/guard_l.png")
local guardRailSprites = {gfx.sprite.new(upperGuardRailImage), gfx.sprite.new(lowerGuardRailImage)}
for i = 1, #guardRailSprites do
    guardRailSprites[i]:setTag(TAG_OBSTACLE)
end

-- Game State
local gameState = "STOPPED"
local gameScore = 0
local gameSpeed = 5

-- Game UI
local gameScoreUIText = "Score: 0"
local gameUIPanelImage = gfx.image.new("images/panel.png")



-- Init
local function init()
    for i = 1, 2, 1 do
        roadSprites[i]:moveTo(roadStartPosXs[i], roadStartPosY)
        roadSprites[i]:add()
        roadSprites[i]:setZIndex(0)

        guardRailSprites[i]:moveTo(guardRailStartPosX, guardRailStartPosYs[i])
        guardRailSprites[i]:add()
        guardRailSprites[i].collisionResponse = gfx.sprite.kCollisionTypeOverlap
        guardRailSprites[i]:setCollideRect(0, 0, 400, 20)
        guardRailSprites[i]:setZIndex(2)
    end

    playerSprite:moveTo(playerStartPosX, playerStartPosY)
    playerSprite:add()
    playerSprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    playerSprite:setCollideRect(0, 0, 28, 26)
    playerSprite:setZIndex(1)

    obstacleSprite:moveTo(obstacleStartPosX, obstacleStartPosY)
    obstacleSprite:add()
    obstacleSprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    obstacleSprite:setCollideRect(0, 0, 48, 48)
    obstacleSprite:setZIndex(2)
end


-- Update Score
local function updateScore(amount)
    gameScore = gameScore + amount
    gameScoreUIText = string.format("Score: %d", gameScore)
end


-- Update Event Func.
function pd.update()
    gfx.sprite.update()

    -- Game STOP
    if gameState == "STOPPED" then
        gameUIPanelImage:draw(100, 20)
        gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)
        gfx.drawTextAligned(gameScoreUIText, 200, 70, kTextAlignment.center)

        -- Game START
        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "ACTIVE"

            updateScore(-gameScore)
            gameSpeed = 5

            playerSprite:moveTo(playerStartPosX, playerStartPosY)
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200))

            for i = 1, 2, 1 do
                roadSprites[i]:moveTo(roadStartPosXs[i], roadStartPosY)
            end
        end

    -- Game UPDATE
    elseif gameState == "ACTIVE" then
        local crankPosition = pd.getCrankPosition() -- Clockwise; 0 ~ 270
        local playerPosYoffset = (crankPosition <= 90 or crankPosition >= 270) and -playerSpeed or playerSpeed
        local _, _, playerCollisions, _ = playerSprite:moveWithCollisions(playerSprite.x, playerSprite.y + playerPosYoffset)

        -- obstacle movement
        obstacleSprite:moveWithCollisions(obstacleSprite.x - gameSpeed, obstacleSprite.y)

        -- obstacle reset
        if obstacleSprite.x < -20 then
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200))

            updateScore(1)
            gameSpeed = gameSpeed + 0.5
        end

        -- road movement
        for i = 1, 2, 1 do
            roadSprites[i]:moveBy(-gameSpeed, 0)
        end

        -- road rotation
        for i = 1, 2 do
            if roadSprites[i].x < -200 then
                local other = (3 - i)
                roadSprites[i]:moveTo(roadSprites[other].x + roadStackPos, roadStartPosY)
            end
        end

        -- Gameover;
        if playerCollisions and #playerCollisions > 0 then
            for i = 1, #playerCollisions do
                local collision = playerCollisions[i]
                local otherTag = collision.other:getTag()

                if otherTag == TAG_OBSTACLE then
                    gameState = "STOPPED"
                end
            end
        end
    end
end










init()
