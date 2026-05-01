

pub mod TestFail { 

    use Assert.{assertTrue}
    use EffectExtras.Fail

    @Test
    pub def test01(): Unit \ { IO, Assert } = 
        let ans: Result[String, Int32] = run {
            Logger.info("This is observable");
            Fail.report("fail1");
            Logger.info("This is not observable !!#'&%£^()[]!!");
            Ok(1)
        } with handler Fail {

            def report(msg, _) = Err(msg)

        } with Logger.runWithIO;
        Assert.assertEq(expected = Err("fail1"), ans)

    @Test
    pub def test02(): Unit \ { Assert } = 
        let ans = run {
            Ok(1)
        } with handler Fail {

            def report(msg, _) = Err(msg)
            
        };
        Assert.assertEq(expected = Ok(1), ans)


}