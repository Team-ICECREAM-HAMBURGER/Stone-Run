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

-- Game State
local gameState = "STOPPED"



-- Init
local function init()
    playerSprite:setCollideRect(4, 4, 56, 40) -- (posX, posY, width, height) 
    playerSprite:moveTo(playerStartPosX, playerStartPosY)
    playerSprite:add()
end


-- Update
function pd.update()
     gfx.sprite.update()

    if gameState == "STOPPED" then
        gfx.drawText("Press A to Start", 200, 40)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "ACTIVE"
            playerSprite:moveTo(playerStartPosX, playerStartPosY)
        end
    elseif gameState == "ACTIVE" then
        local crankPosition = pd.getCrankPosition() -- Clockwise; 0 ~ 270

        if crankPosition <= 90 or crankPosition >= 270 then
            playerSprite:moveBy(0, -playerSpeed) -- posX, posY
        else
            playerSprite:moveBy(0, playerSpeed) -- posX, posY 
        end
    end
end





init()
