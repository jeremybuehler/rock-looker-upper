"use client"

import { useState, useEffect } from "react"
import { ArrowLeft, User, Settings, Brain, Database, Save, Check } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { Textarea } from "@/components/ui/textarea"
import { Separator } from "@/components/ui/separator"
import Link from "next/link"

interface UserProfile {
  name: string
  email: string
  organization: string
  experience: string
  preferredLLM: string
  llmApiKey: string
  enableOfflineMode: boolean
  autoSync: boolean
  gpsAccuracy: string
  cameraQuality: string
  analysisDepth: string
  customPrompt: string
}

export default function ProfilePage() {
  const [profile, setProfile] = useState<UserProfile>({
    name: "",
    email: "",
    organization: "",
    experience: "beginner",
    preferredLLM: "groq-llama3",
    llmApiKey: "",
    enableOfflineMode: true,
    autoSync: true,
    gpsAccuracy: "high",
    cameraQuality: "high",
    analysisDepth: "detailed",
    customPrompt: "",
  })

  const [saved, setSaved] = useState(false)
  const [loading, setLoading] = useState(false)

  // Load profile from localStorage on mount
  useEffect(() => {
    const savedProfile = localStorage.getItem("userProfile")
    if (savedProfile) {
      setProfile(JSON.parse(savedProfile))
    }
  }, [])

  const handleSave = async () => {
    setLoading(true)
    try {
      localStorage.setItem("userProfile", JSON.stringify(profile))
      setSaved(true)
      setTimeout(() => setSaved(false), 2000)
    } catch (error) {
      console.error("Failed to save profile:", error)
    } finally {
      setLoading(false)
    }
  }

  const updateProfile = (field: keyof UserProfile, value: any) => {
    setProfile((prev) => ({ ...prev, [field]: value }))
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-cyan-50 to-white">
      {/* Header */}
      <header className="bg-cyan-800 text-white p-4 shadow-lg">
        <div className="max-w-md mx-auto">
          <div className="flex items-center gap-3">
            <Link href="/">
              <Button variant="ghost" size="sm" className="text-white hover:bg-cyan-700 p-1">
                <ArrowLeft className="h-5 w-5" />
              </Button>
            </Link>
            <div className="flex items-center gap-2">
              <User className="h-6 w-6" />
              <h1 className="font-serif text-xl font-bold">User Profile</h1>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-md mx-auto p-4 space-y-6">
        {/* Personal Information */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <User className="h-5 w-5 text-cyan-600" />
              Personal Information
            </CardTitle>
            <CardDescription>Your basic profile information</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="name">Full Name</Label>
              <Input
                id="name"
                value={profile.name}
                onChange={(e) => updateProfile("name", e.target.value)}
                placeholder="Dr. Jane Smith"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={profile.email}
                onChange={(e) => updateProfile("email", e.target.value)}
                placeholder="jane.smith@university.edu"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="organization">Organization</Label>
              <Input
                id="organization"
                value={profile.organization}
                onChange={(e) => updateProfile("organization", e.target.value)}
                placeholder="Marine Research Institute"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="experience">Experience Level</Label>
              <Select value={profile.experience} onValueChange={(value) => updateProfile("experience", value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="beginner">Beginner</SelectItem>
                  <SelectItem value="intermediate">Intermediate</SelectItem>
                  <SelectItem value="advanced">Advanced</SelectItem>
                  <SelectItem value="expert">Expert/Professional</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* LLM Configuration */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Brain className="h-5 w-5 text-purple-600" />
              AI Model Configuration
            </CardTitle>
            <CardDescription>Configure your preferred AI models for analysis</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="preferredLLM">Primary LLM Model</Label>
              <Select value={profile.preferredLLM} onValueChange={(value) => updateProfile("preferredLLM", value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="groq-llama3">Groq - Llama 3 (Fast)</SelectItem>
                  <SelectItem value="groq-mixtral">Groq - Mixtral 8x7B (Balanced)</SelectItem>
                  <SelectItem value="groq-gemma">Groq - Gemma 7B (Efficient)</SelectItem>
                  <SelectItem value="openai-gpt4">OpenAI GPT-4 (Premium)</SelectItem>
                  <SelectItem value="anthropic-claude">Anthropic Claude (Detailed)</SelectItem>
                  <SelectItem value="google-gemini">Google Gemini Pro (Multimodal)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="analysisDepth">Analysis Depth</Label>
              <Select value={profile.analysisDepth} onValueChange={(value) => updateProfile("analysisDepth", value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="quick">Quick Identification</SelectItem>
                  <SelectItem value="standard">Standard Analysis</SelectItem>
                  <SelectItem value="detailed">Detailed Report</SelectItem>
                  <SelectItem value="comprehensive">Comprehensive Study</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="customPrompt">Custom Analysis Prompt</Label>
              <Textarea
                id="customPrompt"
                value={profile.customPrompt}
                onChange={(e) => updateProfile("customPrompt", e.target.value)}
                placeholder="Add specific instructions for AI analysis (e.g., focus on geological formation, cultural significance, etc.)"
                rows={3}
              />
            </div>

            <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
              <p className="text-amber-800 text-sm">
                <strong>Note:</strong> Some models may require additional API keys. Configure in your project settings.
              </p>
            </div>
          </CardContent>
        </Card>

        {/* App Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Settings className="h-5 w-5 text-slate-600" />
              App Settings
            </CardTitle>
            <CardDescription>Customize your app behavior and preferences</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label>Offline Mode</Label>
                <p className="text-sm text-slate-500">Enable offline data storage and sync</p>
              </div>
              <Switch
                checked={profile.enableOfflineMode}
                onCheckedChange={(checked) => updateProfile("enableOfflineMode", checked)}
              />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <div className="space-y-0.5">
                <Label>Auto Sync</Label>
                <p className="text-sm text-slate-500">Automatically sync when online</p>
              </div>
              <Switch checked={profile.autoSync} onCheckedChange={(checked) => updateProfile("autoSync", checked)} />
            </div>

            <Separator />

            <div className="space-y-2">
              <Label htmlFor="gpsAccuracy">GPS Accuracy</Label>
              <Select value={profile.gpsAccuracy} onValueChange={(value) => updateProfile("gpsAccuracy", value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="low">Low (Battery Saving)</SelectItem>
                  <SelectItem value="medium">Medium (Balanced)</SelectItem>
                  <SelectItem value="high">High (Most Accurate)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="cameraQuality">Camera Quality</Label>
              <Select value={profile.cameraQuality} onValueChange={(value) => updateProfile("cameraQuality", value)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="low">Low (Faster Processing)</SelectItem>
                  <SelectItem value="medium">Medium (Balanced)</SelectItem>
                  <SelectItem value="high">High (Best Quality)</SelectItem>
                  <SelectItem value="ultra">Ultra (Professional)</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Data Management */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Database className="h-5 w-5 text-green-600" />
              Data Management
            </CardTitle>
            <CardDescription>Manage your stored data and preferences</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <Button variant="outline" size="sm">
                Export Data
              </Button>
              <Button variant="outline" size="sm">
                Import Data
              </Button>
            </div>
            <Separator />
            <div className="space-y-2">
              <Button variant="destructive" size="sm" className="w-full">
                Clear All Data
              </Button>
              <p className="text-xs text-slate-500 text-center">
                This will permanently delete all your field notes, photos, and analysis results
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Save Button */}
        <div className="sticky bottom-4">
          <Button onClick={handleSave} disabled={loading} className="w-full bg-cyan-800 hover:bg-cyan-700">
            {loading ? (
              "Saving..."
            ) : saved ? (
              <>
                <Check className="h-4 w-4 mr-2" />
                Saved!
              </>
            ) : (
              <>
                <Save className="h-4 w-4 mr-2" />
                Save Profile
              </>
            )}
          </Button>
        </div>
      </main>
    </div>
  )
}
