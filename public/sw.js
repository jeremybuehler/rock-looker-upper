const CACHE_NAME = "marine-rock-identifier-v1"
const STATIC_CACHE = "static-v1"
const DYNAMIC_CACHE = "dynamic-v1"

// Static assets to cache
const STATIC_ASSETS = ["/", "/camera", "/analyze", "/field-notes", "/symbols", "/manifest.json", "/logo.png"]

// Install event - cache static assets
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(STATIC_CACHE)
      .then((cache) => {
        return cache.addAll(STATIC_ASSETS)
      })
      .then(() => {
        return self.skipWaiting()
      }),
  )
})

// Activate event - clean up old caches
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE) {
              return caches.delete(cacheName)
            }
          }),
        )
      })
      .then(() => {
        return self.clients.claim()
      }),
  )
})

// Fetch event - serve from cache, fallback to network
self.addEventListener("fetch", (event) => {
  const { request } = event

  // Skip non-GET requests
  if (request.method !== "GET") {
    return
  }

  // Handle API requests
  if (request.url.includes("/api/")) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache successful API responses
          if (response.status === 200) {
            const responseClone = response.clone()
            caches.open(DYNAMIC_CACHE).then((cache) => {
              cache.put(request, responseClone)
            })
          }
          return response
        })
        .catch(() => {
          // Return cached response if available
          return caches.match(request).then((cachedResponse) => {
            if (cachedResponse) {
              return cachedResponse
            }
            // Return offline fallback for analysis requests
            if (request.url.includes("/api/analyze")) {
              return new Response(
                JSON.stringify({
                  analyses: [
                    {
                      type: "geological",
                      name: "Offline Analysis Unavailable",
                      confidence: 0,
                      description:
                        "AI analysis requires internet connection. Your image has been saved for analysis when you're back online.",
                      characteristics: ["Offline mode"],
                      formation: "Unknown - offline",
                    },
                  ],
                }),
                {
                  headers: { "Content-Type": "application/json" },
                },
              )
            }
            throw new Error("No cached response available")
          })
        }),
    )
    return
  }

  // Handle static assets and pages
  event.respondWith(
    caches.match(request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse
      }

      return fetch(request)
        .then((response) => {
          // Don't cache non-successful responses
          if (!response || response.status !== 200 || response.type !== "basic") {
            return response
          }

          // Cache the response
          const responseToCache = response.clone()
          caches.open(DYNAMIC_CACHE).then((cache) => {
            cache.put(request, responseToCache)
          })

          return response
        })
        .catch(() => {
          // Return offline fallback page
          if (request.destination === "document") {
            return caches.match("/")
          }
          throw new Error("Network request failed and no cache available")
        })
    }),
  )
})

// Background sync for pending uploads
self.addEventListener("sync", (event) => {
  if (event.tag === "background-sync") {
    event.waitUntil(
      // Notify the main app to sync pending data
      self.clients
        .matchAll()
        .then((clients) => {
          clients.forEach((client) => {
            client.postMessage({ type: "SYNC_PENDING_DATA" })
          })
        }),
    )
  }
})

// Push notifications for sync status
self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting()
  }
})
