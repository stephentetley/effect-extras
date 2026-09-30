/*
 * Copyright 2026 Stephen Tetley
 *
 * Use of this source code is governed by the Apache 2.0 license
 * that can be found in the LICENSE.md file.
 */


pub mod EffectExtras.Fail {

    use IoError.ErrorKind
    use IoError.IoError

    // An effect for error observable by "running" but not 
    // observable within a "run" itself.
    pub eff Fail[err: Type] {
        def report(err: err): Void
    }


    pub def handleWithResult(f: a -> b \ ef): a -> Result[err, b] \ ef - Fail[err] = x -> {
        run {
            Ok(f(x))
        } with handler Fail {
            def report(err, _) = Err(err)
        }
    }

    // The error message is lost
    pub def handleWithOption(f: a -> b \ ef): a -> Option[b] \ ef - Fail[err] = x -> {
        run {
            Some(f(x))
        } with handler Fail {
            def report(_, _) = None
        }
    }

    // The error message is lost
    pub def handleWithDefault(d: b, f: a -> b \ ef): a -> b \ ef - Fail[err] = x -> {
        run {
            f(x)
        } with handler Fail {
            def report(_, _) = d
        }
    }

    // We can't have a safe handle in IO matching the signature for a default 
    // handler - i.e. :
    // > handle(f: a -> b \ ef): a -> b \ ef + IO - Fail
    //
    // because Fail is polymorphic.
    // 
    // We can make a quite close unsafe version but it relies on `bug!`
    // and doesn't solve the polymorphism problem:
    //
    // pub def unsafe_handle(f: a -> b \ ef): a -> b \ ef - Fail[err] + IO with ToString[err] = x -> {
    //     run {
    //         f(x)
    //     } with handler Fail {
    //         def report(msg, _) = { println("${msg}"); bug!("Fail") }
    //     }
    // }
    //
    // ... It seems best not to bother with it
    //




    pub def runWithResult(f: Unit -> a \ ef): Result[err, a] \ ef - Fail[err] = 
        handleWithResult(f)()

    pub def runWithOption(f: Unit -> a \ ef): Option[a] \ ef - Fail[err] = 
        handleWithOption(f)()

    pub def runWithDefault(d: a, f: Unit -> a \ ef): a \ ef - Fail[err] = 
        handleWithResult(f)() |> Result.getWithDefault(d)

    pub def runWithResultOfIoError(f: Unit -> a \ ef): Result[IoError, a] \ ef - Fail[err] with ToString[err] = 
        handleWithResult(f)() |> Result.mapErr(e -> IoError(IoError.ErrorKind.Other, ToString.toString(e)))

    pub def fromResult(x: Result[err, a]): a \ Fail[err] = match x {
        case Ok(a)  => a 
        case Err(e) => Fail.report(e)
    }

    pub def fromOption(x: Option[a]): a \ Fail[Unit] = match x {
        case Some(a)    => a 
        case None       => Fail.report(())
    }

    pub def fromOptionWithFail(err: err, x: Option[a]): a \ Fail[err] = match x {
        case Some(a)    => a 
        case None       => Fail.report(err)
    }

    // Useful for Java interop
    pub def assertNotNull(x: a): Unit \ Fail[Unit] = 
        if (not Object.isNull(x)) () else Fail.report(())

    // Useful for Java interop
    pub def assertNotNullWithFail(err: err, x: a): Unit \ Fail[err] = 
        if (not Object.isNull(x)) () else Fail.report(err)


    // Useful for Java interop - expression version of `assertNotNull`
    pub def returnNotNull(x: a): a \ Fail[Unit] =
        if (not Object.isNull(x)) x else Fail.report(())

    // Useful for Java interop - expression version of `assertNotNull`
    pub def returnNotNullWithFail(err: err, x: a): a \ Fail[err] =
        if (not Object.isNull(x)) x else Fail.report(err)

}

