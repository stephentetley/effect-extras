

pub mod TestAlt { 

    use Assert.{assertTrue}
    use EffectExtras.Alt

    @Test
    pub def test01(): Unit \ { Assert } = 
        let ans: Result[String, Int32] = run {
            Alt.failure("fail1")
        } with handler Alt {

            def alternative(k) = match k(true) {
                case Ok(res) => Ok(res)
                case Err(_) => k(false)
            }

            def failure(msg, _) = Err(msg)

        };
        Assert.assertEq(expected = Err("fail1"), ans)

    @Test
    pub def test02(): Unit \ { Assert } = 
        let ans = run {
            EffectExtras.Alt.alt(() -> Alt.failure("fail1"), _ -> Ok(1))
        } with handler Alt {

            def alternative(k) = match k(true) {
                case Ok(res) => Ok(res)
                case Err(_) => k(false)
            }

            def failure(msg, _) = Err(msg)

        };
        Assert.assertEq(expected = Ok(1), ans)

    @Test
    pub def test03(): Unit \ { Assert } = 
        let ans = run {
            EffectExtras.Alt.withDefault(() -> Alt.failure("fail1"), Ok(1))
        } with handler Alt {

            def alternative(k) = match k(true) {
                case Ok(res) => Ok(res)
                case Err(_) => k(false)
            }

            def failure(msg, _) = Err(msg)
            
        };
        Assert.assertEq(expected = Ok(1), ans)

}