Matrix = {}
--Matrix.__index = Matrix

local ids = {"a","b","c","d","e","f","g","g","i","j","k"}

function Matrix:New(n)
	local out = {}
	setmetatable(out,self)
	self.__index = self

	local rows = {}
	for i=1, n do
		local cols = {}
		for j=1, n do
			table.insert(cols,0)
		end
		table.insert(rows,cols)
	end
	out.mat = rows
	out:Identity()
	
	return out
end

function Matrix:Copy(mat)
	local n = #self.mat
	for i=1,n do
		for j=1,n do
			self:Set(i,j,mat:Get(i,j))
		end
	end
end

function Matrix:Identity()
	self:Zero()
	local n = #self.mat
	for i=1,n do
		self:Set(i,i,1)
	end
end

function Matrix:Zero()
	local n = #self.mat
	for i=1,n do
		for j=1,n do
			self:Set(i,j,0)
		end
	end
end

function Matrix:Translate(...)
	local n = #self.mat
	local m = Matrix:New(n)
	for i=1,n do
		if not (arg[i] == nil) then
			m:Set(n,i,arg[i])
		end
	end
	local out = m * self
	return out
end

function Matrix:Scale(...)
	local n = #self.mat
	local m = Matrix:New(n)
	for i=1,n do
		if not (arg[i] == nil) then
			m:Set(i,i,arg[i])
		end
	end
	local out = m * self
	return out
end

function Matrix:Rotate(pitch,yaw,roll)
	local x = Matrix:New(4)
	local y = Matrix:New(4)
	local z = Matrix:New(4)
	
	--X
	x:Set(2,2,math.cos(pitch))
	x:Set(2,3,math.sin(pitch))
	x:Set(3,2,-math.sin(pitch))
	x:Set(3,3,math.cos(pitch))
	
	--Y
	y:Set(1,1,math.cos(yaw))
	y:Set(1,3,-math.sin(yaw))
	y:Set(3,1,math.sin(yaw))
	y:Set(3,3,math.cos(yaw))
	
	--Z
	z:Set(1,1,math.cos(roll))
	z:Set(1,2,math.sin(roll))
	z:Set(2,1,-math.sin(roll))
	z:Set(2,2,math.cos(roll))
	
	local out = x * y * z
	out = out * self
	return out
end

function Matrix:Get(row,col)
	local n = #self.mat
	if(row > n) then return end
	if(col > n) then return end
	return self.mat[row][col]
end

function Matrix:Set(row,col,v)
	local n = #self.mat
	if(row > n) then return end
	if(col > n) then return end
	self.mat[row][col] = v
end

function Matrix:Print()
	local out = "Matrix:\n"
	local n = #self.mat
	
	for i=1, n do
		for j=1, n do
			val = self:Get(i,j)
			out = out .. "[" .. val .. "],"
		end
		out = out .. "\n"
	end
	Msg(out)
end

function Matrix:__add(a)
	local b = self
	local n = #self.mat
	local out = Matrix:New(n)
	out:Copy(a)
	for i=1,n do
		for j=1,n do
			out:Set(i,j,a:Get(i,j) + b:Get(i,j))
		end
	end
	return out
end

function Matrix:__mul(a)
	local b = self
	local n = #self.mat
	local out = Matrix:New(n)
	out:Copy(a)
	for i=1,n do
		for j=1,n do
			local tmp = 0
			for t=1,n do
				tmp = tmp + a:Get(i,t) * b:Get(t,j)
				out:Set(i,j,tmp)
			end
		end
	end
	return out
end


--local m = Matrix:New(4)
--m:Identity()
--m:Set(4,1,100)
--m:Set(4,2,100)
--m:Set(4,3,100)
--local trans = m:Rotate(1,32,10)
--trans:Print()