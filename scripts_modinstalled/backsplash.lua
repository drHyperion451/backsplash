-- EDIT THIS IF YOU WANT TO RENAME YOUR FOLDER AND THE EXTENSION:
local wallpaper_folder = './wallpapers'
local img_extension = '.png' -- It is not recommended to change this
--- TODO: Find what's the name of the applied wallpaper inside the root, to be applied
local applied_background = 'bg.png'

-- [[ LIBS ]] --

-- Detecs OS. https://gist.github.com/Zbizu/43df621b3cd0dc460a76f7fe5aa87f30
-- Posible OS: Windows, Darwin, Linux 
local function getOS()
	-- ask LuaJIT first
	--[[ if jit then
		return jit.os
	end
	]]--

	-- Unix, Linux variants
	local fh,err = assert(io.popen("uname -o 2>/dev/null","r"))
	if fh then
		Osname = fh:read()
	end

	return Osname or "Windows"
end

---Gets a list of any files.
---@param dir string Set the directory to be scan (e.g. './wallpapers')
---@param ext string Set the extension to be filter out (e.g. '.png')
local function getFiles(dir, ext)
	local ext = ext or "."
	local files = {}

	if getOS() ~= 'Windows' then
		for dir in io.popen("find '" ..dir.. "' -name '*" .. ext .."'"):lines() 
			do table.insert(files, dir)
		end
	else
		-- TODO: Windows
		error("Windows is not supported")
		for dir in io.popen([[dir "C:\Program Files\" /b]]):lines() 
			do print(dir)
		end
	end

	return files
end
-- Extracts filename and extension given any path name
---@param path string Path string, can be absolute or relative.
---@return string filename Filename
---@return string filename Extension
local function extractFilenameAndExtension(path)
    -- Find the last occurrence of '/' or '\' in the path
    local slashIndex = path:find("[/\\][^/\\]*$")

    -- If no slash is found, return the entire path
    if not slashIndex then
        return path, ""
    end

    -- Extract the filename with extension from the path
    local filenameWithExtension = path:sub(slashIndex + 1)

    -- Find the last occurrence of '.' in the filename
    local dotIndex = filenameWithExtension:find("%.[^%.]*$")

    -- If no dot is found, return the filename
    if not dotIndex then
        return filenameWithExtension, ""
    end

    -- Extract the filename and extension
    local filename = filenameWithExtension:sub(1, dotIndex - 1)
    local extension = filenameWithExtension:sub(dotIndex)

    return filename, extension
end

---Finds a string inside a table:
---@param table table
---@param searchString string
---@return boolean
local function isStringInTable(table, searchString)
	for _, value in ipairs(table) do
		if type(value) == "string" and value == searchString
		then
			return true
		end
	end
	return false
end

-- MAIN FUNCTION

-- Change the folder dir according to OS:


-- Get the files inside root directory and folders
local files_infolder = getFiles(wallpaper_folder, img_extension)
local active_files = getFiles(wallpaper_folder, '.active')
local files_root = getFiles('./', img_extension)

-- Reads the *.active file to preserve filename
local active_filename = active_files[1] or tostring(math.random(1, 9999)) -- fallback
active_filename = extractFilenameAndExtension(active_filename)
print("Already applied background: "..active_filename)

--- if there's already an active background in the root folder.
if isStringInTable(files_root, ".//"..applied_background) and #files_infolder ~= 0
then
	print("Already an active background. Applying...")
	os.rename(applied_background, wallpaper_folder.. "/"..active_filename.. img_extension)
	os.remove(wallpaper_folder.. "/" ..active_filename..".active")
else
	print("Error: There is not an active background. Applying one ramdomly instead from: "..wallpaper_folder)
end


-- Select new active filename and write it inside the background file
if #files_infolder ~= 0 then
	active_filename = extractFilenameAndExtension(files_infolder[math.random(1, #files_infolder)])
	print(active_filename)
	-- writes the new .active to preservee the filename
	local file = io.open(wallpaper_folder.. "/" ..active_filename.. ".active", "w")
	if file then
		file:close()
	else
		error("Couldn't write files. Check permissions!")
	end

	print("Applying new background: ".. active_filename)
	os.rename(wallpaper_folder.. "/".. active_filename .. img_extension, applied_background)

else
	print("The wallpapers folder is empty!")
end


-- Gets a random file from the folder and moves it outside, renaming the file to `applied_background`
