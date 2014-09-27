local p = {}

function p.new(x,y,lane,color)
    o = {}
    o.hx = x
    o.hy = laneGFX.h/2
    o.x = o.hx
    o.isActive = false
    o.y = o.hy
    o.lane = lane
    o.color = color
    
    o.setLane = p.setLane
    o.switchWithPlayer = p.switchWithPlayer
    o.draw = p.draw
    
    o.lane:givePlayer(o)
    
    
    return o
end

function p:switchWithPlayer(other)
    local newLane = other.lane
    other:setLane(self.lane)
    self:setLane(newLane)
end

function p:setLane(l)
    self.lane = l
    self.lane:givePlayer(self)
end

function p:draw()
    local ay = self.lane.y + self.y
    lg.setColor(self.color)
    lg.circle("fill", self.x, ay, playerSize / 2, 9)
end

function p.swapLanes(from, to)
    if math.abs(from.lane.pos - to.lane.pos) == 1 then
        from:switchWithPlayer(to)
        --level.activePlayer = to
    end
end

return p
