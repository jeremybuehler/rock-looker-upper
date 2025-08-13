interface StoredImage {
  id: string
  dataUrl: string
  timestamp: string
  synced: number // 0 = false, 1 = true
}

interface StoredFieldNote {
  id: string
  title: string
  description: string
  location: {
    latitude: number
    longitude: number
    accuracy: number
  }
  timestamp: string
  weather?: string
  depth?: string
  substrate?: string
  tags: string[]
  synced: number // 0 = false, 1 = true
}

interface StoredAnalysis {
  id: string
  imageId: string
  results: any[]
  timestamp: string
  synced: number // 0 = false, 1 = true
}

export class OfflineStorage {
  private db: IDBDatabase | null = null
  private readonly DB_NAME = "MarineRockIdentifier"
  private readonly DB_VERSION = 2 // Incremented version for schema change
  private initialized = false

  isReady(): boolean {
    return this.initialized && this.db !== null
  }

  async init(): Promise<void> {
    if (this.initialized) return

    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.DB_NAME, this.DB_VERSION)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => {
        this.db = request.result
        this.initialized = true
        resolve()
      }

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result

        // Clear existing stores if they exist (for schema migration)
        if (db.objectStoreNames.contains("images")) {
          db.deleteObjectStore("images")
        }
        if (db.objectStoreNames.contains("fieldNotes")) {
          db.deleteObjectStore("fieldNotes")
        }
        if (db.objectStoreNames.contains("analyses")) {
          db.deleteObjectStore("analyses")
        }

        // Images store
        const imageStore = db.createObjectStore("images", { keyPath: "id" })
        imageStore.createIndex("timestamp", "timestamp")
        imageStore.createIndex("synced", "synced")

        // Field notes store
        const notesStore = db.createObjectStore("fieldNotes", { keyPath: "id" })
        notesStore.createIndex("timestamp", "timestamp")
        notesStore.createIndex("synced", "synced")

        // Analysis results store
        const analysisStore = db.createObjectStore("analyses", { keyPath: "id" })
        analysisStore.createIndex("timestamp", "timestamp")
        analysisStore.createIndex("synced", "synced")
        analysisStore.createIndex("imageId", "imageId")

