import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"

-- Env.
local gameSaveFile = playdate.datastore
local gameSaveData = playdate.datastore.read()
local pd = playdate
local gfx = playdate.graphics
local pui = playdate.ui
local sfx = playdate.sound
TAG_OBSTACLE = 1
TAG_ITEM = 2

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

-- Item
local itemStartPosX = 450
local itemStartPosY = 240
local itemImage = gfx.image.new("images/item.png")
local itemSprite = gfx.sprite.new(itemImage)
itemSprite:setTag(TAG_ITEM)

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
local guardRailImage = gfx.image.new("images/guard.png")
local guardRailSprites = {gfx.sprite.new(guardRailImage), gfx.sprite.new(guardRailImage)}
for i = 1, #guardRailSprites do
    guardRailSprites[i]:setTag(TAG_OBSTACLE)
end

-- Game State
local gameState = "STOPPED"
local gameSpeed = 5
local gameScore = 0
local gameHighScore = 0
local isHighScoreRecording = false

-- Game UI
local gameUIPanelImage = gfx.image.new("images/panel.png")
local gameScoreUItext = "0"
local gameHighScoreUItext = "High Score: 0"
local gameCommentUItexts = {"", "BEST RECORD!!", "KEEP GOING!!", "YEAHH!!", "XD", "READY?"}
local gameStartUItext = "Press (A) to Start"

-- SFX
local crashSound = sfx.sampleplayer.new("sounds/crash")
local itemGetSound = sfx.sampleplayer.new("sounds/itemGet")
local carEngineSound = sfx.fileplayer.new("sounds/engine_loop")

-- White Text
function DrawWhiteTextAligned(text, x, y, alignment)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned(text, x, y, alignment)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end


-- Update High Score
local function updateHighScore(amount)
    gameHighScore = amount
    gameHighScoreUItext = string.format("High Score: %d", gameHighScore)
end


-- Update Score
local function updateScore(amount)
    gameScore = gameScore + amount
    gameScoreUItext = string.format("%d", gameScore)

    if gameScore > gameHighScore then
        updateHighScore(gameScore)
        isHighScoreRecording = true
    end
end


-- Init
local function init()
    isHighScoreRecording = false
    gameState = "STOPPED"

    -- Load Savedata
    if gameSaveData == nil then
        gameSaveData = {highScore = 0}
    else
        gameHighScore = gameSaveData.highScore
        updateHighScore(gameHighScore)
    end

    -- Load Sprites
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

    itemSprite:moveTo(itemStartPosX, itemStartPosY)
    itemSprite:add()
    itemSprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    itemSprite:setCollideRect(0, 0, 20, 20)
    itemSprite:setZIndex(2)
end


-- Update Event Func.
function pd.update()
    gfx.sprite.update()

    -- Crank Noti.
    if pd.isCrankDocked() then
        pui.crankIndicator:draw()
    end

    -- In-Game UI
    DrawWhiteTextAligned(gameScoreUItext, 10, 1, kTextAlignment.left)
    DrawWhiteTextAligned(gameHighScoreUItext, 390, 1, kTextAlignment.right)

    local gameCommentIndex = 1

    -- HighScore Comment
    if isHighScoreRecording then
        gameCommentIndex = 2

        if gameScore > gameSaveData.highScore + 3 then
            gameCommentIndex = 3
        end

        if gameScore > gameSaveData.highScore + 6 then
            gameCommentIndex = 4
        end
    end

    -- Gamestate Comment
    if gameState == "OVER" then
        isHighScoreRecording = false

        gameSaveData.highScore = gameHighScore
        gameSaveFile.write(gameSaveData)

        gameCommentIndex = 5

    elseif gameState == "STOPPED" then
        isHighScoreRecording = false
        gameCommentIndex = 6
    end

    DrawWhiteTextAligned(gameCommentUItexts[gameCommentIndex], 10, 223, kTextAlignment.left)

    -- Game READY
    if gameState == "STOPPED" or gameState == "OVER" then
        gameUIPanelImage:draw(100, 30)
        gfx.drawTextAligned(gameHighScoreUItext, 200, 50, kTextAlignment.center)
        gfx.drawTextAligned(gameScoreUItext, 200, 85, kTextAlignment.center)
        gfx.drawTextAligned(gameStartUItext, 200, 170, kTextAlignment.center)

        -- Game START
        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "ACTIVE"

            updateScore(-gameScore)
            gameSpeed = 5

            isHighScoreRecording = false

            playerSprite:moveTo(playerStartPosX, playerStartPosY)
            obstacleSprite:moveTo(obstacleStartPosX, math.random(40, 200))
            itemSprite:moveBy(itemStartPosX, math.random(40, 200))

            for i = 1, 2, 1 do
                roadSprites[i]:moveTo(roadStartPosXs[i], roadStartPosY)
            end
        end

    -- Game UPDATE
    elseif gameState == "ACTIVE" then
        local crankPosition = pd.getCrankPosition()
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

        -- item movement
        itemSprite:moveWithCollisions(itemSprite.x - gameSpeed, itemSprite.y)

        -- item reset
        if itemSprite.x < -80 then
            itemSprite:moveTo(itemStartPosX, math.random(40, 200))
        end

        -- engine SFX
        carEngineSound:play(0)

        -- Collision check
        if playerCollisions and #playerCollisions > 0 then
            for i = 1, #playerCollisions do
                local collision = playerCollisions[i]
                local otherTag = collision.other:getTag()

                if otherTag == TAG_OBSTACLE then
                    gameState = "OVER"

                    crashSound:play()
                    carEngineSound:stop()
                elseif otherTag == TAG_ITEM then
                    updateScore(2)
                    gameSpeed = gameSpeed + 0.2

                    itemSprite:moveTo(itemStartPosX, math.random(40, 200))
                    itemGetSound:play()
                end
            end
        end
    end
end










init()
