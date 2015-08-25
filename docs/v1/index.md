# sc-sprites Version 1 Specification

## About this document

This document defines the sc-sprites file format. For general information,
please [see the index page](..).


## Version Specifier

All sc-sprites formats must begin in the same format. This specifies that the
file is indeed of type sc-sprites, the format version it follows, and the
extended format identifier, if any.

The file MUST begin with the string `source comb stylesheet;`. Following this is
an ASCII-encoded integer, then a `;` character. This integer represents the
format version number. This number must not be less than 1 (0 is not allowed),
and must not be greater than 999 (1000 is not allowed).

If the file follows the format exactly, another semicolon must be added, e.g.
`source comb stylesheet;1;;`.

If the next two characters form `x-`, then the file uses the provided version
as a base, however it may also use non-standard extensions. There must then be a
string of alpha-numeric characters including (but not starting with) `-`,
identifying the extended format. There must then be another `;`. An example:
`source comb stylesheet;1;x-json;`.


## File Structure

An sc-sprites file is split into three main sections:

- Header
- Coordinates
- Canvas


### Header

The header begins with the Version Specifier. Afterwards is a list of
attributes, separated by `;`. The header is terminated by a semicolon and a
line-feed.

In version one, there is a single attribute. It is an ASCII-encoded, non-zero,
positive integer. This number is the `cell-width` - the size, in pixels, of each
canvas cell. Each cell is square in shape, so the `cell-width` is really also
the `cell-height`. It is recommended to use a `cell-width` that allows sprites
to be organised on the canvas easily with minimal space between (i.e. `1` is not
a good `cell-width`).


### Coordinates

Next is a set of key-value pairs, which identify the positioning of the sprites
on the canvas. Each pair is separated by a line-feed. There must be no blank
lines in the coordinates section. This section is terminated by a single `=`,
followed by a line-feed. The previous key-value pair must still be terminated by
a line-feed before the `=`.

Keys and values must be separated by the `=` character. This character may be
padded with white-space, which must be ignored. Extra white-space must not
prefix the key or suffix the value.

The key must only contain letters, numbers, or a `.`. The key is case-sensitive.
There must not be two consecutive `.` characters in a key, and the key must not
begin or end with a `.`. Implementations should nest the dot-separated
identifiers in key-value stores. Where multiple keys contain number-only
identifiers at the same nested point (e.g. with keys `tile.building.1`,
`tile.building.2`, `tile.building.3`), implementations should use an array-like
construct.

The value must take a very specific format. It must be space-separated groups of
ASCII-encoded integers. It takes the format of `{pos} {size} {scale} {anim}`,
where:

- `{pos}` consists of two numbers separated by the `,` character.
- `{size}` consists of two numbers separated by the `x` character.
- `{scale}` consists of a single number.
- `{anim}` consists of two numbers separated by the `@` character.

These groups must be separated by a single space character, and must be
intolerant of extra white-space. `{anim}` may be omitted - if it is, then it
defaults to `1@0` and the space trailing after `{scale}` must also be omitted.
If the first value of `{anim}` is specified, the second must also be specified.
All other values must be specified.

`{pos}` represents the `y,x` position of the sprite on the canvas, in cells,
with `0,0` being the top-left. `y` specifies the number of cells to move down,
and `x` the number to move across to find the top-left corner of the sprite. For
animated sprites, it must be the position of the FIRST frame, with the remaining
frames having the same `y` and sitting side-by-side in order (left first).

`{size}` represents the width and height of the sprite, in cells (width first).
For animated sprites, it must be the width and height of the FIRST frame, and
the rest of the frames must maintain the same size. Both numbers must not be
zero.

`{scale}` represents the scale at which to draw the sprite at. It must not be
zero. `1` represents original size, `2` double size, `3` triple size, and so on.
The actual size that the sprite is drawn at may be different, depending on the
situation.

`{anim}` represents some info about the animation, in the format `frames@rate`,
where `frames` is the number of frames in the animation and `rate` is the number
of frames to play in a second. `frames` must not be zero. If `frames` is `1`,
then `rate` should be ignored. In this case, omitting `rate` or using an invalid
character within `rate` should still cause an error. `rate` may be zero if
`frames` is `1`, however must be non-zero otherwise.


### Canvas

The remainder of the file is must be a PNG-encoded bitmap canvas. It is enough
to simply append the data of a PNG file to the end of the previous sections.
This canvas contains the actual sprite images. It must have a width and height
that are multiples of `cell-width`. It is recommended to order the sprites on
the canvas such that as little space as possible does not contain a sprite.
