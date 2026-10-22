using Finance.Domain.Common;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Common;

public static class EntityIds
{
    /// <summary>
    /// Validates a client-generated id and checks it is not used yet — by this user, another user,
    /// or a soft-deleted row. The same 409 is returned in all cases so other users' ids do not leak.
    /// </summary>
    public static async Task EnsureIdIsFreeAsync<T>(this DbSet<T> set, Guid id, CancellationToken ct)
        where T : UserOwnedEntity
    {
        ValidationRules.EnsureUuidV7(id);
        if (await set.IgnoreQueryFilters().AnyAsync(e => e.Id == id, ct))
        {
            throw new ConflictException("id_conflict", $"An entity with id '{id}' already exists.");
        }
    }
}
