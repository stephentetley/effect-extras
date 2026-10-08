pub mod TestFailCustomError { 

    use Assert.{assertTrue}
    use EffectExtras.Fail.Fail

    pub enum UserError with Eq, ToString {
        case UserError(String)
    }


    @Test
    pub def test01(): Unit \ { Assert, Logger } = 
        let px: Proxy[UserError] = Proxy.Proxy;
        let ans = run {
            Logger.info("This is observable");
            Fail.report(UserError.UserError("fail1"));
            Logger.info("This is not observable !!#'&%£^()[]!!");
            1
        } with EffectExtras.Fail.runWithResult(px);
        Assert.assertEq(expected = Err(UserError.UserError("fail1")), ans)

    @Test
    pub def test02(): Unit \ { Assert, Logger } = 
        let px: Proxy[UserError] = Proxy.Proxy;
        let ans = run {
            Logger.info("This is observable");
            Fail.report(UserError.UserError("fail1"));
            Logger.info("This is not observable !!#'&%£^()[]!!");
            1
        } with EffectExtras.Fail.runWithOption(px);
        Assert.assertEq(expected = None, ans)


}