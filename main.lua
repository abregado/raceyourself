require('registry')

function love.load()
    buildAnimations()
    level.collider:setCallbacks(level.collide,level.endCollide)
    score = scoring.new()
    sfx.theme[currentTheme]:play()
    tc.load()
    ps.load()
    restart()
end

function restart()
    level.collider:clear()
    BLOCK_SPEED = START_BLOCK_SPEED
    baseCalm = 3
    calmBeforeStorm = baseCalm
    stormFactor = 0
    score:reset()
    level.reset()
    level.buildLanes()
end

function buildAnimations()
    anims.pShip = {}
    for i,v in ipairs(as.pShip) do
        local newSheet = an.newGrid(64,64,v:getWidth(),v:getHeight())
        local newAnim = an.newAnimation(newSheet('1-5',1),0.3)
        table.insert(anims.pShip,newAnim)
    end
end

function love.draw()
    lg.reset()
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

    score:draw()
end

function updateAnims(dt)
	for i,v in pairs(anims) do
		for j,k in pairs(v) do
            k:update(dt)
        end
	end
end

function love.update(dt)
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

    tc.update(dt)
end

function level.reset()
    level.lanes = {}
    level.players = {}
    level.effects = {}
end

function level.buildLanes()
    for i=1,LANES do
        table.insert(level.lanes,lane.new(i))
    end
    
    for i,v in ipairs(level.lanes) do
        table.insert(level.players,player.new(v,i))
        level.selectNewPlayer(2)
    end
    
end

function level.collide(dt, s1, s2, dx, dy)
    if s1.isCone and not s2.parent.isPlayer then
        s1.parent:look(s2)
    elseif s2.isCone and not s1.parent.isPlayer then
        s2.parent:look(s1)
    else
        local p
        local b
        if s1.parent.isPlayer ==s2.parent.isPlayer then 
            return false
        end
        
        if s1.parent.isPlayer == true then
            p = s1.parent
            b = s2.parent
        else
            p = s2.parent
            b = s1.parent
        end

        if p.isPunching and p.color == b.color then
            sfx.impact:rewind()
            sfx.impact:play()
            if love.system.getOS() == "Android" then
                --no explosions
            else
                local fx = ps.systems.explosion:clone()
                local c = COLORS[p.color]
                fx:setColors(c[1], c[2], c[3], 255, c[1], c[2], c[3], 0)
                fx:setPosition(p.ax, p.ay)
                fx:start()
                table.insert(level.effects, fx)
            end
            b:destroy()
            score:incrementKills()
        else
            if b.isPowerup then
                sfx.powerup:rewind()
                sfx.powerup:play()
                b:destroy()
                score:collectPowerup()
            else
                sfx.explosion:rewind()
                sfx.explosion:play()
                if love.system.getOS() == "Android" then
                    --no explosions
                else
                    local fx = ps.systems.explosion:clone()
                    local c = COLORS[p.color]
                    fx:setColors(c[1], c[2], c[3], 255, c[1], c[2], c[3], 0)
                    fx:setPosition(p.ax, p.ay)
                    fx:start()
                    table.insert(level.effects, fx)
                end

                if p.isControlled then
                    score:decrementLives()
                end

                p:deactivate()
                tc.line = "Collision"
            end
            --p.isColliding = true
            --b.isColliding = true
        end
    
    end
    
    
end

function level.endCollide(dt, s1, s2, dx, dy)
    s1.parent.isColliding = false
    s2.parent.isColliding = false
end

-- equiv to onTouchBegan
function love.mousepressed(x, y, button)
    touch = true
    origTouchX = x
    origTouchY = y
    touchButton = button
end

function level.selectNewPlayer(override)
    for i,v in ipairs(level.players) do
        v.isControlled=false
    end
    
    if override and level.players[override] then
        level.activePlayer = level.players[override]
        level.activePlayer.isControlled = true
    else
        local newPlayer = nil
        local deathtime = 99999
        for i,v in ipairs(level.players) do
            if v.isActive then
                newPlayer = v
            end
        end
        
        if not newPlayer then
            for i,v in ipairs(level.players) do
                if v.timers.deactive.val < deathtime then
                   deathtime = v.timers.deactive.val
                   newPlayer = v
                end
            end
        end
        
        level.activePlayer = newPlayer
        newPlayer.isControlled = true
        newPlayer.isActive = false
        newPlayer.timers.deactive.val = 2
    end
end

-- equiv to onTouchEnded
function love.mousereleased(x, y, button)
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

function love.keypressed(key, isrepeat)
    if score:isGameOver() then
        if key == cont.restart then
            restart()
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
        love.event.quit()
    end

end
