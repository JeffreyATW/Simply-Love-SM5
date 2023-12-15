local MusicWheel, SelectedType
local group_durations = LoadActor("./GroupDurations.lua")

-- width of background quad
local _w = IsUsingWideScreen() and 320 or 310

local af = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(_screen.cx - (IsUsingWideScreen() and 170 or 165), _screen.cy - 55)
	end,

	CurrentSongChangedMessageCommand=function(self)    self:playcommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self)  self:playcommand("Set") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
}

local nxYOffset = -155

local t = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(-95,nxYOffset):zoom( 0.79 )
	end
};

function TopRecord(pn) --�^�ǳ̰��������Ӭ���
	local SongOrCourse, StepsOrTrail;
	local myScoreSet = {
		["HasScore"] = 0;
		["SongOrCourse"] =0;
		["topscore"] = 0;
		["topW1"]=0;
		["topW2"]=0;
		["topW3"]=0;
		["topW4"]=0;
		["topW5"]=0;
		["topMiss"]=0;
		["topOK"]=0;
		["topEXScore"]=0;
		["topMAXCombo"]=0;
		["topDate"]=0;
		};
		
	if GAMESTATE:IsCourseMode() then
		SongOrCourse = GAMESTATE:GetCurrentCourse();
		StepsOrTrail = GAMESTATE:GetCurrentTrail(pn);
	else
		SongOrCourse = GAMESTATE:GetCurrentSong();
		StepsOrTrail = GAMESTATE:GetCurrentSteps(pn);
	end;

	local profile, scorelist;
	
	if SongOrCourse and StepsOrTrail then
		local st = StepsOrTrail:GetStepsType();
		local diff = StepsOrTrail:GetDifficulty();
		local courseType = GAMESTATE:IsCourseMode() and SongOrCourse:GetCourseType() or nil;

		if PROFILEMAN:IsPersistentProfile(pn) then
			-- player profile
			profile = PROFILEMAN:GetProfile(pn);
		else
			-- machine profile
			profile = PROFILEMAN:GetMachineProfile();
		end;

		scorelist = profile:GetHighScoreList(SongOrCourse,StepsOrTrail);
		assert(scorelist);
		local scores = scorelist:GetHighScores();
		assert(scores);
		-- local topscore=0;
		-- local topW1=0;
		-- local topW2=0;
		-- local topW3=0;
		-- local topW4=0;
		-- local topW5=0;
		-- local topMiss=0;
		-- local topOK=0;
		-- local topEXScore=0;
		-- local topMAXCombo=0;
		if scores[1] then
			myScoreSet["SongOrCourse"]=1;
			myScoreSet["HasScore"] = 1;
			myScoreSet["topscore"] = scores[1]:GetScore();
			myScoreSet["topW1"]  = scores[1]:GetTapNoteScore("TapNoteScore_W1");
			myScoreSet["topW2"]  = scores[1]:GetTapNoteScore("TapNoteScore_W2");
			myScoreSet["topW3"]  = scores[1]:GetTapNoteScore("TapNoteScore_W3");
			myScoreSet["topW4"]  = scores[1]:GetTapNoteScore("TapNoteScore_W4");
			myScoreSet["topW5"]  = scores[1]:GetTapNoteScore("TapNoteScore_W5");
			myScoreSet["topMiss"]  = scores[1]:GetTapNoteScore("TapNoteScore_W5")+scores[1]:GetTapNoteScore("TapNoteScore_Miss");
			myScoreSet["topOK"]  = scores[1]:GetHoldNoteScore("HoldNoteScore_Held");
			--myScoreSet["topEXScore"]  = scores[1]:GetTapNoteScore("TapNoteScore_W1")*3+scores[1]:GetTapNoteScore("TapNoteScore_W2")*2+scores[1]:GetTapNoteScore("TapNoteScore_W3")+scores[1]:GetHoldNoteScore("HoldNoteScore_Held")*3;
			if (StepsOrTrail:GetRadarValues( pn ):GetValue( "RadarCategory_TapsAndHolds" ) >=0) then --If it is not a random course
				if scores[1]:GetGrade() ~= "Grade_Failed" then
					myScoreSet["topEXScore"] = scores[1]:GetTapNoteScore("TapNoteScore_W1")*3+scores[1]:GetTapNoteScore("TapNoteScore_W2")*2+scores[1]:GetTapNoteScore("TapNoteScore_W3")+scores[1]:GetHoldNoteScore("HoldNoteScore_Held")*3;
				else
					myScoreSet["topEXScore"] = (StepsOrTrail:GetRadarValues( pn ):GetValue( "RadarCategory_TapsAndHolds" )*3+StepsOrTrail:GetRadarValues( pn ):GetValue( "RadarCategory_Holds" )*3)*scores[1]:GetPercentDP();
				end
			else --If it is Random Course then the scores[1]:GetPercentDP() value will be -1
				if scores[1]:GetGrade() ~= "Grade_Failed" then
					myScoreSet["topEXScore"]  = scores[1]:GetTapNoteScore("TapNoteScore_W1")*3+scores[1]:GetTapNoteScore("TapNoteScore_W2")*2+scores[1]:GetTapNoteScore("TapNoteScore_W3")+scores[1]:GetHoldNoteScore("HoldNoteScore_Held")*3;
				else
					myScoreSet["topEXScore"]  = 0;
				end
			end
			myScoreSet["topMAXCombo"]  = scores[1]:GetMaxCombo();
			myScoreSet["topDate"]  = scores[1]:GetDate() ;
		else
			myScoreSet["SongOrCourse"]=1;
			myScoreSet["HasScore"] = 0;
		end;
	else
		myScoreSet["HasScore"] = 0;
		myScoreSet["SongOrCourse"]=0;
		
	end
	return myScoreSet;