        // Symbol cache store
        if (!db.objectStoreNames.contains("symbolCache")) {
          const symbolStore = db.createObjectStore("symbolCache", { keyPath: "id" })
          symbolStore.createIndex("category", "category")
          symbolStore.createIndex("lastUpdated", "lastUpdated")
        }
      }
    })
  }

  // Image storage methods
  async storeImage(imageDataUrl: string): Promise<string> {
    if (!this.isReady()) throw new Error("Database not initialized")

    const id = Date.now().toString()
    const image: StoredImage = {
      id,
      dataUrl: imageDataUrl,
      timestamp: new Date().toISOString(),
      synced: 0, // Using 0 instead of false
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["images"], "readwrite")
      const store = transaction.objectStore("images")
      const request = store.add(image)

      request.onsuccess = () => resolve(id)
      request.onerror = () => reject(request.error)
    })
  }

  async getImage(id: string): Promise<StoredImage | null> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["images"], "readonly")
      const store = transaction.objectStore("images")
      const request = store.get(id)

      request.onsuccess = () => resolve(request.result || null)
      request.onerror = () => reject(request.error)
    })
  }

  // Field notes storage methods
  async storeFieldNote(note: Omit<StoredFieldNote, "id" | "synced">): Promise<string> {
    if (!this.isReady()) throw new Error("Database not initialized")

    const id = Date.now().toString()
    const fieldNote: StoredFieldNote = {
      ...note,
      id,
      synced: 0, // Using 0 instead of false
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["fieldNotes"], "readwrite")
      const store = transaction.objectStore("fieldNotes")
      const request = store.add(fieldNote)

      request.onsuccess = () => resolve(id)
      request.onerror = () => reject(request.error)
    })
  }

  async getFieldNotes(): Promise<StoredFieldNote[]> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["fieldNotes"], "readonly")
      const store = transaction.objectStore("fieldNotes")
      const index = store.index("timestamp")
      const request = index.getAll()

      request.onsuccess = () => {
        const notes = request.result.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
        resolve(notes)
      }
      request.onerror = () => reject(request.error)
    })
  }

  // Analysis storage methods
  async storeAnalysis(imageId: string, results: any[]): Promise<string> {
    if (!this.isReady()) throw new Error("Database not initialized")

    const id = Date.now().toString()
    const analysis: StoredAnalysis = {
      id,
      imageId,
      results,
      timestamp: new Date().toISOString(),
      synced: 0, // Using 0 instead of false
    }

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["analyses"], "readwrite")
      const store = transaction.objectStore("analyses")
      const request = store.add(analysis)

      request.onsuccess = () => resolve(id)
      request.onerror = () => reject(request.error)
    })
  }

  async getAnalysis(imageId: string): Promise<StoredAnalysis | null> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["analyses"], "readonly")
      const store = transaction.objectStore("analyses")
      const index = store.index("imageId")
      const request = index.get(imageId)

      request.onsuccess = () => resolve(request.result || null)
      request.onerror = () => reject(request.error)
    })
  }

  // Symbol cache methods
  async cacheSymbols(symbols: any[]): Promise<void> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["symbolCache"], "readwrite")
      const store = transaction.objectStore("symbolCache")

      // Clear existing cache
      store.clear()

      // Add new symbols
      symbols.forEach((symbol) => {
        store.add({
          ...symbol,
          lastUpdated: new Date().toISOString(),
        })
      })

      transaction.oncomplete = () => resolve()
      transaction.onerror = () => reject(transaction.error)
    })
  }

  async getCachedSymbols(): Promise<any[]> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction(["symbolCache"], "readonly")
      const store = transaction.objectStore("symbolCache")
      const request = store.getAll()

      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }

  // Sync methods
  async getPendingUploadsCount(): Promise<number> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      let count = 0
      const stores = ["images", "fieldNotes", "analyses"]
      let completed = 0

      stores.forEach((storeName) => {
        const transaction = this.db!.transaction([storeName], "readonly")
        const store = transaction.objectStore(storeName)
        const index = store.index("synced")
        const request = index.count(IDBKeyRange.only(0))

        request.onsuccess = () => {
          count += request.result
          completed++
          if (completed === stores.length) {
            resolve(count)
          }
        }
        request.onerror = () => reject(request.error)
      })
    })
  }

  async syncPendingData(): Promise<void> {
    if (!this.isReady()) throw new Error("Database not initialized")

    // In a real implementation, this would sync with your backend
    // For now, we'll just mark items as synced
    return new Promise((resolve, reject) => {
      const stores = ["images", "fieldNotes", "analyses"]
      let completed = 0

      stores.forEach((storeName) => {
        const transaction = this.db!.transaction([storeName], "readwrite")
        const store = transaction.objectStore(storeName)
        const index = store.index("synced")
        const request = index.openCursor(IDBKeyRange.only(0))

        request.onsuccess = (event) => {
          const cursor = (event.target as IDBRequest).result
          if (cursor) {
            const item = cursor.value
            item.synced = 1 // Using 1 instead of true
            cursor.update(item)
            cursor.continue()
          } else {
            completed++
            if (completed === stores.length) {
              resolve()
            }
          }
        }
        request.onerror = () => reject(request.error)
      })
    })
  }

  // Utility methods
  async clearAllData(): Promise<void> {
    if (!this.isReady()) throw new Error("Database not initialized")

    return new Promise((resolve, reject) => {
      const stores = ["images", "fieldNotes", "analyses", "symbolCache"]
      let completed = 0

      stores.forEach((storeName) => {
        const transaction = this.db!.transaction([storeName], "readwrite")
        const store = transaction.objectStore(storeName)
        const request = store.clear()

        request.onsuccess = () => {
          completed++
          if (completed === stores.length) {
            resolve()
          }
        }
        request.onerror = () => reject(request.error)
      })
    })
  }

  async getStorageUsage(): Promise<{ used: number; quota: number }> {
    if ("storage" in navigator && "estimate" in navigator.storage) {
      const estimate = await navigator.storage.estimate()
      return {
        used: estimate.usage || 0,
        quota: estimate.quota || 0,
      }
    }
    return { used: 0, quota: 0 }
  }
}
