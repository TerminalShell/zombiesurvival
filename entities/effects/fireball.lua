function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

local function CollideCallback(particle, hitpos, hitnormal)
	if particle:GetDieTime() == 0 then return end
	particle:SetDieTime(0)

	if math.random(3) == 3 then
		util.Decal("Impact.AlienFlesh", hitpos + hitnormal, hitpos - hitnormal)
	end
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local hitnormal = data:GetNormal() * -1

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 48)

	local grav = Vector(0, 0, 400)
	for i = 1, math.random(60, 85) do
		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(32, 72) + hitnormal * math.Rand(48, 198))
		particle:SetDieTime(math.Rand(0.6, 1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 6))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-15, 15))
		particle:SetGravity(grav)
		particle:SetCollide(true)
		particle:SetCollideCallback(CollideCallback)
	end
	emitter:Finish()

	util.Decal("Impact.AlienFlesh", pos + hitnormal, pos - hitnormal)

	//sound.Play("npc/antlion_grub/squashed.wav", pos, 74, math.random(95, 110))
end