end;

--default difficulty stuff
local function GetDifListY(d)
	local r=0;
	if d == "Difficulty_Beginner" then
		r=(31.5*0);
	elseif d == "Difficulty_Easy" then
		r=(31.5*1);
	elseif d == "Difficulty_Medium" then
		r=(31.5*2);
	elseif d == "Difficulty_Hard" then
		r=(31.5*3);
	elseif d == "Difficulty_Challenge" then
		r=(31.5*4);
	elseif d == "Difficulty_Edit" then
		r=(31.5*5);
	end;
	return r;
end;

local function GetDifListX(self,pn,offset,fade)
	if pn==PLAYER_1 then
		--self:horizalign(left);
		self:x(SCREEN_CENTER_X+150-offset+125);
		if fade>0 then
			self:faderight(fade);
		end;
	else
		--self:horizalign(right);
		self:x(SCREEN_CENTER_X+150+offset+150);
		if fade>0 then
			self:fadeleft(fade);
		end;
	end;
	return r;
end;

--每個難度的分數列表
local function DrawDifList(pn,diff)
	local t=Def.ActorFrame {
		InitCommand=cmd(player,pn;y,SCREEN_CENTER_Y-115;x,-75;zoom,1.0);
		OffCommand=cmd(linear,0.25;diffusealpha,0;);
		song=GAMESTATE:GetCurrentSong();
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentTrailP1ChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentTrailP2ChangedMessageCommand=cmd(queuecommand,"Set");
		CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
--難度別最高分數資訊
		Def.RollingNumbers {
			File = THEME:GetPathF("_sf rounded pro", "20px");
			InitCommand=cmd(shadowlengthy,2;zoom,0.65;strokecolor,Color("Outline"));
			BeginCommand=cmd(playcommand,"Set");
			OffCommand=cmd(linear,0.25;diffusealpha,0;);
			SetCommand=function(self)
				local st=GAMESTATE:GetCurrentStyle():GetStepsType();
				local song=GAMESTATE:GetCurrentSong();
				local course = GAMESTATE:GetCurrentCourse();

				if song then
					GetDifListX(self,pn,270,0);
					--self:y(GetFlexDifListY(diff, st, song));
					self:y(GetDifListY(diff)+2);
					if song:HasStepsTypeAndDifficulty(st,diff) then
						local steps = song:GetOneSteps( st, diff );
						if PROFILEMAN:IsPersistentProfile(pn) then
							-- player profile
							profile = PROFILEMAN:GetProfile(pn);
						else
							-- machine profile
							profile = PROFILEMAN:GetMachineProfile();
						end;
						scorelist = profile:GetHighScoreList(song,steps);
						assert(scorelist);
						local scores = scorelist:GetHighScores();
						assert(scores);
						local topscore=0;
						if scores[1] then
							topscore = scores[1]:GetScore();
						end;
						assert(topscore);
						--topscore=10;
						-- self:diffuse(CustomDifficultyToLightColor(diff));
						-- self:strokecolor(CustomDifficultyToDarkColor(diff));
						self:diffuse(color("1,1,1,1"));
						self:strokecolor(color("0.2,0.2,0.2,1"));
						self:diffusealpha(1);
						-- if pn==PLAYER_1 then
							-- self:settextf("%09d   %s",topscore,THEME:GetString("CustomDifficulty",ToEnumShortString(diff)));
						-- else
							-- self:settextf("%s   %09d",THEME:GetString("CustomDifficulty",ToEnumShortString(diff)),topscore);
						-- end;
						if pn==PLAYER_1 and topscore ~= 0  then
							self:Load("RollingNumbersSongData");
							self:targetnumber(topscore);
						elseif pn==PLAYER_2 and topscore ~= 0  then
							self:Load("RollingNumbersSongData");
							self:targetnumber(topscore);
						else 
							self:settextf("");
						end;
						
						
					else
						self:settext("");
					end;
				else
					self:settext("");			
				end;
			end;
			
			
		};
		
    Def.ActorFrame{
      InitCommand=function(s) s:x(90) end,
      LoadActor(THEME:GetPathG("StageIn","Spin FullCombo"))..{
        InitCommand=function(s) s:shadowlength(1):zoom(0):draworder(5):x(24):diffusealpha(0.8) end,
		OffCommand=cmd(linear,0.25;diffusealpha,0;);
        SetCommand=function(self)
          local st=GAMESTATE:GetCurrentStyle():GetStepsType();
          local song=GAMESTATE:GetCurrentSong();
          local course = GAMESTATE:GetCurrentCourse();
          if song then
		  	GetDifListX(self,pn,285,0);
			self:y(GetDifListY(diff)+0.5);
            if song:HasStepsTypeAndDifficulty(st,diff) then
              local steps = song:GetOneSteps( st, diff );
              if PROFILEMAN:IsPersistentProfile(pn) then
                profile = PROFILEMAN:GetProfile(pn);
              else
                profile = PROFILEMAN:GetMachineProfile();
              end;
              scorelist = profile:GetHighScoreList(song,steps);
              assert(scorelist);
              local scores = scorelist:GetHighScores();
              assert(scores);
              local topscore;
              if scores[1] then
                topscore = scores[1];
         	assert(topscore);
						local misses = topscore:GetTapNoteScore("TapNoteScore_Miss")+topscore:GetTapNoteScore("TapNoteScore_CheckpointMiss")
												+topscore:GetTapNoteScore("TapNoteScore_HitMine")+topscore:GetHoldNoteScore("HoldNoteScore_LetGo")
						local boos = topscore:GetTapNoteScore("TapNoteScore_W5")
						local goods = topscore:GetTapNoteScore("TapNoteScore_W4")
						local greats = topscore:GetTapNoteScore("TapNoteScore_W3")
						local perfects = topscore:GetTapNoteScore("TapNoteScore_W2")
						local marvelous = topscore:GetTapNoteScore("TapNoteScore_W1")
						local hasUsedLittle = string.find(topscore:GetModifiers(),"Little")
						if (misses+boos) == 0 and scores[1]:GetScore() > 0 and (marvelous+perfects)>0 and (not hasUsedLittle) and topscore:GetGrade()~="Grade_Failed" then
							if (goods+greats+perfects) == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W1"]);
								self:glowblink();
								self:effectperiod(0.20);

							elseif goods+greats == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W2"]);
								--self:glowshift();

							elseif (misses+boos+goods) == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W3"]);
								self:stopeffect();

							elseif (misses+boos) == 0 then
								self:diffuse(GameColor.Judgment["JudgmentLine_W4"]);
								self:stopeffect();

                  end;
                  self:visible(true)
                  self:zoom(0.15);
                else
                  self:visible(false)
                end;
              else
                self:visible(false)
              end;
            else
              self:visible(false)
            end;
          else
            self:visible(false)
          end;
        end
      };
	  };
---Grade
	
			Def.Quad{
			InitCommand=cmd(shadowlengthy,2;zoom,0.30;cropright,0.01;);
			BeginCommand=cmd(playcommand,"Set");
			OffCommand=cmd(linear,0.25;diffusealpha,0;);
			SetCommand=function(self)
				local st=GAMESTATE:GetCurrentStyle():GetStepsType();
				
				local song=nil;
				song=GAMESTATE:GetCurrentSong();
				
				if song then
					GetDifListX(self,pn,208,0);
					--self:y(GetFlexDifListY(diff, st, song));
					self:y(GetDifListY(diff)+1);
					if song:HasStepsTypeAndDifficulty(st,diff) then
						local steps = song:GetOneSteps( st, diff );
						if PROFILEMAN:IsPersistentProfile(pn) then
							-- player profile
							profile = PROFILEMAN:GetProfile(pn);
						else
							-- machine profile
							profile = PROFILEMAN:GetMachineProfile();
						end;
						scorelist = profile:GetHighScoreList(song,steps);
						assert(scorelist);
						local scores = scorelist:GetHighScores();
						assert(scores);
						local topgrade;
						local temp=#scores;
						if scores[1] then
							for i=1,temp do 
								topgrade = scores[1]:GetGrade();
								curgrade = scores[i]:GetGrade();
								assert(topgrade);
								if scores[1]:GetScore()>1  then
									if scores[1]:GetScore()==1000000 and scores[1]:GetGrade() =="Grade_Tier07" then --AutoPlayHack
										self:LoadBackground(THEME:GetPathG("myMusicWheel","Tier01"));
										self:diffusealpha(1);
										break;
									else --Normal
										if ToEnumShortString(curgrade) ~= "Failed" then --current Rank is not Failed
											self:LoadBackground(THEME:GetPathG("myMusicWheel",ToEnumShortString(curgrade)));
											self:diffusealpha(1);
											break;
										else --current Rank is Failed
											if i == temp then
												self:LoadBackground(THEME:GetPathG("myMusicWheel",ToEnumShortString(curgrade)));
												self:diffusealpha(1);
												break;
											end;
										end;
									end;
								else
									self:diffusealpha(0);
								end;
							end;
						else
							self:diffusealpha(0);
						end;
					else
						self:diffusealpha(0);
					end;
				else
					self:diffusealpha(0);
				end;
			end;
		};

			Def.Quad{
				InitCommand=cmd(shadowlengthy,2;zoom,0.30;cropright,0.01;);
				BeginCommand=cmd(playcommand,"Set");
				OffCommand=cmd(linear,0.25;diffusealpha,0;);
				SetCommand=function(self)
					local st=GAMESTATE:GetCurrentStyle():GetStepsType();
					
					local song=nil;
					song=GAMESTATE:GetCurrentSong();
					
					if song then
						GetDifListX(self,pn,208,0);
						--self:y(GetFlexDifListY(diff, st, song));
						self:y(GetDifListY(diff)+1);
						if song:HasStepsTypeAndDifficulty(st,diff) then
							local steps = song:GetOneSteps( st, diff );
							if PROFILEMAN:IsPersistentProfile(pn) then
								-- player profile
								profile = PROFILEMAN:GetProfile(pn);
							else
								-- machine profile
								profile = PROFILEMAN:GetMachineProfile();
							end;
							scorelist = profile:GetHighScoreList(song,steps);
							assert(scorelist);
							local scores = scorelist:GetHighScores();
							assert(scores);
							local topgrade;
							local temp=#scores;
							if scores[1] then
								for i=1,temp do 
									topgrade = scores[1]:GetGrade();
									curgrade = scores[i]:GetGrade();
									assert(topgrade);
									if scores[1]:GetScore()>1  then
										if scores[1]:GetScore()==1000000 and scores[1]:GetGrade() =="Grade_Tier07" then --AutoPlayHack
											self:LoadBackground(THEME:GetPathG("myMusicWheel","Tier01"));
											self:diffusealpha(1);
											break;
										else --Normal
											if ToEnumShortString(curgrade) ~= "Failed" then --current Rank is not Failed
												self:LoadBackground(THEME:GetPathG("myMusicWheel",ToEnumShortString(curgrade)));
												self:diffusealpha(1);
												break;
											else --current Rank is Failed
												if i == temp then
													self:LoadBackground(THEME:GetPathG("myMusicWheel",ToEnumShortString(curgrade)));
													self:diffusealpha(1);
													break;
												end;
											end;
										end;
									else
										self:diffusealpha(0);
									end;
								end;
							else
								self:diffusealpha(0);
							end;
						else
							self:diffusealpha(0);
						end;
					else
						self:diffusealpha(0);
					end;
				end;
			
		};

		
	};
	return t;
