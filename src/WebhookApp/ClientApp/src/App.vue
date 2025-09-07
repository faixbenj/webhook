<template>
  <div id="app">
    <header class="header">
      <h1>🔗 Webhook Monitor</h1>
      <div class="stats">
        <span class="stat">
          <strong>{{ webhooks.length }}</strong> webhooks (last hour)
        </span>
        <span class="connection-status" :class="{ connected: isConnected }">
          {{ isConnected ? '🟢 Connected' : '🔴 Disconnected' }}
        </span>
      </div>
    </header>

    <main class="main">
      <div v-if="webhooks.length === 0" class="empty-state">
        <p>No webhooks received yet. Send a POST request to:</p>
        <code>{{ webhookUrl }}</code>
      </div>

      <div v-else class="webhook-feed">
        <div
          v-for="webhook in webhooks"
          :key="webhook.id"
          class="webhook-item"
          :class="{ 'webhook-new': newWebhookIds.has(webhook.id) }"
        >
          <div class="webhook-header" @click="toggleExpanded(webhook.id)">
            <div class="webhook-meta">
              <span class="timestamp">{{ formatTimestamp(webhook.timestamp) }}</span>
              <span class="source-ip" v-if="webhook.sourceIp">{{ webhook.sourceIp }}</span>
              <span class="content-type">{{ webhook.contentType }}</span>
            </div>
            <button class="expand-btn" :class="{ expanded: expandedItems.has(webhook.id) }">
              {{ expandedItems.has(webhook.id) ? '▼' : '▶' }}
            </button>
          </div>

          <div v-if="expandedItems.has(webhook.id)" class="webhook-details">
            <div class="webhook-section">
              <h4>Headers</h4>
              <pre class="json-display">{{ formatJson(webhook.headers) }}</pre>
            </div>

            <div class="webhook-section">
              <h4>Payload</h4>
              <pre class="json-display">{{ formatJson(webhook.payload) }}</pre>
            </div>

            <div v-if="webhook.rawPayload && webhook.rawPayload !== formatJson(webhook.payload)" class="webhook-section">
              <h4>Raw Payload</h4>
              <pre class="raw-display">{{ webhook.rawPayload }}</pre>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as signalR from '@microsoft/signalr'

interface WebhookData {
  id: string
  timestamp: string
  sourceIp?: string
  headers: Record<string, string[]>
  payload: any
  rawPayload?: string
  contentType: string
}

const webhooks = ref<WebhookData[]>([])
const isConnected = ref(false)
const expandedItems = ref(new Set<string>())
const newWebhookIds = ref(new Set<string>())
const webhookUrl = ref(`${window.location.origin}/webhook`)

let connection: signalR.HubConnection | null = null

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

const formatJson = (obj: any) => {
  try {
    return JSON.stringify(obj, null, 2)
  } catch {
    return String(obj)
  }
}

const toggleExpanded = (id: string) => {
  if (expandedItems.value.has(id)) {
    expandedItems.value.delete(id)
  } else {
    expandedItems.value.add(id)
  }
}

const showNotification = (webhook: WebhookData) => {
  if ('Notification' in window && Notification.permission === 'granted') {
    new Notification('New Webhook Received', {
      body: `From: ${webhook.sourceIp || 'Unknown'} at ${formatTimestamp(webhook.timestamp)}`,
      icon: '/favicon.ico',
      tag: webhook.id
    })
  }
}

const requestNotificationPermission = async () => {
  if ('Notification' in window && Notification.permission === 'default') {
    await Notification.requestPermission()
  }
}

const registerServiceWorker = async () => {
  if ('serviceWorker' in navigator) {
    try {
      const registration = await navigator.serviceWorker.register('/sw.js')
      console.log('Service Worker registered:', registration)
    } catch (error) {
      console.error('Service Worker registration failed:', error)
    }
  }
}

const loadRecentWebhooks = async () => {
  try {
    const response = await fetch('/webhook/recent')
    if (response.ok) {
      const data = await response.json()
      webhooks.value = data
    }
  } catch (error) {
    console.error('Failed to load recent webhooks:', error)
  }
}

