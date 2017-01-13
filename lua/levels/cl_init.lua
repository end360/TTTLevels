Levels.myXP = Levels.myXP or 0
Levels.myLevel = Levels.myLevel or 1
Levels.LevelColors = {
	Color(235, 0, 0),
	Color(0, 235, 0),
	Color(0, 0, 235),
	Color(235, 235, 0),
	Color(235, 0, 235),
	Color(0, 235, 235),
	Color(0, 141, 255)
}

net.Receive("Levels_GetXP", function(len)
		Levels.myXP = net.ReadInt(32)
		Levels.myLevel = net.ReadInt(32)
end)
net.Receive("Levels_AddXP", function(len)
		local toadd = net.ReadInt(32)
		Levels.addXP(toadd)
end)
local w = ScrW()*.2604167
local h = ScrH()*.037
local y = 50
local a = 255
Levels.addxps = {}
local times = CurTime()
function addXP(amt)
	Levels.myXP = Levels.myXP + amt
	
	while Levels.myXP >= Levels.xpForLevel do
		Levels.myXP = Levels.myXP - Levels.xpForLevel
		Levels.myLevel = Levels.myLevel + 1
		Levels.addxps[#Levels.addxps + 1] = {"Level Up", h+60+(#Levels.addxps*18), 255}
	end
	times = CurTime()
	Levels.addxps[#Levels.addxps + 1] = {amt, h+60+(#Levels.addxps*18), 255}
end
local function drawAddXP()
	if hook.Call("HUDShouldDraw", "LevelsAddXP") == false then return end
	if #addxps > 0 and times+5 > CurTime() then
		for i=0, #addxps do
			draw.SimpleText("+ "..Levels.addxps[i][1], "Trebuchet24", 45, Levels.addxp[i][2], Color(255,255,255,Levels.addxp[i][3]), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			Levels.addxp[i][2] = math.Clamp(Levels.addxp[i][2] - .10, h+20, 999999)
			Levels.addxp[i][3] = math.Clamp(Levels.addxp[i][3] - 1.125, 0, 255)
		end
	elseif #addxps > 0 and times+5 < CurTime() then
		addxps = {}
	end
end
hook.Add("HUDPaint", "TTTXP_PaintXPUpdate", drawAddXP)
local twenty = ScrH()*.019
local twentyfive = ScrH()*.023
local ten = ScrH()*.0093
local levelColors = Levels.levelColors
local function HUDPaint()
	if hook.Call("HUDShouldDraw", "LevelsXPBar") == false then return end
	local myXP = Levels.myXP
	local xpForLevel = Levels.xpForLevel
	local myLevel = Levels.myLevel
	draw.RoundedBox(0, twenty, twenty, w, h, Color(96, 96, 96, 225) )
	draw.RoundedBox(0, twentyfive, twentyfive, w*math.Clamp(myXP/xpForLevel,0,.98), h-ten, levelColors[(myLevel)%(#levelColors-1)] or Color(0,191,255))
	draw.SimpleText("Level: "..myLevel,"Trebuchet24",(w+twentyfive)/2,h,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "TTTXP_PaintBar", HUDPaint)
