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


    // An effect for recoverable errors within a "run".
    pub eff Alt {
        def alternative(): Bool
        def failure(msg: String): Void
    }

    pub def handleWithResult(f: a -> b \ ef): a -> Result[String, b] \ ef - Alt = x -> {
        run {
            Ok(f(x))
        } with handler Alt {

            def alternative(k) = match k(true) {
                case Ok(res) => Ok(res)
                case Err(_) => k(false)
            }

            def failure(msg, _) = Err(msg)
        }
    }
    
    pub def runWithResult(f: Unit -> a \ ef): Result[String, a] \ ef - Alt =
        handleWithResult(f)()


    pub def alt(p: Unit -> a \ ef1, q: Unit -> a \ ef2 ): a \ Alt + ef1 + ef2 = 
        if (Alt.alternative()) p() else q()

    pub def optional(p: Unit -> a \ ef ): Option[a] \ Alt + ef = 
        alt(_ -> { let a = p(); Some(a)}, _ -> None)


    pub def withDefault(p: Unit -> a \ ef, d: a): a \ Alt + ef = 
        alt(p, _ -> d)

}