const setupSignalR = async () => {
  connection = new signalR.HubConnectionBuilder()
    .withUrl('/webhookhub')
    .withAutomaticReconnect()
    .build()

  connection.on('NewWebhook', (webhook: WebhookData) => {
    // Add to beginning of array
    webhooks.value.unshift(webhook)
    
    // Mark as new for animation
    newWebhookIds.value.add(webhook.id)
    setTimeout(() => {
      newWebhookIds.value.delete(webhook.id)
    }, 2000)

    // Show notification
    showNotification(webhook)

    // Keep only recent webhooks (last hour worth)
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000)
    webhooks.value = webhooks.value.filter(w => new Date(w.timestamp) > oneHourAgo)
  })

  connection.onreconnecting(() => {
    isConnected.value = false
  })

  connection.onreconnected(() => {
    isConnected.value = true
  })

  connection.onclose(() => {
    isConnected.value = false
  })

  try {
    await connection.start()
    isConnected.value = true
    console.log('SignalR connected')
  } catch (error) {
    console.error('SignalR connection error:', error)
  }
}

onMounted(async () => {
  await requestNotificationPermission()
  await registerServiceWorker()
  await loadRecentWebhooks()
  await setupSignalR()
})

onUnmounted(() => {
  connection?.stop()
})
</script>

<style scoped>
#app {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  margin: 0;
  padding: 0;
  min-height: 100vh;
  background-color: #f5f5f5;
}

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h1 {
  margin: 0;
  font-size: 1.8rem;
  font-weight: 600;
}

.stats {
  display: flex;
  gap: 20px;
  align-items: center;
}

.stat {
  background: rgba(255,255,255,0.2);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
}

.connection-status {
  padding: 8px 16px;
  border-radius: 20px;
  background: rgba(255,255,255,0.2);
  transition: background-color 0.3s;
}

.connection-status.connected {
  background: rgba(76, 175, 80, 0.3);
}

.main {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.empty-state code {
  background: #f8f9fa;
  padding: 12px 20px;
  border-radius: 6px;
  font-family: 'Courier New', monospace;
  font-size: 1.1rem;
  color: #495057;
  border: 1px solid #e9ecef;
  display: inline-block;
  margin-top: 15px;
}

.webhook-feed {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.webhook-item {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  overflow: hidden;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.webhook-item:hover {
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
}

.webhook-new {
  border-color: #4CAF50;
  animation: pulse 2s ease-in-out;
}

@keyframes pulse {
  0% { box-shadow: 0 0 0 0 rgba(76, 175, 80, 0.7); }
  70% { box-shadow: 0 0 0 10px rgba(76, 175, 80, 0); }
  100% { box-shadow: 0 0 0 0 rgba(76, 175, 80, 0); }
}

.webhook-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  cursor: pointer;
  background: linear-gradient(90deg, #f8f9fa 0%, #e9ecef 100%);
  transition: background 0.2s;
}

.webhook-header:hover {
  background: linear-gradient(90deg, #e9ecef 0%, #dee2e6 100%);
}

.webhook-meta {
  display: flex;
  gap: 16px;
  align-items: center;
  flex-wrap: wrap;
}

.timestamp {
  font-weight: 600;
  color: #495057;
  font-size: 1rem;
}

.source-ip {
  background: #007bff;
  color: white;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 0.85rem;
  font-weight: 500;
}

.content-type {
  background: #6c757d;
  color: white;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 0.85rem;
}

.expand-btn {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  transition: all 0.2s;
  color: #6c757d;
}

.expand-btn:hover {
  background: rgba(0,0,0,0.1);
}

.expand-btn.expanded {
  transform: rotate(0deg);
}

.webhook-details {
  padding: 20px;
  border-top: 1px solid #e9ecef;
  background: #ffffff;
}

.webhook-section {
  margin-bottom: 24px;
}

.webhook-section:last-child {
  margin-bottom: 0;
}

.webhook-section h4 {
  margin: 0 0 12px 0;
  color: #495057;
  font-size: 1.1rem;
  font-weight: 600;
  padding-bottom: 8px;
  border-bottom: 2px solid #e9ecef;
}

.json-display, .raw-display {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 16px;
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
  line-height: 1.5;
  color: #495057;
  overflow-x: auto;
  white-space: pre-wrap;
  word-wrap: break-word;
  margin: 0;
}

.json-display {
  max-height: 400px;
  overflow-y: auto;
}

.raw-display {
  background: #fff3cd;
  border-color: #ffeaa7;
  color: #856404;
}

@media (max-width: 768px) {
  .header {
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }
  
  .stats {
    flex-direction: column;
    gap: 10px;
  }
  
  .webhook-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .main {
    padding: 15px;
  }
}
</style>