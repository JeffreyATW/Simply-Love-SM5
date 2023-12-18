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

local marquee_index
local text_table = {}
local leaving_screen = false

local x = _screen.cx-182+nxXOffset

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(x, _screen.cy+23+nxYOffset)
		self:visible( GAMESTATE:IsHumanPlayer(player) )

		self:queuecommand("Shift");
	end,
	ShiftCommand=function(self, params)
		local myX = x
		if GAMESTATE:GetNumSidesJoined() == 2 and player == PLAYER_2 then
			myX = x + width + 36
		end

		if IsUsingWideScreen() then
			myX = myX - 5
		end

		self:x(myX)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(true)
		end

		self:queuecommand("Shift");
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

local nxPeakXOffset = 100
local textZoom = 0.6;

-- The Peak NPS text
af2[#af2+1] = LoadFont("_@fot-newrodin pro db 20px")..{
	Name="NPS",
	Text="",
	InitCommand=function(self)
		self:horizalign(left):zoom(textZoom)
		self:playcommand("Shift")
		-- We want black text in Rainbow mode except during HolidayCheer(), white otherwise.
		self:diffuse((ThemePrefs.Get("RainbowMode") and not HolidayCheer()) and {0, 0, 0, 1} or {1, 1, 1, 1})
	end,
	ShiftCommand=function(self)
		if GAMESTATE:GetNumSidesJoined() == 2 and player == PLAYER_2 then
			self:x(-241+nxPeakXOffset):y(-41)
		else
			self:x(40+nxPeakXOffset):y(-41)
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		self:queuecommand("Shift");
	end,
	HideCommand=function(self)
		self:settext("Peak NPS: ")
		self:visible(false)
	end,
	RedrawCommand=function(self)
		if leaving_screen then return end
		if SL[pn].Streams.PeakNPS ~= 0 then
			local nps = SL[pn].Streams.PeakNPS * SL.Global.ActiveModifiers.MusicRate
				self:horizalign(((GAMESTATE:GetNumSidesJoined() == 2 and player == PLAYER_2) and left or right))
				marquee_index = 0
				text_table = {}
				table.insert(text_table,("Peak NPS: %.1f"):format(nps))
				table.insert(text_table,("Peak eBPM: %.1f"):format(nps*15))
				self:finishtweening():playcommand("Marquee",{text_table=text_table})
			self:visible(true)
		end
	end,
	MarqueeCommand=function(self)
		marquee_index = (marquee_index % #text_table) + 1
			self:settext(text_table[marquee_index])
			self:sleep(2):queuecommand("Marquee")
	end,
	OffCommand=function(self)
		leaving_screen = true
		self:stoptweening()
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
			local textHeight = 17
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		HideCommand=function(self)
			self:settext("")
		end,
		RedrawCommand=function(self)
			if leaving_screen then return end
			breakdown_table = {}
			marquee_index = 0
			self:settext(GenerateBreakdownText(pn, 0))
			breakdown_table[1] = GenerateBreakdownText(pn, 0)
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom*(1+minimization_level*0.1)) and minimization_level < 4 do
				if self:GetWidth() < (width/textZoom*(1.7)) then
					breakdown_table[2] = GenerateBreakdownText(pn, minimization_level-1)
				end
				self:settext(GenerateBreakdownText(pn, minimization_level))
				breakdown_table[1] = GenerateBreakdownText(pn, minimization_level)
				minimization_level = minimization_level + 1
			end
			self:finishtweening():playcommand("Marquee",{breakdown_table=breakdown_table})
		end,
		MarqueeCommand=function(self)
			marquee_index = (marquee_index % #breakdown_table) + 1
			self:settext(breakdown_table[marquee_index])
			self:sleep(5):queuecommand("Marquee")
		end,
		OffCommand=function(self)
			self:stoptweening()
		end,
	}
}

local patternInfoY = -18

af2[#af2+1] = Def.ActorFrame{
	Name="PatternInfo",
	InitCommand=function(self)
		self:x(width+16);
		self:y(patternInfoY);
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(patternInfoY)
		else
			self:y(-38 - 80)
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
				self:xy(-width/2 + 40, -height/2 + 10)
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
						self:settext(string.format("%d/%d (%0.2f%%)", streamMeasures, totalMeasures, streamMeasures/totalMeasures*100))
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
				self:xy(-width/2 + 50, -height/2 + 10)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
			end,
		}

	end
end

return af