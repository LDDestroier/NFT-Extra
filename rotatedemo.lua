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

local nfte = dofile "nfte.lua"
local scr_x, scr_y = term.getSize()

local map = {
	x = 0,
	y = 0,
	xsize = scr_x - 6,
	ysize = scr_y - 10,
	rotate = 0,
	horizon = 9
}

map.image = {
	{
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
	},
	{
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
		"                                                   ",
	},
	{
		"ccccccccccccccccccccccccccccccccccccccccccccccccccc",
		"ccccccccccccccccccccccccccccccccccccccccccccccccccc",
		"ccccccccccccc0eccceec0ccc0ccc0ccc0ccee0cccccccccccc",
		"ccccccccccccccee00ee0000000c0000000eeeccccccccccccc",
		"cccccccccccccceee0ee00ee0000000e0e0ee0ccccccccccccc",
		"ccccccccccccc0eeeeee0e0ee00000ee0e0e00ccccccccccccc",
		"ccccccffffffccee0eee0eeee00e00eeee000cccccc777ccccc",
		"cccccccfff44c0ec00ee00ee00ee000eee0e0ccccc74477cccc",
		"cccccccc4444ccccc0cc0cc00cc0cc0cc0ccc0ccccc444ccccc",
		"cccbbbbbb0ebbbbbb444cccccccccccccccccccccce000ecccc",
		"ccbbbcbbb0bbbbbbb4ccc88cccccc88cccccccccceee0eeeecc",
		"cbbbccbb7bbbccccccccc8888888888ccccccccceee0feeeeec",
		"14411bbb7bb11111111118c8c88c8c81111114eeeeeffee44e1",
		"11111bb7bbb11111111117c8c88c8c71111144ee1eeffe44ee1",
		"1111bbb7cccc111111111717c77c717111111111ccccfeee111",
		"111cccccccccc11111111777177177711111111ccccccccc111",
		"11ccccccccccc1111111f7777777777f1111111cccccccccc11",
		"11ccccccccccc11111ffff77777777ffff11111cccccccccc11",
		"1cccccccccccc11ffffffffffffffffffffff11ccccccccccc1",
		"1ccccccccccccffffffffffffffffffffffffffccccccccccc1",
	}
}

local render = function()
	local im = map.image
	im = nfte.rotateImage(im, math.rad(map.rotate))
	im = nfte.stretchImage(im, map.xsize, map.ysize + math.abs(math.sin(math.rad(map.rotate * 2)) * 6))
	term.clear()
	nfte.drawImageCenter(im)
end

while true do
	local evt = {os.pullEvent()}
	if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
		map.rotate = (evt[3] + math.floor(scr_x / 2)) * 6
		map.ysize = scr_y * (math.floor(evt[4] - scr_y / 2) / 5)
	elseif evt[1] == "key" and evt[2] == keys.q then
		return
	end
	render()
end
