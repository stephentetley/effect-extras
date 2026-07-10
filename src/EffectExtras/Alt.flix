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


    pub def manyWith(combine: (a, ac) -> ac, init: ac, p: Unit -> a \ ef): ac \ (Alt + ef) = 
        def loop(k) = {
            let ans = EffectExtras.Alt.optional(p);
            match ans {
                case Some(a) => loop(ka -> { let ac = combine(a, ka); k(ac) })
                case None    => k(init)
            }
        };
        loop(x -> x)

    pub def many(p: Unit -> a \ ef): List[a] \ Alt + ef = 
        def loop(k) = {
            match EffectExtras.Alt.optional(p) {
                case Some(a) => loop(ks -> k(List.cons(a, ks)))
                case None    => k(Nil)
            }
        };
        loop(identity)

    pub def many1(p: Unit -> a \ ef): List[a] \ Alt + ef = 
        let first = p();
        let tail = many(p);
        first :: tail

    pub def count(n: Int32, p: Unit -> a \ ef): List[a] \ Alt + ef = 
       def loop(i, k) = {
            if (i > 0) {
                let a = p();
                loop(i - 1, ks -> k(List.cons(a, ks)))
            }
            else k(Nil)
        };
        loop(n, identity)

    pub def ntimes(p: Unit -> a \ ef): Int32 \ Alt + ef = 
       def loop(k) = {
            match EffectExtras.Alt.optional(p) {
                case Some(_) => loop(ki -> k(ki + 1))
                case None    => k(0)
            }
        };
        loop(identity)


    pub def skipMany(p: Unit -> a \ ef): Unit \ Alt + ef = 
        def loop(k) = {
            match EffectExtras.Alt.optional(p) {
                case Some(_) => loop(ku -> k(ku))
                case None    => k()
            }
        };
        loop(identity)

    pub def skipMany1(p: Unit -> a \ ef): Unit \ Alt + ef = 
        let _ = p();
        skipMany(p)

    pub def skipManyTill(p: Unit -> a \ ef, endp: Unit -> b \ ef): Unit \ Alt + ef = 
        def loop(k) = {
            match EffectExtras.Alt.optional(endp) {
                case Some(_) => k()
                case None    => match EffectExtras.Alt.optional(p) {
                    case Some(_) => loop(k)
                    case None    => Alt.failure("skipManyTill")
                }
            }
        };
        loop(identity)

}
