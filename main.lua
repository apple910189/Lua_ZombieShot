function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180

    zombies = {}
    bullets = {}
end
-- dt updats every frame to be the amount of time in second between
-- the previous frame and the current one. If the game is running
-- at 60 frames per second, then dt will equal 1/60.
function love.update(dt)
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt -- when dt droped, the speed increase, but it 'looks' in same speed
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    
    -- zombie movement and it's nil
    for i,z in ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt -- 對radian做cos可以得到x
        z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt
        
        if distance(z.x,z.y,player.x,player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
            end
        end
    end  

    -- bullet movement
    for i,b in ipairs(bullets) do 
        b.x = b.x + math.cos(b.direction) * b.speed * dt -- b.direction不能用playerMouseAngle()因為update是所以會一直更新方向
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

end

function love.draw()
    love.graphics.draw(sprites.background,0,0)
    love.graphics.draw(sprites.player,player.x,player.y, playerMouseAngle(), nil,nil, sprites.player:getWidth()/2,sprites.player:getHeight()/2)

    -- zombie shawn and it'sradian
    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y,zombiePlayerAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)
    end

    --bullet spawn
    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y)
    end
end

function love.keypressed(key)
    if key=="space" then
        spawnZombie()
    end
end

function love.mousepressed(x,y,button)
    if button == 1 then
        spawnBullet()
    end
end

function playerMouseAngle()
    return math.atan2(player.y-love.mouse.getY(), player.x-love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y-enemy.y, player.x-enemy.x)
end 

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0,love.graphics.getWidth())
    zombie.y = math.random(0,love.graphics.getHeight())
    zombie.speed = 100
    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 300
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function distance(x1,y1,x2,y2)
    return math.sqrt((x1-x2)^2+(y1-y2)^2)
end