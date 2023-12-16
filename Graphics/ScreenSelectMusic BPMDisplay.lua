return Def.BPMDisplay {
	File=THEME:GetPathF("", "_@fot-newrodin pro db 20px");
	Name="BPMDisplay";
	InitCommand=cmd(halign,0);
	SetCommand=function(self) self:SetFromGameState() end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
};