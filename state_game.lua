local game = {}

function game:draw()
    lg.setColor(255,255,255)
    for i,v in ipairs(level.lanes) do
        v:draw()
    end
    
    for i,v in ipairs(level.lanes) do
        v:drawBlocks()
        v:drawPowerups()
    end
    
    for i,v in ipairs(level.players) do
        v:draw()
    end
    
    tc.draw()
    lg.setBlendMode("additive")

    for i,v in ipairs(level.effects) do
        lg.draw(v, 0, 0)
    end
    
    lg.setBlendMode("alpha")

    score:draw()
    
end

function game.restart()
    level.collider:clear()
    BLOCK_SPEED = START_BLOCK_SPEED
    baseCalm = 3
    calmBeforeStorm = baseCalm
    stormFactor = 0
    score:reset()
    level.reset()
    level.buildLanes()
end

function game:enter(from)
    if from == state.menu then
        game.restart()
        sfx.theme[currentTheme]:rewind()
        sfx.theme[currentTheme]:play()
    end
end

function game:leave()
    sfx.theme[currentTheme]:stop()
end

function game:update(dt)
    for i,v in pairs(level.effects) do
        v:update(dt)
        if v:getCount() == 0 then
            table.remove(level.effects, i)
        end
    end

    if not score:isGameOver() then
        if DEBUG_MODE then
            if love.keyboard.isDown('p') then
                return
            end
        end
        
        for i,v in ipairs(level.lanes) do
            v:update(dt)
        end
        
        for i,v in ipairs(level.players) do
            v:update(dt)
        end
    
        level.collider:update(dt)
    
        if calmBeforeStorm > 0 then
            calmBeforeStorm = calmBeforeStorm - dt
        else
            stormFactor = stormFactor + 1
            calmBeforeStorm = baseCalm + stormFactor
        end
    
        if BLOCK_SPEED < MAX_BLOCK_SPEED then
            BLOCK_SPEED = BLOCK_SPEED + stormFactor * dt
        end
    
        updateAnims(dt)
    end
    score:timeIncrease(dt)
    tc.update(dt)
end



-- equiv to onTouchEnded
function game:mousereleased(x, y, button)
    touch = false
    if button == touchButton then
        if not touchMoved then
            -- tap detected
            tc.tap(x, y)
        elseif not score:isGameOver() then
            local dx = lm.getX() - origTouchX
            local dy = lm.getY() - origTouchY

            if math.abs(dy) > vertSwipeRatio * math.abs(dx) then
                -- vertical swipe detected
                tc.verticalSwipe(dy < 0)
            elseif math.abs(dx) > horizSwipeRatio * math.abs(dy) then
                -- horizontal swipe detected
                tc.horizontalSwipe(dx > 0)
            else
                -- not vertical nor horizontal
                tc.line = "unsupported swipe"
            end

            touchMoved = false
        end
    end 
end

-- equiv to onTouchBegan
function game:mousepressed(x, y, button)
    touch = true
    origTouchX = x
    origTouchY = y
    touchButton = button
end

function game:keypressed(key, isrepeat)
    if score:isGameOver() then
        if key == cont.restart then
            score:storeScore()
            game.restart()
        end
    else
        if DEBUG_MODE and key == 'm' and not isrepeat then
            sfx.theme[currentTheme]:stop()
            currentTheme = currentTheme + 1
            if currentTheme > #sfx.theme then
                currentTheme = 1
            end
            sfx.theme[currentTheme]:play()
        elseif level.activePlayer then
            if key == cont.jump then
                level.activePlayer:jumpUp()
            elseif key == cont.crouch then
                level.activePlayer:jumpDown()
            elseif key == cont.punch then
                level.activePlayer:punch()
            elseif key == cont.laneUp then
                player.laneUp()
            elseif key == cont.laneDown then
                player.laneDown()
            end
        end
    end
    
    if key == cont.quit then
        if score:isGameOver() then
            score:storeScore()
        end
        gs.switch(state.menu)
    end

end


return game
