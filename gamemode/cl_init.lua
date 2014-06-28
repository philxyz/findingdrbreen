-- Finding Dr Breen - cl_init.lua
-- philxyz 2014
-- Liberty License

include("shared.lua")
require("notification")

ShowDeathMessage = false

RemainingTime = DefaultRoundTime

DeathScreams = {
	"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav"
}

BreenSpeeches = {
        {"vo/Breencast/br_collaboration01.wav", 10},
        {"vo/Breencast/br_collaboration02.wav", 6},
        {"vo/Breencast/br_collaboration03.wav", 10},
        {"vo/Breencast/br_collaboration04.wav", 6},
        {"vo/Breencast/br_collaboration05.wav", 14},
        {"vo/Breencast/br_collaboration06.wav", 4},
        {"vo/Breencast/br_collaboration07.wav", 15},
        {"vo/Breencast/br_collaboration08.wav", 17},
        {"vo/Breencast/br_collaboration09.wav", 8},
        {"vo/Breencast/br_collaboration10.wav", 12},
        {"vo/Breencast/br_collaboration11.wav", 5},

        {"vo/Breencast/br_disruptor01.wav", 12},
        {"vo/Breencast/br_disruptor02.wav", 14},
        {"vo/Breencast/br_disruptor03.wav", 15},
        {"vo/Breencast/br_disruptor04.wav", 7},
        {"vo/Breencast/br_disruptor05.wav", 13},
        {"vo/Breencast/br_disruptor06.wav", 6},
        {"vo/Breencast/br_disruptor07.wav", 13},
        {"vo/Breencast/br_disruptor08.wav", 8},

        {"vo/Breencast/br_instinct01.wav", 17},
        {"vo/Breencast/br_instinct02.wav", 14},
        {"vo/Breencast/br_instinct03.wav", 18},
        {"vo/Breencast/br_instinct04.wav", 12},
        {"vo/Breencast/br_instinct05.wav", 12},
        {"vo/Breencast/br_instinct06.wav", 10},
        {"vo/Breencast/br_instinct07.wav", 9},
        {"vo/Breencast/br_instinct08.wav", 9},
        {"vo/Breencast/br_instinct09.wav", 5},
        {"vo/Breencast/br_instinct10.wav", 11},
        {"vo/Breencast/br_instinct11.wav", 5},
        {"vo/Breencast/br_instinct12.wav", 6},
        {"vo/Breencast/br_instinct13.wav", 19},
        {"vo/Breencast/br_instinct14.wav", 6},
        {"vo/Breencast/br_instinct15.wav", 6},
        {"vo/Breencast/br_instinct16.wav", 6},
        {"vo/Breencast/br_instinct17.wav", 7},
        {"vo/Breencast/br_instinct18.wav", 5},
        {"vo/Breencast/br_instinct19.wav", 10},
        {"vo/Breencast/br_instinct20.wav", 7},
        {"vo/Breencast/br_instinct21.wav", 4},
        {"vo/Breencast/br_instinct22.wav", 6},
        {"vo/Breencast/br_instinct23.wav", 6},
        {"vo/Breencast/br_instinct24.wav", 14},
        {"vo/Breencast/br_instinct25.wav", 8},

        {"vo/Breencast/br_overwatch01.wav", 14},
        {"vo/Breencast/br_overwatch02.wav", 18},
        {"vo/Breencast/br_overwatch03.wav", 17},
        {"vo/Breencast/br_overwatch04.wav", 29},
        {"vo/Breencast/br_overwatch05.wav", 14},
        {"vo/Breencast/br_overwatch06.wav", 30},
        {"vo/Breencast/br_overwatch07.wav", 50},
        {"vo/Breencast/br_overwatch08.wav", 37},
        {"vo/Breencast/br_overwatch09.wav", 30},

        {"vo/Breencast/br_tofreeman01.wav", 4},
        {"vo/Breencast/br_tofreeman02.wav", 4},
        {"vo/Breencast/br_tofreeman03.wav", 9},
        {"vo/Breencast/br_tofreeman04.wav", 7},
        {"vo/Breencast/br_tofreeman05.wav", 12},
        {"vo/Breencast/br_tofreeman06.wav", 4},
        {"vo/Breencast/br_tofreeman07.wav", 6},
        {"vo/Breencast/br_tofreeman08.wav", 10},
	{"vo/Breencast/br_tofreeman09.wav", 6},
        {"vo/Breencast/br_tofreeman10.wav", 6},
        {"vo/Breencast/br_tofreeman11.wav", 3},
        {"vo/Breencast/br_tofreeman12.wav", 2},

        {"vo/Breencast/br_welcome01.wav", 5},
        {"vo/Breencast/br_welcome02.wav", 8},
        {"vo/Breencast/br_welcome03.wav", 9},
        {"vo/Breencast/br_welcome04.wav", 6},
        {"vo/Breencast/br_welcome05.wav", 12},
        {"vo/Breencast/br_welcome06.wav", 4},
        {"vo/Breencast/br_welcome07.wav", 3}
}

