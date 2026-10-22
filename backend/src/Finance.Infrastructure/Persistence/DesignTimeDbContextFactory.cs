using Finance.Application.Abstractions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Finance.Infrastructure.Persistence;

/// <summary>Used by `dotnet ef` only.</summary>
internal sealed class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__Postgres")
                               ?? "Host=localhost;Port=5445;Database=smallney;Username=smallney;Password=smallney;Gss Encryption Mode=Disable";
        var options = new DbContextOptionsBuilder<AppDbContext>();
        DependencyInjection.ConfigureDbContext(options, connectionString);
        return new AppDbContext(options.Options, new NoUser(), TimeProvider.System);
    }

    private sealed class NoUser : ICurrentUser
    {
        public Guid? UserId => null;
    }
}
