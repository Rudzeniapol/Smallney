using System.Buffers.Text;
using System.Globalization;
using System.Text;
using FluentValidation;
using FluentValidation.Results;

namespace Finance.Application.Common;

/// <summary>Opaque keyset cursor for lists ordered by (date desc, id desc).</summary>
public readonly record struct DateIdCursor(DateOnly Date, Guid Id)
{
    public string Encode() =>
        Base64Url.EncodeToString(Encoding.UTF8.GetBytes($"{Date:yyyy-MM-dd}|{Id:N}"));

    public static DateIdCursor Decode(string cursor)
    {
        try
        {
            var raw = Encoding.UTF8.GetString(Base64Url.DecodeFromChars(cursor));
            var parts = raw.Split('|');
            if (parts.Length == 2
                && DateOnly.TryParseExact(parts[0], "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date)
                && Guid.TryParseExact(parts[1], "N", out var id))
            {
                return new DateIdCursor(date, id);
            }
        }
        catch (FormatException)
        {
            // Falls through to the validation error below.
        }

        throw new ValidationException([new ValidationFailure("cursor", "Cursor is malformed.") { ErrorCode = "invalid_cursor" }]);
    }
}

public sealed record CursorPage<T>(IReadOnlyList<T> Items, string? NextCursor)
{
    public bool HasMore => NextCursor is not null;
}
