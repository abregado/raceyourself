local l = {}

function l.new(pos)
    local o={}
    o.x = 0
    o.y = (pos-1)*laneGFX.h
    
    o.w = screen.w
    o.h = laneGFX.h
    o.bgBlocks = {}
    for i=0,4 do
        table.insert(o.bgBlocks,{x=i*o.w/3,y=o.y})
    end

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
    lg.setColor(255,255,255)
    --draw lane background at location x,y (in case we need to repos the lanes
    --lg.setColor(color.lane)
    --lg.rectangle("fill",self.x,self.y,self.w,self.h)
    --lg.setColor(color.divider)
    --lg.rectangle("line",self.x,self.y,self.w,self.h)
    
    for i,v in ipairs(self.bgBlocks) do
        local gw = as.laneBG:getHeight()
        local gh = as.laneBG:getHeight()
        local sx = self.w/gw/3
        local sy = self.h/gh
        lg.draw(as.laneBG,v.x,v.y,0,sx,sy)
    end
    
    if self.player.isControlled then
        local gw = as.laneOver:getHeight()
        local gh = as.laneOver:getHeight()
        local sx = self.w/gw/3
        local sy = self.h/gh
        lg.setColor(COLORS[self.player.color])
        lg.setBlendMode('additive')
        lg.draw(as.laneOver,self.x,self.y,0,sx,sy)
        lg.setBlendMode('alpha')
    end
    
    
    
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
    
    --scroll background
    for i,v in ipairs(self.bgBlocks) do
        v.x = v.x -(dt*BLOCK_SPEED*0.5)
        if v.x< (self.w/-3) then
            v.x = self.w/3*4
        end
    end
    
    
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