end;

--player selection

local function DrawDifListPlayershadowp1(pn,diff)
	local f = Def.ActorFrame {
		InitCommand=cmd(player,pn;x,SCREEN_CENTER_X-10-5;y,SCREEN_TOP+280+nxYOffset;diffuseramp;effectcolor2,Color.White;effectcolor1,color("1,1,1,0.5");effectclock,'beatnooffset');
		LoadActor("p1_shadow") .. {
			InitCommand=cmd(zoom,1);
			OnCommand=cmd(diffusealpha,0;linear,0.05;diffusealpha,1);
			BeginCommand=cmd(playcommand,"Set");
			OffCommand=cmd(linear,0.25;diffusealpha,0;);
			SetCommand=function(self)
				if GAMESTATE:IsHumanPlayer(PLAYER_1) then
				local st=GAMESTATE:GetCurrentStyle():GetStepsType();
				local song=GAMESTATE:GetCurrentSong();
				if song then
					if song:HasStepsTypeAndDifficulty(st,diff) and diff==GAMESTATE:GetCurrentSteps(pn):GetDifficulty() then
						self:diffusealpha(1);
						self:y(GetDifListY(diff));
					else
						self:stopeffect();
						self:diffusealpha(0);
				end
				else
						self:stopeffect();
						self:diffusealpha(0);
				end;
				end

			end;
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
		};
		
		
	}
	return f;
