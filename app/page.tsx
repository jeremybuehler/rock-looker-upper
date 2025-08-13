import { Camera, Search, MapPin, Database, Wifi, WifiOff, Upload, User } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
// Added offline hook import
import { useOffline } from "@/components/offline-provider"

export default function HomePage() {
  // Added offline status and sync functionality
  const { isOnline, syncStatus, pendingUploads } = useOffline()

  return (
    <div className="min-h-screen bg-gradient-to-b from-cyan-50 to-white">
      {/* Header */}
      <header className="bg-cyan-800 text-white p-4 shadow-lg">
        <div className="max-w-md mx-auto">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center justify-center gap-2 flex-1">
              <span className="font-serif text-lg font-bold text-center">Marine Rock Identifier</span>
            </div>
            <Link href="/profile">
              <Button
                variant="ghost"
                size="lg"
                className="text-white hover:bg-cyan-700 bg-cyan-700/30 border border-cyan-600/50 rounded-full p-3"
              >
                <User className="h-7 w-7" />
              </Button>
            </Link>
          </div>
          <p className="text-cyan-100 text-center text-sm">Explore the Depths: Identify, Document, and Discover!</p>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-md mx-auto p-4 space-y-6">
        {/* Status Indicator */}
        <div className="flex items-center justify-between bg-white rounded-lg p-3 shadow-sm border">
          <span className="text-slate-600 text-sm">Connection Status</span>
          <div className="flex items-center gap-2">
            {/* Updated status indicator to show offline state and sync status */}
            {isOnline ? <Wifi className="h-4 w-4 text-green-600" /> : <WifiOff className="h-4 w-4 text-red-600" />}
            <span className={`text-sm font-medium ${isOnline ? "text-green-600" : "text-red-600"}`}>
              {isOnline ? "Online" : "Offline"}
            </span>
            {syncStatus === "syncing" && <Upload className="h-3 w-3 text-blue-600 animate-pulse" />}
          </div>
        </div>

        {/* Added pending uploads indicator */}
        {pendingUploads > 0 && (
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
            <div className="flex items-center gap-2">
              <Upload className="h-4 w-4 text-amber-600" />
              <span className="text-amber-800 text-sm">
                {pendingUploads} item{pendingUploads > 1 ? "s" : ""} pending sync
              </span>
            </div>
            <p className="text-amber-700 text-xs mt-1">Data will sync automatically when connection is restored</p>
          </div>
        )}

        {/* Quick Actions */}
        <div className="space-y-4">
          <h2 className="font-serif text-xl font-bold text-slate-700">Quick Actions</h2>

          {/* Camera Capture */}
          <Card className="hover:shadow-md transition-shadow">
            <CardHeader className="pb-3">
              <div className="flex items-center gap-3">
                <div className="bg-cyan-100 p-2 rounded-lg">
                  <Camera className="h-6 w-6 text-cyan-800" />
                </div>
                <div>
                  <CardTitle className="text-lg">Capture Specimen</CardTitle>
                  <CardDescription>Take a photo for AI-powered identification</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <Link href="/camera">
                <Button className="w-full bg-cyan-800 hover:bg-cyan-700">Open Camera</Button>
              </Link>
            </CardContent>
          </Card>

          {/* AI Analysis */}
          <Card className="hover:shadow-md transition-shadow">
            <CardHeader className="pb-3">
              <div className="flex items-center gap-3">
                <div className="bg-purple-100 p-2 rounded-lg">
                  <Search className="h-6 w-6 text-purple-600" />
                </div>
                <div>
                  <CardTitle className="text-lg">AI Analysis</CardTitle>
                  <CardDescription>Multi-model identification with confidence scores</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <Link href="/analyze">
                <Button variant="outline" className="w-full bg-transparent">
                  Start Analysis
                </Button>
              </Link>
            </CardContent>
          </Card>

          {/* Field Notes */}
          <Card className="hover:shadow-md transition-shadow">
            <CardHeader className="pb-3">
              <div className="flex items-center gap-3">
                <div className="bg-green-100 p-2 rounded-lg">
                  <MapPin className="h-6 w-6 text-green-600" />
                </div>
                <div>
                  <CardTitle className="text-lg">GPS Field Notes</CardTitle>
                  <CardDescription>Location-tagged observations and findings</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <Link href="/field-notes">
                <Button variant="outline" className="w-full bg-transparent">
                  Add Field Note
                </Button>
              </Link>
            </CardContent>
          </Card>

          {/* Symbol Database */}
          <Card className="hover:shadow-md transition-shadow">
            <CardHeader className="pb-3">
              <div className="flex items-center gap-3">
                <div className="bg-amber-100 p-2 rounded-lg">
                  <Database className="h-6 w-6 text-amber-600" />
                </div>
                <div>
                  <CardTitle className="text-lg">Symbol Database</CardTitle>
                  <CardDescription>Search geological and cultural symbols</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <Link href="/symbols">
                <Button variant="outline" className="w-full bg-transparent">
                  Browse Database
                </Button>
              </Link>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activity */}
        <div className="space-y-4">
          <h2 className="font-serif text-xl font-bold text-slate-700">Recent Activity</h2>
          <Card>
            <CardContent className="p-4">
              <p className="text-slate-500 text-center">
                No recent identifications. Start by capturing your first specimen!
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Community Message */}
        <div className="bg-cyan-50 rounded-lg p-4 border border-cyan-200">
          <p className="text-cyan-800 text-sm text-center">
            Join a community of explorers and contribute to marine science
          </p>
        </div>
      </main>

      {/* Bottom Navigation Placeholder */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200 p-4">
        <div className="max-w-md mx-auto flex justify-center">
          <p className="text-slate-500 text-sm">Tap to identify, swipe to catalog</p>
        </div>
      </nav>
    </div>
  )
}
