resource.AddFile( "materials/waypointmarker/wpmarker.vmt" )
resource.AddFile( "materials/waypointmarker/wpmarker.vtf" )
util.AddNetworkString("waypointmarker")
util.AddNetworkString("deathmarker")
util.AddNetworkString("requestmarker")




function CreateWaypoint(client,args)
if not client:IsCombine() then return false end
		local trace = client:GetEyeTraceNoCursor()
		if (!trace.Hit) then return end
print(args)
		local strings = {name = client:Name(), msg = args or false}
		local transmitstring = util.TableToJSON(strings)
		net.Start("waypointmarker")
			net.WriteVector(trace.HitPos)
			net.WriteString(transmitstring)
		net.Broadcast()
client:Notify("Waypoint generated.")
return ""

end


apex.commands.Register("/waypoint",CreateWaypoint)


function CreateRequest(client,args)
if client:IsCombine() or client:IsArrested() or client:Team() == TEAM_VORT then return end

		local strings = {name = client:Name(), msg = args or false}
		local transmitstring = util.TableToJSON(strings)
		net.Start("requestmarker")
			net.WriteVector(client:GetPos())
			net.WriteString(transmitstring)
		net.Broadcast()
client:Notify("Request sent.")
return ""
end


apex.commands.Register("/request",CreateRequest)

