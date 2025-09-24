# Script para ejecutar Flutter Web en localhost:3000
# Compatible con Windows PowerShell

Write-Host "🚀 Iniciando DevUni App en localhost:3000..." -ForegroundColor Green

# Configurar puerto 3000 para Flutter Web
$env:FLUTTER_WEB_PORT = "3000"

# Ejecutar Flutter en Chrome con puerto específico
flutter run -d chrome --web-port=3000 --web-hostname=localhost --web-renderer=html

Write-Host "✅ Aplicación ejecutándose en http://localhost:3000" -ForegroundColor Green