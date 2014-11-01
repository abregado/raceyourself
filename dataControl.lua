dataControl = {}

--savefile should be in the registry
saveFile,fileError = fs.newFile("data.txt")

function dataControl.draw()
    if DEBUG_MODE then
        love.graphics.setColor(0,255,0)
        local y = 30
        for name,data in pairs(rawData) do
            love.graphics.print(name..": "..tostring(data),0,y)
            y=y+30
        end
    end
end

function dataControl.save()
    local data = {}
    
    --allocate variables to the data object here, that will be saved
    data.scoreboard = scoreboard
    --end variable alloation
    
    if saveFile:open("w") then
        saveFile:write(serialize(data))
        saveFile:close()
    end
end

function dataControl.load()
    if saveFile:open("r") then
        local rawData = saveFile:read()
        local data = deserialize(rawData)
        if type(data)=='table' then
        
            --allocate variables to load and where to assign them
            --where numbers are required use tonumber!! else BUGS
            scoreboard = {}
            for i,v in ipairs(data.scoreboard) do
                if tonumber(v.score) > 0 then
                    table.insert(scoreboard,{score=math.floor(tonumber(v.score)) or 0,powerups=tonumber(v.powerups) or 0,kills=tonumber(v.kills) or 0})
                end
            end
            rawData = data -- for debug info
            --end variable allocation
            
        end
        saveFile:close()
    end
end

return dataControl
