ANIM_ACT_LOOP = 0
ANIM_ACT_LOOP_LERP = 1
ANIM_ACT_STOP = 2

local AnimationT = {}

function AnimationT:Init()
	self.playing = false
	--self:Reset()
	self.frame = self.start
	self.oldframe = self.start
	self.act = ANIM_ACT_LOOP
end

function AnimationT:Reset()
	self.playing = false
	--print("Stopped Playing!\n")
	self.frame = self.start
	self.oldframe = self.start
	self:Play()
end

function AnimationT:Stop()
	self.playing = false
	--print("Stopped Playing!\n")
end

function AnimationT:Play()
	if(self.playing == false) then
		self.playing = true
		self.frameTime = LevelTime()
		self.oldFrameTime = LevelTime() + self.lerp
		--print("Started Playing!\n")
	end
end

function AnimationT:Animate()
	--print("Animate\n")
	if(self.playing != true) then return end
	--print("Is Playing\n")
	if(LevelTime() > self.frameTime) then
		--print("New Frame\n")
		self.oldFrameTime = self.frameTime
		self.oldframe = self.frame
		
		self.frameTime = LevelTime() + self.lerp
		self.frame = self.frame + 1
		if(self.frame >= self.endf) then
			if(self.act == ANIM_ACT_LOOP) then
				self.frame = self.start
				self.oldframe = self.start
			elseif(self.act == ANIM_ACT_LOOP_LERP) then
				self.frame = self.start
			elseif(self.act == ANIM_ACT_STOP) then
				self.frame = self.endf
				self.oldframe = self.endf
				self:Stop()
			end
		end
		
		if ( self.frameTime > LevelTime() + 200 ) then
			self.frameTime = LevelTime();
		end

		if ( self.oldFrameTime > LevelTime() ) then
			self.oldFrameTime = LevelTime();
		end
	end
	if(self.ref != nil) then
		--print("Ref-Frame\n")
		local backlerp = 1.0 - (LevelTime() - self.oldFrameTime ) / ( self.frameTime - self.oldFrameTime );
		self.ref:SetOldFrame(self.oldframe)
		self.ref:SetFrame(self.frame)
		self.ref:SetLerp(backlerp)
	else
		--print("Ref was nil\n")
	end
end

function AnimationT:SetRef(r)
	self.ref = r
end

function AnimationT:SetType(t)
	if(t >= 0 and t <= ANIM_ACT_STOP) then
		self.act = t
	end
end

function AnimationT:SetStart(s)
	self.start = s
end

function AnimationT:SetEnd(e)
	self.endf = self.start + e
	self.length = e
end

function AnimationT:GetStart()
	return self.start
end

function AnimationT:GetLength()
	return self.length
end

function AnimationT:GetFrame()
	return self.frame
end

function Animation(_start,_end,_lerp)
	local o = {}

	setmetatable(o,AnimationT)
	AnimationT.__index = AnimationT

	o.start = _start
	o.endf = _start + _end
	o.length = _end
	o.lerp = 1000/_lerp
	
	o:Init()
	o.Init = nil
	
	return o;
end