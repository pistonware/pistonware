local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/pistonware/pistonware/main/'..select(1, path:gsub('pistonware/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'pistonware', 'pistonware/games', 'pistonware/profiles', 'pistonware/assets', 'pistonware/libraries', 'pistonware/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

	if not shared.PistonwareDeveloper then
		-- version-based autoupdate: compare remote version.txt to the cached one
		local suc, remoteVersion = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/pistonware/pistonware/main/version.txt?v='..os.time(), true)
		end)
		if suc and remoteVersion and remoteVersion ~= '404: Not Found' then
			remoteVersion = remoteVersion:gsub('%s', '')
			local cachedVersion = (isfile('pistonware/profiles/version.txt') and readfile('pistonware/profiles/version.txt') or ''):gsub('%s', '')
			if remoteVersion ~= cachedVersion then
				wipeFolder('pistonware')
				wipeFolder('pistonware/games')
				wipeFolder('pistonware/guis')
				wipeFolder('pistonware/libraries')
			end
			writefile('pistonware/profiles/version.txt', remoteVersion)
		end
	end

return loadstring(downloadFile('pistonware/main.lua'), 'main')()