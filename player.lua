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
    local c = VIEWCONE
    o.cone = level.collider:addPolygon(o.ax,o.ay,o.ax+c.w,o.ay+(c.h/2),o.ax+c.w,o.ay-(c.h/2))
    o.cone.isCone = true
    o.cone.parent = o
    local x1,y1,x2,y2 = o.cone:bbox()
    local x3,y3 = o.cone:center()
    o.cone.ox = x1-x3
    
    p.setupMethods(o)

    

    o.xMotionQ = {}
    o.yMotionQ = {}
    o.xMotion = nil
    o.yMotion = nil
    
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
    o.getNextMotions = p.getNextMotions
    o.moveTo = p.moveTo
    o.moveBy = p.moveBy
    o.delay = p.delay
    o.deactivate = p.deactivate
    o.activate = p.activate
    o.drawCon = p.drawCon
    o.look=p.look
    o.react=p.react
    o.jumpUp = p.jumpUp
    o.jumpDown = p.jumpDown
end

function p:switchWithPlayer(other)
    local newLane = other.lane
    --self.lane.collider:remove(self.cob)
    --other.lane.collider:remove(other.cob)
    other:setLane(self.lane)
    self:setLane(newLane)
    self:moveBy(LANE_SWAP_DUR, 0, (self.lane.pos - other.lane.pos) * self.lane.h, tween.easing.outCubic)
    other:moveBy(LANE_SWAP_DUR, 0, (other.lane.pos - self.lane.pos) * self.lane.h, tween.easing.outCubic)
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
        
        self:drawCon()
        
    elseif self.timers.deactive.val < 2 and self.isControlled then
        lg.setColor(COLORS[self.color][1],COLORS[self.color][2],COLORS[self.color][3],125)
        lg.circle("line", self.ax, self.ay, (playerSize / 2)+6, 9)
        self:drawCon()
    end
    

end

function p:drawCon()
    if self.isControlled then
        lg.setColor(color.controlled)
        lg.circle("fill", self.ax, self.ay, (playerSize / 4), 9)
    else
        lg.setColor(color.colliding)
        self.cone:draw('fill')
    end
end

function p:getNextMotions()
    if not self.xMotion then
        local nextX = table.remove(self.xMotionQ, 1)
        if nextX then
            nextX.endX = nextX.endX or (nextX.deltaX + self.ax)
            nextX.startX = self.ax
            self.xMotion = tween.new(nextX.dur, 
                                     {x=nextX.startX}, 
                                     {x=nextX.endX},
                                     nextX.tween or tween.easing.linear)
        else
            self.xMotion = nil
        end
    end

    if not self.yMotion then
        local nextY = table.remove(self.yMotionQ, 1)
        if nextY then
            nextY.endY = nextY.endY or (nextY.deltaY + self.ay)
            nextY.startY = self.ay
            self.yMotion = tween.new(nextY.dur, 
                                     {y=nextY.startY}, 
                                     {y=nextY.endY},
                                     nextY.tween or tween.easing.linear)
        else
            self.yMotion = nil
        end
    end
end

function p:update(dt)
    local xEnd = nil
    local yEnd = nil

    self:getNextMotions()

    if self.xMotion then
        xEnd = self.xMotion:update(dt)
        self.ax = self.xMotion.subject.x
    end

    if self.yMotion then
        yEnd = self.yMotion:update(dt)
        self.ay = self.yMotion.subject.y
    end

    if xEnd then self.xMotion = nil end
    if yEnd then self.yMotion = nil end
    
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
    self.cone:moveTo(self.ax-self.cone.ox,self.ay)
    
end

function p:moveTo(dur, x, y, tweenFunc)
    if x ~= 0 then
        table.insert(self.xMotionQ, {dur=dur, endX=x, elapsed=0.0, tween=tweenFunc})
    end
    if y ~= 0 then
        table.insert(self.yMotionQ, {dur=dur, endY=y, elapsed=0.0, tween=tweenFunc})
    end
end

function p:moveBy(dur, x, y, tweenFunc)
    if x ~= 0 then
        table.insert(self.xMotionQ, {dur=dur, deltaX=x, elapsed=0.0, tween=tweenFunc})
    end
    if y ~= 0 then
        table.insert(self.yMotionQ, {dur=dur, deltaY=y, elapsed=0.0, tween=tweenFunc})
    end
end

function p:delay(dur)
    table.insert(self.xMotionQ, {dur=dur, deltaX=0, elapsed=0.0})
    table.insert(self.yMotionQ, {dur=dur, deltaY=0, elapsed=0.0})
end

function p.swapLanes(from, to)
    if math.abs(from.lane.pos - to.lane.pos) == 1 then
        from:switchWithPlayer(to)
        --level.activePlayer = to
    end
end

function p:punch()
    if self.timers.stunned.val == 0 then
        local pixels = laneGFX.w * PUNCH_DIST
        local returnDur = pixels / BLOCK_SPEED
        self.isPunching=true
        self.timers.punch.val = PUNCH_TIME
        self.timers.stunned.val = STUN_TIME
        self:moveBy(PUNCH_TIME, pixels, 0, tween.easing.outExpo)
        self:moveBy(returnDur, -pixels, 0)
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

function p:look(shape)
    if self.isControlled == false and self.isActive then
        local options = {}
        if shape.parent.boxType == 1 then
            table.insert(options,"DOWN")
        elseif shape.parent.boxType == 2 then
            table.insert(options,"DOWN")
            table.insert(options,"UP")
        elseif shape.parent.boxType == 3 then
            table.insert(options,"UP")
        end
        if shape.parent.color == self.color then
            table.insert(options,"PUNCH")
        end
        self:react(options)
    end
end

function p:react(options)
   
    if self.xMotion == nil and self.yMotion == nil and not next(self.xMotionQ) and not next(self.yMotionQ) and #options>0 then
        local delay = math.random(1,10)/10000*AI_DELAYMAX
        local reaction = nil 
        local rand = math.random(1,#options)
        if options[rand] == "UP" then
            self:delay(delay)
            self:jumpUp()
        elseif options[rand] == "DOWN" then
            self:delay(delay)
            self:jumpDown()
        elseif options[rand] == "PUNCH" then
            self:delay(delay)
            self:punch()
        end
    end
end

function p:help()
    tc.line = "help!"
end

function p:jumpDown()
    self:moveBy(JUMP_HALF_DUR, 0, laneGFX.h / 3, tween.easing.outCubic)
    self:delay(JUMP_DELAY_DUR)
    self:moveBy(JUMP_HALF_DUR, 0, -laneGFX.h / 3, tween.easing.inCubic)
end

function p:jumpUp()
    self:moveBy(JUMP_HALF_DUR, 0, -laneGFX.h / 3, tween.easing.outCubic)
    self:delay(JUMP_DELAY_DUR)
    self:moveBy(JUMP_HALF_DUR, 0, laneGFX.h / 3, tween.easing.inCubic)
end

function p.laneDown()
    if level.activePlayer.lane.pos < LANES then
        player.swapLanes(level.activePlayer, level.lanes[level.activePlayer.lane.pos+1].player)
    end
end

function p.laneUp()
    if level.activePlayer.lane.pos > 1 then
        player.swapLanes(level.activePlayer, level.lanes[level.activePlayer.lane.pos-1].player)
    end
end

return p
