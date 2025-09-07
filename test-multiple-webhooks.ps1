# Send multiple different webhook types to test the application

Write-Host "🚀 Testing Webhook Monitor Application" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Test 1: User Registration
Write-Host "`n📝 Sending User Registration Webhook..." -ForegroundColor Yellow
$userReg = @{
    event = "user.registered"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        user_id = 12345
        email = "newuser@example.com"
        name = "Alice Johnson"
        plan = "premium"
    }
} | ConvertTo-Json -Depth 5

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:8099/webhook" -Method POST -Body $userReg -ContentType "application/json"
    Write-Host "✅ User registration webhook sent successfully! ID: $($response1.id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to send webhook: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep 2

# Test 2: Payment Processing
Write-Host "`n💳 Sending Payment Webhook..." -ForegroundColor Yellow
$payment = @{
    event = "payment.completed"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        payment_id = "pay_abc123"
        amount = 2999
        currency = "USD"
        customer = @{
            id = "cust_456"
            email = "customer@example.com"
        }
        metadata = @{
            order_id = "order_789"
            product = "Premium Subscription"
        }
    }
} | ConvertTo-Json -Depth 5

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:8099/webhook" -Method POST -Body $payment -ContentType "application/json"
    Write-Host "✅ Payment webhook sent successfully! ID: $($response2.id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to send webhook: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep 2

# Test 3: System Alert
Write-Host "`n🚨 Sending System Alert Webhook..." -ForegroundColor Yellow
$alert = @{
    event = "system.alert"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    severity = "high"
    message = "Database connection pool exhausted"
    data = @{
        service = "api-gateway"
        instance = "api-01"
        metrics = @{
            cpu_usage = 95.2
            memory_usage = 87.5
            active_connections = 1024
        }
    }
} | ConvertTo-Json -Depth 5

try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:8099/webhook" -Method POST -Body $alert -ContentType "application/json"
    Write-Host "✅ System alert webhook sent successfully! ID: $($response3.id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to send webhook: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep 2

# Test 4: Simple Text Webhook
Write-Host "`n📄 Sending Simple Text Webhook..." -ForegroundColor Yellow
$simpleText = "This is a simple text webhook without JSON structure"

try {
    $response4 = Invoke-RestMethod -Uri "http://localhost:8099/webhook" -Method POST -Body $simpleText -ContentType "text/plain"
    Write-Host "✅ Simple text webhook sent successfully! ID: $($response4.id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to send webhook: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 All test webhooks completed!" -ForegroundColor Cyan
Write-Host "Check your browser at http://localhost:8099 to see the real-time updates!" -ForegroundColor Cyan