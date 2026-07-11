

pub mod TestAlt { 
    use SimpleParse.oneToNine

    use Assert.{assertTrue}
    use EffectExtras.Alt.Alt
    use SimpleParse.{runParser}

    @Test
    pub def failure01(): Unit \ Assert = 
        let ans: Result[String, Int32] = run {
            Alt.failure("fail1")
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Err("fail1"), ans)


    @Test
    pub def parse01(): Unit \ Assert = 
        let ans = runParser(
            _ -> SimpleParse.next(), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(1), ans)



    @Test
    pub def alt01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.alt(_ -> Alt.failure("fail1"), SimpleParse.anyNum),
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(1), ans)


    @Test
    pub def optional01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.optional(SimpleParse.zero), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(None), ans)


    @Test
    pub def optional02(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.optional(SimpleParse.one), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(Some(1)), ans)

    @Test
    pub def withDefault01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.withDefault(SimpleParse.zero, 10), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(10), ans)


    @Test
    pub def withDefault02(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.withDefault(SimpleParse.one, 10), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(1), ans)

    @Test
    pub def withDefault03(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.withDefault(() -> Alt.failure("fail1"), 10), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(10), ans)


    @Test
    pub def swapError01(): Unit \ Assert = 
        let ans = run {
            let p: Unit -> Int32 \ Alt = () -> Alt.failure("fail");
            EffectExtras.Alt.swapError("override", p)
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Err("override"), ans)


    @Test
    pub def many01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.many(SimpleParse.zero), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(List#{}), ans)

    @Test
    pub def many02(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.many(SimpleParse.anyNum), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(List#{1,2,3,4}), ans)

    @Test
    pub def many03(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.many(SimpleParse.oneToNine), 
            List#{1,2,3,4,10}
        );
        Assert.assertEq(expected = Ok(List#{1,2,3,4}), ans)


    @Test
    pub def manyWith01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.manyWith(Chain.cons, Chain.empty(), SimpleParse.zero), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(Chain.empty()), ans)


    @Test
    pub def manyWith02(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.manyWith(Chain.cons, Chain.empty(), SimpleParse.anyNum), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(List#{1,2,3,4} |> List.toChain), ans)

    @Test
    pub def manyWith03(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.manyWith(Chain.cons, Chain.empty(), SimpleParse.oneToNine), 
            List#{1,2,3,4,10}
        );
        Assert.assertEq(expected = Ok(List#{1,2,3,4} |> List.toChain), ans)



    @Test
    pub def manyTill01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.manyTill(SimpleParse.anyNum, SimpleParse.four), 
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(List#{1,2,3}), ans)




    @Test
    pub def count01(): Unit \ Assert = 
        let ans = runParser(
            _ -> EffectExtras.Alt.count(2, SimpleParse.oneToNine),
            List#{1,2,3,4}
        );
        Assert.assertEq(expected = Ok(List#{1, 2}), ans)

}
