-- Currently the Density Graph in SSM doesn't work for Courses.
-- Disable the functionality.
if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)

-- Height and width of the density graph.
local height = 56
local width = IsUsingWideScreen() and 283 or 273

local nxXOffset = -264
local nxYOffset = 131

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		self:xy(_screen.cx-182+nxXOffset, _screen.cy+23+nxYOffset)

		if player == PLAYER_2 then
			self:addx(width+36)
		end

		if IsUsingWideScreen() then
			self:addx(-5)
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(true)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(false)
		end
	end,
	PlayerProfileSetMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Redraw")
		end
	end,
	CodeMessageCommand=function(self, params)
		-- Toggle between the density graph and the pattern info
		if params.Name == "TogglePatternInfo" and params.PlayerNumber == player then
			-- Only need to toggle in versus since in single player modes, both
			-- panes are already displayed.
			if GAMESTATE:GetNumSidesJoined() == 2 then
				self:queuecommand("TogglePatternInfo")
			end
		end
	end,
}


af[#af+1] = Def.ActorFrame{
	Name="ChartParser",
	-- Hide when scrolling through the wheel. This also handles the case of
	-- going from song -> folder. It will get unhidden after a chart is parsed
	-- below.
	CurrentSongChangedMessageCommand=function(self)
		self:queuecommand("Hide")
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		self:queuecommand("Hide")
		self:stoptweening()
		self:sleep(0.4)
		self:queuecommand("ParseChart")
	end,
	ParseChartCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			MESSAGEMAN:Broadcast(pn.."ChartParsing")
			ParseChartInfo(steps, pn)
			self:queuecommand("Show")
		end
	end,
	ShowCommand=function(self)
		if GAMESTATE:GetCurrentSong() and
				GAMESTATE:GetCurrentSteps(player) then
			MESSAGEMAN:Broadcast(pn.."ChartParsed")
			self:queuecommand("Redraw")
		else
			self:queuecommand("Hide")
		end
	end
}

local af2 = af[#af]

-- The Density Graph itself. It already has a "RedrawCommand".
af2[#af2+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:addx(-width/2):addy(height/2)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(true)
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end
}
-- Don't let the density graph parse the chart.
-- We do this in parent actorframe because we want to "stall" before we parse.
af2[#af2]["CurrentSteps"..pn.."ChangedMessageCommand"] = nil

local nxPeakXOffset = -10
local textZoom = 0.6;

-- The Peak NPS text
af2[#af2+1] = LoadFont("_@fot-newrodin pro db 20px")..{
	Name="NPS",
	Text="Peak NPS: ",
	InitCommand=function(self)
		self:horizalign(left):zoom(textZoom)
		if player == PLAYER_1 then
			self:addx(40+nxPeakXOffset):addy(-41)
		else
			self:addx(-131+nxPeakXOffset):addy(-41)
		end
		-- We want black text in Rainbow mode except during HolidayCheer(), white otherwise.
		self:diffuse((ThemePrefs.Get("RainbowMode") and not HolidayCheer()) and {0, 0, 0, 1} or {1, 1, 1, 1})
	end,
	HideCommand=function(self)
		self:settext("Peak NPS: ")
		self:visible(false)
	end,
	RedrawCommand=function(self)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS * SL.Global.ActiveModifiers.MusicRate))
			self:visible(true)
		end
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end
}

-- Breakdown
af2[#af2+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
		self:addy(height/2 - actorHeight/2)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(true)
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end,
	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 20
			self:diffuse(color("#000000")):zoomto(width, bgHeight):diffusealpha(0.5):addy(-1.5)
		end
	},

	LoadFont("_@fot-newrodin pro db 20px")..{
		Text="",
		Name="BreakdownText",
		InitCommand=function(self)
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		HideCommand=function(self)
			self:settext("")
		end,
		RedrawCommand=function(self)
			self:settext(GenerateBreakdownText(pn, 0))
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
				self:settext(GenerateBreakdownText(pn, minimization_level))
				minimization_level = minimization_level + 1
			end
		end,
	}
}

local patternInfoY = -20

af2[#af2+1] = Def.ActorFrame{
	Name="PatternInfo",
	InitCommand=function(self)
		self:x(width+16);
		self:y(patternInfoY);
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(patternInfoY)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(patternInfoY)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end
}

local af3 = af2[#af2]

local layout = {
	{"Crossovers", "Footswitches"},
	{"Sideswitches", "Jacks"},
	{"Brackets", "Total Stream"},
}

local colSpacing = 150
local rowSpacing = 24

local textZoom = 0.6;

for i, row in ipairs(layout) do
	for j, col in pairs(row) do
		af3[#af3+1] = LoadFont("_@fot-newrodin pro db 20px")..{
			Text=col ~= "Total Stream" and "0" or "None (0.0%)",
			Name=col .. "Value",
			InitCommand=function(self)
				local textHeight = 17
				self:zoom(textZoom):horizalign(right)
				if col == "Total Stream" then
					self:maxwidth(100)
				end
				self:xy(-width/2 + 40, -height/2 + 13)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
			end,
			HideCommand=function(self)
				if col ~= "Total Stream" then
					self:settext("0")
				else
					self:settext("None (0.0%)")
				end
			end,
			RedrawCommand=function(self)
				if col ~= "Total Stream" then
					self:settext(SL[pn].Streams[col])
				else
					local streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(pn)
					local totalMeasures = streamMeasures + breakMeasures
					if streamMeasures == 0 then
						self:settext("None (0.0%)")
					else
						self:settext(string.format("%d/%d (%0.1f%%)", streamMeasures, totalMeasures, streamMeasures/totalMeasures*100))
					end
				end
			end
		}

		af3[#af3+1] = LoadFont("_@fot-newrodin pro db 20px")..{
			Text=col,
			Name=col,
			InitCommand=function(self)
				local textHeight = 17
				self:maxwidth(width/textZoom):zoom(textZoom):horizalign(left)
				self:xy(-width/2 + 50, -height/2 + 13)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
			end,
		}

	end
end

return af
