/*
CPList = {}

CPList["npc_combine_camera"] = true
CPList["npc_turret_ceiling"] = true
CPList["npc_cscanner"] = true
CPList["CombineElite"] = true
CPList["npc_combinegunship"] = true
CPList["npc_combine_s"] = true
CPList["npc_hunter"] = true
CPList["npc_scanner"] = true
CPList["npc_helicopter"] = true
CPList["npc_manhack"] = true
CPList["npc_metropolice"] = true
CPList["CombinePrison"] = true
CPList["PrisonShotgunner"] = true
CPList["npc_rollermine"] = true
CPList["ShotgunSoldier"] = true
CPList["npc_strider"] = true
CPList["npc_turret_floor"] = true

-- timer.Create( "MakeFriendly", 8, 0, function()
--     for k,ent in pairs (ents.GetAll()) do
--         if CPList[ent:GetClass()] then
--             ent:Activate()
--             for l, client in player.Iterator() do
--                 if client:IsCombine() then
--                     ent:AddEntityRelationship( client, D_NU, 0 )
--                 else
--                     ent:AddEntityRelationship( client, D_HT, 0 )
--                 end
--             end
--         end
--     end
-- end)

hook.Add("PlayerSpawn", "runonspawn", function(client)

    if IsValid(client) then
        for k,ent in pairs (ents.GetAll()) do
        if CPList[ent:GetClass()] then
            ent:Activate()
            for l, client in player.Iterator() do
                if client:IsCombine() then
                    ent:AddEntityRelationship( client, D_FR, 0 )
                end
                if string.match( client:GetModel(), "group03" ) then
                    ent:AddEntityRelationship( client, D_HT, 0 )
                else
                    ent:AddEntityRelationship( client, D_NU, 0 )
                end
            end
        end
    end
    else return end
end)

hook.Add("PlayerDisconnected", "OnDisconnect", function(client)
    if IsValid(client) then
        for k,ent in pairs (ents.GetAll()) do
        if CPList[ent:GetClass()] then
            ent:Activate()
            for l, client in player.Iterator() do
                if client:IsCombine() then
                    ent:AddEntityRelationship( client, D_FR, 0 )
                end
                if ( string.find(client:GetModel(), "group03") ) then
                    ent:AddEntityRelationship( client, D_HT, 0 )
                end
                if client:GetMoveType() == MOVETYPE_NOCLIP and client:IsAdmin() then
                    ent:AddEntityRelationship( client, D_FR, 0 )
                else
                    ent:AddEntityRelationship(client, D_NU, 0)
                end
            end
        end
        end
    else return end
end)

hook.Add("OnEntityCreated", "ListEnts", function(ent)
    for _, ent in ents.Iterator() do
        if ( CPList[ent:GetClass()] ) then
            ent:Activate()

            for l, client in player.Iterator() do
                if client:IsCombine() then
                    ent:AddEntityRelationship(client, D_FR, 0)
                end

                if ( string.find(client:GetModel(), "group03") ) then
                    ent:AddEntityRelationship(client, D_HT, 0)
                else
                    ent:AddEntityRelationship(client, D_NU, 0)
                end
            end
        end
    end

    return true
end)
*/

print("NPC module initialized successfully.")