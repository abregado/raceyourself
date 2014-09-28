local pu = {}

function pu.new(x,y)
    o = {}

    o.x= x
    o.y= y
    
    o.w = playerSize
    o.h = playerSize
    o.size = playerSize
    
    o.isGarbage = false
    o.isPowerup = true
    
    o.color = COLORS[4]
    
    o.cob = level.collider:addCircle(0,0,o.w)
    o.cob:moveTo(o.x,o.y)
    o.cob.parent = o
    
    pu.setupMethods(o)
    return o
end

function pu.setupMethods(o)
    o.move = pu.move
    o.draw = pu.draw
    o.destroy = pu.destroy
end


function pu:move(dt)
    self.x = self.x - (dt * BLOCK_SPEED)

    if self.x + self.size / 2 < 0 then
        self:destroy()
    end

    self.cob:moveTo(self.x, self.y)
end

function pu:draw()
    if self.isGarbage then
        lg.setColor(0,0,0)
    else
        lg.setColor(self.color)
    end
    self.cob:draw('fill')
end

function pu:destroy()
    self.isGarbage = true
end

return pu