end;

local function DrawDifListPlayershadowp1f(pn,diff)
	local f = Def.ActorFrame {
		InitCommand=cmd(player,pn;y,SCREEN_CENTER_y+400;);
		Def.ActorFrame {

			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
			--CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
		};
			
	}
	return f;
end;

if not GAMESTATE:IsCourseMode() then

t[#t+1] = Def.ActorFrame {
 	InitCommand=cmd(zoom,5.06;x,SCREEN_CENTER_X-290;y,SCREEN_CENTER_Y-75;diffusealpha,0;linear,0.25;diffusealpha,0.5;);
	OffCommand=cmd(linear,0.25;diffusealpha,0;);
	Def.Banner {
		OnCommand=cmd();
		SetCommand=function(self)
		if not GAMESTATE:IsCourseMode() then
		local song = GAMESTATE:GetCurrentSong();
				if song then
					if song:HasJacket() then
						self:diffusealpha(1);
						self:LoadBackground(song:GetJacketPath());
						self:zoomtowidth(130);
						self:zoomtoheight(130);	
						self:croptop(0.274);
						self:cropbottom(0.271);
						self:faderight(0.5);
						self:fadeleft(0.5);
					elseif song:HasBackground() then
						self:diffusealpha(1);
						self:LoadFromCached("background",song:GetBackgroundPath())
						self:zoomtowidth(130);
						self:zoomtoheight(130);	
						self:croptop(0.274);
						self:cropbottom(0.271);
						self:faderight(0.5);
						self:fadeleft(0.5)
					else
						self:Load(THEME:GetPathG("","Common fallback jacket"));
						self:zoomtowidth(130);
						self:zoomtoheight(130);
						self:croptop(0.274);
						self:cropbottom(0.271);
						self:faderight(0.5);
						self:fadeleft(0.5)
					end;
				elseif SCREENMAN:GetTopScreen():GetNextScreenName()=="ScreenStageInformation" 
				and SCREENMAN:GetTopScreen():GetPrevScreenName()~="ScreenSelectMusic" then
						local selgrp =SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection();
						if not GAMESTATE:GetCurrentSong() then
							myLoadGroupJacket(selgrp, self);
							self:zoomtowidth(130);
							self:zoomtoheight(130);	
							self:croptop(0.274);
						self:cropbottom(0.271);
							self:faderight(0.5);
							self:fadeleft(0.5)
							self:stoptweening();
						else
							self:Load(THEME:GetPathG("","Common fallback jacket"));
							self:zoomtowidth(130);
							self:zoomtoheight(130);	
							self:croptop(0.274);
						self:cropbottom(0.271);
							self:faderight(0.5);
							self:fadeleft(0.5)
							self:stoptweening();							
						end;
				else
						self:diffusealpha(1);
						self:Load(THEME:GetPathG("","Common fallback jacket"));
						self:zoomtowidth(130);
						self:zoomtoheight(130);		
						self:croptop(0.274);
						self:cropbottom(0.271);
						self:faderight(0.5);
						self:fadeleft(0.5)						
				end;
		else
			local course = GAMESTATE:GetCurrentCourse();
			if course then
				self:x(SCREEN_CENTER_X+0);
				self:LoadFromCourse(GAMESTATE:GetCurrentCourse());
						self:zoomtowidth(304);
						self:zoomtoheight(304);				
			end;
		end;
		self:stoptweening();
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		};
};

