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
