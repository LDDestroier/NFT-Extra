os.loadAPI(fs.combine(shell.dir(),"nfte"))
local image = nfte.loadImage("demo.nft")
local rimage, adjX, adjY
local scr_x, scr_y = term.getSize()
local angle = 0
local ts = tostring
while true do
    term.clear()
    rimage = nfte.stretchImage(nfte.rotateImage(image, angle),30,8)
    nfte.drawImageCenter(rimage,19,9)
    angle = angle + 0.03
    term.setCursorPos(1,scr_y)
    sleep(0.1)
end
--print(textutils.serialize(rimage))
