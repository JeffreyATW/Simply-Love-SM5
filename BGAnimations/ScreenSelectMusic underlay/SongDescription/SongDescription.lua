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
		self:x(SCREEN_CENTER_X-offset+275);
		if fade>0 then
			self:faderight(fade);
		end;
	else
		--self:horizalign(right);
		self:x(SCREEN_CENTER_X-offset+310);
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
		
---Grade
	
			Def.ActorFrame{
			InitCommand=cmd(shadowlengthy,2;zoom,0.13;cropright,0.01;);
			BeginCommand=cmd(playcommand,"Set");
			OffCommand=cmd(linear,0.25;diffusealpha,0;);
			SetCommand=function(self)
				self:player(pn);
				local st=GAMESTATE:GetCurrentStyle():GetStepsType();
				
				local song=nil;
				song=GAMESTATE:GetCurrentSong();
				
				if song and GAMESTATE:IsPlayerEnabled(pn) then
					GetDifListX(self,pn,235,0);
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
										self:RemoveAllChildren();
										self:AddChildFromPath(THEME:GetPathG("myMusicWheel","Tier01"));
										self:diffusealpha(1);
										break;
									else --Normal
										if ToEnumShortString(curgrade) ~= "Failed" then --current Rank is not Failed
											self:RemoveAllChildren();
											self:AddChildFromPath(THEME:GetPathG("myMusicWheel",ToEnumShortString(curgrade)));
											self:diffusealpha(1);
											break;
										else --current Rank is Failed
											if i == temp then
												self:RemoveAllChildren();
												self:AddChildFromPath(THEME:GetPathG("myMusicWheel",ToEnumShortString(curgrade)));
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
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP1ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP2ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
		};		
	};
	return t;
end;

--player selection

local function DrawDifListPlayershadowp1(pn,diff)
	
	local f = Def.ActorFrame {
		InitCommand=cmd(x,SCREEN_CENTER_X-207;y,SCREEN_TOP+281+nxYOffset;diffuseramp;effectcolor2,Color.White;effectcolor1,color("1,1,1,0.5");effectclock,'beatnooffset');
		LoadActor("p1_shadow") .. {
			InitCommand=function(self)
				self:zoom(1):y(GetDifListY(diff));
				if (pn == PLAYER_2) then
					self:rotationy(180);
					self:x(115);
				end
			end;
			OnCommand=cmd(diffusealpha,0;linear,0.05;diffusealpha,1);
			BeginCommand=cmd(playcommand,"Set");
			OffCommand=cmd(linear,0.25;diffusealpha,0;);
			SetCommand=function(self)
				if GAMESTATE:IsHumanPlayer(pn) then
					local st=GAMESTATE:GetCurrentStyle():GetStepsType();
					local song=GAMESTATE:GetCurrentSong();
					if song then
						local currentSteps = GAMESTATE:GetCurrentSteps(pn)
						if currentSteps and song:HasStepsTypeAndDifficulty(st,diff) and diff==currentSteps:GetDifficulty() then
							self:diffusealpha(1);
						else
							self:stopeffect();
							self:diffusealpha(0);
						end
					else
							self:stopeffect();
							self:diffusealpha(0);
					end;
				else
					self:stopeffect();
					self:diffusealpha(0);	
				end;
			end;
			CurrentSongChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
			CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set");
			CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
			CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set");
		};
	}
	return f;
end;

local jacketSize = 130

