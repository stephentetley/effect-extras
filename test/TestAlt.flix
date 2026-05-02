

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

    @Test
    pub def test03(): Unit \ { Assert } = 
        let ans = run {
            EffectExtras.Alt.withDefault(() -> Alt.failure("fail1"), 1)
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Ok(1), ans)

}