t[#t+1]=LoadActor("songtitlebg")..{
	
	OnCommand=cmd(draworder,-500;x,SCREEN_CENTER_X+100;y,SCREEN_CENTER_Y;zoom,0.667;diffusealpha,0;linear,0.25;diffusealpha,1;x,SCREEN_CENTER_X;);
	};

t[#t+1] = Def.BitmapText {
		Font = "Common Normal",
		InitCommand=cmd(horizalign,left;x,SCREEN_CENTER_X-320;y,SCREEN_CENTER_Y-141;zoom,0.5;shadowlengthy,2;diffusealpha,0.5;),
		OnCommand=function(self)
			self:settext("Song Length:            BPM:")
			end;	
			BeginCommand=cmd(playcommand,"Set");
			OffCommand=cmd(decelerate,0.25;diffusealpha,0;);
			SetCommand=function(self)
				self:diffuse(color("1,1,1,1"));
				self:strokecolor(color("0.1,0.1,0.3,1"));
				myScoreSet = TopRecord(PLAYER_1);
				local temp = myScoreSet["topDate"];
				if (myScoreSet["SongOrCourse"]==1) then
					if (myScoreSet["HasScore"]==1) then
						self:diffusealpha(0.5);
					else
						self:diffusealpha(0.5);
					end
				else
					self:diffusealpha(0);
				end
			end;
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP1ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP2ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentCourseChangedMessageCommand=cmd(queuecommand,"Set");
		};
		
