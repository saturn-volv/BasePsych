local style = "inner" -- inner, center, edge, outer

local width = 593 -- default: 593
local height = 11 -- default: 11

local bar_offset_x = 0 -- default: 0
local bar_offset_y = 0 -- default: 0

local border_color = "000000"
local border_thickness = 4 -- default: 4

local override_colors = true -- default: true
local override_p1_color = override_colors and "00ff00" or nil
local override_p2_color = override_colors and "ff0000" or nil

local p1_offset_x = -26 -- default: -26
local p1_offset_y = 0 -- default: 0
local p2_offset_x = 26 -- default: 26
local p2_offset_y = 0 -- default: 0

--

local function to_hex(rgb)
	return string.format("%x", (rgb[1] * 0x10000) + (rgb[2] * 0x100) + rgb[3])
end

local sprite_border = "healthbar_border"
local sprite_p1 = "healthbar_p1"
local sprite_p2 = "healthbar_p2"

local bar_origin_x 
local bar_origin_y

local p_origin_y
--dad note doesn't have flash--
function opponentNoteHit(id,dir,type,sus)
	runHaxeCode([[
	   game.opponentStrums.members[]] .. dir .. [[].playAnim("static", true)
	]]);
end
--classic score--
function onCreate()
	makeLuaText('oldScore', 'Score:' .. score, 800, 390, 670)
	setTextSize('oldScore', 15)
	setTextBorder('oldScore', 1.5, '000000')
	addLuaText('oldScore')
	if getPropertyFromClass('ClientPrefs', 'downScroll') == false then
	setProperty('oldScore.y', 670)
	elseif getPropertyFromClass('ClientPrefs', 'downScroll') == true then
	setProperty('oldScore.y', 106)
	end
end

function onRecalculateRating()
	setTextString('oldScore', 'Score:' .. score)
end

function onCreatePost()
--Vanilla UI hide properties-- 
	setProperty('scoreTxt.visible', false)
	setProperty('timeBar.visible', false)
	setProperty('timeBarBG.visible', false)
	setProperty('timeTxt.visible', false)
--healthbar stuffs--
	setProperty("healthBarBG.visible", false)
	setProperty("healthBar.visible", false)
	
	bar_origin_x = (1280 - width) / 2
	bar_origin_y = getProperty("healthBarBG.sprTracker.y") - (height / 2)
	p_origin_y = getProperty("iconP1.y")
	
	makeLuaSprite(sprite_border, "",
		bar_origin_x - border_thickness + bar_offset_x,
		bar_origin_y - border_thickness + bar_offset_y
	)
	makeGraphic(sprite_border,
		width + (border_thickness * 2),
		height + (border_thickness * 2),
		border_color
	)
	addLuaSprite(sprite_border, true)
	setObjectCamera(sprite_border, "hud")
	setObjectOrder(sprite_border, 0)
	
	makeLuaSprite(sprite_p1, "",
		bar_origin_x + (width / 2) + bar_offset_x,
		bar_origin_y + bar_offset_y
	)
	makeGraphic(sprite_p1,
		(width / 2),
		height,
		override_colors and override_p1_color or to_hex(getProperty("boyfriend.healthColorArray"))
	)
	addLuaSprite(sprite_p1, true)
	setObjectCamera(sprite_p1, "hud")
	setObjectOrder(sprite_p1, 2)
	setProperty(sprite_p1 .. ".origin.x", getProperty(sprite_p1 .. ".width"))
	
	makeLuaSprite(sprite_p2, "",
		bar_origin_x + bar_offset_x,
		bar_origin_y + bar_offset_y
	)
	makeGraphic(sprite_p2,
		(width / 2),
		height,
		override_colors and override_p2_color or to_hex(getProperty("dad.healthColorArray"))
	) 
	addLuaSprite(sprite_p2, true)
	setObjectCamera(sprite_p2, "hud")
	setObjectOrder(sprite_p2, 1)
	setProperty(sprite_p2 .. ".origin.x", 0)
end

