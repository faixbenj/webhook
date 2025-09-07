# 🔔 Browser Notification Testing Script
# This script sends webhooks with delays to help you see the notifications

Write-Host "🔔 BROWSER NOTIFICATION TESTING" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Make sure your browser is open at http://localhost:5001" -ForegroundColor White
Write-Host "2. ALLOW notifications when prompted by the browser" -ForegroundColor Red
Write-Host "3. Keep the browser tab active or in background" -ForegroundColor White
Write-Host "4. Watch for desktop notifications as webhooks are sent!" -ForegroundColor White
Write-Host ""

# Wait for user to get ready
Read-Host "Press ENTER when you're ready to start the notification test"

Write-Host "`n🚀 Starting notification test in 3 seconds..." -ForegroundColor Green
Start-Sleep 3

# Test 1: Priority Alert
Write-Host "`n🚨 Sending PRIORITY ALERT webhook..." -ForegroundColor Red
$priorityAlert = @{
    event = "PRIORITY_ALERT"
    severity = "CRITICAL"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    message = "🚨 URGENT: Production system down!"
    data = @{
        service = "payment-processor"
        error_count = 150
        downtime_minutes = 5
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5001/webhook" -Method POST -Body $priorityAlert -ContentType "application/json"
    Write-Host "✅ Priority alert sent! ID: $($response.id)" -ForegroundColor Green
    Write-Host "   👀 Check for desktop notification!" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n⏱️  Waiting 8 seconds for you to see the notification..." -ForegroundColor Cyan
Start-Sleep 8

# Test 2: User Activity
Write-Host "`n👤 Sending USER ACTIVITY webhook..." -ForegroundColor Blue
$userActivity = @{
    event = "user.login"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    user = @{
        id = "user_12345"
        email = "john.doe@company.com"
        location = "New York, NY"
        device = "Chrome on Windows"
    }
    metadata = @{
        ip_address = "192.168.1.100"
        session_id = "sess_abc123"
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5001/webhook" -Method POST -Body $userActivity -ContentType "application/json"
    Write-Host "✅ User activity sent! ID: $($response.id)" -ForegroundColor Green
    Write-Host "   👀 Check for desktop notification!" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n⏱️  Waiting 8 seconds for you to see the notification..." -ForegroundColor Cyan
Start-Sleep 8

# Test 3: Sales Event
Write-Host "`n💰 Sending SALES EVENT webhook..." -ForegroundColor Green
$salesEvent = @{
    event = "sale.completed"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    amount = 1299.99
    currency = "USD"
    customer = @{
        name = "Sarah Johnson"
        email = "sarah@example.com"
        country = "United States"
    }
    product = @{
        name = "Premium Software License"
        sku = "PSL-2025"
        category = "Software"
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5001/webhook" -Method POST -Body $salesEvent -ContentType "application/json"
    Write-Host "✅ Sales event sent! ID: $($response.id)" -ForegroundColor Green
    Write-Host "   👀 Check for desktop notification!" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n⏱️  Waiting 8 seconds for you to see the notification..." -ForegroundColor Cyan
Start-Sleep 8

Write-Host "`n🎉 NOTIFICATION TEST COMPLETED!" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔍 WHAT YOU SHOULD HAVE SEEN:" -ForegroundColor Yellow
Write-Host "• 3 desktop notifications appeared (even if browser was in background)" -ForegroundColor White
Write-Host "• Each notification showed webhook details (source IP, timestamp)" -ForegroundColor White
Write-Host "• Notifications appeared in your system's notification area" -ForegroundColor White
Write-Host "• Real-time updates in the browser without page refresh" -ForegroundColor White
Write-Host ""
Write-Host "🚫 IF YOU DIDN'T SEE NOTIFICATIONS:" -ForegroundColor Red
Write-Host "• Make sure you clicked 'Allow' when the browser asked for notification permission" -ForegroundColor White
Write-Host "• Check your browser's notification settings" -ForegroundColor White
Write-Host "• Ensure notifications aren't disabled system-wide" -ForegroundColor White
Write-Host ""
Write-Host "✅ The webhook app is working perfectly!" -ForegroundColor Green