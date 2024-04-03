local addonName = "Unreal Tournament Killstreak Sounds"
local sounds = list.GetForEdit(addonName)
resource.AddWorkshop("3209446591")
do
	local fileName = string.gsub(string.lower(addonName), "%s+", "_") .. ".json"
	if not file.Exists(fileName, "DATA") then
		file.Write(fileName, util.TableToJSON({
			[2] = {
				"doublekill.mp3",
				"doublekill2.mp3",
				"doublekill3.mp3"
			},
			[3] = "triplekill.mp3",
			[5] = {
				"multikill.mp3",
				"multikill2.mp3"
			},
			[6] = {
				"rampage.mp3",
				"rampage2.mp3"
			},
			[7] = {
				"killingspree.mp3",
				"killingspree2.mp3"
			},
			[8] = {
				"dominating.mp3",
				"dominating2.mp3"
			},
			[9] = "impressive.mp3",
			[10] = {
				"unstoppable.mp3",
				"unstoppable2.mp3"
			},
			[11] = "outstanding.mp3",
			[12] = {
				"megakill.mp3",
				"megakill2.mp3"
			},
			[13] = {
				"ultrakill.mp3",
				"ultrakill2.mp3"
			},
			[14] = {
				"eagleeye.mp3",
				"eagleeye2.mp3"
			},
			[15] = "ownage.mp3",
			[16] = "comboking.mp3",
			[17] = "maniac.mp3",
			[18] = "ludicrouskill.mp3",
			[19] = "bullseye.mp3",
			[20] = "excellent.mp3",
			[21] = "pancake.mp3",
			[22] = {
				"headhunter.mp3",
				"headhunter2.mp3"
			},
			[23] = "unreal.mp3",
			[24] = "assassin.mp3",
			[25] = "whickedsick.mp3",
			[26] = "massacre.mp3",
			[27] = "killingmachine.mp3",
			[28] = {
				"monsterkill.mp3",
				"monsterkill2.mp3"
			},
			[29] = "holyshit.mp3",
			[30] = "godlike.mp3",
			["headshot"] = {
				"headshot.mp3",
				"headshot2.mp3",
				"headshot3.mp3",
				"headshot4.mp3"
			}
		}, true))
	end
	file.AsyncRead(fileName, "DATA", function(_, __, status, data)
		if status ~= FSASYNC_OK then
			return
		end
		for key, value in pairs(util.JSONToTable(data)) do
			sounds[key] = value
		end
	end)
end
do
	local emitKillstreakSound = nil
	do
		local Create, Remove
		do
			local _obj_0 = timer
			Create, Remove = _obj_0.Create, _obj_0.Remove
		end
		local tostring = tostring
		local isstring = isstring
		local istable = istable
		local random = math.random
		hook.Add("PlayerDisconnected", addonName, function(ply)
			return Remove(addonName .. " - " .. tostring(ply))
		end)
		emitKillstreakSound = function(ply, placeholder)
			local timerName = addonName .. " - " .. tostring(ply)
			return Create(timerName, 0.25, 1, function()
				if not ply:IsValid() or (ply:IsPlayer() and not ply:Alive()) then
					return
				end
				local soundName = sounds[placeholder]
				if istable(soundName) then
					local length = #soundName
					if length == 0 then
						return
					end
					if length == 1 then
						soundName = soundName[1]
					else
						soundName = soundName[random(1, length)]
					end
				end
				if isstring(soundName) then
					return ply:EmitSound("killstreak-sounds/" .. soundName, random(50, 100), random(90, 110), 1, 0, 1)
				end
			end)
		end
		EmitKillstreakSound = emitKillstreakSound
	end
	local flags = bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY)
	local utks_time_to_kill = CreateConVar("utks_time_to_kill", "5", flags, "Time to successfully complete a series of kills, once the specified time has elapsed the series will be invalid.", 0, 300)
	local HITGROUP_HEAD = HITGROUP_HEAD
	local CurTime = CurTime
	hook.Add("DoPlayerDeath", addonName, function(ply, attacker, damageInfo)
		if not (attacker:IsValid() and attacker ~= ply and attacker:IsPlayer() and attacker:Alive()) then
			return
		end
		if ply:LastHitGroup() == HITGROUP_HEAD and damageInfo:IsBulletDamage() then
			attacker[addonName .. " - Frags"] = attacker[addonName .. " - Frags"] + 1
			emitKillstreakSound(attacker, "headshot")
			return
		end
		local lastKill, curTime = attacker[addonName], CurTime()
		attacker[addonName] = curTime
		if not lastKill then
			return
		end
		local frags = attacker[addonName .. " - Frags"]
		if (curTime - lastKill) > utks_time_to_kill:GetFloat() then
			frags = 0
		end
		frags = frags + 1
		attacker[addonName .. " - Frags"] = frags
		emitKillstreakSound(attacker, frags)
		return
	end)
	local utks_npc_kills = CreateConVar("utks_npc_kills", "0", flags, "Enable kill streak for NPCs.", 0, 1):GetBool()
	cvars.AddChangeCallback("utks_npc_kills", function(_, __, value)
		utks_npc_kills = value == "1"
	end, addonName)
	hook.Add("OnNPCKilled", addonName, function(_, attacker)
		if not (utks_npc_kills and attacker and attacker:IsValid() and attacker:IsPlayer() and attacker:Alive()) then
			return
		end
		local lastKill, curTime = attacker[addonName], CurTime()
		attacker[addonName] = curTime
		if not lastKill then
			return
		end
		local frags = attacker[addonName .. " - Frags"]
		if (curTime - lastKill) > utks_time_to_kill:GetFloat() then
			frags = 0
		end
		frags = frags + 1
		attacker[addonName .. " - Frags"] = frags
		emitKillstreakSound(attacker, frags)
		return
	end)
end
do
	local resetCounter
	resetCounter = function(ply)
		ply[addonName .. " - Frags"] = 0
	end
	hook.Add("PlayerSpawn", addonName, resetCounter)
	return hook.Add("PostPlayerDeath", addonName, resetCounter)
end
