using System.Text.Json;
using Finance.Application.Common;
using Finance.Domain.Common;
using FluentValidation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace Finance.Api.Infrastructure;

/// <summary>Maps exceptions to RFC 9457 problem details. Every problem carries a stable <c>code</c> extension.</summary>
internal sealed class ProblemDetailsExceptionHandler(
    IProblemDetailsService problemDetails,
    IHostEnvironment environment,
    ILogger<ProblemDetailsExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext context, Exception exception, CancellationToken cancellationToken)
    {
        var problem = exception switch
        {
            ValidationException validation => ValidationProblem(validation),
            NotFoundException notFound => Problem(StatusCodes.Status404NotFound, "not_found", "Resource not found", notFound.Message),
            ConflictException conflict => Problem(StatusCodes.Status409Conflict, conflict.Code, "Conflict", conflict.Message),
            DomainException domain => Problem(StatusCodes.Status422UnprocessableEntity, domain.Code, "Business rule violated", domain.Message),
            AuthenticationFailedException auth => Problem(StatusCodes.Status401Unauthorized, auth.Code, "Unauthorized", auth.Message),
            UnauthorizedAccessException => Problem(StatusCodes.Status401Unauthorized, "unauthorized", "Unauthorized", null),
            BadHttpRequestException badRequest => Problem(badRequest.StatusCode, "bad_request", "Bad request", badRequest.Message),
            JsonException json => Problem(StatusCodes.Status400BadRequest, "invalid_json", "Bad request", json.Message),
            DbUpdateException { InnerException: PostgresException { SqlState: PostgresErrorCodes.UniqueViolation } } =>
                Problem(StatusCodes.Status409Conflict, "duplicate", "Conflict", "The entity already exists."),
            OperationCanceledException when context.RequestAborted.IsCancellationRequested =>
                Problem(499, "request_cancelled", "Request cancelled", null),
            _ => null,
        };

        if (problem is null)
        {
            logger.LogError(exception, "Unhandled exception for {Method} {Path}", context.Request.Method, context.Request.Path);
            problem = Problem(
                StatusCodes.Status500InternalServerError,
                "internal_error",
                "Internal server error",
                environment.IsDevelopment() ? exception.ToString() : null);
        }

        context.Response.StatusCode = problem.Status!.Value;
        return await problemDetails.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = context,
            ProblemDetails = problem,
            Exception = exception,
        });
    }

    private static ProblemDetails ValidationProblem(ValidationException exception)
    {
        var errors = exception.Errors
            .GroupBy(e => e.PropertyName ?? string.Empty)
            .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());
        var problem = new HttpValidationProblemDetails(errors)
        {
            Status = StatusCodes.Status400BadRequest,
            Title = "Validation failed",
        };
        problem.Extensions["code"] = "validation_failed";
        problem.Extensions["errorCodes"] = exception.Errors
            .GroupBy(e => e.PropertyName ?? string.Empty)
            .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorCode).Distinct().ToArray());
        return problem;
    }

    private static ProblemDetails Problem(int status, string code, string title, string? detail)
    {
        var problem = new ProblemDetails { Status = status, Title = title, Detail = detail };
        problem.Extensions["code"] = code;
        return problem;
    }
}
