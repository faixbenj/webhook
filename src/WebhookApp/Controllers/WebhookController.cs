using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Newtonsoft.Json;
using WebhookApp.Hubs;
using WebhookApp.Models;
using WebhookApp.Services;

namespace WebhookApp.Controllers;

[ApiController]
[Route("[controller]")]
public class WebhookController : ControllerBase
{
    private readonly IWebhookStorageService _storageService;
    private readonly IHubContext<WebhookHub> _hubContext;
    private readonly ILogger<WebhookController> _logger;

    public WebhookController(
        IWebhookStorageService storageService,
        IHubContext<WebhookHub> hubContext,
        ILogger<WebhookController> logger)
    {
        _storageService = storageService;
        _hubContext = hubContext;
        _logger = logger;
    }

    [HttpPost]
    public async Task<IActionResult> ReceiveWebhook()
    {
        try
        {
            // Read the raw body
            string rawPayload;
            using (var reader = new StreamReader(Request.Body))
            {
                rawPayload = await reader.ReadToEndAsync();
            }

            // Parse payload if it's JSON
            object? parsedPayload = null;
            if (!string.IsNullOrEmpty(rawPayload))
            {
                try
                {
                    parsedPayload = JsonConvert.DeserializeObject(rawPayload);
                }
                catch (JsonException)
                {
                    // If not valid JSON, keep as string
                    parsedPayload = rawPayload;
                }
            }

            // Create webhook data
            var webhookData = new WebhookData
            {
                SourceIp = HttpContext.Connection.RemoteIpAddress?.ToString(),
                Headers = Request.Headers.ToDictionary(h => h.Key, h => h.Value.ToArray()!),
                Payload = parsedPayload,
                RawPayload = rawPayload,
                ContentType = Request.ContentType ?? "application/json"
            };

            // Store webhook
            await _storageService.AddWebhookAsync(webhookData);

            // Broadcast to connected clients
            await _hubContext.Clients.All.SendAsync("NewWebhook", webhookData);

            _logger.LogInformation("Webhook received from {SourceIp} with ID {WebhookId}", 
                                 webhookData.SourceIp, webhookData.Id);

            return Ok(new { id = webhookData.Id, timestamp = webhookData.Timestamp });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing webhook");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }

    [HttpGet("recent")]
    public async Task<IActionResult> GetRecentWebhooks()
    {
        try
        {
            var webhooks = await _storageService.GetRecentWebhooksAsync();
            return Ok(webhooks);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving recent webhooks");
            return StatusCode(500, new { error = "Internal server error" });
        }
    }
}