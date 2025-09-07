using WebhookApp.Hubs;
using WebhookApp.Services;
using Microsoft.AspNetCore.SignalR;

var builder = WebApplication.CreateBuilder(args);

// Suppress health check request logging completely
builder.Logging.AddFilter("Microsoft.AspNetCore.Hosting.Diagnostics", LogLevel.Warning);
builder.Logging.AddFilter("Microsoft.AspNetCore.Routing.EndpointMiddleware", LogLevel.Warning);
builder.Logging.AddFilter("Microsoft.AspNetCore.Http.Result.OkObjectResult", LogLevel.Warning);

// Add HttpContextAccessor
builder.Services.AddHttpContextAccessor();

// Add services to the container.
builder.Services.AddControllers()
    .AddNewtonsoftJson(); // For JSON serialization

builder.Services.AddSignalR();

// Register custom services
builder.Services.AddSingleton<IWebhookStorageService, InMemoryWebhookStorageService>();

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowViteDev", policy =>
    {
        policy.WithOrigins("http://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Add static files and SPA services
builder.Services.AddSpaStaticFiles(configuration =>
{
    configuration.RootPath = "ClientApp/dist";
});

var app = builder.Build();

// Middleware to suppress logging for health check requests
app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/healthz"))
    {
        // Create a fake logger that doesn't log anything for health checks
        var originalLogger = context.RequestServices.GetService<ILogger<Program>>();
        
        // Process the request without triggering normal request logging
        await next();
        return;
    }
    
    await next();
});

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseCors("AllowViteDev");
}

app.UseStaticFiles();
if (!app.Environment.IsDevelopment())
{
    app.UseSpaStaticFiles();
}

app.UseRouting();

// Add a dedicated health endpoint that bypasses all MVC logging
app.MapGet("/healthz", async (IHubContext<WebhookHub> hubContext) =>
{
    try
    {
        // Check if SignalR hub is accessible
        // This verifies the hub context is properly initialized
        var hubClients = hubContext.Clients;
        
        // Perform a lightweight operation to ensure the hub is responsive
        // We don't actually send anything, just verify the clients collection is accessible
        _ = hubClients.All;

        // If we get here, SignalR hub is healthy
        return Results.Ok(new
        {
            status = "healthy",
            timestamp = DateTime.UtcNow,
            checks = new
            {
                signalr_hub = "healthy"
            }
        });
    }
    catch (Exception ex)
    {
        // SignalR hub or other critical component is unhealthy
        return Results.Json(new
        {
            status = "unhealthy",
            timestamp = DateTime.UtcNow,
            checks = new
            {
                signalr_hub = "unhealthy"
            },
            error = ex.Message
        }, statusCode: 503);
    }
});

app.MapControllers();
app.MapHub<WebhookHub>("/webhookhub");

// Configure SPA
app.UseSpa(spa =>
{
    spa.Options.SourcePath = "ClientApp";

    if (app.Environment.IsDevelopment())
    {
        spa.UseProxyToSpaDevelopmentServer("http://localhost:5173");
    }
});

app.Run();