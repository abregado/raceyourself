require('registry')

function love.load()
    level.buildLanes()
    tc.load()
    level.collider:setCallbacks(level.collide,level.endCollide)
    score = scoring.new()
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
end

function love.update(dt)
    if DEBUG_MODE and love.keyboard.isDown('p') then
        return
    end
    tc.update(dt)
    
    for i,v in ipairs(level.lanes) do
        v:update(dt)
    end
    
    for i,v in ipairs(level.players) do
        v:update(dt)
    end

    level.collider:update(dt)

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
            b:destroy()
        else
            if b.isPowerup then
                b:destroy()
                score:collectPowerup()
            else
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
    end
end

-- equiv to onTouchEnded
function love.mousereleased(x, y, button)
    touch = false
    if button == touchButton then
        if not touchMoved then
            -- tap detected
            tc.tap(x, y)
        else
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
