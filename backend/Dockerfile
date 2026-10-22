# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore first so that the layer is cached until a project file changes.
COPY Directory.Build.props Directory.Packages.props ./
COPY src/Finance.Domain/Finance.Domain.csproj src/Finance.Domain/
COPY src/Finance.Application/Finance.Application.csproj src/Finance.Application/
COPY src/Finance.Infrastructure/Finance.Infrastructure.csproj src/Finance.Infrastructure/
COPY src/Finance.Api/Finance.Api.csproj src/Finance.Api/
RUN dotnet restore src/Finance.Api/Finance.Api.csproj

COPY src/ src/
RUN dotnet publish src/Finance.Api/Finance.Api.csproj -c Release -o /app --no-restore /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
COPY --from=build /app .
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "Finance.Api.dll"]
