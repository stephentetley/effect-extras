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

    pub def runWithResult(f: Unit -> a \ ef): Result[String, a] \ ef - Fail = 
        handleWithResult(f)()

    pub def runWithResultOfIoError(f: Unit -> a \ ef): Result[IoError, a] \ ef - Fail = 
        handleWithResult(f)() |> Result.mapErr(s -> IoError(IoError.ErrorKind.Other, s))


}
