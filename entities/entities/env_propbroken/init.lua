AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModelScale(1.03, 0)
end

function ENT:AttachTo(ent)
	self:SetModel(ent:GetModel())
	self:SetSkin(ent:GetSkin() or 0)
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())
	self:SetAlpha(ent:GetAlpha())
	self:SetOwner(ent)
	self:SetParent(ent)
	ent._BARRICADEBROKEN = self
end
