### v0.4.2
   Added `Alt.runAlt`

### v0.4.1
   Added default hander for `Fail`.
   Added `returnNotNull`

### v0.4.0
   Major refactor - rewrote `Alt` and `Fail` to be layered (`Alt` is layered over 
     and extends `Fail`)
   Added `assertNotNull` functions.

### v0.3.1
   Added `fromOption` functions.

### v0.3.0
   Added `runWithDefault` functions.
   Added `fromResult` functions.
   Moved the `Alt` "parser" combinators into the module `EffectExtras.Alt.Combinators`.

### v0.2.0
   Added many combinators to `Alt`.

### v0.1.0
   `Alt` effect for error recovery within a "run".
   `Fail` effect for error observable by "run" but not 
   recoverable within a "run".

