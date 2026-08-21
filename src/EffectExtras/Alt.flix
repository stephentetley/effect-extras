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


pub mod EffectExtras.Alt {
    
    use EffectExtras.Fail

    // An effect for recoverable errors within a "run".
    // Alt is epexted to be layered above Fail
    pub eff Alt {
        def alternative(): Bool
    }

    // Note - order of hanlders is crucial
    pub type alias Alternative = Alt + Fail

    pub def handleWithResult(f: a -> b \ ef): a -> Result[String, b] \ ef - Alternative = x -> {
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

    pub def handleWithOption(f: a -> b \ ef): a -> Option[b] \ ef - Alternative = x -> {
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

    pub def runWithResult(f: Unit -> a \ ef): Result[String, a] \ ef - Alternative =
        handleWithResult(f)()

    pub def runWithDefault(d: a, f: Unit -> a \ ef): a \ ef - Alternative = 
        handleWithResult(f)() |> Result.getWithDefault(d)

    pub def alt(p: Unit -> a \ ef1, q: Unit -> a \ ef2 ): a \ Alt + ef1 + ef2 = 
        if (Alt.alternative()) p() else q()

    pub def optional(p: Unit -> a \ ef ): Option[a] \ Alt + ef = 
        alt(() -> { let a = p(); Some(a)}, () -> None)

    pub def withDefault(p: Unit -> a \ ef, d: a): a \ Alt + ef = 
        alt(p, _ -> d)

    pub def swapError(msg: String, p: Unit -> a \ ef): a \ Alternative + ef = 
        alt(p, _ -> Fail.report(msg))
        

}

