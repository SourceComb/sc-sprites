# sc-sprites - Lua/Generic Reference Implementation

## General usage info

You will need to create an adapter for whatever image loading library you want
to use. It must be a function that takes the PNG data, and returns a table of
functions:

- `:getWidth()` - gets the width of the PNG canvas
- `:getHeight()` - gets the height of the PNG canvas
- `:getImage()` - gets the image as whatever is most useful to you (usually
  just the image object a constructor returned)

Please see [the main repo README](https://github.com/SourceComb/sc-sprites/blob/master/README.md)
or [the site](http://sourcecomb.github.io/sc-sprites/) for more info.
