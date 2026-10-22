using System.Net;
using System.Net.Http.Json;
using System.Text;
using Finance.Application.Features.Me;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class MeTests(ApiFactory factory)
{
    [Fact]
    public async Task Patch_changes_only_present_fields()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync();

        var me = await PatchAsync<MeResponse>(user, $$"""{"firstDayOfMonth": 25, "defaultSpendingAccountId": "{{account.Id}}", "lowBalanceThreshold": 5000}""");

        me.FirstDayOfMonth.Should().Be(25);
        me.DefaultSpendingAccountId.Should().Be(account.Id);
        me.LowBalanceThreshold.Should().Be(5000);
        me.BaseCurrency.Should().Be("BYN");
        me.Timezone.Should().Be("Europe/Minsk");

        var unchanged = await PatchAsync<MeResponse>(user, """{"baseCurrency": "eur"}""");
        unchanged.BaseCurrency.Should().Be("EUR");
        unchanged.DefaultSpendingAccountId.Should().Be(account.Id);
        unchanged.FirstDayOfMonth.Should().Be(25);
    }

    [Fact]
    public async Task Null_clears_the_default_spending_account()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync();
        await PatchAsync<MeResponse>(user, $$"""{"defaultSpendingAccountId": "{{account.Id}}"}""");

        var me = await PatchAsync<MeResponse>(user, """{"defaultSpendingAccountId": null}""");

        me.DefaultSpendingAccountId.Should().BeNull();
    }

    [Fact]
    public async Task Null_is_rejected_for_required_settings()
    {
        var user = await factory.RegisterUserAsync();
        var response = await SendPatchAsync(user, """{"timezone": null}""");
        await response.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
    }

    [Fact]
    public async Task Invalid_values_are_rejected()
    {
        var user = await factory.RegisterUserAsync();

        await (await SendPatchAsync(user, """{"firstDayOfMonth": 31}""")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await SendPatchAsync(user, """{"timezone": "Mars/Base"}""")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await SendPatchAsync(user, """[1, 2]""")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "bad_request");
        await (await SendPatchAsync(user, """{"firstDayOfMonth": """)).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "invalid_json");
    }

    [Fact]
    public async Task Default_spending_account_must_belong_to_the_user()
    {
        var owner = await factory.RegisterUserAsync();
        var foreign = await owner.CreateAccountAsync();
        var user = await factory.RegisterUserAsync();

        var response = await SendPatchAsync(user, $$"""{"defaultSpendingAccountId": "{{foreign.Id}}"}""");

        await response.ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    private static async Task<T> PatchAsync<T>(TestUser user, string json)
    {
        var response = await SendPatchAsync(user, json);
        await response.EnsureStatusAsync(HttpStatusCode.OK);
        return (await response.Content.ReadFromJsonAsync<T>(Json.Options))!;
    }

    private static Task<HttpResponseMessage> SendPatchAsync(TestUser user, string json) =>
        user.Client.PatchAsync("/api/v1/me", new StringContent(json, Encoding.UTF8, "application/merge-patch+json"));
}
