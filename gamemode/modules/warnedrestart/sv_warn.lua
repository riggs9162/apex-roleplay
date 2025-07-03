concommand.Add("apex_beginrestart",function(client)
if not IsValid(client) then
BroadcastLua([[RCountDown()]])
timer.Simple(300,function()
RunConsoleCommand("changelevel",game.GetMap())
end)
end
end)







concommand.Add("apex_beginrestartfull",function(client)
if not IsValid(client) then
BroadcastLua([[RCountDown()]])
timer.Simple(300,function()
RunConsoleCommand("_restart")
end)
end
end)

