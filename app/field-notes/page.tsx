"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { ArrowLeft, MapPin, Plus, Calendar, Navigation, Loader2 } from "lucide-react"
import Link from "next/link"

interface FieldNote {
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
}

interface LocationState {
  loading: boolean
  error: string | null
  coordinates: GeolocationCoordinates | null
}

export default function FieldNotesPage() {
  const [notes, setNotes] = useState<FieldNote[]>([])
  const [showForm, setShowForm] = useState(false)
  const [location, setLocation] = useState<LocationState>({
    loading: false,
    error: null,
    coordinates: null,
  })

  // Form state
  const [title, setTitle] = useState("")
  const [description, setDescription] = useState("")
  const [weather, setWeather] = useState("")
  const [depth, setDepth] = useState("")
  const [substrate, setSubstrate] = useState("")
  const [tags, setTags] = useState("")

  // Load saved notes on component mount
  useEffect(() => {
    const savedNotes = localStorage.getItem("marine-field-notes")
    if (savedNotes) {
      setNotes(JSON.parse(savedNotes))
    }
  }, [])

  const getCurrentLocation = () => {
    setLocation({ loading: true, error: null, coordinates: null })

    if (!navigator.geolocation) {
      setLocation({
        loading: false,
        error: "Geolocation is not supported by this browser",
        coordinates: null,
      })
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setLocation({
          loading: false,
          error: null,
          coordinates: position.coords,
        })
      },
      (error) => {
        setLocation({
          loading: false,
          error: error.message,
          coordinates: null,
        })
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 60000,
      },
    )
  }

  const saveNote = () => {
    if (!title.trim() || !description.trim() || !location.coordinates) {
      return
    }

    const newNote: FieldNote = {
      id: Date.now().toString(),
      title: title.trim(),
      description: description.trim(),
      location: {
        latitude: location.coordinates.latitude,
        longitude: location.coordinates.longitude,
        accuracy: location.coordinates.accuracy || 0,
      },
      timestamp: new Date().toISOString(),
      weather: weather.trim() || undefined,
      depth: depth.trim() || undefined,
      substrate: substrate.trim() || undefined,
      tags: tags
        .split(",")
        .map((tag) => tag.trim())
        .filter((tag) => tag.length > 0),
    }

    const updatedNotes = [newNote, ...notes]
    setNotes(updatedNotes)
    localStorage.setItem("marine-field-notes", JSON.stringify(updatedNotes))

    // Reset form
    setTitle("")
    setDescription("")
    setWeather("")
    setDepth("")
    setSubstrate("")
    setTags("")
    setLocation({ loading: false, error: null, coordinates: null })
    setShowForm(false)
  }

  const formatCoordinates = (lat: number, lng: number) => {
    return `${lat.toFixed(6)}°, ${lng.toFixed(6)}°`
  }

  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp)
    return date.toLocaleDateString() + " " + date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
  }

  const getAccuracyColor = (accuracy: number) => {
    if (accuracy <= 10) return "text-green-600"
    if (accuracy <= 50) return "text-yellow-600"
    return "text-red-600"
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
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-slate-800">GPS Field Notes</h1>
            <p className="text-slate-600">Location-tagged observations and findings</p>
          </div>
          <Button onClick={() => setShowForm(true)} className="bg-green-600 hover:bg-green-700">
            <Plus className="w-4 h-4 mr-2" />
            Add Note
          </Button>
        </div>

        {/* Add Note Form */}
        {showForm && (
          <Card className="mb-6 border-green-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MapPin className="w-5 h-5 text-green-600" />
                New Field Note
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Location Section */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-700">Location</label>
                {!location.coordinates && !location.loading && (
                  <Button onClick={getCurrentLocation} variant="outline" className="w-full bg-transparent">
                    <Navigation className="w-4 h-4 mr-2" />
                    Get Current Location
                  </Button>
                )}
                {location.loading && (
                  <div className="flex items-center justify-center p-4 bg-slate-50 rounded-lg">
                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                    Getting location...
                  </div>
                )}
                {location.error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
                    <p className="text-red-600 text-sm">{location.error}</p>
                    <Button onClick={getCurrentLocation} variant="outline" size="sm" className="mt-2 bg-transparent">
                      Try Again
                    </Button>
                  </div>
                )}
                {location.coordinates && (
                  <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
                    <div className="flex items-center gap-2 mb-1">
                      <MapPin className="w-4 h-4 text-green-600" />
                      <span className="font-medium text-green-800">Location Acquired</span>
                    </div>
                    <p className="text-sm text-green-700">
                      {formatCoordinates(location.coordinates.latitude, location.coordinates.longitude)}
                    </p>
                    <p className={`text-xs ${getAccuracyColor(location.coordinates.accuracy || 0)}`}>
                      Accuracy: ±{Math.round(location.coordinates.accuracy || 0)}m
                    </p>
                  </div>
                )}
              </div>

              {/* Basic Information */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Title *</label>
                  <Input
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="e.g., Limestone outcrop near reef"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Weather</label>
                  <Input
                    value={weather}
                    onChange={(e) => setWeather(e.target.value)}
                    placeholder="e.g., Sunny, calm seas"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-700">Description *</label>
                <Textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Detailed observations, specimen characteristics, environmental context..."
                  rows={4}
                />
              </div>

              {/* Environmental Details */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Depth</label>
                  <Input value={depth} onChange={(e) => setDepth(e.target.value)} placeholder="e.g., 15m, Intertidal" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Substrate</label>
                  <Input
                    value={substrate}
                    onChange={(e) => setSubstrate(e.target.value)}
                    placeholder="e.g., Sandy, Rocky, Coral"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-700">Tags</label>
                <Input
                  value={tags}
                  onChange={(e) => setTags(e.target.value)}
                  placeholder="e.g., fossil, sedimentary, artifact (comma-separated)"
                />
              </div>

              {/* Form Actions */}
              <div className="flex gap-2 pt-4">
                <Button
                  onClick={saveNote}
                  disabled={!title.trim() || !description.trim() || !location.coordinates}
                  className="bg-green-600 hover:bg-green-700"
                >
                  Save Note
                </Button>
                <Button variant="outline" onClick={() => setShowForm(false)}>
                  Cancel
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Notes List */}
        <div className="space-y-4">
          {notes.length === 0 ? (
            <Card>
              <CardContent className="p-8 text-center">
                <MapPin className="w-12 h-12 text-slate-300 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-slate-600 mb-2">No field notes yet</h3>
                <p className="text-slate-500 mb-4">
                  Start documenting your marine discoveries with GPS-tagged observations
                </p>
                <Button onClick={() => setShowForm(true)} className="bg-green-600 hover:bg-green-700">
                  <Plus className="w-4 h-4 mr-2" />
                  Add Your First Note
                </Button>
              </CardContent>
            </Card>
          ) : (
            notes.map((note) => (
              <Card key={note.id} className="hover:shadow-md transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div>
                      <CardTitle className="text-lg">{note.title}</CardTitle>
                      <div className="flex items-center gap-4 text-sm text-slate-500 mt-1">
                        <div className="flex items-center gap-1">
                          <Calendar className="w-3 h-3" />
                          {formatDate(note.timestamp)}
                        </div>
                        <div className="flex items-center gap-1">
                          <MapPin className="w-3 h-3" />
                          {formatCoordinates(note.location.latitude, note.location.longitude)}
                        </div>
                      </div>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-3">
                  <p className="text-slate-700">{note.description}</p>

                  {/* Environmental Details */}
                  {(note.weather || note.depth || note.substrate) && (
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-2 text-sm">
                      {note.weather && (
                        <div className="flex items-center gap-1 text-slate-600">
                          <span className="font-medium">Weather:</span> {note.weather}
                        </div>
                      )}
                      {note.depth && (
                        <div className="flex items-center gap-1 text-slate-600">
                          <span className="font-medium">Depth:</span> {note.depth}
                        </div>
                      )}
                      {note.substrate && (
                        <div className="flex items-center gap-1 text-slate-600">
                          <span className="font-medium">Substrate:</span> {note.substrate}
                        </div>
                      )}
                    </div>
                  )}

                  {/* Tags */}
                  {note.tags.length > 0 && (
                    <div className="flex flex-wrap gap-2">
                      {note.tags.map((tag, index) => (
                        <Badge key={index} variant="secondary">
                          {tag}
                        </Badge>
                      ))}
                    </div>
                  )}

                  {/* Location Accuracy */}
                  <div className="text-xs text-slate-500">GPS Accuracy: ±{Math.round(note.location.accuracy)}m</div>
                </CardContent>
              </Card>
            ))
          )}
        </div>
      </div>
    </div>
  )
}
