namespace WebhookApp.Models;

public class WebhookData
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string? SourceIp { get; set; }
    public Dictionary<string, string[]> Headers { get; set; } = new();
    public object? Payload { get; set; }
    public string? RawPayload { get; set; }
    public string ContentType { get; set; } = "application/json";
}