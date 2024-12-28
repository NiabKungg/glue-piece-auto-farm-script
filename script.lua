local DiscordLib =
    loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()

local win = DiscordLib:Window("Glue Piece NewUI")

local serv = win:Server("Main", "")

_G.AutoFarm_Level = false
_G.AutoFarmTarget = nil
_G.itemUse = nil
_G.tpIsland = nil
_G.selectFruit = nil
_G.tpAllFruitStat = false
_G.dalayTPAllFruit = 1
_G.clickForTP = false
_G.defGravity = 196.2

function playerTeleportTo(target) 
    if target.Position.Y > -28.5 then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target
        -- print("Teleport Player To", target)
    end
end

-- ฟังก์ชันสำหรับใช้งานวาปหาผลทั้งหมด
function TP_AllFruit(dealy)
    for i, j in pairs(game:GetService("Workspace").Fruity:GetChildren()) do
        if not _G.tpAllFruitStat then
            break
        end
        print(i, j.Name, j.Position)
        -- game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = j.CFrame * CFrame.new(0, -2, 0)
        playerTeleportTo(j.CFrame * CFrame.new(0, -2, 0)) 

        wait(dealy)
    end
end

-- ฟังก์ชันสำหรับ server rejoin
function serverRejoin()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:Teleport(game.PlaceId, p)
end

-- ฟังก์ชันสำหรับ server hop
function serverHop()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    
    -- ดึงข้อมูลเซิร์ฟเวอร์
    local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"))
    
    for _, server in ipairs(servers.data) do
        -- ข้ามเซิร์ฟเวอร์ที่เต็มหรือเซิร์ฟเวอร์ปัจจุบัน
        if server.playing < server.maxPlayers and server.id ~= currentJobId then
            print("Switching to server:", server.id)
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, server.id, game:GetService("Players").LocalPlayer)
            return
        end
    end
    
    print("No available servers found!")
end

function getArrayAllFruit()
    result = {}
    for i, j in pairs(game:GetService("Workspace").Fruity:GetChildren()) do
        table.insert(result, j.Name)
    end
    return result
end

-- ฟังก์ชันสำหรับ ดึงข้อมูล item ทั้งหมดมาจาก BackPack 
function getBackpackItems()
    -- เข้าถึง LocalPlayer
    local player = game:GetService("Players").LocalPlayer
    -- game:GetService("Players").LocalPlayer.Backpack
    -- ตรวจสอบว่า Backpack มีอยู่หรือไม่
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        -- สร้าง array (table) สำหรับเก็บชื่อไอเท็ม
        local itemsArray = {}

        -- วนลูปผ่านไอเท็มใน Backpack
        for _, item in pairs(backpack:GetChildren()) do
            -- เก็บชื่อไอเท็มลงใน array
            table.insert(itemsArray, item.Name)
        end

        -- คืนค่า array ที่มีชื่อไอเท็มทั้งหมด
        return itemsArray
    else
        print("ไม่พบ Backpack ของผู้เล่น")
        return {}
    end
end

-- ฟังก์ชันสำหรับใช้งาน Combat อัตโนมัติ
function equipCombatTool(toolEquip)
    -- ตรวจสอบว่ามีชื่อของเครื่องมือถูกส่งมาหรือไม่
    if not toolEquip then
        print("กรุณาใส่ชื่อเครื่องมือที่ต้องการใช้งาน!")
        return
    end

    -- เข้าถึง LocalPlayer
    local player = game:GetService("Players").LocalPlayer

    -- ค้นหา Backpack ของผู้เล่น
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        -- ค้นหาเครื่องมือใน Backpack ตามชื่อที่กำหนด
        local combatTool = backpack:FindFirstChild(toolEquip)
        if combatTool then
            -- ย้ายเครื่องมือไปยังตัวละครเพื่อใช้งาน
            combatTool.Parent = player.Character
            -- print(toolEquip, "ถูกใช้งานแล้ว!")
        else
            -- print("ไม่พบเครื่องมือชื่อ:", toolEquip, "ใน Backpack")
        end
    else
        -- print("ไม่พบ Backpack ของผู้เล่น")
    end
end