local t = Def.ActorFrame {};

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
					elseif song:HasBackground() then
						self:diffusealpha(1);
						self:LoadFromCached("background",song:GetBackgroundPath())
					elseif song:HasBanner() then
						self:diffusealpha(1);
						self:LoadFromCached("banner",song:GetBannerPath())
					else
						self:Load(THEME:GetPathG("","Common fallback jacket"));
					end;
				else
					self:diffusealpha(1);
					section = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection();
					local bannerPath = SONGMAN:GetSongGroupBannerPath(section)
					if bannerPath ~= "" then
						self:LoadFromCached("banner",bannerPath)
					else
						self:Load(THEME:GetPathG("","Common fallback jacket"));					
					end
				end;
				self:scaletocover(0, 0, jacketSize, jacketSize);
				local zoomedWidth = self:GetWidth() * self:GetZoom();
				local sideCrop = ((zoomedWidth - jacketSize) / zoomedWidth) / 2;

				self:cropright(sideCrop);
				self:cropleft(sideCrop);
				self:scaletofit(zoomedWidth / -2, -jacketSize / 2, zoomedWidth / 2, jacketSize / 2);
				self:croptop(0.274);
				self:cropbottom(0.271);
				self:faderight(0.5);
				self:fadeleft(0.5)	
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
		Font = "_@fot-newrodin pro db 20px",
		InitCommand=cmd(horizalign,left;x,SCREEN_CENTER_X-320;y,SCREEN_CENTER_Y-141;zoom,0.5;shadowlengthy,2;diffusealpha,0.5;),
		OnCommand=function(self)
			self:settext("Song Length:            BPM:                                     P1      P2")
		end;
		BeginCommand=cmd(playcommand,"Set");
		OffCommand=cmd(decelerate,0.25;diffusealpha,0;);
		SetCommand=function(self)
			self:diffuse(color("1,1,1,1"));
			self:strokecolor(color("0.1,0.1,0.3,1"));
			local pn = (GAMESTATE:GetNumSidesJoined() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)) and PLAYER_2 or PLAYER_1
			myScoreSet = TopRecord(pn);
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
			local pn = (GAMESTATE:GetNumSidesJoined() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)) and PLAYER_2 or PLAYER_1
				myScoreSet = TopRecord(pn);
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
		local pn = (GAMESTATE:GetNumSidesJoined() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)) and PLAYER_2 or PLAYER_1
								myScoreSet = TopRecord(pn);
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

local function OnlyHasBanner(song)
	return song ~= nil and song:HasBanner() and not song:HasJacket() and not song:HasBackground()
end

local JacketInitCommand=cmd(zoom,2;x,SCREEN_CENTER_X-470;y,SCREEN_CENTER_Y-73;diffusealpha,1;draworder,1;diffusealpha,0;linear,0.5;diffusealpha,1;);
local JacketOffCommand=cmd(linear,0.25;diffusealpha,0;);
local JacketBannerOnCommand=cmd(ztest,false;);

local blurFactor = 12;

local function ScaleToCrop(jacket)
	jacket:scaletocover(0, 0, jacketSize, jacketSize);
	local zoomedWidth = jacket:GetWidth() * jacket:GetZoom();
	local sideCrop = ((zoomedWidth - jacketSize) / zoomedWidth) / 2;

	jacket:cropright(sideCrop);
	jacket:cropleft(sideCrop);
	return zoomedWidth;
end

t[#t+1] = Def.ActorFrame { --song banner background
	InitCommand=JacketInitCommand;
	OffCommand=JacketOffCommand;
		
	Def.ActorFrameTexture{
		InitCommand=function(self)
			self:SetTextureName( "ScreenTex" )
			self:SetWidth(jacketSize);
			self:SetHeight(jacketSize);
			self:Create();
		end;
		Def.Banner {
			Name="BannerBG";
			OnCommand=JacketBannerOnCommand;
			SetCommand=function(self)
				local hasBanner = false
				if not GAMESTATE:IsCourseMode() then
					local song = GAMESTATE:GetCurrentSong()
					if OnlyHasBanner(song) then
						hasBanner = true
						ScaleToCrop(self)
						self:LoadFromCached("banner",song:GetBannerPath())
					else
						section = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection();
						local bannerPath = SONGMAN:GetSongGroupBannerPath(section)
						if bannerPath ~= "" then
							hasBanner = true
							ScaleToCrop(self)
							self:LoadFromCached("banner",bannerPath)
						end
					end
				end
				self:diffusealpha(hasBanner and 1 or 0);
				self:stoptweening();
			end;
			CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		};
	},
	Def.ActorFrameTexture{
		InitCommand=function(self)
			self:SetTextureName( "ScreenPixel" )
			self:SetWidth(jacketSize/blurFactor);
			self:SetHeight(jacketSize/blurFactor);
			self:Create();
		end;
		Def.Sprite{
			Texture = "ScreenTex";
			OnCommand = function(self)
				self:y((jacketSize / blurFactor) / 2)
				self:x((jacketSize / blurFactor) / 2 +.5)
				self:zoom(1/blurFactor)
			end,
		}
	},
	
	Def.Sprite{
		Texture = "ScreenPixel";
		OnCommand = function(self)
			self:SetHeight(jacketSize / blurFactor)
			self:SetWidth(jacketSize / blurFactor)
			self:zoom(blurFactor)
		end,
	};
	Def.Quad {
		InitCommand=function(self)
			self:diffuse(Color.Black);
			self:scaletocover(-jacketSize / 2, -jacketSize / 2, jacketSize / 2, jacketSize / 2);
		end;
		OnCommand=JacketBannerOnCommand;
		SetCommand=function(self)
			local hasBanner = false
			if not GAMESTATE:IsCourseMode() then
				local song = GAMESTATE:GetCurrentSong()
				if OnlyHasBanner(song) then
					hasBanner = true
				else
					section = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection();
					local bannerPath = SONGMAN:GetSongGroupBannerPath(section)
					if bannerPath ~= "" then
						hasBanner = true
					end
				end
			end
			self:diffusealpha(hasBanner and 0.667 or 0);
			self:stoptweening();
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	};
};

