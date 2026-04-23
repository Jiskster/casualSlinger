-- pw_super has to be greater than 0 to be super in ringslinger. [Jisk:4-21-2026]

local STRONGSUPERDAMAGE = 30 -- If super has this amount of rings or more, incoming damage is increased.

local function countEmeraldFlag(emflag)
	local c = 0

	for i=1,7 do
		if (emflag & (1<<(i-1))) then
			c = $ + 1
		end
	end
	
	return c
end

local function emeraldTouchSpecial(special, toucher)
	local player = toucher.player
	if not (toucher and toucher.valid and player and player) then
		return
	end

	if player.powers[pw_super] then -- nope
		return true
	end

	if countEmeraldFlag(player.powers[pw_emeralds]) == 6 then
		player.powers[pw_super] = 1
		player.powers[pw_emeralds] = 1|2|4|8|16|32|64
		P_DoSuperTransformation(player, false)
		P_KillMobj(special)
		return true
	end
end

for i=MT_EMERALD1, MT_EMERALD7 do
	addHook("TouchSpecial", emeraldTouchSpecial, i)
end

addHook("TouchSpecial", emeraldTouchSpecial, MT_FLINGEMERALD)

addHook("MapLoad", function()
	if G_RingSlingerGametype() then
		emeralds = 1|2|4|8|16|32|64
	end
end)

addHook("ShouldDamage", function(target, inflictor, source, damage, damagetype)
	if not G_RingSlingerGametype() then
		return
	end 

	local attackerplayer
	local player

	if (target and target.valid and target.player and target.player.valid) then
		player = target.player
	end

	if (source and source.valid and source.player and source.player.valid) then
		attackerplayer = source.player
	elseif (inflictor and inflictor.valid and inflictor.player and inflictor.player.valid) then
		attackerplayer = inflictor.player
	end

	if not (player or attackerplayer) then
		return
	end

	if not (player.powers[pw_super]) then
		return
	end

	local lossrings = 1

	if player.rings >= STRONGSUPERDAMAGE then
		lossrings = 5
	end

	if player.rings < lossrings then
		lossrings = max(0, $ - player.rings)
	end
	
	if lossrings then
		player.rings = max(0, $ - lossrings)
		S_StartSound(target, sfx_s3kb9)
		
		-- Slow down when getting attacked
		target.momx = ($*6)/10
		target.momy = ($*6)/10
	end

	return false
end, MT_PLAYER)

addHook("PlayerThink", function(player)
	if not G_RingSlingerGametype() then
		return
	end
	
	local mo = player.mo
	
	if not (mo and mo.valid) then
		return
	end
	
	if player.powers[pw_super] then
		player.charflags = $|SF_SUPER
	else
		player.charflags = $ & ~SF_SUPER
	end
end)

COM_AddCommand("forcesuper", function(player)
	if not (player.mo and player.mo.valid) then
		return end;

	player.powers[pw_super] = 1
	player.powers[pw_emeralds] = 1|2|4|8|16|32|64

	P_DoSuperTransformation(player, false)

	player.rings = 900

	print("CHEAT: "..player.name.." forced themselves to be super!")
end, COM_ADMIN)