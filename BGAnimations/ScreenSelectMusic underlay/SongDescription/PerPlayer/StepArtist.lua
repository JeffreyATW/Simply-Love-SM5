local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local text_table, marquee_index

-- EX score is a number like 92.67
local GetPointsForSong = function(maxPoints, exScore)
	local thresholdEx = 50.0
	local percentPoints = 40.0

	-- Helper function to take the logarithm with a specific base.
	local logn = function(x, y)
		return math.log(x) / math.log(y)
	end

	-- The first half (logarithmic portion) of the scoring curve.
	local first = logn(
		math.min(exScore, thresholdEx) + 1,
		math.pow(thresholdEx + 1, 1 / percentPoints)
	)

	-- The seconf half (exponential portion) of the scoring curve.
	local second = math.pow(
		100 - percentPoints + 1,
		math.max(0, exScore - thresholdEx) / (100 - thresholdEx)
	) - 1

	-- Helper function to round to a specific number of decimal places.
	-- We want 100% EX to actually grant 100% of the points.
	-- We don't want to  lose out on any single points if possible. E.g. If
	-- 100% EX returns a number like 0.9999999999999997 and the chart points is
	-- 6500, then 6500 * 0.9999999999999997 = 6499.99999999999805, where
	-- flooring would give us 6499 which is wrong.
	local roundPlaces = function(x, places)
		local factor = 10 ^ places
		return math.floor(x * factor + 0.5) / factor
	end

	local percent = roundPlaces((first + second) / 100.0, 6)
	return math.floor(maxPoints * percent)
end

local nxXOffset = -267;
local nxYOffset = 71;

local p2XOffset = 335;

local textZoom = 0.6;

local stepsText = GAMESTATE:IsCourseMode() and Screen.String("SongNumber"):format(1) or Screen.String("STEPS")

