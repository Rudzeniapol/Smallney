using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Users;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Me;

public sealed class MeService(IAppDbContext db, ICurrentUser currentUser, IValidator<UpdateMeRequest> validator)
{
    public async Task<User> GetUserAsync(CancellationToken ct)
    {
        var userId = currentUser.RequiredUserId();
        return await db.Users.FirstOrDefaultAsync(u => u.Id == userId, ct)
               ?? throw new NotFoundException("User", userId);
    }

    public async Task<MeResponse> GetAsync(CancellationToken ct) => MeResponse.From(await GetUserAsync(ct));

    /// <param name="present">Names (case-insensitive) of the properties present in the patch document.</param>
    public async Task<MeResponse> PatchAsync(UpdateMeRequest patch, IReadOnlySet<string> present, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(patch, ct);
        var user = await GetUserAsync(ct);

        if (present.Contains(nameof(UpdateMeRequest.BaseCurrency)))
        {
            user.BaseCurrency = Required(patch.BaseCurrency, "baseCurrency").Trim().ToUpperInvariant();
        }

        if (present.Contains(nameof(UpdateMeRequest.Timezone)))
        {
            user.Timezone = Required(patch.Timezone, "timezone");
        }

        if (present.Contains(nameof(UpdateMeRequest.FirstDayOfMonth)))
        {
            user.FirstDayOfMonth = Required(patch.FirstDayOfMonth, "firstDayOfMonth");
        }

        if (present.Contains(nameof(UpdateMeRequest.LowBalanceThreshold)))
        {
            user.LowBalanceThreshold = Required(patch.LowBalanceThreshold, "lowBalanceThreshold");
        }

        if (present.Contains(nameof(UpdateMeRequest.DefaultSpendingAccountId)))
        {
            if (patch.DefaultSpendingAccountId is { } accountId
                && !await db.Accounts.AnyAsync(a => a.Id == accountId, ct))
            {
                throw new NotFoundException("Account", accountId);
            }

            user.DefaultSpendingAccountId = patch.DefaultSpendingAccountId;
        }

        await db.SaveChangesAsync(ct);
        return MeResponse.From(user);
    }

    private static T Required<T>(T? value, string property)
        where T : struct =>
        value ?? throw NullNotAllowed(property);

    private static string Required(string? value, string property) => value ?? throw NullNotAllowed(property);

    private static ValidationException NullNotAllowed(string property) =>
        new([new ValidationFailure(property, $"'{property}' cannot be null.") { ErrorCode = "null_not_allowed" }]);
}
