using Finance.Domain.Sync;
using Finance.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Finance.Infrastructure.Persistence.Configurations;

internal sealed class SyncChangeLogConfiguration : IEntityTypeConfiguration<SyncChangeLog>
{
    public void Configure(EntityTypeBuilder<SyncChangeLog> builder)
    {
        builder.HasKey(l => new { l.UserId, l.EntityId, l.ClientUpdatedAt });
        builder.Property(l => l.EntityType).HasMaxLength(40);
        builder.Property(l => l.Operation).HasConversion<string>().HasMaxLength(10);
        builder.Property(l => l.Status).HasMaxLength(20);
        builder.HasIndex(l => l.ProcessedAt);
        builder.HasOne<User>().WithMany().HasForeignKey(l => l.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
