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
        level.activePlayer:jumpUp()
    else
        tc.line = "Swipe: DOWN"
        level.activePlayer:jumpDown()
    end
end

function tc.horizontalSwipe(right)
    local activePlayer = level.activePlayer

    if activePlayer.timers.stunned.val ~= 0 then
        return
    end
 
    if right then
        tc.line = "Swipe: RIGHT"
        activePlayer:punch()
    else
        tc.line = "Swipe: LEFT"
    end
end

function tc.tap(x, y)
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
