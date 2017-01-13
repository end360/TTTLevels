Levels.xpForLevel = 100
Levels.xpForTKill = 10
Levels.xpForInnoKill = 10
Levels.xpLossForTK = 0 -- Set to anything above 0 to lose XP

-- Pointshop (1) points on level-up, Remove /* and */ to enable
/*
local pointsForLevelup = 1000
local function givePointshopReward(ply, lvl)
  if SERVER then
    ply:PS_GivePoints(pointsForLevelup)
  else
    // HUD Stuff would go here
  end
end
hook.Add("Levels_LevelUp", "Levels_PSReward", givePointshopReward)
*/
