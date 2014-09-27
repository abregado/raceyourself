lg = love.graphics
lm = love.mouse
lw = love.window

LANES = 3
COLORS = {{r=255, g=0, b=0, a=255},
          {r=0, g=255, b=0, a=255},
          {r=0, g=0, b=255, a=255},
          {r=255, g=255, b=0, a=255},
          {r=0, g=255, b=255, a=255},
          {r=255, g=0, b=255, a=255},
          {r=255, g=255, b=255, a=255}}

function love.load()
    line = "Hello World"

    tapThreshold = 0.08
    touchMoved = false

    horizSwipeRatio = 10
    vertSwipeRatio = 10

    player = {}
    percentPlayerX = 0.1
    playerSize = lw.getHeight() / (LANES * 3)

    playerLane = math.ceil(LANES / 2)

    local x = percentPlayerX * lw.getWidth()
    local y = lw.getHeight() / 2 - lw.getHeight() / LANES

    for i=1,LANES do
        player[i] = {x=x, y=y}
        y = y + lw.getHeight() / LANES
    end
end


function love.draw()
    for i=1,LANES do
        lg.setColor(COLORS[i].r, COLORS[i].g, COLORS[i].b, COLORS[i].a)
        lg.circle("fill", player[i].x, player[i].y, playerSize / 2, 9)
    end
    lg.setColor(COLORS[#COLORS].r, COLORS[#COLORS].g, COLORS[#COLORS].b, COLORS[#COLORS].a)
    lg.print(line, 400, 300)
end

function love.update(dt)
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
            tap(x, y)
        else
            local dx = lm.getX() - origTouchX
            local dy = lm.getY() - origTouchY

            if math.abs(dy) > vertSwipeRatio * math.abs(dx) then
                -- vertical swipe detected
                verticalSwipe(dy < 0)
            elseif math.abs(dx) > horizSwipeRatio * math.abs(dy) then
                -- horizontal swipe detected
                horizontalSwipe(dx < 0)
            else
                -- not vertical nor horizontal
                line = "unsupported swipe"
            end

            touchMoved = false
        end
    end 
end

function verticalSwipe(up)
    if up then
        line = "Swipe: UP"
    else
        line = "Swipe: DOWN"
    end
end

function horizontalSwipe(right)
    if right then
        line = "Swipe: RIGHT"
    else
        line = "Swipe: LEFT"
    end
end

function tap(x, y)
    line = "tap @ (" .. x .. ", " .. y .. ")"

    local tappedLane = LANES

    for i=1,LANES-1 do
        if y < lw.getHeight() * i / LANES then
            tappedLane = i
            break
        end        
    end

    swapLanes(playerLane, tappedLane)
end

function swapLanes(from, to)
    if math.abs(from - to) == 1 then
        local fromY = player[from].y
        player[from].y = player[to].y
        player[to].y = fromY
        playerLane = to
    end
end
