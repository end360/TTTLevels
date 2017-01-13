local sql = sql
util.AddNetworkString("Levels_GetXP")
util.AddNetworkString("Levels_AddXP")
local function sqlQuery(q)
	local res = sql.Query(q)
	if res==false then
		Error("Failure during SQL Query: "..sql.LastError())
		return false
	end
	return res
end
if not sql.TableExists("LevelSystem") then
	sqlQuery("CREATE TABLE LevelSystem ( SteamID TEXT, XP INT, LEVEL INT, Unique(SteamID))")
end
function Levels.createPlayer(steamid)
	sqlQuery("INSERT INTO LevelSystem (SteamID, XP, LEVEL) VALUES ('"..steamid.."', 0, 1)")
end
function Levels.sendXP(ply)
	net.Start("Levels_GetXP")
		net.WriteInt(Levels.getPlayerXP(ply:SteamID()), 32)
		net.WriteInt(Levels.getPlayerLevel(ply:SteamID()), 32)
	net.Send(ply)
end
hook.Add("PlayerAuthed", "Levels_Auth", function (ply, st, a)
	if sqlQuery("SELECT * FROM LevelSystem WHERE SteamID = '"..st.."'") then
		Levels.sendXP(ply)
		return
	end
	Levels.createPlayer(st)
	Levels.sendXP(ply)
end)
Levels.xpUpdateBuffer = Levels.xpUpdateBuffer or {}
function Levels.sendXPUpdate(ply, amt)
	if not amt then return end
	Levels.xpUpdateBuffer[ply] = (Levels.xpUpdateBuffer[ply] or 0) + amt
end
function Levels.sendXPUpdates()
	for ply,amt in pairs(Levels.xpUpdateBuffer) do
		net.Start("Levels_AddXP")
			net.WriteInt(amt, 32)
		net.Send(ply)
	end
	Levels.xpUpdateBuffer = {}
end
function Levels.tttEndRound(result)
	local winteam = (result==WIN_TRAITOR and ROLE_TRAITOR) or (result == WIN_INNOCENT and ROLE_INNOCENT)
	for _,v in pairs(player.GetHumans()) do
		if not v:Alive() and v:GetRole() != winteam then continue end
		Levels.givePlayerXP(v:SteamID(), winteam==ROLE_TRAITOR and Levels.xpForTWin or Levels.xpForInnoWin)
	end
	Levels.sendXPUpdates()
end
hook.Add("TTTEndRound","Levels_SendXPUpdates", Levels.tttEndRound)
function Levels.checkLevel(steamid)
	local xp = Levels.getPlayerXP(steamid) or 0
	if xp >= Levels.xpForLevel then
		Levels.takePlayerXP(steamid, Levels.xpForLevel)
		Levels.addPlayerLevel(steamid)
		hook.Run("Levels_LevelUp", player.GetBySteamID(steamid), Levels.getPlayerLevel(steamid))
	elseif xp<0 then
		Levels.takePlayerLevel(steamid)
	end
end
function Levels.setPlayerXP(steamid, amt)
	local res = sqlQuery("UPDATE LevelSystem SET XP="..amt.." WHERE SteamID='"..steamid.."'")
	Levels.checkLevel(steamid, amt)
end
function Levels.getPlayerLevel(steamid)
	local res = sqlQuery("SELECT LEVEL FROM LevelSystem WHERE SteamID='"..steamid.."'")
	if res == false then
		Levels.createPlayer(steamid)
		return 1
	end
	return tonumber(res) or 1
end
function Levels.addPlayerLevel(steamid)
	sql.Query("UPDATE LevelSystem SET LEVEL="..(Levels.getPlayerLevel(steamid)+1).." WHERE SteamID='"..steamid.."'")
end
function Levels.takePlayerLevel(steamid)
	sql.Query("UPDATE LevelSystem SET LEVEL="..(Levels.getPlayerLevel(steamid)-1).." WHERE SteamID='"..steamid.."'")
end
function Levels.getPlayerXP(steamid)
	local res = sqlQuery("SELECT XP FROM LevelSystem WHERE SteamID='"..steamid.."'")
	if res == false then
		local err = sql.LastError()
		if string.find(err, "exist") then
			Levels.createPlayer(steamid)
			return sqlQuery("SELECT XP FROM LevelSystem WHERE SteamID='"..steamid.."'") or 0
		end
	end
	return tonumber(res) or 0
end
function Levels.givePlayerXP(steamid, amt)
	local xp = Levels.getPlayerXP(steamid) or 0
	Levels.sendXPUpdate(player.GetBySteamID(steamid), amt)
	Levels.setPlayerXP(steamid, xp+amt)
end

function Levels.takePlayerXP(steamid, amt)
	local xp = Levels.getPlayerXP( steamid ) or 0
	Levels.setPlayerXP( steamid, xp-amt)
end
hook.Add("PlayerDeath", "Levels_PlayerDeath", function(vic, inf, att)
	if vic == att then return end
	if att:GetRole() == vic:GetRole() then 
		if Levels.xpLossForTK > 0 then
			Levels.takePlayerXP(att:SteamID(), Levels.xpLossForTK)
		end
	end
	Levels.givePlayerXP(att:SteamID(), att:GetRole() == ROLE_TRAITOR and Levels.xpForTKill or Levels.xpForInnoKill)
end)