return Def.ActorFrame{
	Name="StepArtistAF_" .. pn,

	-- song and course changes
	OnCommand=function(self) self:queuecommand("Reset") end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:queuecommand("Reset") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Reset") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Reset") end,

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- Simply Love doesn't support player unjoining (that I'm aware of!) but this
	-- animation is left here as a reminder to a future me to maybe look into it.
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:ease(0.5, 275):addy(30):diffusealpha(0)
		end
	end,

	-- depending on the value of pn, this will either become
	-- an AppearP1Command or an AppearP2Command when the screen initializes
	["Appear"..pn.."Command"]=function(self) self:visible(true):ease(0.5, 275):addy(30) end,

	InitCommand=function(self)
		self:visible( false ):halign( p )

		if player == PLAYER_1 then

			if GAMESTATE:IsCourseMode() then
				self:x( _screen.cx - (IsUsingWideScreen() and 356 or 346))
				self:y(_screen.cy + nxYOffset + 32)
			else
				self:x( _screen.cx - (IsUsingWideScreen() and 356 or 346))
				self:y(_screen.cy + nxYOffset + 12)
			end

		elseif player == PLAYER_2 then

			if GAMESTATE:IsCourseMode() then
				self:x( _screen.cx - 210 + p2XOffset)
				self:y(_screen.cy + nxYOffset + 32)
			else
				self:x( _screen.cx - 244 + p2XOffset)
				self:y(_screen.cy + nxYOffset + 12)
			end
		end

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	--STEPS label
	LoadFont("_@fot-newrodin pro db 20px")..{
		Text=stepsText,
		InitCommand=function(self)
			self:diffuse(0,0,0,1):horizalign(left):x(30+nxXOffset):zoom(textZoom);
			self:settext("")
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			self:settext( THEME:GetString("ScreenSelectCourse", "SongNumber"):format(params.index) )
		end,
		ResetCommand=function(self)
			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if SongOrCourse and StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
				self:settext(stepsText);
			else
				self:diffuse( PlayerColor(player) )
				self:settext("")
			end
		end
	},

	--stepartist text
	LoadFont("_@fot-newrodin pro db 20px")..{
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):horizalign(left):zoom(textZoom)

			if GAMESTATE:IsCourseMode() then
				self:x(62+nxXOffset):maxwidth(196)
			else
				self:x(77+nxXOffset):maxwidth(182):diffuse(color("#000000"))
			end
		end,
		ResetCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			-- always stop tweening when steps change in case a MarqueeCommand is queued
			self:stoptweening()

			if SongOrCourse and StepsOrTrail then

				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )

				text_table = GetStepsCredit(player)
				marquee_index = 0

				-- don't queue a Marquee in CourseMode
				-- each TrailEntry text change will be broadcast from CourseContentsList.lua
				-- to ensure it stays synced with the scrolling list of songs
				if not GAMESTATE:IsCourseMode() then
					-- only queue a Marquee if there are things in the text_table to display
					self:x(70):diffuse(color("#000000"))
					if #GAMESTATE:GetHumanPlayers() == 1 then 
						self:maxwidth(175)
					else
						self:maxwidth(160)
					end

					if #text_table > 0 then
						if #GAMESTATE:GetHumanPlayers() > 1 then self:queuecommand("Marquee") end
						local fulldesc = ""
						for i=1,#text_table do
							local curText = text_table[i]
							fulldesc = fulldesc .. curText .. "\n"
						end
						self:vertalign("VertAlign_Top"):settext(fulldesc):y(-6)
					else
						-- no credit information was specified in the simfile for this stepchart, so just set to an empty string
						self:settext("")
					end
				end
			else
				-- there wasn't a song/course or a steps object, so the MusicWheel is probably hovering
				-- on a group title, which means we want to set the stepartist text to an empty string for now
				self:settext("")
			end
		end,
		ITLCommand=function(self)
			if #GAMESTATE:GetHumanPlayers() == 1 then
				local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
				local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

				-- always stop tweening when steps change in case a MarqueeCommand is queued
				self:stoptweening()

				if SongOrCourse and StepsOrTrail then

					text_table = GetStepsCredit(player)
					marquee_index = 0

					-- don't queue a Marquee in CourseMode
					-- each TrailEntry text change will be broadcast from CourseContentsList.lua
					-- to ensure it stays synced with the scrolling list of songs
					if not GAMESTATE:IsCourseMode() then
						-- only queue a Marquee if there are things in the text_table to display
						if #text_table > 0 then
							-- self:queuecommand("Marquee")
							local fulldesc = ""
							for i=1,#text_table do
								local curText = text_table[i]
								if string.sub(curText, string.len(curText) - 3, string.len(curText)) == " pts" then
									local max_points = string.sub(curText, 1, string.len(curText) - 4)
									local exscore = tonumber(SL[pn].itlScore)/100
									local max_point_multiplier = 0
									if exscore then
										local points = GetPointsForSong(max_points, exscore)
										local pointsPercent = string.format("%.2f%%", points / max_points * 100)
										curText = points .. "/" .. curText .. " ("..pointsPercent..")"
									end
								end
								fulldesc = fulldesc .. curText .. "\n"
							end
							self:vertalign("VertAlign_Top"):settext(fulldesc):y(-6)
						else
							-- no credit information was specified in the simfile for this stepchart, so just set to an empty string
							self:settext("")
						end
					end
				else
					-- there wasn't a song/course or a steps object, so the MusicWheel is probably hovering
					-- on a group title, which means we want to set the stepartist text to an empty string for now
					self:settext("")
				end
			end
		end,
		MarqueeCommand=function(self)
			-- increment the marquee_index, and keep it in bounds
			marquee_index = (marquee_index % #text_table) + 1
			-- retrieve the text we want to display
			local text = text_table[marquee_index]

			-- set this BitmapText actor to display that text
			self:settext( text )

			-- check for emojis; they shouldn't be diffused to Color.Black
			DiffuseEmojis(self, text)

			if not GAMESTATE:IsCourseMode() then
				-- sleep 2 seconds before queueing the next Marquee command to do this again
				if #text_table > 1 then
					self:sleep(2):queuecommand("Marquee")
				end
			else
				self:sleep(0.5):queuecommand("m")
			end
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			if text_table then
				self:settext( text_table[params.index] or "" )
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
}