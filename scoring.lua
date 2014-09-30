local s = {}

function s.new()
    o = {}

    o.font = lg.newFont()
    o.bigFont = lg.newFont(100)

    o.lLine = "SPACELIVES"
    o.pLine = "SPACECOINS"
    o.kLine = "SPACEKILLS"
    o.lWidth = o.font:getWidth(o.lLine)
    o.pWidth = o.font:getWidth(o.pLine)
    o.kWidth = o.font:getWidth(o.kLine)
    o.fontHeight = o.font:getHeight()

    o.maxX = lw.getWidth() - edgeBuffer
    o.midX = o.maxX - o.kWidth * 1.2
    o.minX = o.midX - o.pWidth * 1.2
    o.microX = o.minX - o.lWidth * 1.2
    o.minY = edgeBuffer
    o.midY = o.minY + o.fontHeight * 1.4
    o.maxY = o.midY + o.fontHeight * 1.4

    o.gameOverMsg = "GAME OVER"
    o.bigFontHeight = o.bigFont:getHeight()
    o.gameOverMsgWidth = o.bigFont:getWidth(o.gameOverMsg)

    if love.system.getOS() == "Android" then
        o.resetMsg = ANDROID_RESTART
    else
        o.resetMsg = DESKTOP_RESTART
    end

    o.resetMsgWidth = o.font:getWidth(o.resetMsg)

    s.setupMethods(o)

    o:reset()

    return o    
end

function s.setupMethods(o)
    o.draw = s.draw
    o.reset = s.reset
    o.collectPowerup = s.collectPowerup
    o.incrementKills = s.incrementKills
    o.decrementLives = s.decrementLives
    o.isGameOver = s.isGameOver
end

function s:draw()
    lg.setColor(COLORS[#COLORS])
    lg.setFont(self.font)
    
    lg.line(self.microX, self.minY, self.microX, self.maxY, self.maxX, self.maxY, self.maxX, self.minY, self.microX, self.minY)
    lg.line(self.microX, self.midY, self.maxX, self.midY)
    lg.line(self.midX, self.minY, self.midX, self.maxY)
    lg.line(self.minX, self.minY, self.minX, self.maxY)

    local lW = self.font:getWidth(self.lives)
    local pW = self.font:getWidth(self.powerups)
    local kW = self.font:getWidth(self.kills)

    lg.print(self.lLine, self.microX + self.lWidth * 0.1, self.minY + self.fontHeight * 0.2)
    lg.print(self.lives, self.microX + (self.lWidth * 1.2 - lW) / 2, self.maxY - self.fontHeight * 1.2)
    lg.print(self.pLine, self.minX + self.pWidth * 0.1, self.minY + self.fontHeight * 0.2)
    lg.print(self.powerups, self.minX + (self.pWidth * 1.2 - pW) / 2, self.maxY - self.fontHeight * 1.2)
    lg.print(self.kLine, self.midX + self.kWidth * 0.1, self.minY + self.fontHeight * 0.2)
    lg.print(self.kills, self.midX + (self.kWidth * 1.2 - kW) / 2, self.maxY - self.fontHeight * 1.2)
    
    if love.system.getOS() == "Android" then
        local xo = self.font:getWidth(ANDROID_INSTRUCTIONS)/2
        local yo = self.font:getHeight(ANDROID_INSTRUCTIONS)+10
        lg.print(ANDROID_INSTRUCTIONS,(screen.w/2)-xo,screen.h-yo)
    else 
        local xo = self.font:getWidth(DESKTOP_INSTRUCTIONS)/2
        local yo = self.font:getHeight(DESKTOP_INSTRUCTIONS)+10
        lg.print(DESKTOP_INSTRUCTIONS,(screen.w/2)-xo,screen.h-yo)
    end

    if self.gameOver then
        lg.print(self.resetMsg, (lw.getWidth() - self.resetMsgWidth) / 2, (lw.getHeight() + self.bigFontHeight * 1.2) / 2)
        lg.setFont(self.bigFont)
        lg.print(self.gameOverMsg, (lw.getWidth() - self.gameOverMsgWidth) / 2, (lw.getHeight() - self.bigFontHeight) / 2)
    end
end

function s:reset()
    self.powerups = 0
    self.kills = 0
    self.gameOver = false
    self.lives = START_LIVES
end

function s:collectPowerup()
    self.powerups = self.powerups + 1
end

function s:incrementKills()
    self.kills = self.kills + 1
end

function s:decrementLives()
    self.lives = self.lives - 1
    if self.lives == 0 then
        self.gameOver = true
    end
end

function s:isGameOver()
    return self.gameOver
end

return s
