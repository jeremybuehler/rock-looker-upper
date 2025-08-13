"use client"

import { useState, useRef, useCallback } from "react"
import { Camera, RotateCcw, Check } from "lucide-react"
import { Button } from "@/components/ui/button"

interface CameraCaptureProps {
  onCapture: (imageData: string) => void
  onCancel: () => void
}

export function CameraCapture({ onCapture, onCancel }: CameraCaptureProps) {
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
          facingMode: "environment",
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

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    context.drawImage(video, 0, 0, canvas.width, canvas.height)

    const imageDataUrl = canvas.toDataURL("image/jpeg", 0.8)
    setCapturedImage(imageDataUrl)
    stopCamera()
  }, [stopCamera])

  const retakePhoto = useCallback(() => {
    setCapturedImage(null)
    startCamera()
  }, [startCamera])

  const confirmPhoto = useCallback(() => {
    if (capturedImage) {
      onCapture(capturedImage)
    }
  }, [capturedImage, onCapture])

  return (
    <div className="space-y-4">
      {!stream && !capturedImage && (
        <div className="text-center space-y-4">
          <Button onClick={startCamera} disabled={isLoading} className="bg-cyan-800 hover:bg-cyan-700">
            {isLoading ? "Starting Camera..." : "Start Camera"}
          </Button>
          {error && <p className="text-red-500 text-sm">{error}</p>}
        </div>
      )}

      {stream && !capturedImage && (
        <div className="space-y-4">
          <div className="relative bg-black rounded-lg overflow-hidden">
            <video ref={videoRef} autoPlay playsInline muted className="w-full h-auto" />
          </div>
          <div className="flex gap-3">
            <Button onClick={onCancel} variant="outline" className="flex-1 bg-transparent">
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
          <img src={capturedImage || "/placeholder.svg"} alt="Captured specimen" className="w-full rounded-lg" />
          <div className="flex gap-3">
            <Button onClick={retakePhoto} variant="outline" className="flex-1 bg-transparent">
              <RotateCcw className="h-4 w-4 mr-2" />
              Retake
            </Button>
            <Button onClick={confirmPhoto} className="flex-1 bg-green-600 hover:bg-green-700">
              <Check className="h-4 w-4 mr-2" />
              Confirm
            </Button>
          </div>
        </div>
      )}

      <canvas ref={canvasRef} className="hidden" />
    </div>
  )
}
