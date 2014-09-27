require('registry')

function love.load()
    level.buildLanes()
    tc.load()
end

function love.draw()
    for i,v in ipairs(level.lanes) do
        v:draw(0,(i-1)*laneGFX.h)
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

end

function level.buildLanes()
    for i=1,LANES do
        table.insert(level.lanes,lane.new(i))
    end
    
    for i,v in ipairs(level.lanes) do
        table.insert(level.players,player.new(percentPlayerX*lw.getWidth(),(i-1)*laneGFX.h,v,i))
        level.activePlayer = level.players[playerLane]
    end
    
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
