local l = {}

function l.new(pos)
    local o={}
    o.x = 0
    o.y = (pos-1)*laneGFX.h
    
    o.w = screen.w
    o.h = laneGFX.h

    o.pos = pos
    o.blocks = {}
    o.player = nil
    
    
    --o.collider = HC.new()
    --o.collider:setCallbacks(l.collide,l.endCollide)
    
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
    o.drawBlocks = l.drawBlocks
    
    return o
end 

function l:draw()

    --draw lane background at location x,y (in case we need to repos the lanes
    lg.setColor(color.lane)
    lg.rectangle("fill",self.x,self.y,self.w,self.h)
    lg.setColor(color.divider)
    lg.rectangle("line",self.x,self.y,self.w,self.h)
    
    
end

function l:drawBlocks()
    --draw all blocks in this lane
    for i,v in ipairs(self.blocks) do
        v:draw()
    end
end

function l:givePlayer(player)
    self.player = player
    --self.collider:addShape(player.cob)
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
    
    --self.collider:update(dt)
    
    
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
                level.collider:remove(v.cob)
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




return l
