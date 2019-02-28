local tArg = {...}
local nftePath = "/nfte.lua"
if not fs.exists(nftePath) then
	local haych = http.get("https://raw.githubusercontent.com/LDDestroier/NFT-Extra/master/nfte.lua")
	if haych then local file = fs.open(nftePath, "w") file.write(haych.readAll()) file.close() else error("Can't download NFTE! How can I work as a good demo now!?") end
end
local nfte = dofile "nfte.lua"
local scr_x, scr_y = term.getSize()
local map = {
	x = 0, y = 0,
	pitch = 0,
	rotate = 0,
	horizon = 9,
	zoom = 1,
}
local keysDown, miceDown = {}, {}
if tArg[1] then map.image = nfte.loadImage(tArg[1]) else map.image = {
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
		}, {
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
		}, {
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
		},
	}
end
local imX, imY = nfte.getSize(map.image)
map.image = nfte.stretchImageKeepAspect(map.image, scr_x, scr_y)
local tsv = function(visible) if term.current().setVisible then term.current().setVisible(visible) end end
local render = function()
	tsv(false)
	local im = nfte.rotateImage(map.image, math.rad(map.rotate))
	local rimX, rimY = nfte.getSize(im)
	im = nfte.stretchImage(im, rimX * map.zoom, rimY * math.cos(math.rad(map.pitch)) * map.zoom)
	term.clear()
	nfte.drawImageCenter(im, math.floor(0.5 + scr_x / 2 + map.x), (0.5 + scr_y / 2 + map.y))
	tsv(true)
end
render()
local control = function()
	local doRender = false
	while true do
		if miceDown[1] then
			map.rotate = (miceDown[1][1] + math.floor(scr_x / 2)) * 8
			map.pitch = ((miceDown[1][2] - scr_y / 2) / (scr_y / 2)) * 90
			render()
		else
			if keysDown[keys.x] then
				sleep(0) return
			end if keysDown[keys.left] then
				map.rotate = map.rotate - 2 doRender = true
			end if keysDown[keys.right] then
				map.rotate = map.rotate + 2 doRender = true
			end if keysDown[keys.up] then
				map.pitch = map.pitch + 4 doRender = true
			end if keysDown[keys.down] then
				map.pitch = map.pitch - 4 doRender = true
			end if keysDown[keys.w] then
				map.zoom = map.zoom + 0.02 doRender = true
			end if keysDown[keys.s] then
				map.zoom = map.zoom - 0.02 doRender = true
			end if keysDown[keys.a] then
				map.x = map.x + 1 doRender = true
			end if keysDown[keys.d] then
				map.x = map.x - 1 doRender = true
			end if keysDown[keys.e] then
				map.y = map.y + 1 doRender = true
			end if keysDown[keys.q] then
				map.y = map.y - 1 doRender = true
			end
			if doRender then render() doRender = false end
		end
		sleep(0.05)
	end
end
local getInput = function()
	while true do
		local evt = {os.pullEvent()}
		if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then miceDown[evt[2]] = {evt[3],evt[4]}
		elseif evt[1] == "mouse_up" then miceDown[evt[2]] = nil
		elseif evt[1] == "key" then keysDown[evt[2]] = true
		elseif evt[1] == "key_up" then keysDown[evt[2]] = nil end
	end
end
parallel.waitForAny(getInput, control)
