local nftePath = "/nfte"
if not fs.exists(nftePath) then
	local haych = http.get("https://raw.githubusercontent.com/LDDestroier/NFT-Extra/master/nfte.lua")
	if haych then
		local file = fs.open(nftePath, "w")
		file.write(haych.readAll())
		file.close()
	else
		error("Can't download NFTE! How can I work as a good demo now!?")
	end
end

nfte = dofile("nfte")

local scr_x, scr_y = term.getSize()
local mx, my = scr_x / 2, scr_y / 2
local x, y = mx, my

-- demo image, a creepy face thing
local origImage = {
	{
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"                   ",
		"             19x14 ",
	},
	{
		"   fff      fff    ",
		"  fffff    fffff   ",
		"  fff7f    fff7f   ",
		"  fffff    fffff   ",
		"   fff      fff    ",
		"           ffffff  ",
		"        ffffffffff ",
		"   fffffffffffffff ",
		"  f77fffffffffff7f ",
		" f77ffffffffff7777f",
		"f77ffffffffff77777f",
		"f77fffffffffff7777f",
		"f77ffffffffffff777f",
		"fffffffffffffffffff",
	},
	{
		"   000      000    ",
		"  00000    00000   ",
		"  000f0    000f0   ",
		"  00000    00000   ",
		"   000      000    ",
		"           aaaaaa  ",
		"        aaa22222aa ",
		"   eeeaaa222222aaa ",
		"  effaa222222aaafe ",
		" effaa222222aaffffe",
		"effaa2222a22afffffe",
		"effa222aa222aaffffe",
		"effa22aa22222aafffe",
		"eeeeeeeeeeeeeeeeeee",
	},
}
local image = origImage

local render = function()
	term.setBackgroundColor(colors.black)
	while true do
		term.clear()
		nfte.drawImageCenter(
			image,
			math.floor(x),
			math.floor(y)
		)
		sleep(0.05)
	end
end

local demo = function()
	sleep(0.5)
	local ox, oy = nfte.getSize(origImage)
	for i = 0, 10 do
		image = nfte.stretchImage( origImage, ox + i * 5, oy + i, true )
		sleep(0.05)
	end
	sleep(0.1)
	for i = 10, -4, -1 do
		image = nfte.stretchImage( origImage, ox + i * 5, oy + i, true )
		sleep(0.05)
	end
	sleep(0.1)
	for i = -4, 0 do
		image = nfte.stretchImage( origImage, ox + i * 5, oy + i, true )
		sleep(0.05)
	end
	sleep(0.1)
	for i = 0, 360, 2 do
		image = nfte.rotateImage( origImage, math.rad(i) )
		sleep(0.05)
	end
	image = origImage
	sleep(0.05)
	for i = ox, -ox*2, -2 do
		image = nfte.stretchImage( origImage, i, oy, true )
		sleep(0.05)
	end
	sleep(0.05)
	for i = oy, -oy*2, -2 do
		image = nfte.stretchImage( origImage, -ox*2, i, true )
		sleep(0.05)
	end
	sleep(0.05)
	for i = -ox*2, ox, 2 do
		image = nfte.stretchImage( origImage, i, -oy*2, true )
		sleep(0.05)
	end
	sleep(0.05)
	for i = -oy*2, oy, 2 do
		image = nfte.stretchImage( origImage, ox, i, true )
		sleep(0.05)
	end
	sleep(0.1)
	for i = 1, 4 do
		if i % 2 == 0 then
			image = origImage
			sleep(0.25)
		else
			image = nfte.grayOut(origImage)
			sleep(0.5)
		end
	end
	sleep(0.2)
	for i = 0, 2 do
		image = nfte.lighten(origImage, i)
		sleep(0.1)
	end
	sleep(1)
	for i = 1, -2, -1 do
		image = nfte.lighten(origImage, i)
		sleep(0.1)
	end
	sleep(1)
	for i = -2, 0 do
		image = nfte.lighten(origImage, i)
		sleep(0.1)
	end
	sleep(0.2)
	for i = 0, 4 do
		image = nfte.pixelateImage(origImage, i, i)
		sleep(0.2)
	end
	sleep(0.5)
	for i = 4, 0, -1 do
		image = nfte.pixelateImage(origImage, i, i)
		sleep(0.2)
	end
end

-- I use parallel because it's easier, hoh.
parallel.waitForAny(render, demo)
