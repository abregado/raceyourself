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

    o.ax = o.x
    o.ay = o.lane.y + o.y

    o.motions = {}
    o.currentMotion = nil
    
    o.setLane = p.setLane
    o.switchWithPlayer = p.switchWithPlayer
    o.draw = p.draw
    o.update = p.update
    o.getNextMotion = p.getNextMotion
    o.moveTo = p.moveTo
    o.moveBy = p.moveBy
    
    o.lane:givePlayer(o)
    
    
    return o
end

function p:switchWithPlayer(other)
    local newLane = other.lane
    other:setLane(self.lane)
    self:setLane(newLane)
    self:moveTo(0.5, other.ax, other.ay)
    other:moveTo(0.5, self.ax, self.ay)
end

function p:setLane(l)
    self.lane = l
    self.lane:givePlayer(self)
end

function p:draw()
    lg.setColor(self.color)
    lg.circle("fill", self.ax, self.ay, playerSize / 2, 9)
end

function p:getNextMotion()
    self.currentMotion = table.remove(self.motions, 1)
    if self.currentMotion then
        self.currentMotion.deltaX = self.currentMotion.deltaX or (self.currentMotion.endX - self.ax)
        self.currentMotion.deltaY = self.currentMotion.deltaY or (self.currentMotion.endY - self.ay)
        self.currentMotion.startX = self.ax
        self.currentMotion.startY = self.ay
    end
end

function p:update(dt)
    if self.currentMotion then
        self.currentMotion.elapsed = self.currentMotion.elapsed + dt

        local percent = self.currentMotion.elapsed / self.currentMotion.dur
        if percent > 1 then
            percent = 1
        end

        self.ax = percent * self.currentMotion.deltaX + self.currentMotion.startX
        self.ay = percent * self.currentMotion.deltaY + self.currentMotion.startY
        
        if percent == 1 then
            self:getNextMotion()
        end
    elseif self.motions then
        self:getNextMotion()
    end
end

function p:moveTo(dur, x, y)
    table.insert(self.motions, {dur=dur, endX=x, endY=y, elapsed=0.0})
end

function p:moveBy(dur, x, y)
    table.insert(self.motions, {dur=dur, deltaX=x, deltaY=y, elapsed=0.0})
end

function p.swapLanes(from, to)
    if math.abs(from.lane.pos - to.lane.pos) == 1 then
        from:switchWithPlayer(to)
        --level.activePlayer = to
    end
end

return p