t[#t+1] = StandardDecorationFromFileOptional("ShockArrowDisplayP1","ShockArrowDisplayP1") .. {
	InitCommand = cmd(x,SCREEN_CENTER_X-122+1000;draworder,5;y,SCREEN_CENTER_Y-171;zoom,0.6;);
	OffCommand = cmd(linear,0.25;diffusealpha,0;);
};

t[#t+1] = StandardDecorationFromFileOptional("SongTime","SongTime") .. {
	InitCommand = cmd(x,SCREEN_CENTER_X-240;y,SCREEN_CENTER_Y-141;zoom,0.5;);
	OffCommand = cmd(diffusealpha,0;);
	SetCommand=function(self)
		local curSelection = nil;
		local length = 0.0;
		if GAMESTATE:IsCourseMode() then
			curSelection = GAMESTATE:GetCurrentCourse();
			self:playcommand("Reset");
			if curSelection then
				local trail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber());
				if trail then
					length = TrailUtil.GetTotalSeconds(trail);
				else
					length = 0.0;
				end;
			else
				length = 0.0;
			end;
		else
			curSelection = GAMESTATE:GetCurrentSong();
			self:playcommand("Reset");
			if curSelection then
				length = curSelection:MusicLengthSeconds();
				if curSelection:IsLong() then
					self:playcommand("Long");
				elseif curSelection:IsMarathon() then
					self:playcommand("Marathon");
				else
					self:playcommand("Reset");
				end
			else
				length = 0.0;
				self:playcommand("Reset");
			end;
							myScoreSet = TopRecord(PLAYER_1);
				local temp = myScoreSet["topDate"];
				if (myScoreSet["SongOrCourse"]==1) then
					if (myScoreSet["HasScore"]==1) then
						self:settext( temp);
						self:diffusealpha(1);
					else
						self:diffusealpha(1);
					end
				else
					self:diffusealpha(0);
					end;
		end;
		self:settext( SecondsToMSS(length) );
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
	CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
	CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
	
};


t[#t+1] = StandardDecorationFromFileOptional("BPMDisplay","BPMDisplay")..{
	InitCommand = cmd(x,SCREEN_CENTER_X-170;y,SCREEN_CENTER_Y-141;zoom,0.5;);
	OffCommand = cmd(diffusealpha,0;);
	SetCommand=function(self)
								myScoreSet = TopRecord(PLAYER_1);
				local temp = myScoreSet["topDate"];
				if (myScoreSet["SongOrCourse"]==1) then
					if (myScoreSet["HasScore"]==1) then
						self:diffusealpha(1);
					else
						self:diffusealpha(1);
					end
				else
					self:diffusealpha(0);
					end;
			end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
	CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
	CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
};



