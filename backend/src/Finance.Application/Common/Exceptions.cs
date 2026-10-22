namespace Finance.Application.Common;

/// <summary>The resource does not exist for the current user (also used for other users' data, to avoid leaking it).</summary>
public sealed class NotFoundException(string resource, object id)
    : Exception($"{resource} '{id}' was not found.")
{
    public string Resource { get; } = resource;
}

/// <summary>The request conflicts with the current state (HTTP 409).</summary>
public sealed class ConflictException(string code, string message) : Exception(message)
{
    public string Code { get; } = code;
}

/// <summary>Credentials or a refresh token were rejected (HTTP 401).</summary>
public sealed class AuthenticationFailedException(string code, string message) : Exception(message)
{
    public string Code { get; } = code;
}
