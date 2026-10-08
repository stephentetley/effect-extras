

pub mod TestFail { 

    use Assert.{assertTrue}
    use EffectExtras.Fail.Fail

    @Test
    pub def test01(): Unit \ { Assert, Logger } = 
        let px: Proxy[String] = Proxy.Proxy;
        let ans = run {
            Logger.info("This is observable");
            Fail.report("fail1");
            Logger.info("This is not observable !!#'&%£^()[]!!");
            1
        } with EffectExtras.Fail.runWithResult(px);
        Assert.assertEq(expected = Err("fail1"), ans)

    @Test
    pub def test02(): Unit \ { Assert, Logger } = 
        let px: Proxy[String] = Proxy.Proxy;
        let ans: Result[String, Int32] = run {
            Logger.info("This is observable");
            1
        } with EffectExtras.Fail.runWithResult(px);
        Assert.assertEq(expected = Ok(1), ans)

    @Test
    pub def test03(): Unit \ { Assert, Logger } = 
        let px: Proxy[String] = Proxy.Proxy;
        let ans: Int32 = run {
            Logger.info("This is observable");
            1
        } with EffectExtras.Fail.runWithDefault(px, 1);
        Assert.assertEq(expected = 1, ans)

    @Test
    pub def test04(): Unit \ { Assert, Logger } = 
        let px: Proxy[String] = Proxy.Proxy;
        let ans = run {
            Logger.info("This is observable");
            Fail.report("fail1");
            Logger.info("This is not observable !!#'&%£^()[]!!");
            1
        } with EffectExtras.Fail.runWithDefault(px, 1000);
        Assert.assertEq(expected = 1000, ans)

    @Test
    pub def test05(): Unit \ { Assert, Logger } = 
        let px: Proxy[String] = Proxy.Proxy;
        let ans = run {
            Logger.info("This is observable");
            Fail.report("fail1");
            Logger.info("This is not observable !!#'&%£^()[]!!");
            1
        } with EffectExtras.Fail.runWithOption(px);
        Assert.assertEq(expected = None, ans)


}