t[#t+1] = Def.ActorFrame { --song jacket
 	InitCommand=cmd(zoom,2;x,SCREEN_CENTER_X-470;y,SCREEN_CENTER_Y-73;diffusealpha,1;draworder,1;diffusealpha,0;linear,0.5;diffusealpha,1;);
	OffCommand=cmd(linear,0.25;diffusealpha,0;);
	Def.Banner {
		OnCommand=cmd(ztest,false;);
		SetCommand=function(self)
		if not GAMESTATE:IsCourseMode() then
		local song = GAMESTATE:GetCurrentSong();
				if song then
					if song:HasJacket() then
						self:diffusealpha(1);
						self:LoadBackground(song:GetJacketPath());
						self:zoomtowidth(130);
						self:zoomtoheight(130);					
					elseif song:HasBackground() then
						self:diffusealpha(1);
						self:LoadFromCached("background",song:GetBackgroundPath())
						self:zoomtowidth(130);
						self:zoomtoheight(130);							
					else
						self:Load(THEME:GetPathG("","Common fallback jacket"));
						self:zoomtowidth(130);
						self:zoomtoheight(130);							
					end;
				elseif SCREENMAN:GetTopScreen():GetNextScreenName()=="ScreenStageInformation" 
				and SCREENMAN:GetTopScreen():GetPrevScreenName()~="ScreenSelectMusic" then
						local selgrp =SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection();
						if not GAMESTATE:GetCurrentSong() then
							myLoadGroupJacket(selgrp, self);
							self:zoomtowidth(130);
							self:zoomtoheight(130);	
							self:stoptweening();
						else
							self:Load(THEME:GetPathG("","Common fallback jacket"));
							self:zoomtowidth(130);
							self:zoomtoheight(130);	
							self:stoptweening();							
						end;
				else
						self:diffusealpha(1);
						self:Load(THEME:GetPathG("","Common fallback jacket"));
						self:zoomtowidth(130);
						self:zoomtoheight(130);							
				end;
		else
			local course = GAMESTATE:GetCurrentCourse();
			if course then
				self:x(SCREEN_CENTER_X+0);
				self:LoadFromCourse(GAMESTATE:GetCurrentCourse());
						self:zoomtowidth(304);
						self:zoomtoheight(304);				
			end;
		end;
		self:stoptweening();
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		};
};


