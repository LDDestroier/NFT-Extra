# NFT-Extra

NFT Extra is a standalone expansion of the NFT API, made to ease the process of transforming NFT images.

Stretch, merge, flip, rotate, and more.

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

(finish later)
