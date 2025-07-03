util.AddNetworkString( "thirdPerson" )

function thirdPerson(client)

net.Start( "thirdPerson" )
net.WriteBool(true)
net.Send( client )

end
apex.commands.Register("/thirdperson", thirdPerson)

function firstPerson(client)

net.Start( "thirdPerson" )
net.WriteBool(false)
net.Send( client )

end
apex.commands.Register("/firstperson", firstPerson)

hook.Add("PlayerSpawn","NOCROSSHAIR",function(p)
p:CrosshairDisable()
end)

