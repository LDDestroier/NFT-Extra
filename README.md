# NFT-Extra

NFT Extra is a standalone expansion and general API for the NFT image format, made to ease the process of transforming and drawing NFT images.

Stretch, merge, flip, rotate, and more. Can be loaded in a regular Lua 5.2 terminal as well.

## Documentation

### Image loading/unloading
```
imageData = nfte.loadImage( pathToImage )
```
Loads an image from a specific path.

```
imageData = nfte.loadImageData( contentsOfImage )
```
Loads an image based on the contents of the image, rather than the path to the image.

```
imageData = nfte.convertFromNFP( contentsOfNFP )
```
Loads an image based on the contents of an NFP image.

```
imageContents = nfte.unloadImage( imageData )
```
Unloads the image data into a string format that can then be written to disk.


### Image inspection
```
x, y = nfte.getSize( imageData )
```
Returns the width and height of an image.

```
print( nfte.help( functionName ) )
```
Returns a basic description of one of the functions.


### Image manipulation
```
croppedImage = nfte.crop( imageData, x1, y1, x2, y2 )
```
Crops an image to (x1, y1) through (x2, y2)

```
tintedImage = nfte.colorSwap( imageData, textConvert, backConvert )
```
Takes two (or one) table(s) textConvert and backConvert, and uses them to swap the colors of each pixel in an image.
textConvert and backConvert are formatted as such:
```
textConvert = {
  ["7"] = "5",
  ["8"] = "a",
  ["9"] = "3",
  ["a"] = "8",
  ["b"] = "4",
  ...
}
```
Using that would replace every text color 7 with 5, every 8 with a, every 9 with 3, et cetera.
You British wankers can also call nfte.colourSwap().

```
flippedImage = nfte.flipX( imageData )
```
Returns the image, but flipped horizontally.
This will also (try to) flip all block characters.

```
flippedImage = nfte.flipY( imageData )
```
Returns the image, but flipped vertically.
Unlike nfte.flipX, this doesn't touch block characters, as that would be a nightmare to program. Oh, well.

```
rectangle = nfte.makeRectangle( width, height, char, textColor, backColor )
```
Returns a blank, rectangular imageData with the inputted width and height, character, and text and background colors.

```
grayImage = nfte.grayOut( imageData )
```
Returns the image, but grayed out. You weird British folk can also call nfte.greyOut().

```
lighterImage = nfte.lighten( imageData, amount )
```
Returns the image, but with all the colors lightened 'amount' times.
This doesn't alter the palette, it just replaces all colors with one that's a lighter shade.

```
darkerImage = nfte.darken( imageData, amount )
```
Returns the image, but with all the colors darkened 'amount' times.
This doesn't alter the palette, again.

```
stretchedImage = nfte.stretchImage( imageData, newWidth, newHeight, doNotRepeatChar )
```
Scales the image to (newWidth, newHeight).
If doNotRepeatChar is true, it will not repeat characters within the image, which would make images with text in them read like "hhheeellllllooo   wwwooorrrlllddd" instead of " h  e  l  l  o     w  o  r  l  d ".

```
pixelyImage = nfte.pixelateImage( imageData, amountX, amountY )
```
Basically, scales the image down by (amountX, amountY), then back up. Results in a pixelated image.

```
mergedImage = nfte.merge( {imageData1, x1, y1}, {imageData2, x2, y2}, ... )
```
Merges multiple images at different (x, y) positions into one big image. imageData1 will layer over imageData2, 2 over 3, et cetera.
This function is useful for reducing flickering, as you can simply merge all other images together and render it all at once.

```
rotatedImage = nfte.rotateImage( imageData, angles, originX, originY )
```
Rotates the image around (originX, originY) by 'angles' degrees. The origin defaults to the center of the image.


### Image drawing
```
nfte.drawImage( imageData, x, y )
```
Draws an image at (x, y). All transparency is set to black.

```
nfte.drawImageTransparent(image, x, y)
```
Draws an image at (x, y), but with transparency. As such, it's not quite as speedy as the former.

```
nfte.drawImageCenter( image, x, y )
```
Draws an image centered around (x, y). All transparency is set to black.
You British peasants can call nfte.drawImageCentre().

```
nfte.drawImageCenterTransparent( image, x, y )
```
Draws an image centered around (x, y). And it's also got transparency, hey. Again, it's not quite as speedy as the former.
Those formerly of the EU can call nfte.drawImageCentreTransparent().
