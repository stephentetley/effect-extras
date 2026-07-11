

pub mod SimpleParse {

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

}