/*
 * Copyright 2026 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pub mod EffectExtras.Fail {

    use IoError.ErrorKind
    use IoError.IoError

    // An effect for error observable by "running" but not 
    // observable within a "run" itself.
    pub eff Fail {
        def report(msg: String): Void
    }


    pub def handleWithResult(f: a -> b \ ef): a -> Result[String, b] \ ef - Fail = x -> {
        run {
            Ok(f(x))
        } with handler Fail {
            def report(s, _) = Err(s)
        }
    }

    // The error message is lost
    pub def handleWithOption(f: a -> b \ ef): a -> Option[b] \ ef - Fail = x -> {
        run {
            Some(f(x))
        } with handler Fail {
            def report(_, _) = None
        }
    }


    pub def handle(f: a -> b \ ef): a -> b \ ef - Fail + IO = x -> {
        run {
            f(x)
        } with handler Fail {
            def report(msg, _) = { println(msg); bug!("Fail") }
        }
    }


    // With this handler failure is not recoverable - an error message 
    // is printed and the program stops.
    @DefaultHandler
    pub def runWithIO(f: Unit -> a \ ef): a \ ef + IO - Fail = 
        handle(f)()


    pub def runWithResult(f: Unit -> a \ ef): Result[String, a] \ ef - Fail = 
        handleWithResult(f)()

    pub def runWithOption(f: Unit -> a \ ef): Option[a] \ ef - Fail = 
        handleWithOption(f)()

    pub def runWithDefault(d: a, f: Unit -> a \ ef): a \ ef - Fail = 
        handleWithResult(f)() |> Result.getWithDefault(d)

    pub def runWithResultOfIoError(f: Unit -> a \ ef): Result[IoError, a] \ ef - Fail = 
        handleWithResult(f)() |> Result.mapErr(s -> IoError(IoError.ErrorKind.Other, s))

    pub def fromResult(x: Result[e, a]): a \ Fail  with ToString[e] = match x {
        case Ok(a)  => a 
        case Err(e) => Fail.report(ToString.toString(e))
    }

    pub def fromOption(x: Option[a]): a \ Fail = match x {
        case Some(a)    => a 
        case None       => Fail.report("fromOption(None)")
    }

    pub def fromOptionWithMessage(msg: String, x: Option[a]): a \ Fail = match x {
        case Some(a)    => a 
        case None       => Fail.report(msg)
    }

    // Useful for Java interop
    pub def assertNotNull(x: a): Unit \ Fail = 
        if (not Object.isNull(x)) () else Fail.report("object is null")

    // Useful for Java interop
    pub def assertNotNullWithMessage(msg: String, x: a): Unit \ Fail = 
        if (not Object.isNull(x)) () else Fail.report(msg)


    // Useful for Java interop - expression version of `assertNotNull`
    pub def returnNotNull(x: a): a \ Fail =
        if (not Object.isNull(x)) x else Fail.report("object is null")

}

