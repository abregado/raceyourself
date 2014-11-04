require ('lovedebug')
require('registry')


function love.load()
    buildAnimations()
    level.collider:setCallbacks(level.collide,level.endCollide)
    score = scoring.new()
    tc.load()
    ps.load()
    state.game.restart()
	gs.registerEvents()
    dataControl.load()
	gs.switch(state.menu)
    print("test string printed to console")
end

function buildAnimations()
    anims.pShip = {}
    for i,v in ipairs(as.pShip) do
        local newSheet = an.newGrid(64,64,v:getWidth(),v:getHeight())
        local newAnim = an.newAnimation(newSheet('1-5',1),0.3)
        table.insert(anims.pShip,newAnim)
    end
end

function updateAnims(dt)
	for i,v in pairs(anims) do
		for j,k in pairs(v) do
            k:update(dt)
        end
	end
end

function love.quit()
    dataControl.save()
end
