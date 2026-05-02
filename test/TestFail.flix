

pub mod TestFail { 

    use Assert.{assertTrue}
    use EffectExtras.Fail.Fail

    @Test
    pub def test01(): Unit \ { Assert, Logger }= 
        let ans = run {
            Logger.info("This is observable");
            Fail.report("fail1");
            Logger.info("This is not observable !!#'&%£^()[]!!");
            1
        } with EffectExtras.Fail.runWithResult;
        Assert.assertEq(expected = Err("fail1"), ans)

    @Test
    pub def test02(): Unit \ { Assert, Logger } = 
        let ans = run {
            Logger.info("This is observable");
            1
        } with EffectExtras.Fail.runWithResult;
        Assert.assertEq(expected = Ok(1), ans)


}