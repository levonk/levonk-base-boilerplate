using System;
using System.Threading.Tasks;

namespace {{package_name | pascal_case}};

/// <summary>
/// {{package_description}}
/// </summary>
public class Service
{
    private readonly ILogger<Service> _logger;

    public Service(ILogger<Service> logger)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Example method that demonstrates basic functionality
    /// </summary>
    /// <param name="input">Sample input parameter</param>
    /// <returns>Sample result</returns>
    public async Task<string> ProcessAsync(string input)
    {
        _logger.LogInformation("Processing input: {Input}", input);

        try
        {
            // Your business logic here
            var result = await Task.FromResult($"Processed: {input}");
            
            _logger.LogInformation("Successfully processed input");
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing input: {Input}", input);
            throw;
        }
    }

    /// <summary>
    /// Example synchronous method
    /// </summary>
    /// <param name="value">Sample value</param>
    /// <returns>Modified value</returns>
    public int MultiplyByTwo(int value)
    {
        _logger.LogDebug("Multiplying {Value} by 2", value);
        return value * 2;
    }
}
