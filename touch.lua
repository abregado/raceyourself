local tc = {}

function tc.load()
    tc.line = "Hello World"
    
    local x = percentPlayerX * lw.getWidth()
    local y = lw.getHeight() / 2 - lw.getHeight() *math.floor(LANES/2)/LANES

    --[[for i=1,LANES do
        player[i] = {x=x, y=y}
        y = y + lw.getHeight() / LANES
    end]]
end


function tc.draw()
    --[[for i=1,LANES do
        lg.setColor(COLORS[i])
        lg.circle("fill", level.players[i].x, level.players[i].y, playerSize / 2, 9)
        lg.setColor(0,0,0)
        lg.print(i,level.players[i].x, level.players[i].y)
    end]]
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
    if up then
        tc.line = "Swipe: UP"
    else
        tc.line = "Swipe: DOWN"
    end
end

function tc.horizontalSwipe(right)
    if right then
        tc.line = "Swipe: RIGHT"
        level.activePlayer:punch()
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

    --[[for i=1,LANES-1 do
        if y < lw.getHeight() * i / LANES then
            tappedLane = i
            break
        end        
    end]]

    tc.line = "tap @ (" .. x .. ", " .. y .. ") in lane" .. tappedLane.pos .. " from " .. level.activePlayer.lane.pos
    if tappedLane then
        player.swapLanes(level.activePlayer, tappedLane.player)
    end
end



return tc
