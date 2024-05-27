-- backsplash.lua
-- Swaps the current title_background with any background inside the wallpaper_dir folder
-- It should run before statup. This way the background would cicle between some avaliable options
print(" \
\
______               _     _____         _              _     \
| ___ \\             | |   /  ___|       | |            | |    \
| |_/ /  __ _   ___ | | __\\ `--.  _ __  | |  __ _  ___ | |__  \
| ___ \\ / _` | / __|| |/ / `--. \\| '_ \\ | | / _` |/ __|| '_ \\ \
| |_/ /| (_| || (__ |   < /\\__/ /| |_) || || (_| |\\__ \\| | | |\
\\____/  \\__,_| \\___||_|\\ _\\____/ | .__/ |_| \\__,_||___/|_| |_|\
for Dwarf Fortress               | |                          \
                                 |_|                          \
\
") --splashscreen, just because

local root_dir = dfhack.getDFPath()

local art_dir = root_dir .. '/data/art/'

-- EDIT THIS IF YOU WANT TO RENAME YOUR FOLDER AND THE EXTENSION:
local wallpaper_dir_name = "wallpapers"

-- TODO: When avaliable. Use dfhack.scriptmanager.getModStatePath(mod_id) to use a persistent folder, 
-- so it will be synced with Steam Cloud
local wallpaper_dir = root_dir.. "/dfhack-config/mods/backsplash/".. wallpaper_dir_name .. "/"
local applied_background = 'title_background.png'
local backup_wallpaper_name = 'title_background copy.png'
local img_extension = '.png' -- It is not recommended to change this

---------- LIBS ------------
--- Just for keeping track of debug messages and delete it before its on release
local function dbg_error(msg)
	print(msg)
end

-- Generates an empty folder recursively
-- dfhack.filesystem.mkdir_recursive(path) doesn't work for some reason. So I've created this instead
---@param path string Set the directory to be scan (e.g. './wallpapers')
---@return boolean error Returns false if the folder can't be created
local function recursive_mkdir(path)
    -- Check if the directory already exists
    if dfhack.filesystem.isdir(path) then
        return true
    end

    -- Recursively create the parent directory
    local parent_dir = path:match("^(.*)/") or path:match("^(.*)\\")
    if parent_dir and not dfhack.filesystem.isdir(parent_dir) then
        if not recursive_mkdir(parent_dir) then
            return false
        end
    end

    -- Create the directory
    if dfhack.filesystem.mkdir(path) then
        return true
    else
		-- At the last step check if the path  was created and return false if it doesn't
		if not dfhack.filesystem.isdir(path) then
			return false
		else
			return true
		end
    end
end

---Gets a list of any files and filter by extension.
---@param dir string Set the directory to be scan (e.g. './wallpapers')
---@param ext string Set the extension to be filter out (e.g. '.png')
local function getFiles(dir, ext)
	local ext = ext or ""
	local files = dfhack.filesystem.listdir(dir)
	local filtered_files = {}
	for _, filename in ipairs(files) do
		-- Check if the filename ends with .png
		for file in string.gmatch(filename, ".*%"..ext.."$") do
			table.insert(filtered_files, file)
		end
	end
	return filtered_files
end

-- Extracts filename and extension given any path name
---@param filenameWithExtension string Path string, can be absolute or relative.
---@return string filename Filename
---@return string filename Extension
local function extractFilenameAndExtension(filenameWithExtension) --path
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

-- Copies and pastes a file. Self explanatory lol.
---@param source string Path of source file.
---@param destination string Path of destination file.
---@return boolean error Returns false if it couldn't copy
---@return string errormsg Returns an error message if avaliable
local function fileCopy(source, destination)
    local input_file = io.open(source, "rb")
    if not input_file then
        return false, "Could not open source file for reading"
    end

    local output_file = io.open(destination, "wb")
    if not output_file then
        input_file:close()
        return false, "Could not open destination file for writing"
    end

    local content = input_file:read("*all")
    if not content then
        input_file:close()
        output_file:close()
        return false, "Could not read source file"
    end

    local success = output_file:write(content)
    if not success then
        input_file:close()
        output_file:close()
        return false, "couldn't write to the destination file"
    end

    input_file:close()
    output_file:close()
    return true, ""
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


---------- MAIN FUNCTION ------------

-- Creates the 'backgrounds' folder if it does not exist
if not dfhack.filesystem.isdir(wallpaper_dir) then
	print(wallpaper_dir_name.." folder does not exist: generating...")
	-- TODO: When it's avaliable, use dfhack.scriptmanager.getModSourcePath to copy 
	-- the readme file that goes inside the backgrounds folder directory, instead
	-- of putting the info with io.open and write.
	if recursive_mkdir(wallpaper_dir) then
			local file = io.open(wallpaper_dir.."readme.txt", "w")
			if file then
				file:write("Put all your wallpapers inside this folder.\
		It should be a .png file.\
		Is it recommended to use images with no transparency and 1920x1080, but not mandatory.")
				file:close()
			else
				error("Couldn't write files. Check permissions for the folder: '"..wallpaper_dir.."'")
			end
	else		
		error("Couldn't generate the folder. Please check folder permisions for:".. wallpaper_dir)
	end
end


-- Get the files inside root directory and folders

local wallpaper_files = getFiles(wallpaper_dir, img_extension)
local active_files = getFiles(wallpaper_dir, '.active')
local art_files = getFiles(art_dir, img_extension)

-- *.active file. Just the filename with no .active extension
local dot_active = (active_files[1] or "default")..tostring(math.random(1, 9)) -- fallback
dot_active = extractFilenameAndExtension(dot_active) --default#
print("Already applied background: "..dot_active)

-- If there's already an active background in the root folder it will move the applied background
-- aka. title_background.png back to the 'backgrounds' folder.
printall(active_files)

if isStringInTable(active_files, dot_active..".active") then
	print("Already an active background. Saving it to the backgrounds folder...")
	-- This way it would preserve the filename if possible.
	fileCopy(art_dir..applied_background, wallpaper_dir..dot_active.. img_extension)
	os.remove(wallpaper_dir ..dot_active..".active") -- purge old .active file
elseif #wallpaper_files == 0 then
	-- If the wallpaper directory is empty do not do anything
	print("There is not an active background and the background folder is empty. Nothing is changed")
else
	-- If there is no .active Save the current background with a random defauwallpaper_fileslt#.png name. 
	print("There is not an active background. Saving the original one. Applying one ramdomly instead from: "..wallpaper_dir)
	fileCopy(art_dir..applied_background, art_dir..backup_wallpaper_name)
	fileCopy(art_dir..applied_background, wallpaper_dir..dot_active.. img_extension)
end

-- Select new active filename and move it to the art/ directory, renaming it accordingly
-- This applies the background, as the game just detects if title_background.png already exists
if #wallpaper_files ~= 0 then
	dot_active = extractFilenameAndExtension(wallpaper_files[math.random(1, #wallpaper_files)])
	print(dot_active)
	-- writes the new .active to preserve the filename of the original wallpaper
	local file = io.open(wallpaper_dir..dot_active.. ".active", "w")
	if file then
		file:close()
	else
		error("Couldn't write files. Check permissions for the folder: '".. art_dir.."' and '"..wallpaper_dir)
	end

	print("Applying new background: ".. dot_active)
	fileCopy(wallpaper_dir.. "/".. dot_active .. img_extension, art_dir..applied_background)

else
	print("The wallpapers folder is empty! Please go to '", wallpaper_dir, "and fill it with PNG files. Try to match the 1920x1080 resolution if possible.")
end

-- Print empty lines, so the console is not cluttered
print("\n")
