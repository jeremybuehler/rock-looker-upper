"use client"

import { useState, useRef, useCallback } from "react"
import { Camera, RotateCcw, Check, ArrowLeft } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import Link from "next/link"

export default function CameraPage() {
  const [stream, setStream] = useState<MediaStream | null>(null)
  const [capturedImage, setCapturedImage] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  const startCamera = useCallback(async () => {
    setIsLoading(true)
    setError(null)

    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: "environment", // Use back camera on mobile
          width: { ideal: 1920 },
          height: { ideal: 1080 },
        },
      })

      setStream(mediaStream)
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream
      }
    } catch (err) {
      setError("Unable to access camera. Please check permissions.")
      console.error("Camera access error:", err)
    } finally {
      setIsLoading(false)
    }
  }, [])

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach((track) => track.stop())
      setStream(null)
    }
  }, [stream])

  const capturePhoto = useCallback(() => {
    if (!videoRef.current || !canvasRef.current) return

    const video = videoRef.current
    const canvas = canvasRef.current
    const context = canvas.getContext("2d")

    if (!context) return

    // Set canvas dimensions to match video
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight

    // Draw the video frame to canvas
    context.drawImage(video, 0, 0, canvas.width, canvas.height)

    // Convert to data URL
    const imageDataUrl = canvas.toDataURL("image/jpeg", 0.8)
    setCapturedImage(imageDataUrl)
    stopCamera()
  }, [stopCamera])

  const retakePhoto = useCallback(() => {
    setCapturedImage(null)
    startCamera()
  }, [startCamera])

  const confirmPhoto = useCallback(() => {
    // Here we would typically save the photo and navigate to analysis
    // For now, we'll just navigate back to home
    console.log("Photo confirmed:", capturedImage)
    // TODO: Save photo and navigate to analysis page
  }, [capturedImage])

  return (
    <div className="min-h-screen bg-slate-900">
      {/* Header */}
      <header className="bg-cyan-800 text-white p-4 shadow-lg">
        <div className="max-w-md mx-auto flex items-center gap-3">
          <Link href="/">
            <Button variant="ghost" size="sm" className="text-white hover:bg-cyan-700 p-2">
              <ArrowLeft className="h-5 w-5" />
            </Button>
          </Link>
          <h1 className="font-serif text-xl font-bold">Capture Specimen</h1>
        </div>
      </header>

      <main className="max-w-md mx-auto p-4">
        {!stream && !capturedImage && (
          <div className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardContent className="p-6 text-center space-y-4">
                <div className="bg-cyan-100 p-4 rounded-full w-16 h-16 mx-auto flex items-center justify-center">
                  <Camera className="h-8 w-8 text-cyan-800" />
                </div>
                <div className="space-y-2">
                  <h2 className="font-serif text-xl font-bold text-white">Ready to Capture</h2>
                  <p className="text-slate-300 text-sm">
                    Position your specimen in good lighting for best identification results
                  </p>
                </div>
                <Button onClick={startCamera} disabled={isLoading} className="w-full bg-cyan-800 hover:bg-cyan-700">
                  {isLoading ? "Starting Camera..." : "Start Camera"}
                </Button>
                {error && <p className="text-red-400 text-sm">{error}</p>}
              </CardContent>
            </Card>

            <div className="bg-slate-800 rounded-lg p-4 border border-slate-700">
              <h3 className="font-medium text-white mb-2">Photography Tips</h3>
              <ul className="text-slate-300 text-sm space-y-1">
                <li>• Use natural lighting when possible</li>
                <li>• Fill the frame with your specimen</li>
                <li>• Keep the camera steady</li>
                <li>• Include a scale reference if available</li>
              </ul>
            </div>
          </div>
        )}

        {stream && !capturedImage && (
          <div className="space-y-4">
            <div className="relative bg-black rounded-lg overflow-hidden">
              <video ref={videoRef} autoPlay playsInline muted className="w-full h-auto" />
              <div className="absolute inset-0 border-2 border-cyan-400 rounded-lg pointer-events-none">
                <div className="absolute top-4 left-4 w-6 h-6 border-l-2 border-t-2 border-cyan-400"></div>
                <div className="absolute top-4 right-4 w-6 h-6 border-r-2 border-t-2 border-cyan-400"></div>
                <div className="absolute bottom-4 left-4 w-6 h-6 border-l-2 border-b-2 border-cyan-400"></div>
                <div className="absolute bottom-4 right-4 w-6 h-6 border-r-2 border-b-2 border-cyan-400"></div>
              </div>
            </div>

            <div className="flex gap-3">
              <Button
                onClick={stopCamera}
                variant="outline"
                className="flex-1 bg-slate-800 border-slate-600 text-white hover:bg-slate-700"
              >
                Cancel
              </Button>
              <Button onClick={capturePhoto} className="flex-1 bg-cyan-800 hover:bg-cyan-700">
                <Camera className="h-4 w-4 mr-2" />
                Capture
              </Button>
            </div>
          </div>
        )}

        {capturedImage && (
          <div className="space-y-4">
            <div className="relative bg-black rounded-lg overflow-hidden">
              <img src={capturedImage || "/placeholder.svg"} alt="Captured specimen" className="w-full h-auto" />
            </div>

            <div className="flex gap-3">
              <Button
                onClick={retakePhoto}
                variant="outline"
                className="flex-1 bg-slate-800 border-slate-600 text-white hover:bg-slate-700"
              >
                <RotateCcw className="h-4 w-4 mr-2" />
                Retake
              </Button>
              <Link href="/analysis" className="flex-1">
                <Button onClick={confirmPhoto} className="w-full bg-green-600 hover:bg-green-700">
                  <Check className="h-4 w-4 mr-2" />
                  Analyze
                </Button>
              </Link>
            </div>

            <div className="bg-slate-800 rounded-lg p-4 border border-slate-700">
              <p className="text-slate-300 text-sm text-center">
                Photo captured successfully! Tap "Analyze" to identify your specimen using AI.
              </p>
            </div>
          </div>
        )}

        <canvas ref={canvasRef} className="hidden" />
      </main>
    </div>
  )
}