function checkAndEquipTool(toolEquip)
    -- ตรวจสอบว่ามีชื่อของเครื่องมือถูกส่งมาหรือไม่
    if not toolEquip then
        print("กรุณาใส่ชื่อเครื่องมือที่ต้องการตรวจสอบ!")
        return
    end

    -- เข้าถึง LocalPlayer
    local player = game:GetService("Players").LocalPlayer

    -- ค้นหา Backpack ของผู้เล่น
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        -- ค้นหาเครื่องมือใน Backpack ตามชื่อที่กำหนด
        local combatTool = backpack:FindFirstChild(toolEquip)
        if combatTool then
            print("พบเครื่องมือ:", toolEquip, "ใน Backpack แล้ว!")
            equipCombatTool(toolEquip)
        end
    else
        print("ไม่พบ Backpack ของผู้เล่น")
    end
end

-- ฟังก์ชันสำหรับทิ้งผลทั้งหมดในตัว
function dropAllFruit()
    local frits = {}  -- สร้าง array สำหรับเก็บชื่อไอเท็ม

    for i, j in pairs(getBackpackItems()) do
        if string.find(j, "Fruity") then
            table.insert(frits, j)  -- เพิ่มไอเท็มที่มีคำว่า "Fruity" เข้าไปใน array frits
        end
    end

    for i, fruit in pairs(frits) do
        equipCombatTool(fruit)
        local args = {
            "Drop Fruity"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RemoteEvent"):WaitForChild("Fruity"):WaitForChild("Fruity_Event"):FireServer(unpack(args))
        print(i, fruit, "Drop Successfully")
    end
end

-- ฟังก์ชันเช็คว่าผู้เล่นตายหรือไม่
function checkIfPlayerDead()
    if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid")
        
        -- ตรวจสอบว่าค่า Health <= 0 หรือไม่
        if humanoid.Health <= 0 then
            print("Player is dead. Waiting for 8 seconds...")
            wait(8) -- รอ 8 วินาที
        else
            -- print("Player is alive.")
        end
    else
        print("Character or Humanoid not found!")
    end
end

-- main auto farm
function mainAutoFarm(mobName)
    local x = game:GetService("Workspace").NPCs:FindFirstChild(mobName)
    local npcs = x:GetChildren() -- ดึงรายชื่อ NPCs ทั้งหมดใน mobName

    for i, mob in pairs(npcs) do
        repeat
            wait()
            checkIfPlayerDead()
            checkAndEquipTool(_G.itemUse)

            -- ตรวจสอบว่ามี Humanoid ใน NPC หรือไม่
            if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                if _G.itemUse == "Combat" then
                    -- ส่งคำสั่งโจมตีแบบ Combat
                    local args = {
                        {
                            mob.Humanoid
                        }
                    }
                    game:GetService("Players").LocalPlayer.Character:WaitForChild("Combat"):WaitForChild("Remote"):WaitForChild("Combat_Event"):FireServer(unpack(args))
                elseif _G.itemUse == "Epic Sword" then
                    -- ส่งคำสั่งโจมตีแบบ Sword
                    local args = {
                        "Slash",
                        {
                            mob.Humanoid
                        }
                    }
                    game:GetService("Players").LocalPlayer.Character:WaitForChild("Epic Sword"):WaitForChild("Remote"):WaitForChild("Weapon_Event"):FireServer(unpack(args))
                else
                    print("อาวุธที่กำหนดไม่รองรับ:", _G.itemUse)
                end

                -- ตั้งค่า CFrame ของ LocalPlayer ให้ไปยังมอนสเตอร์ตัวปัจจุบัน
                -- game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                playerTeleportTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))

                -- ตรวจสอบว่าพลังชีวิตของมอนสเตอร์ <= 0 หรือไม่
                if mob.Humanoid.Health <= 0 then
                    _G.Stop = true
                else
                    _G.Stop = false
                end
            else
                print("Humanoid หรือ HumanoidRootPart ไม่พบใน NPC:", mob.Name)
                wait(0.5)
                break
            end
        until _G.AutoFarm_Level == false or _G.Stop == true
    end
end


-- ############################### --

local autofarm = serv:Channel("Auto Farm")

autofarm:Seperator()

local allmobs = {}

for i, j in pairs(game:GetService("Workspace").NPCs:GetChildren()) do
    table.insert(allmobs, j.Name)
end

