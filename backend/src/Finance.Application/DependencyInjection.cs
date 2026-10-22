using System.Text.Json;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Auth;
using Finance.Application.Features.Categories;
using Finance.Application.Features.Me;
using Finance.Application.Features.Rates;
using Finance.Application.Features.Transactions;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        // Error keys match the camelCase JSON property names.
        ValidatorOptions.Global.PropertyNameResolver = (_, member, _) =>
            member is null ? null : JsonNamingPolicy.CamelCase.ConvertName(member.Name);

        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly, includeInternalTypes: true);
        services.AddSingleton(TimeProvider.System);

        services.AddScoped<AuthService>();
        services.AddScoped<MeService>();
        services.AddScoped<BalanceQueries>();
        services.AddScoped<AccountWriter>();
        services.AddScoped<AccountQueries>();
        services.AddScoped<CategoryWriter>();
        services.AddScoped<CategoryQueries>();
        services.AddScoped<TransactionWriter>();
        services.AddScoped<TransactionQueries>();
        services.AddScoped<RatesQueries>();
        return services;
    }
}
