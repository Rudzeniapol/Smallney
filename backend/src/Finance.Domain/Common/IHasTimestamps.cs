namespace Finance.Domain.Common;

/// <summary>Technical UTC timestamps maintained by the persistence layer.</summary>
public interface IHasTimestamps
{
    DateTime CreatedAt { get; set; }

    DateTime UpdatedAt { get; set; }
}
