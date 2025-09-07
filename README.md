# Webhook Monitor

A real-time webhook monitoring application built with ASP.NET Core and Vue 3.

## Features

- 🔗 **Real-time webhook monitoring** - Receive and display webhooks instantly
- 📱 **Browser notifications** - Get notified of new webhooks even when the app is in the background
- 📊 **JSON formatting** - Auto-formatted, collapsible JSON payload display
- ⏰ **1-hour retention** - Automatically manages webhook history
- 🚀 **Real-time updates** - Uses SignalR for instant updates
- 🐳 **Docker ready** - Containerized with Kubernetes Helm charts
- 📱 **Service Worker** - Background notifications and offline capability

## Quick Start

### Development

1. **Prerequisites:**
   - .NET 8.0 SDK
   - Node.js 20+
   - Visual Studio Code or Visual Studio

2. **Clone and run:**
   ```bash
   git clone <repository-url>
   cd webhook
   dotnet run --project src/WebhookApp
   ```

3. **The application will be available at:**
   - Frontend: `http://localhost:5000`
   - Webhook endpoint: `http://localhost:5000/webhook`

### Docker

1. **Build image:**
   ```bash
   docker build -t webhook-monitor .
   ```

2. **Run container:**
   ```bash
   docker run -p 8080:80 webhook-monitor
   ```

### Kubernetes with Helm

1. **Deploy to Kubernetes:**
   ```bash
   helm install webhook-monitor ./helm/webhook-monitor
   ```

2. **Update values for your environment:**
   ```bash
   helm upgrade webhook-monitor ./helm/webhook-monitor --set ingress.hosts[0].host=your-domain.com
   ```

## Usage

1. **Open the application** in your browser
2. **Allow notifications** when prompted
3. **Send webhooks** to the `/webhook` endpoint:

   ```bash
   curl -X POST http://localhost:5000/webhook \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello World", "timestamp": "2025-01-01T00:00:00Z"}'
   ```

4. **View real-time updates** in the web interface and receive browser notifications

## API Endpoints

- `POST /webhook` - Receive webhook payloads
- `GET /webhook/recent` - Get recent webhooks (last hour)
- `GET /webhookhub` - SignalR hub for real-time updates

## Configuration

The application uses in-memory storage with 1-hour retention. No external dependencies required.

## Architecture

- **Backend**: ASP.NET Core 8.0 with SignalR
- **Frontend**: Vue 3 + TypeScript
- **Storage**: In-memory with automatic cleanup
- **Real-time**: SignalR WebSockets
- **Notifications**: Service Worker + Web Notifications API
- **Containerization**: Docker + Kubernetes Helm charts

## Development Scripts

```bash
# Install frontend dependencies
cd src/WebhookApp/ClientApp
npm install

# Run frontend in development mode
npm run dev

# Build frontend for production
npm run build

# Run backend
dotnet run --project src/WebhookApp
```