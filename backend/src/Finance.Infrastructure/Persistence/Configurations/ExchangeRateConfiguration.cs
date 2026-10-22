using Finance.Domain.ExchangeRates;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Finance.Infrastructure.Persistence.Configurations;

internal sealed class ExchangeRateConfiguration : IEntityTypeConfiguration<ExchangeRate>
{
    public void Configure(EntityTypeBuilder<ExchangeRate> builder)
    {
        builder.HasKey(r => new { r.FromCurrency, r.ToCurrency, r.Date });
        builder.Property(r => r.FromCurrency).HasMaxLength(3);
        builder.Property(r => r.ToCurrency).HasMaxLength(3);
        builder.Property(r => r.Rate).HasPrecision(28, 14);
        builder.Property(r => r.Source).HasMaxLength(20);
        builder.HasIndex(r => r.Date);
    }
}
