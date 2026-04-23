-- by function by clairebun
local function zCollide(mo1,mo2)
	if mo1.z > mo2.height+mo2.z then return false end
	if mo2.z > mo1.height+mo1.z then return false end
	return true
end

addHook("PlayerThink", function(player)
	if not G_RingSlingerGametype() then
		return
	end

	if not (player.mo and player.mo.valid) then
		return
	end
end)

addHook("MobjMoveCollide", function(movemobj, mobj)
	if not G_RingSlingerGametype() then
		return
	end 

	if not zCollide(movemobj, mobj) then
		return
	end

	local player

	if (movemobj.player and movemobj.player.valid) then
		player = movemobj.player
	end

	if not (mobj.player and mobj.player.valid) or not (player) then -- if victim isn't a player or if we arent a player, gtfo
		return
	end
	
	if (mobj.player.powers[pw_flashing]) 
	or (mobj.player.powers[pw_invulnerability]) then
		return
	end

	if player.dashmode > 3*TICRATE then
		mobj.attackedbydash = true
		P_DamageMobj(mobj, movemobj, movemobj)
		movemobj.momx = $ / 2
		movemobj.momy = $ / 2
	end
end, MT_PLAYER)

addHook("HurtMsg", function(player, inflictor, source)
	if not G_RingSlingerGametype() then
		return
	end 

	local attackerplayer
	if (source and source.valid and source.player and source.player.valid) then
		attackerplayer = source.player
	elseif (inflictor and inflictor.valid and inflictor.player and inflictor.player.valid) then
		attackerplayer = inflictor.player
	end

	if not attackerplayer then
		return
	end

	local mo = player.mo

	if not (mo and mo.valid) then
		return
	end

	if not (mo.attackedbydash) then
		return
	end

	print(("%s's dashmode impaled %s"):format(attackerplayer.name, player.name))
	return true
end, MT_PLAYER)

addHook("MobjMoveBlocked", function(movemobj, mobj)
	if not G_RingSlingerGametype() then
		return
	end 

	local player = movemobj.player

	if not (player and player.valid) then
		return
	end

	if (player.dashmode > 3*TICRATE) then
		local oldspeed = player.speed

		P_DoPlayerPain(player)

		if oldspeed < 60*FU then
			movemobj.momz = $ * 2
		else
			movemobj.momz = $ * 3
		end

		if not player.powers[pw_super] then
			P_PlayerEmeraldBurst(player)
		end
		
		P_PlayerWeaponAmmoBurst(player)
		S_StartSound(movemobj, sfx_shldls)
	end
end, MT_PLAYER)