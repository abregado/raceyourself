local l = {}

function l.new(pos)
    local o={}
    o.pos = pos
    o.blocks = {}
    o.player = nil
    o.y = (o.pos-1)*laneGFX.h
    
    o.collider = HC.new()
    o.collider:setCallbacks(l.collide,l.endCollide)
    
    l.setupMethods(o)
    
    return o
end

function l.setupMethods(o)
    --always add new object methods here
    o.draw = l.draw
    o.update = l.update
    o.removeBlocks = l.removeBlocks
    o.spawnBlock = l.spawnBlock
    o.givePlayer = l.givePlayer
    o.withinBounds = l.withinBounds
    
    return o
end 

function l:draw(x,y)

    --draw lane background at location x,y (in case we need to repos the lanes
    local w = screen.w
    local h = laneGFX.h
    lg.setColor(color.lane)
    lg.rectangle("fill",x,y,w,h)
    lg.setColor(color.divider)
    lg.rectangle("line",x,y,w,h)
    
    --draw all blocks in this lane
    for i,v in ipairs(self.blocks) do
        v:draw(x,y)
    end
end

function l:givePlayer(player)
    self.player = player
end

function l:update(dt)

    --move all the blocks in this lane
    for i,v in ipairs(self.blocks) do
        v:move(dt)
    end
    
    --garbage disposal
    self:removeBlocks()
    
    --for testing, add a block when there are none
    if #self.blocks==0 then
        self:spawnBlock()
    end
    
    self.collider:update(dt)
    
    
end

function l:spawnBlock()
    table.insert(self.blocks,block.new(self))
end

function l:removeBlocks(all)
    if all then
        self.blocks={}
    else        
        for i,v in ipairs(self.blocks) do
            if v.isGarbage then
                self.collider:remove(v.cob)
                table.remove(self.blocks,i)
            end
        end
    end
end

function l:withinBounds(x,y)
    local oy = self.y
    local my = self.y+laneGFX.h
    if y >= oy and y < my then
        return true
    else
        return false
    end
end

function l.collide(dt, s1, s2, dx, dy)
    local p
    local b
    if s1.parent.isPlayer == true then
        p = s1.parent
        b = s2.parent
    else
        p = s2.parent
        b = s1.parent
    end

    if p.isPunching then
        b:destroy()
    else
        p.isColliding = true
        b.isColliding = true
    end
end

function l.endCollide(dt, s1, s2, dx, dy)
    s1.parent.isColliding = false
    s2.parent.isColliding = false
end


return l
