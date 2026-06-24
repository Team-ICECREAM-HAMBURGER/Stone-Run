import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- Env.
local pd = playdate
local gfx = pd.graphics

-- Player
local playerStartPosX = 40
local playerStartPosY = 120
local playerSpeed = 3
local playerImage = gfx.image.new("images/capybara.png")
local playerSprite = gfx.sprite.new(playerImage)

-- Obstacle
local obstacleStartPosX = 450
local obstacleStartPosY = 240
local obstacleImage = gfx.image.new("images/rock.png")
local obstacleSprite = gfx.sprite.new(obstacleImage)
local obstacleSpeed = 5

-- Game State
local gameState = "STOPPED"


-- Init
local function init()
    playerSprite:setCollideRect(4, 4, 56, 40) -- (posX, posY, width, height) 
    playerSprite:moveTo(playerStartPosX, playerStartPosY)
    playerSprite:add()

    obstacleSprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    obstacleSprite:setCollideRect(0, 0, 48, 48)
    obstacleSprite:moveTo(obstacleStartPosX, obstacleStartPosY)
    obstacleSprite:add()
end


-- Update
function pd.update()
     gfx.sprite.update()

     -- Game STOPPED
    if gameState == "STOPPED" then
        gfx.drawTextAligned("Press A to Start", 200, 40, kTextAlignment.center)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "ACTIVE"
            playerSprite:moveTo(playerStartPosX, playerStartPosY)
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200))
        end
    -- Game ACTIVE
    elseif gameState == "ACTIVE" then
        local crankPosition = pd.getCrankPosition() -- Clockwise; 0 ~ 270

        if crankPosition <= 90 or crankPosition >= 270 then
            playerSprite:moveBy(0, -playerSpeed) -- posX, posY
        else
            playerSprite:moveBy(0, playerSpeed) -- posX, posY 
        end

        local actualX, actualY, collisions, length = obstacleSprite:moveWithCollisions(obstacleSprite.x - obstacleSpeed, obstacleSprite.y)

        if obstacleSprite.x < -20 then
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200))
        end

        if length > 0 or playerSprite.y > 210 or playerSprite.y < 30 then  -- length of collisions array; D = y - 30
            gameState = "STOPPED"
        end
    end
end





init()
