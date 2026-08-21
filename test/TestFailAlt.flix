

pub mod TestFailAlt { 

    use Assert.{assertTrue}
    use EffectExtras.Fail
    use EffectExtras.Alt

    @Test
    pub def test01(): Unit \ { Assert } = 
        let ans: Result[String, Int32] = run {
            let d1 = 0;
            Alt.liftFail(() -> Fail.report("fail1"));
            d1
        } with EffectExtras.Alt.runWithResult;
        Assert.assertEq(expected = Err("fail1"), ans)



}
