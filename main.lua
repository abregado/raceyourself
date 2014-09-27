require('registry')

function love.load()
    level.buildLanes()
    tc.load()
    level.collider:setCallbacks(level.collide,level.endCollide)
end

function love.draw()
    lg.reset()
    for i,v in ipairs(level.lanes) do
        v:draw()
    end
    
    for i,v in ipairs(level.lanes) do
        v:drawBlocks()
    end
    
    for i,v in ipairs(level.players) do
        v:draw()
    end
    
    tc.draw()
end

function love.update(dt)
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
        level.activePlayer = level.players[playerLane]
    end
    
end

function level.collide(dt, s1, s2, dx, dy)
    local p
    local b
    if s1.parent.isPlayer ==s2.parent.isPlayer then 
        return
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
        p.isColliding = true
        b.isColliding = true
    end
    
    tc.line = "Collision"
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
