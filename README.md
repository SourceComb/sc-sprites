# sc-sprites - JavaScript/Generic Reference Implementation #

> _**NOTE**: JavaScript doesn't always handle binary data the best, so by
> default this library tries to use an extension of `x-base64-canvas`, which
> stores the canvas section in base64 rather than as raw data._

> _**NOTE 2**: This library currently only exposes Common JS-style modules. We
> recognise that this may be a pain for some, and hope to fix this in the
> future. However, we much prefer the `require()` way of importing over AMD,
> and as far as we can tell there isn't an existing tool that produces
> AMD-compatible code. We will look into revising this at a later date._

This generic API provides the basic functionality of sc-sprites in JavaScript,
ignoring the actual graphics implementation. In order to make full use of this
library, you will need to provide an adapter that can handle reading PNG images
from a base64-encoded String.

> This library reuses a lot of the logic from the [Lua/Generic implementation]
> (specifically lua-generic-v0.2.0). It should also be noted that the API for
> this library is also intentionally designed to be better than that for
> Lua/Generic 0.2.0, which might very well only have been doable after seeing
> what a poorly put together API looks like.

[Lua/Generic implementation]: https://github.com/SourceComb/sc-sprites/tree/lua-generic


## Using ##

First, install using npm:

    $ npm install --save sc-sprites

Reminder for browser people: we currently only support `browserify`.

Then you'll need an sc-sprites file. Currently, this API requires that you use
the extension `x-base64-canvas`, and that your canvas be base64-encoded rather
than raw data.

Next, you'll need to `require('sc-sprites')` and create an adapter:

```js
var scspr = require('sc-sprites')

var adapter = new scspr.Adapter({
  constructImage: function (b64data) {/* ... */},
  getImageSize: function (image) {/* ... */}
})
```

The adapter functions must provide the following API:

```js
/**
 * b64data: A string containing the base64 encoded PNG data
 * returns: An object that is useful to your renderer
 */
function constructImage (b64data)

/**
 * image: An object as returned by constructImage
 * returns: Object
 *   width: The width (in pixels) of the canvas
 *   height: The height (in pixels) of the canvas
 */
function getImageSize (image)
```

You can then construct a spritesheet:

```js
var sheet = new scspr.Spritesheet(adapter, stringData)
// You might need the object returned by constructImage:
var sheetCanvas = sheet.getCanvas()
```

And now you have something you can start working with:

```js
var playerSprite = sheet.sprites.player.running.right
// You could also use sheet.getSprite('player.running.right')

console.log('player.running.right is on the spritesheet at (%d,%d)',
            playerSprite.pos.x, playerSprite.pos.y)
console.log('player.running.right is %dpx x %dpx',
            playerSprite.size.width, playerSprite.size.height)
console.log('player.running.right should be displayed at %dx',
            playerSprite.scale)
console.log('player.running.right has %d frames and runs at %d fps',
            playerSprite.ani.frames, playerSprite.ani.rate)

// You can iterate over frames (each of which implements the above interface)
playerSprite.frames.forEach(function (frame) {/* ... */})
// If you need the frames as an array for some reason:
playerSprite.frames.toArray()
```
