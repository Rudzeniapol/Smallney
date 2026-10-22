using Finance.Application.Abstractions;
using Microsoft.IdentityModel.JsonWebTokens;

namespace Finance.Api.Infrastructure;

internal sealed class HttpCurrentUser(IHttpContextAccessor accessor) : ICurrentUser
{
    public Guid? UserId =>
        accessor.HttpContext?.User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value is { } sub && Guid.TryParse(sub, out var id)
            ? id
            : null;
}
