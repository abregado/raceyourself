local b = {}

function b.new(lane)
    o={}
    
    o.x=laneGFX.w
    o.y= laneGFX.h/3
    o.isGarbage = false
    o.w = laneGFX.h/9
    o.h = laneGFX.h/3
    o.lane = lane
    
    o.boxType = math.floor(math.random(1,3))
    o.color = math.floor(math.random(1,LANES))
    
    if o.boxType == 1 then
        o.y=0
        o.h=laneGFX.h/3*2
    elseif o.boxType == 2 then
    elseif o.boxType == 3 then
        o.h=laneGFX.h/3*2
    end
    
    o.cob = o.lane.collider:addRectangle(o.x,o.y,o.w,o.h)
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
    self.cob:move(-1*dt*BLOCK_SPEED,0)
    
    if self.x+self.w < 0 then
        self:destroy()
        
    end
    
end

function b:draw(x,y)
    if self.isColliding then
        lg.setColor(color.colliding)
    else
        lg.setColor(COLORS[self.color])
    end
    
    lg.rectangle("fill",x+self.x,y+self.y,self.w,self.h)
    
    lg.setColor(color.debug)
    self.cob:draw('line')

end

function b:destroy()
    self.isGarbage=true
end

return b
