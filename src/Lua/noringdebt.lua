local cv_noringdebt = CV_RegisterVar({
	name = "noringdebt", 
	defaultvalue = "Off", 
	flags = CV_NETVAR, 
	PossibleValue = CV_OnOff
})

addHook("PlayerThink", function(player)
	if not (cv_noringdebt.value) then
		return
	end
		
	if not (player.rings) then
		player.pflags = $ | PF_ATTACKDOWN -- ya cant fire
	end
end)