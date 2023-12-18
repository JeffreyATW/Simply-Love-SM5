local t = Def.ActorFrame{
	Name="PerPlayer"
}

-- Always add these elements for both players, even if only one is joined right now
-- If the other player suddenly latejoins, we can't dynamically add more actors to the screen
-- We can only unhide hidden actors that were there all along
for player in ivalues( PlayerNumber ) do
	t[#t+1] = LoadActor("./FolderStats.lua", player)
	t[#t+1] = LoadActor("./ScoreBox.lua", player)
end

return t
