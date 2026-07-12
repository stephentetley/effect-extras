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

    pub def runWithDefault(d: a, f: Unit -> a \ ef): a \ ef - Alt = 
        handleWithResult(f)() |> Result.getWithDefault(d)

    pub def alt(p: Unit -> a \ ef1, q: Unit -> a \ ef2 ): a \ Alt + ef1 + ef2 = 
        if (Alt.alternative()) p() else q()

    pub def optional(p: Unit -> a \ ef ): Option[a] \ Alt + ef = 
        alt(_ -> { let a = p(); Some(a)}, _ -> None)

    pub def withDefault(p: Unit -> a \ ef, d: a): a \ Alt + ef = 
        alt(p, _ -> d)

    pub def swapError(msg: String, p: Unit -> a \ ef): a \ Alt + ef = 
        alt(p, _ -> Alt.failure(msg))
        

    // Don't need `seqLeft` / `seqRight` as the defintion is just the direct 
    // style 

    // pub def seqLeft(p: Unit -> a \ ef1, q: Unit -> b \ ef2): a \ ef1 + ef2 = 
    //     let a = p();
    //     let _ = q();
    //     a


    // parser style combinators - use `many` etc with care, they will loop 
    // forever without a stopping condition

    // `failure` is the stopping condition, so we can't use this for combinators like 
    // `skipManyTill` that stop on success.
    def loopTillFail(p: Unit -> a \ ef1, init: ac, sk: (a, ac) -> ac \ ef2): ac \ Alt + ef1 + ef2 =  
       def loop(k) = {
            match optional(p) {
                case Some(a) => loop(ka -> let ans = unchecked_cast(sk(a, ka) as _  \ {}); k(ans))
                case None    => k(init)
            }
        };
        unchecked_cast(loop(x -> x) as _  \ Alt + ef1 + ef2)

    def loopTillEnd(p: Unit -> a \ ef1, 
                    endp: Unit -> b \ ef2, 
                    init: ac, 
                    sk: (a, ac) -> ac \ ef3): (ac, b) \ Alt + ef1 + ef2 + ef3 =  
       def loop(ac, k) = {
            match optional(endp) {
                case Some(b) => k(ac, b)
                case None    => {
                    let a = p();
                    let ac1 = unchecked_cast(sk(a, ac) as _  \ {});
                    loop(ac1, k)
                }
            }
        };
        loop(init, (ac, b) -> (ac, b))

    pub def pchoice(ps: List[Unit -> a \ ef]): a \ Alt + ef = 
        def loop(xs) = match xs {
            case p :: fs => alt(p, _ -> loop(fs))
            case Nil     => Alt.failure("pchoice")
        };
        loop(ps)



    pub def many(p: Unit -> a \ ef): List[a] \ Alt + ef = 
        loopTillFail(p, Nil, List.cons)

    pub def manyWith(combine: (a, ac) -> ac \ ef1, 
                        init: ac, 
                        p: Unit -> a \ ef): ac \ (Alt + ef + ef1) = 
        loopTillFail(p, init, combine)


    pub def many1(p: Unit -> a \ ef): List[a] \ Alt + ef = 
        p() :: many(p)

    pub def many1With(combine: (a, ac) -> ac \ ef1, 
                        init: ac, 
                        p: Unit -> a \ ef): ac \ (Alt + ef + ef1) = 
        combine(p(), manyWith(combine, init, p))

    pub def manyTill(p: Unit -> a \ ef, endp: Unit -> b \ ef1): List[a] \ Alt + ef + ef1 = 
        def loop(k) = {
            match optional(endp) {
                case Some(_) => k(Nil)
                case None    => match optional(p) {
                    case Some(a) => loop(ks -> k(a :: ks))
                    case None => Alt.failure("manyTill")
                }
            }
        };
        loop(x -> x)



    pub def manyTillWith(combine: (a, ac) -> ac \ ef2, 
                            init: ac, 
                            p: Unit -> a \ ef, 
                            endp: Unit -> b \ ef1): ac \ Alt + ef + ef1 + ef2 = 
        loopTillEnd(p, endp, init, combine) |> fst

    pub def many1Till(p: Unit -> a \ ef, endp: Unit -> b \ ef1): List[a] \ Alt + ef + ef1 = 
        p() :: manyTill(p, endp)

    pub def many1TillWith(combine: (a, ac) -> ac \ ef2, 
                            init: ac, 
                            p: Unit -> a \ ef, 
                            endp: Unit -> b \ ef1): ac \ Alt + ef + ef1 + ef2 = 
        combine(p(), manyTillWith(combine, init, p, endp))


    pub def sepBy(p: Unit -> a \ ef, sep: Unit -> b \ ef1): List[a] \ Alt + ef + ef1 = 
        alt(_ -> p() :: many( _ -> { let _ = sep(); p() }), _ -> Nil)

    pub def sepByWith(combine: (a, ac) -> ac \ ef2, 
                        init: ac, 
                        p: Unit -> a \ ef, 
                        sep: Unit -> b \ ef1): ac \ (Alt + ef + ef1 + ef2) = 
        alt(_ -> combine(p(), manyWith(combine, init, _ -> { let _ = sep(); p() })), _ -> init)


    pub def sepBy1(p: Unit -> a \ ef, sep: Unit -> b \ ef1): List[a] \ Alt + ef + ef1 = 
        p() :: many(_ -> { let _ = sep(); p() })

    pub def sepBy1With(combine: (a, ac) -> ac \ ef2, 
                        init: ac, 
                        p: Unit -> a \ ef, 
                        sep: Unit -> b \ ef1): ac \ (Alt + ef + ef1 + ef2)= 
        combine(p(), manyWith(combine, init, _ -> { let _ = sep(); p() }))

    // separated and optionally terminated with sep.
    pub def sepEndBy(p: Unit -> a \ ef, sep: Unit -> b \ ef1): List[a] \ Alt + ef + ef1 = 
        def loop(k) = match optional(p) {
            case Some(a) => match optional(sep) {
                case Some(_) => loop(ks -> k(a :: ks))
                case None => k(List#{a})                
            }
            case None => k(Nil)
        };
        loop(x -> x)

   pub def sepEndByWith(combine: (a, ac) -> ac \ ef2, 
                        init: ac,
                        p: Unit -> a \ ef, 
                        sep: Unit -> b \ ef1): ac \ Alt + ef + ef1 + ef2 = 
        def loop(k) = match optional(p) {
            case Some(a) => match optional(sep) {
                case Some(_) => loop(ka -> k(unchecked_cast(combine(a, ka) as _ \ {})))
                case None => k(combine(a, init))
            }
            case None => k(init)
        };
        unchecked_cast(loop(x -> x) as _ \ Alt + ef + ef1 + ef2)


    pub def sepEndBy1(p: Unit -> a \ ef, sep: Unit -> b \ ef1): List[a] \ Alt + ef + ef1 = 
        let a = p();
        alt(_ -> { let _ = sep(); let rest = sepEndBy(p, sep); a :: rest }, _ -> List#{a})

   pub def sepEndBy1With(combine: (a, ac) -> ac \ ef2, 
                            init: ac, 
                            p: Unit -> a \ ef, 
                            sep: Unit -> b \ ef1): ac \ Alt + ef + ef1 + ef2 = 
        let a = p();
        alt(_ -> { let _ = sep(); let rest = sepEndByWith(combine, init, p, sep); combine(a, rest) }, _ -> combine(a, init))



    // many separated and ended by `sep`
    pub def endBy(p: Unit -> a \ ef, sep: Unit -> b \ ef): List[a] \ Alt + ef = 
        many(_ -> { let a = p(); let _ = sep(); a })

    pub def endByWith(combine: (a, ac) -> ac \ ef2, init: ac, p: Unit -> a \ ef, sep: Unit -> b \ ef1): ac \ (Alt + ef + ef1 + ef2) = 
        manyWith(combine, init, _ -> { let a = p(); let _ = sep(); a })

    pub def endBy1(p: Unit -> a \ ef, sep: Unit -> a \ ef): List[a] \ Alt + ef = 
        let a = p();
        let _ = sep();
        a :: endBy(p, sep)

    pub def endBy1With(combine: (a, ac) -> ac \ ef2, init: ac, p: Unit -> a \ ef, sep: Unit -> b \ ef1): ac \ (Alt + ef + ef1 + ef2) = 
        let a = p();
        let _ = sep();
        combine(a, endByWith(combine, init, p, sep))


    pub def count(n: Int32, p: Unit -> a \ ef): List[a] \ Alt + ef = 
       countWith((x,xs) -> x :: xs, Nil, n, p)

    pub def countWith(combine: (a, ac) -> ac \ ef1, init: ac, n: Int32, p: Unit -> a \ ef): ac \ (Alt + ef + ef1) = 
       def loop(i, k) = {
            if (i > 0) {
                let a = p();
                loop(i - 1, ks -> k(unchecked_cast(combine(a, ks) as _ \ {})))
            }
            else k(init)
        };
        unchecked_cast(loop(n, identity) as _ \ Alt + ef + ef1)



    pub def ntimes(p: Unit -> a \ ef): Int32 \ Alt + ef = 
       manyWith((_, ac) -> ac + 1, 0, p)


    pub def ntimesSepBy(p: Unit -> a \ ef, sep: Unit -> b \ ef1): Int32 \ Alt + ef + ef1 = 
       sepByWith((_, ac) -> ac + 1, 0 , p, sep)

    pub def ntimesEndBy(p: Unit -> a \ ef, sep: Unit -> b \ ef1): Int32 \ Alt + ef + ef1 = 
       endByWith((_, ac) -> ac + 1, 0 , p, sep)

    pub def ntimesSepEndBy(p: Unit -> a \ ef, sep: Unit -> b \ ef1): Int32 \ Alt + ef + ef1 = 
       sepEndByWith((_, ac) -> ac + 1, 0 , p, sep)


    pub def skipMany(p: Unit -> a \ ef): Unit \ Alt + ef = 
        loopTillFail(p, (), (_, ac) -> ac)

    pub def skipMany1(p: Unit -> a \ ef): Unit \ Alt + ef = 
        let _ = p();
        skipMany(p)

    pub def skipManyTill(p: Unit -> a \ ef1, endp: Unit -> b \ ef2): b \ Alt + ef1 + ef2 = 
        loopTillEnd(p, endp, (), (_, ac) -> ac) |> snd

   pub def skipMany1Till(p: Unit -> a \ ef1, endp: Unit -> b \ ef2): b \ Alt + ef1 + ef2 = 
        let _ = p();
        skipManyTill(p, endp)

}

