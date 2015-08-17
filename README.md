# sc-sprites - Format Specification

## About sc-sprites

sc-sprites is a simple file format for working with spritesheets. It is fairly
simple to edit sheets without many tools, and it is simple to load sprite
information into a game or animation.

sc-sprites is a format created by Source Comb Software to help tidy up assets
and simplify formats. It is accompanied by a simple editor (TBD) that focusses
on low-res pixel-focussed sprites.


## About this documentation

The sc-sprites documentation is located in a git repository, hosted at
https://github.com/SourceComb/sc-sprites. The master branch of this repository
simply contains this README. The gh-pages branch contains the documentation as a
Jekyll site, written in Markdown. You can see this documentation in HTML form at
http://sourcecomb.github.io/sc-sprites. This documentation provides general
information surrounding sc-sprites, as well as technical documents in the `docs`
subdirectory. The documentation for all format versions is available at the
[releases page], as zip archives of both the Jekyll site and the HTML site.

The repository also contains reference implementations for various languages and
frameworks. These are available in separate branches, named in the format
`<language>-<framework>`. Any language with a reference implementation will have
at least generic implementation, at the branch `<language>-generic`, which is
independent of framework. These implementations provide reading functionality,
and, where appropriate, creating and modifying functionality.

[releases page]: https://github.com/SourceComb/sc-sprites/releases
