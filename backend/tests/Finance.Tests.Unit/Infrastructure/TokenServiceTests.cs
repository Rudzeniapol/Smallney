using Finance.Domain.Users;
using Finance.Infrastructure.Auth;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;

namespace Finance.Tests.Unit.Infrastructure;

public class TokenServiceTests
{
    private static readonly JwtOptions Options = new()
    {
        Issuer = "test",
        Audience = "test-clients",
        SigningKey = new string('k', 48),
        AccessTokenMinutes = 15,
        RefreshTokenDays = 30,
    };

    private readonly TokenService _service = new(Microsoft.Extensions.Options.Options.Create(Options), TimeProvider.System);

    [Fact]
    public void Access_token_is_a_15_minute_jwt_for_the_user()
    {
        var user = new User { Id = Guid.CreateVersion7(), Email = "a@b.by" };
        var before = DateTime.UtcNow;

        var issued = _service.CreateAccessToken(user);
        var jwt = new JsonWebTokenHandler().ReadJsonWebToken(issued.Token);

        jwt.Subject.Should().Be(user.Id.ToString());
        jwt.Issuer.Should().Be("test");
        jwt.Audiences.Should().ContainSingle("test-clients");
        jwt.Alg.Should().Be("HS256");
        issued.ExpiresAt.Should().BeCloseTo(before.AddMinutes(15), TimeSpan.FromSeconds(5));
    }

    [Fact]
    public void Refresh_tokens_are_random_and_stored_as_sha256()
    {
        var a = _service.CreateRefreshToken();
        var b = _service.CreateRefreshToken();

        a.Token.Should().NotBe(b.Token);
        a.Hash.Should().HaveLength(64).And.NotBe(a.Token);
        _service.HashRefreshToken(a.Token).Should().Be(a.Hash);
        a.ExpiresAt.Should().BeCloseTo(DateTime.UtcNow.AddDays(30), TimeSpan.FromSeconds(5));
    }

    [Fact]
    public void Password_service_hashes_and_verifies()
    {
        var passwords = new PasswordService();
        var user = new User();
        user.PasswordHash = passwords.Hash(user, "correct horse");

        passwords.Verify(user, "correct horse").Should().Be(Finance.Application.Abstractions.PasswordCheck.Success);
        passwords.Verify(user, "wrong").Should().Be(Finance.Application.Abstractions.PasswordCheck.Failed);
    }
}
