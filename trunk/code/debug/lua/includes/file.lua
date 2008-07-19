

function dirtree(dir)
  assert(dir and dir ~= "", "directory parameter is missing or empty")
  if string.sub(dir, -1) == "/" then
    dir=string.sub(dir, 1, -2)
  end

  local diriters = {lfs.dir(dir)}
  local dirs = {dir}

  return function()
    repeat 
      local entry = diriters[#diriters]()
      if entry then 
        if entry ~= "." and entry ~= ".." then 
          local filename = table.concat(dirs, "/").."/"..entry
          local attr = lfs.attributes(filename)
          if attr.mode == "directory" then 
            table.insert(dirs, entry)
            table.insert(diriters, lfs.dir(filename))
          end
          return filename, attr
        end
      else
        table.remove(dirs)
        table.remove(diriters)
      end
    until #diriters==0
  end
end

function findFileByType(n)
	local tab = {}
	for filename, attr in dirtree(".") do
		if not(attr.mode == "directory") then
			if(string.GetExtensionFromFilename(filename) == string.GetExtensionFromFilename("." .. n)) then
				local f = string.sub(filename,3,string.len(filename))
				table.insert(tab,f)
			end
		end
	end
	return tab
end

function fileExists(n)
	local tab = findFileByType(string.GetExtensionFromFilename(n))
	for k,v in pairs(tab) do
		if(v == n) then
			return true
		end
	end
	return false
end