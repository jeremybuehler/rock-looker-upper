"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { ArrowLeft, Database, Trash2, Upload, HardDrive, Wifi, WifiOff } from "lucide-react"
import Link from "next/link"
import { useOffline } from "@/components/offline-provider"

export default function OfflinePage() {
  const { isOnline, storage, syncStatus, pendingUploads } = useOffline()
  const [storageUsage, setStorageUsage] = useState({ used: 0, quota: 0 })
  const [isClearing, setIsClearing] = useState(false)

  useEffect(() => {
    updateStorageUsage()
  }, [])

  const updateStorageUsage = async () => {
    const usage = await storage.getStorageUsage()
    setStorageUsage(usage)
  }

  const clearAllData = async () => {
    setIsClearing(true)
    try {
      await storage.clearAllData()
      await updateStorageUsage()
    } catch (error) {
      console.error("Failed to clear data:", error)
    } finally {
      setIsClearing(false)
    }
  }

  const formatBytes = (bytes: number) => {
    if (bytes === 0) return "0 Bytes"
    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  }

  const usagePercentage = storageUsage.quota > 0 ? (storageUsage.used / storageUsage.quota) * 100 : 0

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-cyan-50 p-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="flex items-center gap-4 mb-6">
          <Link href="/">
            <Button variant="ghost" size="sm">
              <ArrowLeft className="w-4 h-4 mr-2" />
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Offline Storage</h1>
            <p className="text-slate-600">Manage offline data and sync settings</p>
          </div>
        </div>

        <div className="space-y-6">
          {/* Connection Status */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                {isOnline ? <Wifi className="w-5 h-5 text-green-600" /> : <WifiOff className="w-5 h-5 text-red-600" />}
                Connection Status
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-slate-700">Current Status:</span>
                <span className={`font-medium ${isOnline ? "text-green-600" : "text-red-600"}`}>
                  {isOnline ? "Online" : "Offline"}
                </span>
              </div>

              <div className="flex items-center justify-between">
                <span className="text-slate-700">Sync Status:</span>
                <span className="font-medium">
                  {syncStatus === "syncing" ? "Syncing..." : syncStatus === "error" ? "Error" : "Idle"}
                </span>
              </div>

              <div className="flex items-center justify-between">
                <span className="text-slate-700">Pending Uploads:</span>
                <span className="font-medium text-amber-600">{pendingUploads} items</span>
              </div>

              {!isOnline && (
                <div className="p-3 bg-amber-50 border border-amber-200 rounded-lg">
                  <p className="text-amber-800 text-sm">
                    You're currently offline. Data will sync automatically when connection is restored.
                  </p>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Storage Usage */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <HardDrive className="w-5 h-5" />
                Storage Usage
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Used Storage</span>
                  <span>
                    {formatBytes(storageUsage.used)} / {formatBytes(storageUsage.quota)}
                  </span>
                </div>
                <Progress value={usagePercentage} className="w-full" />
                <p className="text-xs text-slate-500">{usagePercentage.toFixed(1)}% of available storage used</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                <div className="p-3 bg-slate-50 rounded-lg">
                  <div className="font-medium text-slate-700">Images</div>
                  <div className="text-slate-600">Captured specimens</div>
                </div>
                <div className="p-3 bg-slate-50 rounded-lg">
                  <div className="font-medium text-slate-700">Field Notes</div>
                  <div className="text-slate-600">GPS-tagged observations</div>
                </div>
                <div className="p-3 bg-slate-50 rounded-lg">
                  <div className="font-medium text-slate-700">Analysis Results</div>
                  <div className="text-slate-600">AI identification data</div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Offline Capabilities */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Database className="w-5 h-5" />
                Offline Capabilities
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-slate-700">Camera capture and image storage</span>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-slate-700">GPS field notes creation and storage</span>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-slate-700">Symbol database browsing (cached)</span>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
                  <span className="text-slate-700">Limited AI analysis (offline fallback)</span>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-red-500 rounded-full"></div>
                  <span className="text-slate-700">Real-time AI analysis (requires internet)</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Data Management */}
          <Card>
            <CardHeader>
              <CardTitle>Data Management</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
                <h4 className="font-medium text-red-800 mb-2">Clear All Offline Data</h4>
                <p className="text-red-700 text-sm mb-3">
                  This will permanently delete all stored images, field notes, analysis results, and cached data. Make
                  sure you've synced any important data before proceeding.
                </p>
                <Button variant="destructive" onClick={clearAllData} disabled={isClearing} size="sm">
                  {isClearing ? (
                    <>
                      <Upload className="w-4 h-4 mr-2 animate-spin" />
                      Clearing...
                    </>
                  ) : (
                    <>
                      <Trash2 className="w-4 h-4 mr-2" />
                      Clear All Data
                    </>
                  )}
                </Button>
              </div>

              <div className="text-xs text-slate-500">
                <p>• Data is automatically synced when you're online</p>
                <p>• Offline storage uses your browser's IndexedDB</p>
                <p>• Service worker caches app resources for offline use</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
