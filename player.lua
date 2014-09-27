local p = {}

function p.new(x,y,lane,color)
    o = {}
    o.hx = x
    o.isPlayer=true
    o.hy = laneGFX.h/2
    o.x = o.hx
    o.isActive = false
    o.y = o.hy
    o.lane = lane
    o.color = color
    o.isPunching = false
    o.timers={}
    o.timers.punch = {val=0}
    o.timers.stunned = {val=0}
    o.timers.respawn = {val=0}
    
    o.cob = shapes.newCircleShape(o.x,o.y,playerSize/2)
    o.cob.parent = o
    
    p.setupMethods(o)

    o.ax = o.x
    o.ay = o.lane.y + o.y

    o.motions = {}
    o.currentMotion = nil
    
    o.lane:givePlayer(o)
    
    
    return o
end

function p.setupMethods(o)
    o.setLane = p.setLane
    o.switchWithPlayer = p.switchWithPlayer
    o.draw = p.draw
    o.update = p.update
    o.punch = p.punch
    o.setLane = p.setLane
    o.switchWithPlayer = p.switchWithPlayer
    o.draw = p.draw
    o.update = p.update
    o.getNextMotion = p.getNextMotion
    o.moveTo = p.moveTo
    o.moveBy = p.moveBy
    o.delay = p.delay
end

function p:switchWithPlayer(other)
    local newLane = other.lane
    self.lane.collider:remove(self.cob)
    other.lane.collider:remove(other.cob)
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
 
    if self.isColliding then
        lg.setColor(color.colliding)
    else
        lg.setColor(COLORS[self.color])
    end
    
    lg.circle("fill", self.ax, self.ay, playerSize / 2, 9)
    
    if self.isPunching then
        lg.circle("line", self.ax, self.ay, (playerSize / 2)+3, 9)
        lg.circle("line", self.ax, self.ay, (playerSize / 2)+6, 9)
    end
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
    
    for i,v in pairs(self.timers) do
        if v.val>0 then
            v.val = v.val - dt
        end
        if v.val < 0 then v.val = 0 end
    end
    
    if self.timers.punch.val == 0 then
        self.isPunching = false
    end
    
    self.cob:moveTo(self.x,self.y)
    
end

function p:moveTo(dur, x, y)
    table.insert(self.motions, {dur=dur, endX=x, endY=y, elapsed=0.0})
end

function p:moveBy(dur, x, y)
    table.insert(self.motions, {dur=dur, deltaX=x, deltaY=y, elapsed=0.0})
end

function p:delay(dur)
    table.insert(self.motions, {dur=dur, deltaX=0, deltaY=0, elapsed=0.0})
end

function p.swapLanes(from, to)
    if math.abs(from.lane.pos - to.lane.pos) == 1 then
        from:switchWithPlayer(to)
        --level.activePlayer = to
    end
end

function p:punch()
    if self.timers.stunned.val == 0 then
        self.isPunching=true
        self.timers.punch.val = 0.2
        self.timers.stunned.val = 1
    end
end

return p
