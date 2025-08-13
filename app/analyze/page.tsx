"use client"

import type React from "react"

import { useState, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Camera, Upload, ArrowLeft, Loader2, MapPin, Calendar, Info } from "lucide-react"
import Link from "next/link"
import Image from "next/image"

interface AnalysisResult {
  type: "geological" | "cultural"
  name: string
  confidence: number
  description: string
  characteristics: string[]
  formation?: string
  age?: string
  cultural_significance?: string
  location_context?: string
}

export default function AnalyzePage() {
  const [selectedImage, setSelectedImage] = useState<string | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [analysisResults, setAnalysisResults] = useState<AnalysisResult[]>([])
  const [analysisProgress, setAnalysisProgress] = useState(0)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        setSelectedImage(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const analyzeSpecimen = async () => {
    if (!selectedImage) return

    setIsAnalyzing(true)
    setAnalysisProgress(0)
    setAnalysisResults([])

    try {
      // Simulate progress updates
      const progressInterval = setInterval(() => {
        setAnalysisProgress((prev) => Math.min(prev + 10, 90))
      }, 200)

      const response = await fetch("/api/analyze", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          image: selectedImage,
          models: ["groq-vision", "geological-expert", "cultural-expert"],
        }),
      })

      clearInterval(progressInterval)
      setAnalysisProgress(100)

      if (response.ok) {
        const results = await response.json()
        setAnalysisResults(results.analyses)
      } else {
        console.error("Analysis failed")
      }
    } catch (error) {
      console.error("Error during analysis:", error)
    } finally {
      setIsAnalyzing(false)
    }
  }

  const getConfidenceColor = (confidence: number) => {
    if (confidence >= 80) return "bg-green-500"
    if (confidence >= 60) return "bg-yellow-500"
    return "bg-red-500"
  }

  const getConfidenceLabel = (confidence: number) => {
    if (confidence >= 80) return "High Confidence"
    if (confidence >= 60) return "Medium Confidence"
    return "Low Confidence"
  }

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
            <h1 className="text-2xl font-bold text-slate-800">AI Analysis</h1>
            <p className="text-slate-600">Multi-model specimen identification</p>
          </div>
        </div>

        {/* Image Upload/Capture */}
        {!selectedImage && (
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Camera className="w-5 h-5" />
                Select Specimen Image
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Link href="/camera">
                  <Button className="w-full h-24 bg-cyan-600 hover:bg-cyan-700">
                    <Camera className="w-6 h-6 mr-2" />
                    Take Photo
                  </Button>
                </Link>
                <Button
                  variant="outline"
                  className="w-full h-24 bg-transparent"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <Upload className="w-6 h-6 mr-2" />
                  Upload Image
                </Button>
              </div>
              <input ref={fileInputRef} type="file" accept="image/*" onChange={handleImageUpload} className="hidden" />
            </CardContent>
          </Card>
        )}

        {/* Selected Image & Analysis */}
        {selectedImage && (
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Specimen Image</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="relative aspect-video bg-slate-100 rounded-lg overflow-hidden mb-4">
                  <Image
                    src={selectedImage || "/placeholder.svg"}
                    alt="Specimen to analyze"
                    fill
                    className="object-contain"
                  />
                </div>
                <div className="flex gap-2">
                  <Button onClick={analyzeSpecimen} disabled={isAnalyzing} className="bg-cyan-600 hover:bg-cyan-700">
                    {isAnalyzing ? (
                      <>
                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                        Analyzing...
                      </>
                    ) : (
                      "Start Analysis"
                    )}
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => {
                      setSelectedImage(null)
                      setAnalysisResults([])
                      setAnalysisProgress(0)
                    }}
                  >
                    Select Different Image
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Analysis Progress */}
            {isAnalyzing && (
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span>Running multi-model analysis...</span>
                      <span>{analysisProgress}%</span>
                    </div>
                    <Progress value={analysisProgress} className="w-full" />
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Analysis Results */}
            {analysisResults.length > 0 && (
              <div className="space-y-4">
                <h2 className="text-xl font-semibold text-slate-800">Analysis Results</h2>
                {analysisResults.map((result, index) => (
                  <Card key={index} className="border-l-4 border-l-cyan-500">
                    <CardHeader>
                      <div className="flex items-start justify-between">
                        <div>
                          <CardTitle className="text-lg">{result.name}</CardTitle>
                          <Badge variant={result.type === "geological" ? "default" : "secondary"}>
                            {result.type === "geological" ? "Geological" : "Cultural Artifact"}
                          </Badge>
                        </div>
                        <div className="text-right">
                          <div
                            className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium text-white ${getConfidenceColor(result.confidence)}`}
                          >
                            {result.confidence}%
                          </div>
                          <p className="text-xs text-slate-500 mt-1">{getConfidenceLabel(result.confidence)}</p>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <p className="text-slate-700">{result.description}</p>

                      <div>
                        <h4 className="font-medium text-slate-800 mb-2">Key Characteristics:</h4>
                        <div className="flex flex-wrap gap-2">
                          {result.characteristics.map((char, i) => (
                            <Badge key={i} variant="outline">
                              {char}
                            </Badge>
                          ))}
                        </div>
                      </div>

                      {result.formation && (
                        <div className="flex items-center gap-2 text-sm text-slate-600">
                          <Info className="w-4 h-4" />
                          <span>
                            <strong>Formation:</strong> {result.formation}
                          </span>
                        </div>
                      )}

                      {result.age && (
                        <div className="flex items-center gap-2 text-sm text-slate-600">
                          <Calendar className="w-4 h-4" />
                          <span>
                            <strong>Age:</strong> {result.age}
                          </span>
                        </div>
                      )}

                      {result.cultural_significance && (
                        <div className="flex items-center gap-2 text-sm text-slate-600">
                          <Info className="w-4 h-4" />
                          <span>
                            <strong>Cultural Significance:</strong> {result.cultural_significance}
                          </span>
                        </div>
                      )}

                      {result.location_context && (
                        <div className="flex items-center gap-2 text-sm text-slate-600">
                          <MapPin className="w-4 h-4" />
                          <span>
                            <strong>Location Context:</strong> {result.location_context}
                          </span>
                        </div>
                      )}
                    </CardContent>
                  </Card>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
