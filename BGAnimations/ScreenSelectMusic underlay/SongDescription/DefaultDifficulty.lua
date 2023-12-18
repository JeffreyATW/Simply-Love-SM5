local t = Def.ActorFrame {};
local function GetEdits( in_Song, in_StepsType )
	if in_Song then
		local sSong = in_Song;
		local sCurrentStyle = GAMESTATE:GetCurrentStyle();
		local sStepsType = in_StepsType;
		local iNumEdits = 0;
		if sSong:HasEdits( sStepsType ) then
			local tAllSteps = sSong:GetAllSteps();
			for i,Step in pairs(tAllSteps) do
				if Step:IsAnEdit() and Step:GetStepsType() == sStepsType then
					iNumEdits = iNumEdits + 1;
				end
			end
			return iNumEdits;
		else
			return iNumEdits;
		end
	else
		return 0;
	end
end;
--

-- Set a fixed list of difficulties to go through.
local DiffList = {
	"Difficulty_Beginner",
	"Difficulty_Easy",
	"Difficulty_Medium",
	"Difficulty_Hard",
	"Difficulty_Challenge",
	"Difficulty_Edit"
}
for idx,diff in pairs(DiffList) do
	local sDifficulty = ToEnumShortString( diff );
	local eachHeight = 23;
	local tLocation = {
		Beginner	= eachHeight*0,
		Easy 		= eachHeight*0.9,
		Medium		= eachHeight*1.81,
		Hard		= eachHeight*2.72,
		Challenge	= eachHeight*3.64,
		Edit 		= eachHeight*4.56,
	};
	-- Outfox note:
	-- There are 18 different difficulties available. So, if these are not defined in tLocation, it will fail.
	-- So for now, prevent loading of those.
	local diffLocationY = tLocation[sDifficulty] or tLocation["Edit"]
	t[#t+1] = Def.ActorFrame {
		SetCommand=function(self)
			local c = self:GetChildren();
			local song = GAMESTATE:GetCurrentSong()
			local bHasStepsTypeAndDifficulty = false;
			local meter = "00";
			if song then
				local st = GAMESTATE:GetCurrentStyle():GetStepsType()
				bHasStepsTypeAndDifficulty = song:HasStepsTypeAndDifficulty( st, diff );
				local steps = song:GetOneSteps( st, diff );
				if steps then
					meter = steps:GetMeter();
					append = ""
				end
			else
				meter=0;
			end
			
		    c.Meter:settextf( "%01d", meter );
			local curDiff1;
			local curDiff2;
			local pn = GAMESTATE:IsPlayerEnabled(PLAYER_1) and PLAYER_1 or PLAYER_2;
			if GAMESTATE:IsPlayerEnabled(pn) then 
				local currentSteps = GAMESTATE:GetCurrentSteps(pn);
				if currentSteps ~= nil then
					curDiff1 = currentSteps:GetDifficulty();
				end
			else
				self:visible(0);
			end
			
			
			
			if bHasStepsTypeAndDifficulty then
				if curDiff1==diff or curDiff2==diff then
					self:playcommand("Show");
				else
					self:playcommand("UnSelect");
					
				end
			else
				self:playcommand("Hide");
			end


		end;
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentTrailP1ChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");

--		LoadActor("cursorglow")..{--��ܪ����w
--			ShowCommand=cmd(stoptweening;zoom,1.2;linear,0.2;diffusealpha,1;zoomy,0.78;zoomx,1);
--			HideCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,1;diffusealpha,0);
--			InitCommand=cmd(x,28;y,tLocation[sDifficulty];shadowlengthy,1;zoom,1;diffuseshift;effectcolor2,color("1,1,1,0.5");effectcolor1,color("1,1,1,1"));
--			UnSelectCommand=cmd(stoptweening;decelerate,0.2;diffusealpha,0;zoom,1.2);
--		};

		LoadActor("StepsDisplay ticks")..{--���ϼ�
			Name="Meter";
			ShowCommand=cmd(stoptweening;linear,0.1;diffuse,DifficultyColor( diff ););
			HideCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,2;diffuse,color( "0.5,0.5,0.5,0.5"));
			InitCommand=cmd(x,0-76;y,diffLocationY+1.3;shadowlengthy,2;zoom,0.44;);
			UnSelectCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,2;diffuse,DifficultyColor( diff ));
		};
		
		LoadFont("_@fot-newrodin pro db 20px") .. { --���״y�z
			Name="Meter";
			Text=THEME:GetString("CustomDifficulty",sDifficulty);
			ShowCommand=cmd(stoptweening;linear,0.1;;diffuse,color("1,1,1,1");strokecolor, color( "0,0,0,0" );zoomx,0.40);
			HideCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,2;diffuse,color( "0.5,0.5,0.5,0.5" );zoomx,0.40);
			InitCommand=cmd(horizalign,left;x,0-70;y,diffLocationY+2;shadowlengthy,2;zoomx,0.40;zoomy,0.4);
			UnSelectCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,2;diffuse,color("1,1,1,1");strokecolor, color( "0,0,0,0" );zoomx,0.40);
		};

		
		LoadFont("_@fot-newrodin pro db 20px") .. { --�Ʀr
			Name="Meter";
			Text="0";
			ShowCommand=cmd(stoptweening;linear,0.1;diffuse,color( "1,1,1,1" );strokecolor, color( "0,0,0,1" ));
			HideCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,2;diffuse,color( "0.5,0.5,0.5,0.5" );strokecolor, color( "0.1,0.1,0.1,0.5" ));
			InitCommand=cmd(x,0-85;y,diffLocationY+2;shadowlengthy,2;zoom,0.45;strokecolor,CustomDifficultyToDarkColor(sDifficulty));
			UnSelectCommand=cmd(stoptweening;decelerate,0.2;shadowlengthy,2;diffuse,color( "1,1,1,1" );strokecolor, color( "0,0,0,1" ));
		};
		

		OffCommand=cmd(linear,0.5;diffusealpha,0;);
	};
	
end
return t