autofarm:Toggle(
    "Auto Farm",
    false,
    function(bool)
        print("_G.AutoFarm_Level =", bool)
        _G.AutoFarm_Level = bool

        if _G.AutoFarmTarget == nil and _G.AutoFarm_Level then
            DiscordLib:Notification("Notification!!", "You haven't selected a mob.", "Okay!")
        elseif _G.itemUse == nil and _G.AutoFarm_Level then
            DiscordLib:Notification("Notification!!", "You haven't pick up equipment!", "Okay!")
        else
            spawn(function()
                while wait() do
                    if _G.AutoFarm_Level then
                        print("Auto Farm...")
                        game:GetService("Workspace").Gravity = 0
                        mainAutoFarm(_G.AutoFarmTarget)
                    else
                        game:GetService("Workspace").Gravity = _G.defGravity
                    end
                end
            end)
        end
    end
)

local mobs =
    autofarm:Dropdown(
    "Select Mob!",
    allmobs,
    function(bool)
        print("_G.AutoFarmTarget =", bool)
        _G.AutoFarmTarget = bool
    end
)


local nowItemUse = getBackpackItems()

local drop =
    autofarm:Dropdown(
    "Pick Equipment!",
    nowItemUse,
    function(bool)
        print("_G.itemUse =", bool)
        _G.itemUse = bool
    end
)

autofarm:Button(
    "Refresh Item",
    function()
        print("Refresh Item Successfully")
        nowItemUse = getBackpackItems()
        drop:Clear()
        for i, j in pairs(nowItemUse) do
            drop:Add(j)
        end
    end
)
autofarm:Seperator()

-- ############################### --

local tpOption = serv:Channel("Teleport")

local islands = {}

for i, island in pairs(game:GetService("Workspace").SpawnLocations:GetChildren()) do
    table.insert(islands, island.Name)
end

tpOption:Seperator()

local island =
    tpOption:Dropdown(
    "Select Island",
    islands,
    function(bool)
        print("_G.tpIsland =", bool)
        _G.tpIsland = bool
    end
)

tpOption:Button(
    "Teleport to Island",
    function()
        print("Teleport to Island Successfully")
        playerTeleportTo(game:GetService("Workspace").SpawnLocations:FindFirstChild(_G.tpIsland).CFrame)
    end
)

tpOption:Seperator()


-- ############################### --

local fruitOption = serv:Channel("Fruit Option")

fruitOption:Seperator()

fruitOption:Toggle(
    "TP All Fruit",
    false,
    function(bool)
        print("_G.tpAllFruitStat =", bool)
        _G.tpAllFruitStat = not _G.tpAllFruitStat

        spawn(function()
            while wait() do
                if _G.tpAllFruitStat then
                    print("tp All Fruit...")
                    TP_AllFruit(_G.dalayTPAllFruit)
                end
            end
        end)

    end
)

local sldr =
    fruitOption:Slider(
    "Delay for TP",
    0,
    50,
    10,
    function(t)
        print("_G.dalayTPAllFruit =", t/10)
        _G.dalayTPAllFruit = t/10
    end
)

fruitOption:Seperator()

local allFruitInMap = getArrayAllFruit()

local island =
    fruitOption:Dropdown(
    "Select Fruit",
    allFruitInMap,
    function(bool)
        print("Teleport to", bool, "Successfully")
        _G.selectFruit = bool
    end
)

fruitOption:Button(
    "Refresh Fruit",
    function()
        print("Refresh Fruit Successfully")
        allFruitInMap = getArrayAllFruit()
        island:Clear()
        for i, j in pairs(allFruitInMap) do
            island:Add(j)
        end
    end
)

fruitOption:Button(
    "Teleport Fruit",
    function()
        print("Teleport to Island Successfully")
        playerTeleportTo(game:GetService("Workspace").Fruity:FindFirstChild(_G.selectFruit).CFrame)
    end
)

fruitOption:Seperator()


fruitOption:Button(
    "Drop All Fruit",
    function()
        print("Drop All Fruit Successfully")
        dropAllFruit()
    end
)

fruitOption:Seperator()


-- ############################### --

local serv = serv:Channel("Server")

serv:Button(
    "Rejoin",
    function()
        print("Rejoin Successfully")
        serverRejoin()
    end
)

serv:Button(
    "Server Hop",
    function()
        print("Server Hop Successfully")
        serverHop()
    end
)

-- ############################### --
