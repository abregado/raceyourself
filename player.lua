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
    
    o.cob = o.lane.collider:addCircle(o.x,o.y,playerSize/2)
    o.cob.parent = o
    
    p.setupMethods(o)
    
    o.lane:givePlayer(o)
    
    
    return o
end

function p.setupMethods(o)
    o.setLane = p.setLane
    o.switchWithPlayer = p.switchWithPlayer
    o.draw = p.draw
    o.update = p.update
    o.punch = p.punch
end

function p:switchWithPlayer(other)
    local newLane = other.lane
    other:setLane(self.lane)
    self:setLane(newLane)
end

function p:update(dt)
    self.cob:moveTo(self.x,self.y)

    for i,v in pairs(self.timers) do
        if v.val > 0 then
            v.val = v.val - dt
        end
        if v.val < 0 then v.val = 0 end
    end
    
    if self.timers.punch.val == 0 then
        self.isPunching = false
    end
    
end

function p:setLane(l)
    self.lane = l
    self.lane:givePlayer(self)
end

function p:draw()
    local ay = self.lane.y + self.y
    
    if self.isColliding then
        lg.setColor(color.colliding)
    else
        lg.setColor(self.color)
    end
    
    lg.circle("fill", self.x, ay, playerSize / 2, 9)
    
    if self.isPunching then
        lg.circle("line", self.x, ay, (playerSize / 2)+3, 9)
        lg.circle("line", self.x, ay, (playerSize / 2)+6, 9)
    end
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