function onUpdatePost(el)
	local percent_p1 = (getProperty("healthBar.percent") / 100)
	local percent_p2 = 1 - percent_p1
	
	local scale_p1 = (percent_p1 * 2) + (percent_p1 < 1 and 0.01 or 0)
	local scale_p2 = percent_p2 * 2
	setProperty(sprite_p1 .. ".scale.x", scale_p1)
	setProperty(sprite_p2 .. ".scale.x", scale_p2)
	
	local real_width_p1 = getProperty(sprite_p1 .. ".width") * scale_p1
	local real_width_p2 = getProperty(sprite_p2 .. ".width") * scale_p2
	
	local center_p1 = -getProperty("iconP1.frameWidth") / 2
	local center_p2 = -getProperty("iconP2.frameWidth") / 2
	
	local temp_x_p1 = {
		["inner"] = bar_origin_x + real_width_p2 + p1_offset_x,
		["center"] = bar_origin_x + real_width_p2 + (real_width_p1 / 2) + center_p1,
		["edge"] = bar_origin_x + width + center_p1,
		["outer"] = bar_origin_x + width + center_p1 + 150 + p1_offset_x
	}
	
	local temp_x_p2 = {
		["inner"] = bar_origin_x + real_width_p2 - 150 + p2_offset_x,
		["center"] = bar_origin_x + (real_width_p2 / 2) + center_p2,
		["edge"] = bar_origin_x + center_p2,
		["outer"] = bar_origin_x + center_p2 - 150 + p2_offset_x
	}
	
	setProperty(sprite_border .. ".x", bar_origin_x - border_thickness + bar_offset_x)
	setProperty(sprite_border .. ".y", bar_origin_y - border_thickness + bar_offset_y)
	
	setProperty(sprite_p1 .. ".x", bar_origin_x + (width / 2) + bar_offset_x)
	setProperty(sprite_p1 .. ".y", bar_origin_y + bar_offset_y)
	
	setProperty(sprite_p2 .. ".x", bar_origin_x + bar_offset_x)
	setProperty(sprite_p2 .. ".y", bar_origin_y + bar_offset_y)
	--noteslplash pos fix--
	for i = 0, getProperty('grpNoteSplashes.length')-1 do
        setPropertyFromGroup('grpNoteSplashes', i, 'offset.x', -20)
        setPropertyFromGroup('grpNoteSplashes', i, 'offset.y', -20)
        setPropertyFromGroup('grpNoteSplashes', i, 'alpha', 0.6)
	end
	--show combo number stuff--
	if getProperty('combo') > 8 then
		setProperty('showComboNum', true)
	else
		setProperty('showComboNum', false)
	end
end

function string.starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end
function string.split(str, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local count = 0
--healthbar recalculate rating stuff--
function goodNoteHit(id, direction, noteType, isSustainNote)
    if not hideHud and not isSustainNote and getProperty('combo') > 9 then
        count = count + 1

        -- lot of vars but shut up i know we need these
        local tag = 'combo' .. count
        local offset = getPropertyFromClass('ClientPrefs', 'comboOffset')

        local pixel = getPropertyFromClass('PlayState', 'isPixelStage')
        local pixelShitPart1 = ''
        local pixelShitPart2 = ''
        local scaleShit = 0.7
        local antialiasing = getPropertyFromClass('ClientPrefs',
                                                  'globalAntialiasing')
        if pixel then
            pixelShitPart1 = 'pixelUI/'
            pixelShitPart2 = '-pixel'
            scaleShit = getPropertyFromClass('PlayState', 'daPixelZoom') * 0.85
            antialiasing = false
        end

        -- pixel style is great too
        makeLuaSprite(tag, pixelShitPart1 .. 'combo' .. pixelShitPart2, 0, 0)
        scaleObject(tag, scaleShit, scaleShit)
        updateHitbox(tag)

        -- i wanted to put that after ratio var but psych don't let me do that
        screenCenter(tag, 'y')

        -- my brain told me to fix the offsets as fast as i can
        local ox = screenWidth * 0.35 + getProperty(tag .. '.width') / 4.1
        local oy = getProperty(tag .. '.y') + getProperty(tag .. '.height') /
                       1.45
        if pixel then
            ox = ox + 3
            oy = oy + 10
        else
            ox = ox - 40
            oy = oy / 1.05
        end
        setProperty(tag .. '.x', ox + offset[1])
        setProperty(tag .. '.y', oy - offset[2])

        -- box2d based??? dik
        setProperty(tag .. '.acceleration.y', 600)
        setProperty(tag .. '.velocity.y', getProperty(tag .. '.velocity.y') -
                        150 + math.random(1, 10))

        setProperty(tag .. '.antialiasing', antialiasing)
        setObjectCamera(tag, 'camGame')
        addLuaSprite(tag)
        setObjectOrder(tag, getObjectOrder('strumLineNotes') - 1)

        -- fuck psych doesn't support startDelay so i use a timer instead
        runTimer(tag .. ',timer', crochet * 0.001)
    end
end

function onTimerCompleted(tag)
    if string.starts(tag, 'combo') then
        -- funni split moment()
        local leObj = string.split(tag, ',')[1]
        doTweenAlpha(leObj .. ',tween', leObj, 0, 0.2, 'linear')
    end
end

function onTweenCompleted(tag)
    if string.starts(tag, 'combo') then
        removeLuaSprite(string.split(tag, ',')[1])
    end
end