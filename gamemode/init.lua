-------------
-- Finding Dr Breen
-- by philxyz
--
-- Liberty License
-------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

PendingRoundTime = DefaultRoundTime
RoundTime = DefaultRoundTime
TimeSinceL = CurTime()

GM.DeadPlayers = {}

concommand.Add("fb_roundtime", function(ply, cmd, args)
	if not ply or not ply:IsValid() or (not ply:IsAdmin() and not ply:IsSuperAdmin()) then
		return
	end

	if not tonumber(args[1]) then
		return
	end

	if tonumber(args[1]) < 30 or tonumber(args[1]) > 600 then
		print("Round time must be between 30 and 600 seconds.")
		return
	end

	PendingRoundTime = tonumber(args[1])
	print("Next round time set to " .. tostring(tonumber(args[1])) .. " seconds duration.")
end)

function GM:Think()
	if (CurTime() - TimeSinceL) >= 1.0 then
		TimeSinceL = CurTime()
		RoundTime = RoundTime - 1
		local plys = player.GetAll()
		local atLeastOnePlayerIsAlive = true
                for _, v in ipairs(plys) do
			if not v:Alive() then atLeastOnePlayerIsAlive = false end

                        umsg.Start("rt")
			umsg.Short(RoundTime)
                        umsg.End()
                end
		if self.RoundInProgress and (RoundTime <= 0 or not atLeastOnePlayerIsAlive) then
			self:KillEveryone()
			local m = self
			timer.Simple(2, function() m:EndRound() end)
		end
	end
end

function GM:KillEveryone()
	self.RoundInProgress = false

	local pls = player.GetAll()
	local breen = ents.FindByClass("npc_breen")
	for _, v in ipairs(pls) do
		umsg.Start("ed", v)
		umsg.End()
		v:TakeDamage(100, breen[1], breen[1])
		timer.Simple(3, function() v:Spawn() end)
	end
end

function GM:KillBreen()
	local e = ents.FindByClass("npc_breen")
	for _, v in ipairs(e) do
		v:TakeDamage(100, v, v)
	end
end

function GM:EndRound()
	if PendingRoundTime ~= DefaultRoundTime then
		RoundTime = PendingRoundTime
	else
		RoundTime = DefaultRoundTime
	end

	self:KillBreen()
	self:ResetDeadPlayers()
	self:GiveUsABreen()
end

function GM:PlayerSpawn(ply)
	ply:AllowFlashlight(true)
	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("weapon_crossbow")
	ply:SetAmmo(0, "XBowBolt")

	umsg.Start("hdm", ply)
	umsg.End()
end

function GM:PlayerDeathThink(ply)
	for _, p in ipairs(self.DeadPlayers) do
		if p == ply:EntIndex() then return false end
	end

	return true
end

function GM:PlayerDeath(victim, inflictor, attacker)
	table.insert(self.DeadPlayers, #self.DeadPlayers + 1, victim:EntIndex())

	umsg.Start("ddm", victim)
	umsg.End()
end

function GM:ResetDeadPlayers()
	self.DeadPlayers = {}

	for _, v in ipairs(player.GetAll()) do
		v:Spawn()
	end
end

function GM:GetBreenPos()
	math.randomseed(os.time())

	local lowestvec = 16383
	local highestvec = -16384

	local ran = false
	for _, v in ipairs(player.GetAll()) do
		ran = true
		local loc = v:GetPos().y
		if loc < lowestvec then
			lowestvec = loc
		end
		if loc > highestvec then
			highestvec = loc
		end
	end

	if ran == false then
		lowestvec = -1000
		highestvec = 1000
	end
	local ypos = math.random(lowestvec - 400, highestvec + 400)

	local v = Vector(math.random(-16384, 16383), ypos, math.random(-16384, 16383))
	while not util.IsInWorld(v) do
		v = Vector(math.random(-16384, 16383), ypos, math.random(-16384, 16383))
	end
	return v
end

function GM:InitPostEntity()
	self:GiveUsABreen()
end

function GM:GiveUsABreen()
	local pos = self:GetBreenPos()
	local breen = ents.Create( "npc_breen" )
        breen:SetPos(pos)
        breen:SetAngles(Angle(0, 0, 0))
        breen:Spawn()
        breen:DropToFloor()

	self.RoundInProgress = true

	for _, v in ipairs(player.GetAll()) do
		umsg.Start("bs", v)
        	umsg.End()
	end
end

function GM:OnNPCKilled(npc, attacker, weapon)

	if attacker:GetClass() == "npc_breen" then return end

	local pga = player.GetAll()

	if npc:GetClass() == "npc_breen" then
		if attacker:IsPlayer() then
			attacker:AddFrags(1)

			for _, v in ipairs(pga) do
				umsg.Start("kn", v)
				umsg.Short(attacker:EntIndex())
				umsg.End()
			end
		end

		-- Kill all players
		for _, v in ipairs(pga) do
			if v:EntIndex() ~= attacker:EntIndex() then
				v:TakeDamage(100, attacker, inflictor)
			end
		end

		local m = self
		
		timer.Simple(2, function() m:EndRound() end)
	end
end
