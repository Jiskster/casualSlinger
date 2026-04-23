local function getSuperPlayers(localplayer)
	local plrs = {}
	
	for player in players.iterate do
		if not (player.mo and player.mo.valid and player.mo.health 
		and player.rings and player.powers[pw_super]) then
			continue
		end
		
		if localplayer and (player == localplayer) then
			continue
		end
		
		if (player.spectator) then
			continue
		end
		
		plrs[#plrs + 1] = player
	end
	
	if #plrs then
		table.sort(plrs, function(a, b)
			return a.rings > b.rings
		end)
	end
	
	return plrs
end

addHook("HUD", function(v, player)
	local x = 16
	local y = 58

	local numgap = 2; -- space between head and number
	local heightgap = 16;
	
	local superplayers = getSuperPlayers(player)
	
	if not #superplayers then
		return
	end
	
	for i,splayer in ipairs(superplayers) do
		local spmo = splayer.mo
		
		local ringsleft = splayer.rings or 0
		local numlen = tonumber(tostring(ringsleft):len()) -- lazy
		local numoffset = numlen*8
		
		local colormap = v.getColormap(spmo.skin, spmo.color)
		local head = v.getSprite2Patch(spmo.skin, SPR2_LIFE, true)
		
		local heightoffset = (i-1)*heightgap
		
		v.drawScaled(x*FU + head.width*FU/2, y*FU + head.height*FU/2 + heightoffset*FU, FU, head, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
		v.drawNum(x + numgap + head.width + numoffset, y + heightoffset, ringsleft, V_SNAPTOLEFT|V_SNAPTOTOP)
	end
end, "game")