local nfte = {}

local tchar = string.char(31)	-- for text colors
local bchar = string.char(30)	-- for background colors
local nchar = string.char(29)	-- for differentiating multiple frames in ANFT

local round = function(num)
	return math.floor(num + 0.5)
end

local deepCopy
deepCopy = function(tbl)
	local output = {}
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			output[k] = deepCopy(v)
		else
			output[k] = v
		end
	end
	return output
end

local function stringWrite(str,pos,ins,exc)
	str, ins = tostring(str), tostring(ins)
	local output, fn1, fn2 = str:sub(1,pos-1)..ins..str:sub(pos+#ins)
	if exc then
		repeat
			fn1, fn2 = str:find(exc,fn2 and fn2+1 or 1)
			if fn1 then
				output = stringWrite(output,fn1,str:sub(fn1,fn2))
			end
		until not fn1
	end
	return output
end

local checkValid = function(image)
	if type(image) == "table" then
		if #image == 3 then
--			if #image[1] + #image[2] + #image[3] >= 3 then
				return (#image[1] == #image[2] and #image[2] == #image[3])
--			end
		end
	end
	return false
end

local checkIfANFT = function(image)
	if type(image) == "table" then
		return type(image[1][1]) == "table"
	elseif type(image) == "string" then
		return image:find(nchar) and true or false
	end
end

local bl = {	-- blit
	[' '] = 0,
	['0'] = 1,
	['1'] = 2,
	['2'] = 4,
	['3'] = 8,
	['4'] = 16,
	['5'] = 32,
	['6'] = 64,
	['7'] = 128,
	['8'] = 256,
	['9'] = 512,
	['a'] = 1024,
	['b'] = 2048,
	['c'] = 4096,
	['d'] = 8192,
	['e'] = 16384,
	['f'] = 32768,
}
local lb = {} 	-- tilb
for k,v in pairs(bl) do
	lb[v] = k
end

local ldchart = {	-- it stands for light/dark chart
	["0"] = "0",
	["1"] = "4",
	["2"] = "6",
	["3"] = "0",
	["4"] = "0",
	["5"] = "0",
	["6"] = "0",
	["7"] = "8",
	["8"] = "0",
	["9"] = "3",
	["a"] = "2",
	["b"] = "9",
	["c"] = "1",
	["d"] = "5",
	["e"] = "2",
	["f"] = "7"
}

local dlchart = {	-- it stands for dark/light chart
	["0"] = "8",
	["1"] = "c",
	["2"] = "a",
	["3"] = "9",
	["4"] = "1",
	["5"] = "d",
	["6"] = "2",
	["7"] = "f",
	["8"] = "7",
	["9"] = "b",
	["a"] = "7",
	["b"] = "7",
	["c"] = "7",
	["d"] = "7",
	["e"] = "7",
	["f"] = "f"
}

local getSizeNFP = function(image)
	local xsize = 0
	if type(image) ~= "table" then return 0,0 end
	for y = 1, #image do xsize = math.max(xsize,#image[y]) end
	return xsize, #image
end

getSize = function(image)
	assert(checkValid(image), "Invalid image.")
	local x, y = 0, #image[1]
	for y = 1, #image[1] do
		x = math.max(x, #image[1][y])
	end
	return x, y
end
nfte.getSize = getSize

crop = function(image, x1, y1, x2, y2)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = y1, y2 do
		output[1][#output[1]+1] = image[1][y]:sub(x1,x2)
		output[2][#output[2]+1] = image[2][y]:sub(x1,x2)
		output[3][#output[3]+1] = image[3][y]:sub(x1,x2)
	end
	return output
end
nfte.crop = crop

local loadImageDataNFT = function(image, background) -- string image
	local output = {{},{},{}} -- char, text, back
	local y = 1
	local text, back = " ", background or " "
	local doSkip, c1, c2 = false
	local maxX = 0
	for i = 1, #image do
		if doSkip then
			doSkip = false
		else
			output[1][y] = output[1][y] or ""
			output[2][y] = output[2][y] or ""
			output[3][y] = output[3][y] or ""
			c1, c2 = image:sub(i,i), image:sub(i+1,i+1)
			if c1 == tchar then
				text = c2
				doSkip = true
			elseif c1 == bchar then
				back = c2
				doSkip = true
			elseif c1 == "\n" then
				maxX = math.max(maxX, #output[1][y])
				y = y + 1
				text, back = " ", background or " "
			else
				output[1][y] = output[1][y]..c1
				output[2][y] = output[2][y]..text
				output[3][y] = output[3][y]..back
			end
		end
	end
	for y = 1, #output[1] do
		output[1][y] = output[1][y] .. (" "):rep(maxX - #output[1][y])
		output[2][y] = output[2][y] .. (" "):rep(maxX - #output[2][y])
		output[3][y] = output[3][y] .. (" "):rep(maxX - #output[3][y])
	end
	return output
end

loadImageData = function(image, background)
	assert(type(image) == "string", "NFT image data must be string.")
	local output = {}
	if checkIfANFT(image) then
		local L, R = 1, 1
		while L do
			R = (image:find(nchar, L + 1) or 0)
			output[#output+1] = loadImageDataNFT(image:sub(L, R - 1), background)
			L = image:find(nchar, R + 1)
			if L then L = L + 2 end
		end
		return output, "anft"
	else
		return loadImageDataNFT(image, background), "nft"
	end
end
nfte.loadImageData = loadImageData

convertFromNFP = function(image)
	assert(type(image) == "string", "NFP image data must be string.")
	local output = {{},{},{}}
	local imageX, imageY = getSizeNFP(image)
	for y = 1, imageY do
		output[1][y] = ""
		output[2][y] = ""
		output[3][y] = ""
		for x = 1, imageX do
			output[1][y] = output[1][y]..lb[image[y][x] or " "]
			output[2][y] = output[2][y]..lb[image[y][x] or " "]
			output[3][y] = output[3][y]..lb[image[y][x] or " "]
		end
	end
	return output
end
nfte.convertFromNFP = convertFromNFP

loadImage = function(path, background)
	local file = io.open(path, "r")
	if file then
		io.input(file)
		local output, format = loadImageData(io.read("*all"), background)
		io.close()
		return output, format
	else
		error("No such file exists, or is directory.")
	end
end
nfte.loadImage = loadImage

local unloadImageNFT = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = ""
	local text, back = " ", " "
	local c, t, b
	for y = 1, #image[1] do
		for x = 1, #image[1][y] do
			c, t, b = image[1][y]:sub(x,x), image[2][y]:sub(x,x), image[3][y]:sub(x,x)
			if (t ~= text) or (x == 1) then
				output = output..tchar..t
				text = t
			end
			if (b ~= back) or (x == 1) then
				output = output..bchar..b
				back = b
			end
			output = output..c
		end
		if y ~= #image[1] then
			output = output.."\n"
			text, back = " ", " "
		end
	end
	return output
end
unloadImage = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = ""
	if checkIfANFT(image) then
		for i = 1, #image do
			output = output .. unloadImageNFT(image[i])
			if i ~= #image then
				output = output .. nchar .. "\n"
			end
		end
	else
		output = unloadImageNFT(image)
	end
	return output
end
nfte.unloadImage = unloadImage

drawImage = function(image, x, y)
	assert(checkValid(image), "Invalid image.")
	assert(type(x) == "number", "x value must be number, got " .. type(x))
	assert(type(y) == "number", "y value must be number, got " .. type(y))
	local cx, cy = term.getCursorPos()
	for iy = 1, #image[1] do
		term.setCursorPos(x,y+(iy-1))
		term.blit(image[1][iy], image[2][iy], image[3][iy])
	end
	term.setCursorPos(cx,cy)
end
nfte.drawImage = drawImage

drawImageTransparent = function(image, x, y)
	assert(checkValid(image), "Invalid image.")
	assert(type(x) == "number", "x value must be number, got " .. type(x))
	assert(type(y) == "number", "y value must be number, got " .. type(y))
	local cx, cy = term.getCursorPos()
	local c, t, b
	for iy = 1, #image[1] do
		for ix = 1, #image[1][iy] do
			c, t, b = image[1][iy]:sub(ix,ix), image[2][iy]:sub(ix,ix), image[3][iy]:sub(ix,ix)
			if not (b == " " and c == " ") then
				term.setCursorPos(x+(ix-1),y+(iy-1))
				term.blit(c, t, b)
			end
		end
	end
	term.setCursorPos(cx,cy)
end
nfte.drawImageTransparent = drawImageTransparent

drawImageCenter = function(image, x, y)
	local scr_x, scr_y = term.getSize()
	local imageX, imageY = getSize(image)
	return drawImage(image, (x and x or (scr_x/2)) - (imageX/2), (y and y or (scr_y/2)) - (imageY/2))
end
drawImageCentre = drawImageCenter
nfte.drawImageCenter = drawImageCenter
nfte.drawImageCentre = drawImageCenter

drawImageCenterTransparent = function(image, x, y)
	local scr_x, scr_y = term.getSize()
	local imageX, imageY = getSize(image)
	return drawImageTransparent(image, (x and x or (scr_x/2)) - (imageX/2), (y and y or (scr_y/2)) - (imageY/2))
end
drawImageCentreTransparent = drawImageCenterTransparent
nfte.drawImageCenterTransparent = drawImageCenterTransparent
nfte.drawImageCentreTransparent = drawImageCenterTransparent

colorSwap = function(image, text, back)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]
		output[2][y] = image[2][y]:gsub(".", text)
		output[3][y] = image[3][y]:gsub(".", back or text)
	end
	return output
end
colourSwap = colorSwap
nfte.colorSwap = colorSwap
nfte.colourSwap = colorSwap

local xflippable = {
	["\129"] = "\130",
	["\132"] = "\136",
	["\133"] = "\138",
	["\134"] = "\137",
	["\135"] = "\139",
	["\140"] = "\140",
	["\141"] = "\142",
	["\143"] = "\143",
}
local xinvertable = {
	["\144"] = "\159",
	["\145"] = "\157",
	["\146"] = "\158",
	["\147"] = "\156",
	["\148"] = "\151",
	["\152"] = "\155"
}
for k,v in pairs(xflippable) do
	xflippable[v] = k
end
for k,v in pairs(xinvertable) do
	xinvertable[v] = k
end

flipX = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]:reverse():gsub(".", xflippable):gsub(".", xinvertable)
		output[2][y] = ""
		output[3][y] = ""
		for x = 1, #image[1][y] do
			if xinvertable[image[1][y]:sub(x,x)] then
				output[2][y] = image[3][y]:sub(x,x) .. output[2][y]
				output[3][y] = image[2][y]:sub(x,x) .. output[3][y]
			elseif xflippable[image[1][y]:sub(x,x)] then
				output[2][y] = xflippable[image[2][y]:sub(x,x)] .. output[2][y]
				output[3][y] = xflippable[image[3][y]:sub(x,x)] .. output[3][y]
			else
				output[2][y] = image[2][y]:sub(x,x) .. output[2][y]
				output[3][y] = image[3][y]:sub(x,x) .. output[3][y]
			end
		end
	end
	return output
end
nfte.flipX = flipX

flipY = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = #image[1], 1, -1 do
		output[1][#output[1]+1] = image[1][y]
		output[2][#output[2]+1] = image[2][y]
		output[3][#output[3]+1] = image[3][y]
	end
	return output
end
nfte.flipY = flipY

makeRectangle = function(width, height, char, text, back)
	assert(type(width) == "number", "width must be number")
	assert(type(height) == "number", "height must be number")
	local output = {{},{},{}}
	for y = 1, height do
		output[1][y] = (char or " "):rep(width)
		output[2][y] = (text or " "):rep(width)
		output[3][y] = (back or " "):rep(width)
	end
	return output
end
nfte.makeRectangle = makeRectangle

grayOut = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	local chart = {
		["0"] = "0",
		["1"] = "8",
		["2"] = "8",
		["3"] = "8",
		["4"] = "8",
		["5"] = "8",
		["6"] = "8",
		["7"] = "7",
		["8"] = "8",
		["9"] = "7",
		["a"] = "7",
		["b"] = "7",
		["c"] = "7",
		["d"] = "7",
		["e"] = "7",
		["f"] = "f"
	}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]
		output[2][y] = image[2][y]:gsub(".", chart)
		output[3][y] = image[3][y]:gsub(".", chart)
	end
	return output
end
greyOut = grayOut
nfte.grayOut = grayOut
nfte.greyOut = grayOut

lighten = function(image, amount)
	assert(checkValid(image), "Invalid image.")
	if (amount or 1) < 0 then
		return darken(image, -amount)
	else
		local output = deepCopy(image)
		for i = 1, amount or 1 do
			for y = 1, #output[1] do
				output[1][y] = output[1][y]
				output[2][y] = output[2][y]:gsub(".",ldchart)
				output[3][y] = output[3][y]:gsub(".",ldchart)
			end
		end
		return output
	end
end
nfte.lighten = lighten

darken = function(image, amount)
	assert(checkValid(image), "Invalid image.")
	if (amount or 1) < 0 then
		return lighten(image, -amount)
	else
		local output = deepCopy(image)
		for i = 1, amount or 1 do
			for y = 1, #output[1] do
				output[1][y] = output[1][y]
				output[2][y] = output[2][y]:gsub(".",dlchart)
				output[3][y] = output[3][y]:gsub(".",dlchart)
			end
		end
		return output
	end
end
nfte.darken = darken

stretchImage = function(_image, sx, sy, noRepeat)
	assert(checkValid(_image), "Invalid image.")
	local output = {{},{},{}}
	local image = deepCopy(_image)
	if sx < 0 then image = flipX(image) end
	if sy < 0 then image = flipY(image) end
	sx, sy = math.abs(sx), math.abs(sy)
	local imageX, imageY = getSize(image)
	local tx, ty
	if sx == 0 or sy == 0 then
		for y = 1, math.max(sy, 1) do
			output[1][y] = ""
			output[2][y] = ""
			output[3][y] = ""
		end
		return output
	else
		for y = 1, sy do
			for x = 1, sx do
				tx = math.ceil((x / sx) * imageX)
				ty = math.ceil((y / sy) * imageY)
				if not noRepeat then
					output[1][y] = (output[1][y] or "")..image[1][ty]:sub(tx,tx)
				else
					output[1][y] = (output[1][y] or "").." "
				end
				output[2][y] = (output[2][y] or "")..image[2][ty]:sub(tx,tx)
				output[3][y] = (output[3][y] or "")..image[3][ty]:sub(tx,tx)
			end
		end
		if noRepeat then
			for y = 1, imageY do
				for x = 1, imageX do
					if image[1][y]:sub(x,x) ~= " " then
						tx = math.ceil(((x / imageX) * sx) - ((0.5 / imageX) * sx))
						ty = math.ceil(((y / imageY) * sy) - ((0.5 / imageY) * sx))
						output[1][ty] = stringWrite(output[1][ty], tx, image[1][y]:sub(x,x))
					end
				end
			end
		end
		return output
	end
end
nfte.stretchImage = stretchImage

pixelateImage = function(image, amntX, amntY)
	assert(checkValid(image), "Invalid image.")
	local imageX, imageY = getSize(image)
	return stretchImage(stretchImage(image,imageX/math.max(amntX,1), imageY/math.max(amntY,1)), imageX, imageY)
end
nfte.pixelateImage = pixelateImage

merge = function(...)
	local images = {...}
	local output = {{},{},{}}
	local imageX, imageY = 0, 0
	for i = 1, #images do
		imageY = math.max(imageY, #images[i][1][1]+(images[i][3]-1))
		for y = 1, #images[i][1][1] do
			imageX = math.max(imageX, #images[i][1][1][y]+(images[i][2]-1))
		end
	end

	-- will later add code to adjust X/Y positions if negative values are given

	local image, xadj, yadj
	local tx, ty
	for y = 1, imageY do
		output[1][y] = {}
		output[2][y] = {}
		output[3][y] = {}
		for x = 1, imageX do
			for i = 1, #images do
				image, xadj, yadj = images[i][1], images[i][2], images[i][3]
				tx, ty = x-(xadj-1), y-(yadj-1)
				output[1][y][x] = output[1][y][x] or " "
				output[2][y][x] = output[2][y][x] or " "
				output[3][y][x] = output[3][y][x] or " "
				if image[1][ty] then
					if (image[1][ty]:sub(tx,tx) ~= "") and (tx >= 1) then
						output[1][y][x] = (image[1][ty]:sub(tx,tx) == " " and output[1][y][x] or image[1][ty]:sub(tx,tx))
						output[2][y][x] = (image[2][ty]:sub(tx,tx) == " " and output[2][y][x] or image[2][ty]:sub(tx,tx))
						output[3][y][x] = (image[3][ty]:sub(tx,tx) == " " and output[3][y][x] or image[3][ty]:sub(tx,tx))
					end
				end
			end
		end
		output[1][y] = table.concat(output[1][y])
		output[2][y] = table.concat(output[2][y])
		output[3][y] = table.concat(output[3][y])
	end
	return output
end
nfte.merge = merge

rotateImage = function(image, angle, originX, originY)
	local output = {{},{},{}}
	local realOutput = {{},{},{}}
	local tx, ty
	local imageX, imageY = getSize(image)
	if imageX == 0 or imageY == 0 then
		return image
	end
	local originX, originY = originX or math.floor(imageX / 2), originY or math.floor(imageY / 2)
	local rotatePoint = function(x, y, angle, originX, originY)
		return
			round( (x-originX) * math.cos(angle) - (y-originY) * math.sin(angle) ) + originX,
			round( (x-originX) * math.sin(angle) + (y-originY) * math.cos(angle) ) + originY
	end
	local corners = {
		{rotatePoint(1, 		1, 		angle, originX, originY)},
		{rotatePoint(imageX, 	1, 		angle, originX, originY)},
		{rotatePoint(1, 		imageY, angle, originX, originY)},
		{rotatePoint(imageX, 	imageY, angle, originX, originY)},
	}
	local minX = math.min(corners[1][1], corners[2][1], corners[3][1], corners[4][1])
	local maxX = math.max(corners[1][1], corners[2][1], corners[3][1], corners[4][1])
	local minY = math.min(corners[1][2], corners[2][2], corners[3][2], corners[4][2])
	local maxY = math.max(corners[1][2], corners[2][2], corners[3][2], corners[4][2])

	for y = 1, (maxY - minY) + 1 do
		output[1][y] = {}
		output[2][y] = {}
		output[3][y] = {}
		for x = 1, (maxX - minX) + 1 do
			tx, ty = rotatePoint(x + minX - 1, y + minY - 1, -angle, originX, originY)
			output[1][y][x] = " "
			output[2][y][x] = " "
			output[3][y][x] = " "
			if image[1][ty] then
				if tx >= 1 and tx <= #image[1][ty] then
					output[1][y][x] = image[1][ty]:sub(tx,tx)
					output[2][y][x] = image[2][ty]:sub(tx,tx)
					output[3][y][x] = image[3][ty]:sub(tx,tx)
				end
			end
		end
	end
	for y = 1, #output[1] do
		output[1][y] = table.concat(output[1][y])
		output[2][y] = table.concat(output[2][y])
		output[3][y] = table.concat(output[3][y])
	end
	return output, math.ceil(minX), math.ceil(minY)
end
nfte.rotateImage = rotateImage

help = function(input)
	local helpOut = {
		loadImageData = "Loads an NFT image from a string input.",
		loadImage = "Loads an NFT image from a file path.",
		convertFromNFP = "Loads a table NFP image into a table NFT image, same as what loadImage outputs.",
		drawImage = "Draws an image. Does not support transparency, sadly.",
		drawImageTransparent = "Draws an image. Supports transparency, but not as fast as drawImage.",
		drawImageCenter = "Draws an image centered around the inputted coordinates. Does not support transparency.",
		drawImageCentre = "Draws an image centred around the inputted coordinates. Does not support transparency.",
		drawImageCenterTransparent = "Draws an image centered around the inputted coordinates. Supports transparency, but not quite as fast as drawImageCenter.",
		drawImageCentreTransparent = "Draws an image centred around the inputted coordinates. Supports transparency, but not quite as fast as drawImageCentre.",
		flipX = "Returns the inputted image, but flipped horizontally.",
		flipY = "Returns the inputted image, but flipped vertically.",
		grayOut = "Returns the inputted image, but with the colors converted into grayscale as best I could.",
		greyOut = "Returns the inputted image, but with the colors converted into greyscale as best I could.",
		lighten = "Returns the inputted image, but with the colors lightened.",
		darken = "Returns the inputted image, but with the colors darkened.",
		stretchImage = "Returns the inputted image, but it's been stretched to the inputted size. If the fourth argument is true, it will spread non-space characters evenly in the image.",
		pixelateImage = "Returns the inputted image, but pixelated to a variable degree.",
		merge = "Merges two or more images together.",
		crop = "Crops an image between points (X1,Y1) and (X2,Y2).",
		rotateImage = "Rotates an image, and also returns how much the image center's X and Y had been adjusted.",
		colorSwap = "Swaps the colors of a given image with another color, according to an inputted table.",
		colourSwap = "Swaps the colours of a given image with another colour, according to an inputted table."
	}
	return helpOut[input] or "No such function."
end
nfte.help = help

return nfte