function BreenBeginTalking()
	local count = 0

	local function talkcycle(count)
		math.randomseed(os.time())
		local a = math.random(1, #BreenSpeeches)
		surface.PlaySound(BreenSpeeches[a][1])
		count = count + 1
		if count < 3 then
			timer.Simple(math.random(2, 5) + BreenSpeeches[a][2], function() talkcycle(count) end)
		end
	end

	talkcycle(count)
end

function UpdateTimer(trem)
	RemainingTime = trem
end

usermessage.Hook("rt", function(um) UpdateTimer(um:ReadShort()) end)
usermessage.Hook("ds", function(um) Scream(LocalPlayer(), um:ReadShort()) end)
usermessage.Hook("bs", function() BreenBeginTalking() end)
usermessage.Hook("kn", function(um) notification.AddLegacy(ents.GetByIndex(um:ReadShort()):Nick() .. " has found and killed Dr. Breen! Round restarting...", NOTIFY_GENERIC, 4) end)
usermessage.Hook("ed", function() notification.AddLegacy("Nobody found Dr. Breen in time! Naturally, everybody dies!", NOTIFY_GENERIC, 3) end)
usermessage.Hook("ddm", function() ShowDeathMessage = true end)
usermessage.Hook("hdm", function() ShowDeathMessage = false end)

function RemoveDeadRag( ent )
	if (ent == NULL) or (ent == nil) then return end
	if (ent:GetClass() == "class C_ClientRagdoll") then 
		if ent:IsValid() and !(ent == NULL) then
			timer.Simple(20, function() SafeRemoveEntityDelayed(ent,0) end)
		end
	end 
end
hook.Add("OnEntityCreated", "RemoveDeadRag", RemoveDeadRag)

-- Disallow the Q menu
function GM:SpawnMenuEnabled()
	return LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()
end

function GM:PlayerDeath()
	math.randomseed(os.time())
        local which = math.random(1, #DeathScreams)
	surface.PlaySound(DeathScreams[which])
end

function GM:GetRemainingTime()
	if RemainingTime < 0 then
		return "-:--"
	end

	local rtm60 = tostring(RemainingTime % 60)
	if #rtm60 == 1 then
		rtm60 = "0" .. rtm60
	end
	return tostring(math.floor(RemainingTime / 60.0)) .. ":" .. rtm60
end

function GM:HUDPaint()
	draw.RoundedBox(4, 8, 8, 64, 26, Color(100, 100, 100, 100))
	draw.DrawText(self:GetRemainingTime(), "CloseCaption_Bold", 22, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

	if ShowDeathMessage == true then
		draw.DrawText("You have FAILED to locate Breen in time!", "DermaLarge", ScrW()/2, ScrH()/2, Color(135, 20, 135, 255), TEXT_ALIGN_CENTER)
	end
end
