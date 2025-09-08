# 🧪 Pipeline Setup Verification

Write-Host "🔍 Verifying GitHub CI/CD Setup..." -ForegroundColor Cyan
Write-Host ""

# Check 1: Main Repository
Write-Host "📦 Main Repository Status:" -ForegroundColor Yellow
try {
    cd c:\git\webhook
    $mainRepo = git remote get-url origin 2>$null
    if ($mainRepo -eq "https://github.com/faixbenj/webhook-monitor.git") {
        Write-Host "✅ Main repository correctly configured: $mainRepo" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Main repository URL: $mainRepo" -ForegroundColor Yellow
        Write-Host "   Expected: https://github.com/faixbenj/webhook-monitor.git" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Main repository not found or not configured" -ForegroundColor Red
}

Write-Host ""

# Check 2: Helm Repository
Write-Host "⎈ Helm Repository Status:" -ForegroundColor Yellow
try {
    cd c:\git\webhook-helm-repo
    $helmRepo = git remote get-url origin 2>$null
    if ($helmRepo -eq "https://github.com/faixbenj/webhook-monitor-helm.git") {
        Write-Host "✅ Helm repository correctly configured: $helmRepo" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Helm repository URL: $helmRepo" -ForegroundColor Yellow
        Write-Host "   Expected: https://github.com/faixbenj/webhook-monitor-helm.git" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Helm repository not found or not configured" -ForegroundColor Red
}

Write-Host ""

# Check 3: Files exist
Write-Host "📄 Required Files Check:" -ForegroundColor Yellow

$requiredFiles = @(
    @{Path="c:\git\webhook\.github\workflows\build-and-release.yml"; Name="Main CI/CD Pipeline"},
    @{Path="c:\git\webhook-helm-repo\.github\workflows\update-chart.yml"; Name="Helm CI/CD Pipeline"},
    @{Path="c:\git\webhook-helm-repo\charts\webhook-monitor\Chart.yaml"; Name="Helm Chart"},
    @{Path="c:\git\webhook-helm-repo\charts\webhook-monitor\values.yaml"; Name="Chart Values"}
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file.Path) {
        Write-Host "✅ $($file.Name): Found" -ForegroundColor Green
    } else {
        Write-Host "❌ $($file.Name): Missing at $($file.Path)" -ForegroundColor Red
    }
}

Write-Host ""

# Check 4: Username configuration
Write-Host "👤 Username Configuration Check:" -ForegroundColor Yellow
$workflowFile = "c:\git\webhook\.github\workflows\build-and-release.yml"
if (Test-Path $workflowFile) {
    $content = Get-Content $workflowFile -Raw
    if ($content -match "faixbenj") {
        Write-Host "✅ Username 'faixbenj' found in main workflow" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Username not found in main workflow - check for YOUR-USERNAME placeholders" -ForegroundColor Yellow
    }
}

Write-Host ""

# Next Steps
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. 🔑 Create Personal Access Token at: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "   - Select scopes: repo, write:packages, workflow" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 🔐 Add HELM_REPO_TOKEN secret to main repository:" -ForegroundColor White
Write-Host "   - Go to: https://github.com/faixbenj/webhook-monitor/settings/secrets/actions" -ForegroundColor Gray
Write-Host "   - Add secret: HELM_REPO_TOKEN = [your token]" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 📖 Enable GitHub Pages for helm repository:" -ForegroundColor White
Write-Host "   - Go to: https://github.com/faixbenj/webhook-monitor-helm/settings/pages" -ForegroundColor Gray
Write-Host "   - Source: Deploy from branch 'gh-pages'" -ForegroundColor Gray
Write-Host ""
Write-Host "4. 🧪 Test the pipeline:" -ForegroundColor White
Write-Host "   git tag v0.1.0 && git push origin v0.1.0" -ForegroundColor Gray
Write-Host ""

Write-Host "🎉 Setup verification complete!" -ForegroundColor Green