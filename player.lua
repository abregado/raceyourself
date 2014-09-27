local p = {}

function p.new(lane,color)
    o = {}
    
    o.x=lane.x+(lane.w*percentPlayerX)
    o.y=lane.y+(lane.h/2)
    
    o.ax = o.x
    o.ay = o.y
    
    o.isPlayer=true
    o.isActive = false
    o.isControlled = false
    o.lane = lane
    o.color = color
    o.isPunching = false
    o.timers={}
    o.timers.punch = {val=0}
    o.timers.stunned = {val=0}
    o.timers.respawn = {val=0}
    o.timers.deactive = {val=0}
    
    o.cob = level.collider:addCircle(o.ax,o.ay,playerSize/2)
    o.cob.parent = o
    --local c = {w=VIEWCONE.l,h=VIEWCONE.h}
    --o.cone = level.collider:addRectangle(o.ax,o.ay)
    
    p.setupMethods(o)

    

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
    o.draw = p.draw
    o.update = p.update
    o.getNextMotion = p.getNextMotion
    o.moveTo = p.moveTo
    o.moveBy = p.moveBy
    o.delay = p.delay
    o.deactivate = p.deactivate
    o.activate = p.activate
end

function p:switchWithPlayer(other)
    local newLane = other.lane
    --self.lane.collider:remove(self.cob)
    --other.lane.collider:remove(other.cob)
    other:setLane(self.lane)
    self:setLane(newLane)
    self:moveTo(LANE_SWAP_DUR, self.ax, self.lane.y + self.lane.h / 2, tween.easing.outCubic)
    other:moveTo(LANE_SWAP_DUR, other.ax, other.lane.y + other.lane.h / 2, tween.easing.outCubic)
end

function p:setLane(l)
    self.lane = l
    self.lane:givePlayer(self)
end

function p:draw()
    if self.isActive then
        if self.isColliding then
            lg.setColor(color.colliding)
        else
            lg.setColor(COLORS[self.color])
        end
        
        --lg.circle("fill", self.ax, self.ay, playerSize / 2, 9)
        self.cob:draw('fill')
        
        if self.isPunching then
            lg.circle("line", self.ax, self.ay, (playerSize / 2)+3, 9)
            lg.circle("line", self.ax, self.ay, (playerSize / 2)+6, 9)
        end
        
        if self.isControlled then
            lg.setColor(color.controlled)
            lg.circle("fill", self.ax, self.ay, (playerSize / 4), 9)
        end
    elseif self.timers.deactive.val < 2 then
        lg.setColor(COLORS[self.color][1],COLORS[self.color][2],COLORS[self.color][3],125)
        lg.circle("line", self.ax, self.ay, (playerSize / 2)+6, 9)
        if self.isControlled then
            lg.setColor(color.controlled)
            lg.circle("fill", self.ax, self.ay, (playerSize / 4), 9)
        end
    end
    
    if self.isControlled then
        lg.setColor(color.controlled)
        lg.circle("fill", self.ax, self.ay, (playerSize / 4), 9)
    end
end

function p:getNextMotion()
    local nextMotion = table.remove(self.motions, 1)
    if nextMotion then
        nextMotion.endX = nextMotion.endX or (nextMotion.deltaX + self.ax)
        nextMotion.endY = nextMotion.endY or (nextMotion.deltaY + self.ay)
        nextMotion.startX = self.ax
        nextMotion.startY = self.ay
        self.currentMotion = tween.new(nextMotion.dur, 
                                       {x=nextMotion.startX, y=nextMotion.startY}, 
                                       {x=nextMotion.endX, y=nextMotion.endY},
                                       nextMotion.tween or tween.easing.linear)
    else
        self.currentMotion = nil
    end
end

function p:update(dt)
    if self.currentMotion then
        local complete = self.currentMotion:update(dt)

        self.ax = self.currentMotion.subject.x
        self.ay = self.currentMotion.subject.y

        if complete then
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
    
    if self.timers.deactive.val == 0 then
        self:activate()
    end
    
    self.cob:moveTo(self.ax,self.ay)
    
end

function p:moveTo(dur, x, y, tweenFunc)
    table.insert(self.motions, {dur=dur, endX=x, endY=y, elapsed=0.0, tween=tweenFunc})
end

function p:moveBy(dur, x, y, tweenFunc)
    table.insert(self.motions, {dur=dur, deltaX=x, deltaY=y, elapsed=0.0, tween=tweenFunc})
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
        self.timers.punch.val = PUNCH_TIME
        self.timers.stunned.val = STUN_TIME
    end
end

function p:deactivate()
    if self.isActive then
        self.isActive=false
        level.collider:setGhost(self.cob)
        self.timers.deactive.val = DEATH_TIME
        if level.activePlayer == self then
            level.selectNewPlayer()
        end
    end
end

function p:activate()
    if self.isActive == false then
        self.isActive=true
        level.collider:setSolid(self.cob)
    end
end

function p:look()
    
end

function p:react()

end

return p
