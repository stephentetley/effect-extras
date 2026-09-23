# effect-extras

An incubator for Flix effects

Two so far:

* Fail - Failure is only detectable as a result of running the computation
* Alt - extends `Fail` with the ability to run an alternative branch on failure

v0.5.0 (September 2026) 
Fail is now polymorphic in the error type.


Note - from version 0.4.0 `Alt` and `Fail` have changeed to represent a layering.
`Fail` can be used by itself but layering `Alt` on top gets a lot more 
functionality. `Alt` needs `Fail` to be useful. 

Also note Flix has very precise effect signatures - functions that collectively 
belong togther in an API will have different effect signatures if they are 
implemented with just `Alt` or `Fail`.
