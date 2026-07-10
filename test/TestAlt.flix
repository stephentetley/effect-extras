

pub mod TestAlt { 

    use Assert.{assertTrue}
    use EffectExtras.Alt.Alt

    @Test
    pub def test01(): Unit \ { Assert } = 
        let ans: Result[String, Int32] = run {
            Alt.failure("fail1")
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Err("fail1"), ans)

    @Test
    pub def test02(): Unit \ { Assert } = 
        let ans = run {
            EffectExtras.Alt.alt(() -> Alt.failure("fail1"), _ -> 1)
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Ok(1), ans)

    // @Test
    // pub def seqLeft01(): Unit \ { Assert } = 
    //     let ans = run {
    //         EffectExtras.Alt.seqLeft(() -> 1, () -> Alt.failure("failB"))
    //     } with EffectExtras.Alt.runWithResult;
    //     Assert.assertEq(expected = Err("failB"), ans)



    @Test
    pub def withDefault01(): Unit \ { Assert } = 
        let ans = run {
            EffectExtras.Alt.withDefault(() -> Alt.failure("fail1"), 1)
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Ok(1), ans)

    @Test
    pub def count01(): Unit \ { Assert } = 
        let ans = run {
            EffectExtras.Alt.count(2, () -> 1)
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Ok(List#{1, 1}), ans)

    @Test
    pub def swapError01(): Unit \ { Assert } = 
        let ans = run {
            let p: Unit -> Int32 \ Alt = () -> Alt.failure("fail");
            EffectExtras.Alt.swapError("override", p)
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Err("override"), ans)

}