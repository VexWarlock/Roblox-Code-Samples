--ServerScriptService -> script
local Lighting=game:GetService("Lighting")


--pe timpul romaniei
while true do
    task.wait(1)
    Lighting.TimeOfDay=os.date("%H:%M:%S", os.time())
end

--pe timpul UTC
while true do
    task.wait(1)
    Lighting.TimeOfDay=os.date("%H:%M:%S", os.time()-10800)
end
