using Finance.Domain.Accounts;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Finance.Infrastructure.Persistence.Configurations;

internal sealed class AccountConfiguration : IEntityTypeConfiguration<Account>
{
    public void Configure(EntityTypeBuilder<Account> builder)
    {
        builder.Property(a => a.Name).HasMaxLength(100);
        builder.Property(a => a.Type).HasConversion<string>().HasMaxLength(20);
        builder.Property(a => a.Currency).HasMaxLength(3);
        builder.Property(a => a.Color).HasMaxLength(9);
        builder.Property(a => a.Icon).HasMaxLength(50);
        builder.Property(a => a.InterestRatePercent).HasPrecision(9, 4);
        builder.Property(a => a.CapitalizationPeriod).HasConversion<string>().HasMaxLength(20);
        builder.Ignore(a => a.InitialMoney);
    }
}
