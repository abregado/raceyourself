local tc = {}

function tc.load()
    tc.line = "Hello World"
    
    local x = percentPlayerX * lw.getWidth()
    local y = lw.getHeight() / 2 - lw.getHeight() *math.floor(LANES/2)/LANES
end


function tc.draw()
    lg.setColor(COLORS[#COLORS])
    lg.print(tc.line, 400, 300)
end

function tc.update(dt)
    if touch then
       local x = lm.getX()
       local y = lm.getY()
       local dx = x - origTouchX 
       local dy = y - origTouchY 
       
       if math.abs(dx) > tapThreshold or math.abs(dy) > tapThreshold then
           touchMoved = true
       end
    end 
end



function tc.verticalSwipe(up)
    if level.activePlayer.currentMotion then
        return
    end

    if up then
        tc.line = "Swipe: UP"
        level.activePlayer:moveBy(JUMP_HALF_DUR, 0, -laneGFX.h / 3, tween.easing.outCubic)
        level.activePlayer:delay(JUMP_DELAY_DUR)
        level.activePlayer:moveBy(JUMP_HALF_DUR, 0, laneGFX.h / 3, tween.easing.inCubic)
    else
        tc.line = "Swipe: DOWN"
        level.activePlayer:moveBy(JUMP_HALF_DUR, 0, laneGFX.h / 3, tween.easing.outCubic)
        level.activePlayer:delay(JUMP_DELAY_DUR)
        level.activePlayer:moveBy(JUMP_HALF_DUR, 0, -laneGFX.h / 3, tween.easing.inCubic)
    end
end

function tc.horizontalSwipe(right)
    local activePlayer = level.activePlayer

    if activePlayer.timers.stunned.val ~= 0 then
        return
    end
 
    if right then
        tc.line = "Swipe: RIGHT"
        local lane = level.activePlayer.lane
        local pixels = laneGFX.w * PUNCH_DIST
        local returnDur = pixels / BLOCK_SPEED
        activePlayer:punch()
        activePlayer:moveBy(PUNCH_TIME, pixels, 0, tween.easing.outExpo)
        activePlayer:moveBy(returnDur, -pixels, 0)
    else
        tc.line = "Swipe: LEFT"
    end
end

function tc.tap(x, y)
    if level.activePlayer.priorityMotion ~= nil then
        return
    end

    local tappedLane = nil

    for i,v in ipairs(level.lanes) do
        if v:withinBounds(x,y) then
            tappedLane=v
            break
        end
    end

    tc.line = "tap @ (" .. x .. ", " .. y .. ") in lane" .. tappedLane.pos .. " from " .. level.activePlayer.lane.pos
    if tappedLane then
        player.swapLanes(level.activePlayer, tappedLane.player)
    end
end



return tc
