local b = {}

function b.new(lane)
    o={}
    
    o.x=laneGFX.w
    o.y= lane.y
    
    o.w = laneGFX.h/9
    o.h = laneGFX.h/3
    
    
    
    o.isGarbage = false
    o.lane = lane
    
    o.boxType = math.floor(math.random(1,3))
    o.color = math.floor(math.random(1,LANES))
    
    if o.boxType == 1 then
        o.h = o.h*2
    elseif o.boxType == 2 then
        o.y = o.y+o.h
    elseif o.boxType == 3 then
        o.y = o.y+o.h
        o.h= o.h*2
    end
    
    o.ox = o.w/2
    o.oy = o.h/2
    
    o.cob = level.collider:addRectangle(o.x+o.ox,o.y+o.oy,o.w,o.h)
    o.cob.parent = o
    
    b.setupMethods(o)
    return o
    
end

function b.setupMethods(o)
    o.move = b.move
    o.draw = b.draw
    o.destroy = b.destroy
end

function b:move(dt)
    self.x = self.x - (dt*BLOCK_SPEED)
    
    if self.x+self.w < 0 then
        self:destroy()
        
    end
    
    self.cob:moveTo(self.x+self.ox,self.y+self.oy)
    
end

function b:draw(x,y)
    if self.isGarbage then
        lg.setColor(0,0,0)
    elseif self.isColliding then
        lg.setColor(color.colliding)
    else
        lg.setColor(COLORS[self.color])
    end
    self.cob:draw('fill')
end

function b:destroy()
    self.isGarbage=true
end

return b
