/*
 * Copyright 2026 Stephen Tetley
 *
 * Use of this source code is governed by the Apache 2.0 license
 * that can be found in the LICENSE.md file.
 */


pub mod EffectExtras.Alt {
    
    use EffectExtras.Fail

    // An effect for recoverable errors within a "run".
    // Alt is expected to be layered above Fail
    pub eff Alt {
        def alternative(): Bool
    }

    // Note - order of hanlders is crucial
    pub type alias Alternative[err] = Alt + Fail[err]


    /// Interpret fail with Result, rethrow with Fail if the aswer is `Err`
    pub def handle(f: a -> b \ ef): a -> b \ ef + Fail[err] - Alt = x -> {
        let ans = run {
            Ok(f(x))
        } with handler Fail {
            def report(msg, _) = Err(msg)
        }with handler Alt {
            def alternative(k) = match k(true) {
                case Ok(res) => Ok(res)
                case Err(_)  => k(false)
            }
        };
        match ans {
            case Ok(b)      => b
            case Err(msg)   => Fail.report(msg)
        }
    }


    pub def handleWithResult(f: a -> b \ ef): a -> Result[err, b] \ ef - Alternative[err] = x -> {
        run {
            Ok(f(x))
        } with handler Fail {
            def report(msg, _) = Err(msg)
        } with handler Alt {
            def alternative(k) = match k(true) {
                case Ok(res) => Ok(res)
                case Err(_)  => k(false)
            }
        }
    }

    pub def handleWithOption(f: a -> b \ ef): a -> Option[b] \ ef - Alternative[err] = x -> {
        run {
            Some(f(x))
        } with handler Fail {
            def report(_, _) = None
        } with handler Alt {
            def alternative(k) = match k(true) {
                case Some(res) => Some(res)
                case None      => k(false)
            }
        } 
    }

    pub def handleWithDefault(d: b, f: a -> b \ ef): a -> b \ ef - Alternative[err] = x -> {
        handleWithOption(f)(x) |> Option.getWithDefault(d)
    }


    // We can't have a default handler because we need to discharge 
    // two effects - `Alt` and `Fail`, and `Fail` can't have a (safe) 
    // `runWithIO` producing an unwrapped answer (not Option or Result).

    pub def runAlt(f: Unit -> a \ ef): a \ ef + Fail[err] - Alt =
        handle(f)()

    pub def runWithResult(f: Unit -> a \ ef): Result[err, a] \ ef - Alternative[err] =
        handleWithResult(f)()

    pub def runWithDefault(d: a, f: Unit -> a \ ef): a \ ef - Alternative[err] = 
        handleWithResult(f)() |> Result.getWithDefault(d)

    pub def alt(p: Unit -> a \ ef1, q: Unit -> a \ ef2 ): a \ Alt + ef1 + ef2 = 
        if (Alt.alternative()) p() else q()

    pub def optional(p: Unit -> a \ ef ): Option[a] \ Alt + ef = 
        alt(() -> { let a = p(); Some(a)}, () -> None)

    pub def withDefault(p: Unit -> a \ ef, d: a): a \ Alt + ef = 
        alt(p, _ -> d)

    pub def swapError(err: err, p: Unit -> a \ ef): a \ Alternative[err] + ef = 
        alt(p, _ -> Fail.report(err))
        

}

