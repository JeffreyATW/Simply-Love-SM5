local player, pss, isTwoPlayers, graph, target_score, layout = unpack(...)
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local pacemaker = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Bold",
	JudgmentMessageCommand=function(self)
		self:queuecommand("Update")
	end,

	-- common logic used for both the Pacemaker text and the ActionOnTargetMissed mod
	UpdateCommand=function(self)
		local DPCurr = pss:GetActualDancePoints()
		local DPCurrMax = pss:GetCurrentPossibleDancePoints()
		local DPMax = pss:GetPossibleDancePoints()

		local percentDifference = (DPCurr - (target_score * DPCurrMax)) / DPMax

		-- cap negative score displays
		percentDifference = math.max(percentDifference, -target_score)

		local places = 2
		-- if there's enough dance points so that our current precision is ambiguous,
		-- i.e. each dance point is less than half of a digit in the last place,
		-- and we don't already display 2.5 digits,
		-- i.e. 2 significant figures and (possibly) a leading 1,
		-- add a decimal point.
		-- .1995 prevents flickering between .01995, which is rounded and displayed as ".0200", and
		-- and an actual .0200, which is displayed as ".020"
		while (math.abs(percentDifference) < 0.1995 / math.pow(10, places))
			and (DPMax >= 2 * math.pow(10, places + 2)) and (places < 4) do
			places = places + 1
		end

		self:settext(string.format("%+."..places.."f", percentDifference * 100))

		-- have we already missed so many dance points
		-- that the current goal is not possible anymore?
		if ((DPCurrMax - DPCurr) > (DPMax * (1 - target_score))) then
			self:diffusealpha(0.65)
			-- see: ./SL/BGA/ScreenGameplay underlay/PerPlayer/TargetScore/ActionOnTargetMissed.lua
			MESSAGEMAN:Broadcast("TargetGradeMissed", {Player=player})
		end
	end
}

--------------------------------------------------------------
-- if the player wanted the Pacemaker mod

if mods.Pacemaker then

	pacemaker.InitCommand=function(self)
		self:zoom(0.35):shadowlength(1):horizalign(center)

		local width = GetNotefieldWidth()
		local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

		-- mirror image of MeasureCounter.lua
		self:xy(GetNotefieldX(player) + (width/NumColumns), layout.y)
	
		-- Fix overlap issues when MeasureCounter is centered
		-- since in this case we don't need symmetry.
		if (mods.MeasureCounterLeft == false) then
			self:horizalign(left)
			-- nudge slightly left (15% of the width of the bitmaptext when set to "100.00%")
			self:settext("100.00%"):addx( -self:GetWidth()*self:GetZoom() * 0.15 )
			self:settext("")
		end
	end

--------------------------------------------------------------
-- the player didn't want the Pacemaker mod

else
	pacemaker.InitCommand=function(self)
		-- so don't bother with any of the (above) positioning code
		-- and don't even draw the BitmapText actor
		self:visible(false)
	end
end

return pacemaker
