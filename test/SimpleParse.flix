

pub mod SimpleParse {
    use SimpleParse.satisfies

    use EffectExtras.Alt.Alt

    pub eff SimpleParse { 
        def next(): Int32
        def peek(): Option[Int32]
        def atEnd(): Bool
    }

    pub def handle(source: List[Int32], 
                    f: a -> b \ ef): a -> b \ (ef + Alt - SimpleParse) = x -> region rc {
        let position = Ref.fresh(rc, 0);
        let endpos = List.length(source);
        run {
            f(x)
        } with handler SimpleParse {
            
            def next(k) = {
                let pos = Ref.get(position);
                match List.nth(pos, source) {
                    case Some(c) => {
                        Ref.put(pos + 1, position);
                        k(c)
                    }
                    case _ => Alt.failure("Err: at end of input")
                }
            }

            def peek(k) = {
                let pos = Ref.get(position);
                k(List.nth(pos, source))
            }


            def atEnd(k) = {
                let pos = Ref.get(position);
                k(pos >= endpos)
            }
        }
    }


    pub def runParser(p: Unit -> a \ ef, 
                    src: List[Int32]): Result[String, a] \ ef - Alt - SimpleParse = 
        run {
            handle(src, p)()
        } with EffectExtras.Alt.runWithResult

    // Doesn't advance the tojken stream on failure...
    pub def satisfies(pred: Int32 -> Bool): Int32 \ Alt + SimpleParse = 
        match SimpleParse.peek() {
            case Some(i) if pred(i) => SimpleParse.next()
            case _ => Alt.failure("satisfies")
        }

    pub def anyNum(): Int32 \ SimpleParse = SimpleParse.next()

    pub def zeroToNine(): Int32 \ Alt + SimpleParse = satisfies(x -> x >= 0 and x < 10)

    pub def oneToNine(): Int32 \ Alt + SimpleParse = satisfies(x -> x > 0 and x < 10)


    pub def zero(): Int32 \ Alt + SimpleParse = satisfies(x -> x == 0)
    pub def one(): Int32 \ Alt + SimpleParse = satisfies(x -> x == 1)
    pub def two(): Int32 \ Alt + SimpleParse = satisfies(x -> x == 2)
    pub def three(): Int32 \ Alt + SimpleParse = satisfies(x -> x == 3)
    pub def four(): Int32 \ Alt + SimpleParse = satisfies(x -> x == 4)

    pub def isOdd(): Int32 \ Alt + SimpleParse = satisfies(x -> Int32.modulo(x, 2) != 0)

    pub def isEven(): Int32 \ Alt + SimpleParse = satisfies(x -> Int32.modulo(x, 2) == 0)



}