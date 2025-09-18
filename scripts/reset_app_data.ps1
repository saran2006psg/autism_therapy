# PowerShell script to clear ThrivePath app data for fresh testing
# Run this script to clear all login data and reset the app

Write-Host "🔄 Starting ThrivePath app data reset..." -ForegroundColor Cyan

# Clear Chrome browser data for localhost (where the app runs)
Write-Host "🌐 Clearing Chrome browser data..." -ForegroundColor Yellow
try {
    # Close Chrome if running
    Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Clear Chrome cache and local storage
    $chromePaths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Storage",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Session Storage",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\IndexedDB",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\WebStorage"
    )
    
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            Write-Host "  Clearing: $path" -ForegroundColor Gray
            Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "✅ Chrome data cleared" -ForegroundColor Green
}
catch {
    Write-Host "⚠️  Chrome data clearing: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Clear Flutter build cache
Write-Host "🔨 Clearing Flutter build cache..." -ForegroundColor Yellow
try {
    Push-Location "$(Get-Location)\thriveers"
    
    if (Test-Path "build") {
        Remove-Item "build" -Recurse -Force
        Write-Host "✅ Flutter build cache cleared" -ForegroundColor Green
    }
    
    Pop-Location
}
catch {
    Write-Host "⚠️  Flutter cache clearing: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Clear .dart_tool cache
Write-Host "🛠️  Clearing Dart tool cache..." -ForegroundColor Yellow
try {
    Push-Location "$(Get-Location)\thriveers"
    
    if (Test-Path ".dart_tool\chrome-device") {
        Remove-Item ".dart_tool\chrome-device" -Recurse -Force
        Write-Host "✅ Dart tool cache cleared" -ForegroundColor Green
    }
    
    Pop-Location
}
catch {
    Write-Host "⚠️  Dart tool cache clearing: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 App data reset completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart the Flutter app (flutter run --debug)" -ForegroundColor White
Write-Host "2. The app will start fresh with the login/role selection screen" -ForegroundColor White
Write-Host "3. Create new test accounts:" -ForegroundColor White
Write-Host "   - Therapist: therapist@test.com / password123" -ForegroundColor Gray
Write-Host "   - Parent: parent@test.com / password123" -ForegroundColor Gray
Write-Host ""
Write-Host "The app will create fresh test data and sync properly with Firebase!" -ForegroundColor Green
