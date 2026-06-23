-- Env.
local pd = playdate
local gfx = pd.graphics

-- Player
local playerPosX = 40
local playerPosY = 120
local playerSpeed = 3
local playerSprite = gfx.image.new("images/capybara.png")


function pd.update()
    gfx.clear() -- Screen Reset

    local crankPosition = pd.getCrankPosition() -- Clockwise; 0 ~ 270

    if crankPosition <= 90 or crankPosition >= 270 then
        playerPosY = playerPosY - playerSpeed
    else
        playerPosY = playerPosY + playerSpeed
    end

    playerSprite:draw(playerPosX, playerPosY)
end
