using System.Collections.Concurrent;
using WebhookApp.Models;

namespace WebhookApp.Services;

public interface IWebhookStorageService
{
    Task AddWebhookAsync(WebhookData webhook);
    Task<IEnumerable<WebhookData>> GetRecentWebhooksAsync();
    Task CleanupExpiredWebhooksAsync();
}

public class InMemoryWebhookStorageService : IWebhookStorageService
{
    private readonly ConcurrentDictionary<string, WebhookData> _webhooks = new();
    private readonly ILogger<InMemoryWebhookStorageService> _logger;
    private readonly Timer _cleanupTimer;
    private readonly TimeSpan _retentionPeriod = TimeSpan.FromHours(1);

    public InMemoryWebhookStorageService(ILogger<InMemoryWebhookStorageService> logger)
    {
        _logger = logger;
        // Run cleanup every 5 minutes
        _cleanupTimer = new Timer(async _ => await CleanupExpiredWebhooksAsync(), 
                                  null, 
                                  TimeSpan.FromMinutes(5), 
                                  TimeSpan.FromMinutes(5));
    }

    public Task AddWebhookAsync(WebhookData webhook)
    {
        _webhooks[webhook.Id] = webhook;
        _logger.LogInformation("Added webhook {WebhookId} at {Timestamp}", webhook.Id, webhook.Timestamp);
        return Task.CompletedTask;
    }

    public Task<IEnumerable<WebhookData>> GetRecentWebhooksAsync()
    {
        var cutoffTime = DateTime.UtcNow - _retentionPeriod;
        var recentWebhooks = _webhooks.Values
            .Where(w => w.Timestamp >= cutoffTime)
            .OrderByDescending(w => w.Timestamp)
            .ToList();

        return Task.FromResult<IEnumerable<WebhookData>>(recentWebhooks);
    }

    public Task CleanupExpiredWebhooksAsync()
    {
        var cutoffTime = DateTime.UtcNow - _retentionPeriod;
        var expiredKeys = _webhooks.Values
            .Where(w => w.Timestamp < cutoffTime)
            .Select(w => w.Id)
            .ToList();

        foreach (var key in expiredKeys)
        {
            _webhooks.TryRemove(key, out _);
        }

        if (expiredKeys.Any())
        {
            _logger.LogInformation("Cleaned up {Count} expired webhooks", expiredKeys.Count);
        }

        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _cleanupTimer?.Dispose();
    }
}