local messages = {"ONE OF US!",
"BUTT MANGLED!",
"DON'T BUY STARBOUND",
"DO YOU EVEN LIFT?",
"BULLIED",
"DESTRUCTION 2.0",
"MY TIME HERE IS OGRE",
"ROADKILL!",
"GRAPED",
"LEFT FOR DEAD",
"SUCK BRICK KID!",
"2 E Z",
"DICKS OUT 4 HARAMBE",
"DO IT 4 HARAMBE",
"RUN N GUN!1",
"ADMEN 2 ME!",
"Press 'R' to reload!",
"GOTTA GO FAST!!",
"GOTTA HEAL UP!",
"REAGAN SMASH!!!!!",
"IS IT DONE YET?",
"!VOTEMAP38",
"KYS PLEASE"

}

EFFECT.LifeTime = 5

function EFFECT:Init(data)
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))

	self.Seed = math.Rand(0, 10)

	local pos = data:GetOrigin()
	local amount = math.Round(data:GetMagnitude())

	self.Pos = pos
	if amount > 1 then
		self.Message = amount.." BRAINS!"
	else
		self.Message = messages[math.random(#messages)]
	end

	self.DeathTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	self.Pos.z = self.Pos.z + FrameTime() * 32
	return CurTime() < self.DeathTime
end

local col = Color(40, 255, 40, 255)
local col2 = Color(0, 0, 0, 255)
function EFFECT:Render()
	local delta = math.Clamp(self.DeathTime - CurTime(), 0, self.LifeTime) / self.LifeTime
	col.a = delta * 240
	col2.a = col.a
	local ang = EyeAngles()
	local right = ang:Right()
	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Forward(), 90)
	cam.IgnoreZ(true)
	cam.Start3D2D(self.Pos + math.sin(CurTime() + self.Seed) * 30 * delta * right, ang, delta * 0.24 + 0.09)
		draw.SimpleText(self.Message, "ZS3D2DFont", 0, -21, col, TEXT_ALIGN_CENTER)
	cam.End3D2D()
	cam.IgnoreZ(false)
end
