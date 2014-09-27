require('registry')

function love.load()
    level.buildLanes()
end

function love.draw()
    for i,v in ipairs(level.lanes) do
        v:draw(0,(i-1)*laneGFX.h)
    end
end

function love.update(dt)
    for i,v in ipairs(level.lanes) do
        v:update(dt)
    end
end

function level.buildLanes()
    for i=1,LANES do
        table.insert(level.lanes,lane.new())
    end
end
