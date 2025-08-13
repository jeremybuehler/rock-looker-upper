"use client"

import type React from "react"
import { createContext, useContext, useEffect, useState } from "react"
import { OfflineStorage } from "@/lib/offline-storage"

interface OfflineContextType {
  isOnline: boolean
  storage: OfflineStorage
  syncStatus: "idle" | "syncing" | "error"
  pendingUploads: number
  isInitialized: boolean
}

const OfflineContext = createContext<OfflineContextType | null>(null)

export function OfflineProvider({ children }: { children: React.ReactNode }) {
  const [isOnline, setIsOnline] = useState(true)
  const [storage] = useState(() => new OfflineStorage())
  const [syncStatus, setSyncStatus] = useState<"idle" | "syncing" | "error">("idle")
  const [pendingUploads, setPendingUploads] = useState(0)
  const [isInitialized, setIsInitialized] = useState(false)

  useEffect(() => {
    const initializeStorage = async () => {
      try {
        await storage.init()
        setIsInitialized(true)
        await updatePendingCount()
      } catch (error) {
        console.error("Failed to initialize offline storage:", error)
        setSyncStatus("error")
      }
    }

    initializeStorage()

    // Service workers require proper MIME types and file serving that isn't available in this environment

    // Monitor online/offline status
    const handleOnline = () => {
      setIsOnline(true)
      if (isInitialized) {
        syncPendingData()
      }
    }

    const handleOffline = () => {
      setIsOnline(false)
    }

    window.addEventListener("online", handleOnline)
    window.addEventListener("offline", handleOffline)

    // Initial online status
    setIsOnline(navigator.onLine)

    return () => {
      window.removeEventListener("online", handleOnline)
      window.removeEventListener("offline", handleOffline)
    }
  }, [storage, isInitialized])

  const syncPendingData = async () => {
    if (!isOnline || !isInitialized) return

    setSyncStatus("syncing")
    try {
      await storage.syncPendingData()
      await updatePendingCount()
      setSyncStatus("idle")
    } catch (error) {
      console.error("Sync failed:", error)
      setSyncStatus("error")
    }
  }

  const updatePendingCount = async () => {
    if (!isInitialized || !storage.isReady()) return

    try {
      const count = await storage.getPendingUploadsCount()
      setPendingUploads(count)
    } catch (error) {
      console.error("Failed to get pending uploads count:", error)
    }
  }

  return (
    <OfflineContext.Provider value={{ isOnline, storage, syncStatus, pendingUploads, isInitialized }}>
      {children}
    </OfflineContext.Provider>
  )
}

export function useOffline() {
  const context = useContext(OfflineContext)
  if (!context) {
    throw new Error("useOffline must be used within OfflineProvider")
  }
  return context
}