t[#t+1]=DrawDifListPlayershadowp1(PLAYER_1,'Difficulty_Beginner');
t[#t+1]=DrawDifListPlayershadowp1(PLAYER_1,'Difficulty_Easy');
t[#t+1]=DrawDifListPlayershadowp1(PLAYER_1,'Difficulty_Medium');
t[#t+1]=DrawDifListPlayershadowp1(PLAYER_1,'Difficulty_Hard');
t[#t+1]=DrawDifListPlayershadowp1(PLAYER_1,'Difficulty_Challenge');
t[#t+1]=DrawDifListPlayershadowp1(PLAYER_1,'Difficulty_Edit');


--Default Difficulty List
t[#t+1] = LoadActor("DefaultDifficulty.lua")..{
	InitCommand=cmd(x,SCREEN_CENTER_X-165-5;y,SCREEN_CENTER_Y-115;zoom,1.5);
	OnCommand=cmd(diffusealpha,0;linear,0.05;diffusealpha,1);
	OffCommand=cmd(linear,0.25;diffusealpha,0;);

};

	
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
t[#t+1]=DrawDifList(PLAYER_1,'Difficulty_Beginner');
t[#t+1]=DrawDifList(PLAYER_1,'Difficulty_Easy');
t[#t+1]=DrawDifList(PLAYER_1,'Difficulty_Medium');
t[#t+1]=DrawDifList(PLAYER_1,'Difficulty_Hard');
t[#t+1]=DrawDifList(PLAYER_1,'Difficulty_Challenge');
t[#t+1]=DrawDifList(PLAYER_1,'Difficulty_Edit');
end;

end;

-- Song Title
t[#t+1] = LoadFont("_@fot-newrodin pro db 30px")..{
	InitCommand=cmd(horizalign,left;x,SCREEN_CENTER_X-355+40-6;shadowlengthy,3;y,SCREEN_CENTER_Y+12-195-7;draworder,2;zoom,0.8;diffusealpha,0;linear,0.5;diffusealpha,1;);
	OnCommand=cmd(playcommand,"CurrentSongChangedMessage");
	OffCommand=cmd(linear,0.25;diffusealpha,0;);
	CurrentSongChangedMessageCommand=function(self)
	local song = GAMESTATE:GetCurrentSong();
	local course = GAMESTATE:GetCurrentCourse();
		if song or course then
			local tit="";
			if GAMESTATE:IsCourseMode() then
				song=GAMESTATE:GetCurrentCourse();
				tit=song:GetDisplayFullTitle();
			else
				song=GAMESTATE:GetCurrentSong();
				tit=song:GetDisplayMainTitle();
			end;
			self:diffusealpha(1);
			self:maxwidth(420);
			self:settext(tit);
		else
			self:diffusealpha(0);
		end;
	end;
};
--artist--
t[#t+1] = LoadFont("_@fot-newrodin pro db 30px")..{
	InitCommand=cmd(horizalign,left;shadowlengthy,2.5;x,SCREEN_CENTER_X-355+40-6;y,SCREEN_CENTER_Y+45-195-12.5;zoom,0.6;draworder,2;diffusealpha,0;linear,0.5;diffusealpha,0.5;);
	OffCommand=cmd(linear,0.25;diffusealpha,0;);
	CurrentSongChangedMessageCommand=function(self)
	local song = GAMESTATE:GetCurrentSong();
	local course = GAMESTATE:GetCurrentCourse();
		if song or course then
			local tit="";
			if GAMESTATE:IsCourseMode() then
				song=GAMESTATE:GetCurrentCourse();
				tit=song:GetDisplayFullTitle();
				
			else
				song=GAMESTATE:GetCurrentSong();
				tit=song:GetDisplayArtist();
			end;
			self:diffusealpha(0.5);
			self:maxwidth(550);
			self:settext(tit);
		else
			self:diffusealpha(0);
		end;
	end;
};--]]

if not GAMESTATE:IsEventMode() then

	-- long/marathon version bubble graphic and text
	af[#af+1] = Def.ActorFrame{
		InitCommand=function(self)
			self:x( IsUsingWideScreen() and 98 or 92 )
			self:y(-12)
		end,
		SetCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			self:visible( song and (song:IsLong() or song:IsMarathon()) or false )
		end,


		Def.ActorMultiVertex{
			InitCommand=function(self)
				-- these coordinates aren't neat and tidy, but they do create three triangles
				-- that fit together to approximate hurtpiggypig's original png asset
				local verts = {
					--   x   y  z    r,g,b,a
					{{-113, -15, 0}, {1,1,1,1}},
					{{ 113, -15, 0}, {1,1,1,1}},
					{{ 113, 16, 0}, {1,1,1,1}},

					{{ 113, 16, 0}, {1,1,1,1}},
					{{-113, 16, 0}, {1,1,1,1}},
					{{-113, -15, 0}, {1,1,1,1}},

					{{ -98, 16, 0}, {1,1,1,1}},
					{{ -78, 16, 0}, {1,1,1,1}},
					{{ -88, 29, 0}, {1,1,1,1}},
				}
				self:SetDrawState({Mode="DrawMode_Triangles"}):SetVertices(verts)
				self:diffuse(GetCurrentColor())
				self:xy(0,0):zoom(0.5)
			end
		},

		LoadFont("Common Normal")..{
			InitCommand=function(self) self:diffuse(Color.Black):zoom(0.8) end,
			SetCommand=function(self)
				local song = GAMESTATE:GetCurrentSong()
				if not song then self:settext(""); return end

				if song:IsMarathon() then
					self:settext(THEME:GetString("SongDescription", "IsMarathon"))
				elseif song:IsLong() then
					self:settext(THEME:GetString("SongDescription", "IsLong"))
				else
					self:settext("")
				end
			end
		}
	}
end

-- elements we need two of (one for each player) that draw underneath the StepsDisplayList
-- this includes the stepartist boxes, the density graph, and the cursors.
t[#t+1] = LoadActor("../PerPlayer/default.lua");

af[#af+1] = t;

return af