t[#t+1] = Def.ActorFrame { --song jacket
 	InitCommand=JacketInitCommand;
	OffCommand=JacketOffCommand;
	Def.Banner {
		OnCommand=JacketBannerOnCommand;
		SetCommand=function(self)
			if not GAMESTATE:IsCourseMode() then
				local song = GAMESTATE:GetCurrentSong();
				local bannerOnly = false;
				if song then
					if song:HasJacket() then
						self:diffusealpha(1);
						self:LoadBackground(song:GetJacketPath());
					elseif song:HasBackground() then
						self:diffusealpha(1);
						self:LoadFromCached("background",song:GetBackgroundPath())
					elseif OnlyHasBanner(song) then
						bannerOnly = true;
						self:LoadFromCached("banner",song:GetBannerPath())
					else
						self:diffusealpha(1);
						self:Load(THEME:GetPathG("","Common fallback jacket"));
					end;
				else
					self:diffusealpha(1);
					local section = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection();
					local bannerPath = SONGMAN:GetSongGroupBannerPath(section)
					if bannerPath ~= "" then
						bannerOnly = true
						self:LoadFromCached("banner",bannerPath);
					else
						self:Load(THEME:GetPathG("","Common fallback jacket"));
					end
				end;
				if bannerOnly then
					self:cropleft(0):cropright(0);
					self:scaletofit(-65, -65, 65, 65);
				else
					local zoomedWidth = ScaleToCrop(self)
					self:scaletofit(zoomedWidth / -2, -65, zoomedWidth / 2, 65);
				end
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

--Default Difficulty List
t[#t+1] = LoadActor("DefaultDifficulty.lua")..{
	InitCommand=cmd(x,SCREEN_CENTER_X-165-5;y,SCREEN_CENTER_Y-115;zoom,1.5);
	OnCommand=cmd(diffusealpha,0;linear,0.05;diffusealpha,1);
	OffCommand=cmd(linear,0.25;diffusealpha,0;);

};

for _, pn in ipairs({ PLAYER_1, PLAYER_2 }) do
	for __, diff in ipairs({ 'Beginner', 'Easy', 'Medium', 'Hard', 'Challenge', 'Edit'}) do
		t[#t+1]=DrawDifListPlayershadowp1(pn,'Difficulty_' .. diff);
		t[#t+1]=DrawDifList(pn,'Difficulty_' .. diff);
	end;
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
t[#t+1] = LoadActor("./PerPlayer/default.lua");

af[#af+1] = Def.ActorFrame {
	InitCommand=cmd(zoom,.73;addy,-140;draworder,-5;wag;effectmagnitude,-1,-1,-0.5;effecttiming,7,0,7,0;addx,-490;fov,90;rotationy,-5;diffusealpha,0;addz,100;);
	OnCommand=cmd(decelerate,0.8;addx,400;diffusealpha,1;addz,-100;bob;effectmagnitude,0,4,0;effecttiming,4,0,4,0;);
	OffCommand=cmd(decelerate,0.5;addx,-400;diffusealpha,0;addz,100;);
	t;
};

return af
