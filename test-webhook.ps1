$webhook = @{
    message = "Hello from PowerShell!"
    timestamp = "2025-09-08T08:36:00Z"
    event = "user_signup"
    user = @{
        id = 456
        email = "test@example.com"
        name = "John Doe"
    }
    metadata = @{
        source = "test-script"
        version = "1.0"
    }
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "http://localhost:5001/webhook" -Method POST -Body $webhook -ContentType "application/json"
Write-Host "Webhook sent successfully!" -ForegroundColor Green
Write-Host "Response: $($response | ConvertTo-Json)"