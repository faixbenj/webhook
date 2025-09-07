const CACHE_NAME = 'webhook-monitor-v1'
const urlsToCache = [
  '/',
  '/src/main.ts',
  '/src/App.vue'
]

// Install event
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(urlsToCache)
      })
  )
})

// Fetch event
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        return response || fetch(event.request)
      })
  )
})

// Message event for notifications
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'NEW_WEBHOOK') {
    const webhook = event.data.webhook
    
    // Show notification
    if (self.Notification && self.Notification.permission === 'granted') {
      self.registration.showNotification('New Webhook Received', {
        body: `From: ${webhook.sourceIp || 'Unknown'} at ${new Date(webhook.timestamp).toLocaleString()}`,
        icon: '/favicon.ico',
        tag: webhook.id,
        badge: '/favicon.ico',
        actions: [
          {
            action: 'view',
            title: 'View Details'
          }
        ],
        data: {
          webhookId: webhook.id,
          url: '/'
        }
      })
    }
  }
})

// Notification click event
self.addEventListener('notificationclick', (event) => {
  event.notification.close()
  
  if (event.action === 'view' || !event.action) {
    // Open/focus the app
    event.waitUntil(
      self.clients.matchAll({ type: 'window' }).then((clientList) => {
        // If app is already open, focus it
        for (const client of clientList) {
          if (client.url.includes(event.notification.data?.url || '/') && 'focus' in client) {
            return client.focus()
          }
        }
        // Otherwise open a new window
        if (self.clients.openWindow) {
          return self.clients.openWindow(event.notification.data?.url || '/')
        }
      })
    )
  }
})