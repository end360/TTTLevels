if SERVER then
	local version = "1.1"
	Levels = {}
	include('levels/autoupdate.lua')
	include('levels/init.lua')
	AddCSLuaFile()
	AddCSLuaFile('levels/shared.lua')
	AddCSLuaFile('levels/cl_init.lua')
end
include('levels/shared.lua')
if CLIENT then
	Levels = {}
	include('levels/cl_init.lua')
end
