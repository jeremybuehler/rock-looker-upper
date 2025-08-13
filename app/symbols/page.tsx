"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ArrowLeft, Search, Database, Settings, Loader2, Filter } from "lucide-react"
import Link from "next/link"
import Image from "next/image"

interface Symbol {
  id: string
  name: string
  category: "geological" | "cultural" | "marine_life" | "modern"
  description: string
  significance: string
  commonLocations: string[]
  identificationTips: string[]
  imageUrl: string
  tags: string[]
}

interface SearchConfig {
  provider: "groq" | "default"
  model: string
  enabled: boolean
}

const SYMBOL_DATABASE: Symbol[] = [
  {
    id: "1",
    name: "Trilobite Fossil",
    category: "geological",
    description: "Segmented marine arthropod fossils from the Paleozoic Era",
    significance: "Important index fossils for dating rock formations",
    commonLocations: ["Limestone", "Shale", "Sandstone"],
    identificationTips: ["Segmented body", "Compound eyes", "Three-lobed structure"],
    imageUrl: "/placeholder-r6tst.png",
    tags: ["fossil", "paleozoic", "arthropod", "index fossil"],
  },
  {
    id: "2",
    name: "Anchor Stone",
    category: "cultural",
    description: "Stone anchors used by ancient maritime civilizations",
    significance: "Evidence of ancient seafaring and trade routes",
    commonLocations: ["Coastal areas", "Harbor sites", "Shipwreck sites"],
    identificationTips: ["Hole through center", "Weathered stone", "Rounded edges"],
    imageUrl: "/ancient-stone-anchor.png",
    tags: ["anchor", "maritime", "ancient", "navigation"],
  },
  {
    id: "3",
    name: "Ammonite Spiral",
    category: "geological",
    description: "Spiral-shelled cephalopod fossils with distinctive suture patterns",
    significance: "Excellent index fossils for Mesozoic marine environments",
    commonLocations: ["Marine limestone", "Chalk", "Mudstone"],
    identificationTips: ["Spiral shell", "Suture patterns", "Chambered structure"],
    imageUrl: "/placeholder-6qobh.png",
    tags: ["fossil", "mesozoic", "cephalopod", "spiral"],
  },
  {
    id: "4",
    name: "Pottery Sherds",
    category: "cultural",
    description: "Fragments of ceramic vessels from various historical periods",
    significance: "Cultural markers indicating human habitation and trade",
    commonLocations: ["Coastal settlements", "River mouths", "Harbor areas"],
    identificationTips: ["Fired clay", "Decorative patterns", "Rim fragments"],
    imageUrl: "/ancient-pottery-sherds.png",
    tags: ["pottery", "ceramic", "cultural", "settlement"],
  },
  {
    id: "5",
    name: "Coral Growth Patterns",
    category: "marine_life",
    description: "Distinctive growth rings and structures in coral specimens",
    significance: "Environmental indicators and age determination",
    commonLocations: ["Reef environments", "Shallow marine", "Tropical waters"],
    identificationTips: ["Concentric rings", "Branching patterns", "Calcium carbonate"],
    imageUrl: "/coral-growth-rings.png",
    tags: ["coral", "growth rings", "marine biology", "environmental"],
  },
  {
    id: "6",
    name: "Ship Ballast Stones",
    category: "modern",
    description: "Stones used as ballast in historical sailing vessels",
    significance: "Evidence of maritime trade routes and ship construction",
    commonLocations: ["Harbor areas", "Shipwreck sites", "Coastal zones"],
    identificationTips: ["Foreign rock types", "Rounded from handling", "Dense materials"],
    imageUrl: "/ship-ballast-stones-maritime-historical.png",
    tags: ["ballast", "maritime", "trade", "historical"],
  },
]

export default function SymbolsPage() {
  const [symbols, setSymbols] = useState<Symbol[]>(SYMBOL_DATABASE)
  const [filteredSymbols, setFilteredSymbols] = useState<Symbol[]>(SYMBOL_DATABASE)
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState<string>("all")
  const [isSearching, setIsSearching] = useState(false)
  const [showConfig, setShowConfig] = useState(false)
  const [searchConfig, setSearchConfig] = useState<SearchConfig>({
    provider: "default",
    model: "groq-llama-3.2-90b",
    enabled: false,
  })

  // Load search configuration from localStorage
  useEffect(() => {
    const savedConfig = localStorage.getItem("symbol-search-config")
    if (savedConfig) {
      setSearchConfig(JSON.parse(savedConfig))
    }
  }, [])

  // Filter symbols based on search and category
  useEffect(() => {
    let filtered = symbols

    if (selectedCategory !== "all") {
      filtered = filtered.filter((symbol) => symbol.category === selectedCategory)
    }

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (symbol) =>
          symbol.name.toLowerCase().includes(query) ||
          symbol.description.toLowerCase().includes(query) ||
          symbol.tags.some((tag) => tag.toLowerCase().includes(query)) ||
          symbol.significance.toLowerCase().includes(query),
      )
    }

    setFilteredSymbols(filtered)
  }, [symbols, searchQuery, selectedCategory])

  const performAISearch = async (query: string) => {
    if (!searchConfig.enabled || !query.trim()) return

    setIsSearching(true)
    try {
      const response = await fetch("/api/symbols/search", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query,
          provider: searchConfig.provider,
          model: searchConfig.model,
        }),
      })

      if (response.ok) {
        const results = await response.json()
        // Merge AI results with existing database
        const enhancedSymbols = symbols.map((symbol) => {
          const aiMatch = results.matches?.find((match: any) => match.name.toLowerCase() === symbol.name.toLowerCase())
          return aiMatch ? { ...symbol, ...aiMatch } : symbol
        })
        setSymbols(enhancedSymbols)
      }
    } catch (error) {
      console.error("AI search error:", error)
    } finally {
      setIsSearching(false)
    }
  }

  const saveSearchConfig = (config: SearchConfig) => {
    setSearchConfig(config)
    localStorage.setItem("symbol-search-config", JSON.stringify(config))
  }

  const getCategoryColor = (category: string) => {
    switch (category) {
      case "geological":
        return "bg-blue-100 text-blue-800"
      case "cultural":
        return "bg-purple-100 text-purple-800"
      case "marine_life":
        return "bg-green-100 text-green-800"
      case "modern":
        return "bg-orange-100 text-orange-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getCategoryLabel = (category: string) => {
    switch (category) {
      case "geological":
        return "Geological"
      case "cultural":
        return "Cultural"
      case "marine_life":
        return "Marine Life"
      case "modern":
        return "Modern"
      default:
        return category
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-cyan-50 p-4">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex items-center gap-4 mb-6">
          <Link href="/">
            <Button variant="ghost" size="sm">
              <ArrowLeft className="w-4 h-4 mr-2" />
              Back
            </Button>
          </Link>
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-slate-800">Symbol Database</h1>
            <p className="text-slate-600">Search geological and cultural symbols with AI assistance</p>
          </div>
          <Button variant="outline" size="sm" onClick={() => setShowConfig(!showConfig)}>
            <Settings className="w-4 h-4 mr-2" />
            Configure
          </Button>
        </div>

        {/* Configuration Panel */}
        {showConfig && (
          <Card className="mb-6 border-amber-200">
            <CardHeader>
              <CardTitle className="text-lg">Search Configuration</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium">AI Search</label>
                  <Select
                    value={searchConfig.enabled ? "enabled" : "disabled"}
                    onValueChange={(value) => saveSearchConfig({ ...searchConfig, enabled: value === "enabled" })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="disabled">Default Search Only</SelectItem>
                      <SelectItem value="enabled">AI-Enhanced Search</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Provider</label>
                  <Select
                    value={searchConfig.provider}
                    onValueChange={(value: "groq" | "default") =>
                      saveSearchConfig({ ...searchConfig, provider: value })
                    }
                    disabled={!searchConfig.enabled}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="default">Default Database</SelectItem>
                      <SelectItem value="groq">Groq LLM</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Model</label>
                  <Select
                    value={searchConfig.model}
                    onValueChange={(value) => saveSearchConfig({ ...searchConfig, model: value })}
                    disabled={!searchConfig.enabled || searchConfig.provider === "default"}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="groq-llama-3.2-90b">Llama 3.2 90B</SelectItem>
                      <SelectItem value="groq-llama-3.1-70b">Llama 3.1 70B</SelectItem>
                      <SelectItem value="groq-mixtral-8x7b">Mixtral 8x7B</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              {searchConfig.enabled && (
                <div className="p-3 bg-amber-50 border border-amber-200 rounded-lg">
                  <p className="text-amber-800 text-sm">
                    AI-enhanced search will provide additional context and identification assistance using{" "}
                    {searchConfig.provider} with {searchConfig.model}.
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {/* Search and Filters */}
        <Card className="mb-6">
          <CardContent className="p-4">
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex-1 relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
                <Input
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search symbols, descriptions, or tags..."
                  className="pl-10"
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && searchConfig.enabled) {
                      performAISearch(searchQuery)
                    }
                  }}
                />
              </div>
              <div className="flex gap-2">
                <Select value={selectedCategory} onValueChange={setSelectedCategory}>
                  <SelectTrigger className="w-40">
                    <Filter className="w-4 h-4 mr-2" />
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Categories</SelectItem>
                    <SelectItem value="geological">Geological</SelectItem>
                    <SelectItem value="cultural">Cultural</SelectItem>
                    <SelectItem value="marine_life">Marine Life</SelectItem>
                    <SelectItem value="modern">Modern</SelectItem>
                  </SelectContent>
                </Select>
                {searchConfig.enabled && (
                  <Button
                    onClick={() => performAISearch(searchQuery)}
                    disabled={isSearching || !searchQuery.trim()}
                    className="bg-amber-600 hover:bg-amber-700"
                  >
                    {isSearching ? <Loader2 className="w-4 h-4 animate-spin" /> : <Database className="w-4 h-4" />}
                  </Button>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Results Count */}
        <div className="mb-4">
          <p className="text-slate-600 text-sm">
            Showing {filteredSymbols.length} of {symbols.length} symbols
            {selectedCategory !== "all" && ` in ${getCategoryLabel(selectedCategory)}`}
          </p>
        </div>

        {/* Symbols Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredSymbols.map((symbol) => (
            <Card key={symbol.id} className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div>
                    <CardTitle className="text-lg">{symbol.name}</CardTitle>
                    <Badge className={`mt-2 ${getCategoryColor(symbol.category)}`}>
                      {getCategoryLabel(symbol.category)}
                    </Badge>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="aspect-square bg-slate-100 rounded-lg overflow-hidden">
                  <Image
                    src={symbol.imageUrl || "/placeholder.svg"}
                    alt={symbol.name}
                    width={200}
                    height={200}
                    className="w-full h-full object-cover"
                  />
                </div>

                <p className="text-slate-700 text-sm">{symbol.description}</p>

                <div>
                  <h4 className="font-medium text-slate-800 mb-2 text-sm">Significance:</h4>
                  <p className="text-slate-600 text-sm">{symbol.significance}</p>
                </div>

                <div>
                  <h4 className="font-medium text-slate-800 mb-2 text-sm">Common Locations:</h4>
                  <div className="flex flex-wrap gap-1">
                    {symbol.commonLocations.map((location, index) => (
                      <Badge key={index} variant="outline" className="text-xs">
                        {location}
                      </Badge>
                    ))}
                  </div>
                </div>

                <div>
                  <h4 className="font-medium text-slate-800 mb-2 text-sm">Identification Tips:</h4>
                  <ul className="text-slate-600 text-xs space-y-1">
                    {symbol.identificationTips.map((tip, index) => (
                      <li key={index} className="flex items-start gap-1">
                        <span className="text-slate-400 mt-1">•</span>
                        {tip}
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="flex flex-wrap gap-1">
                  {symbol.tags.map((tag, index) => (
                    <Badge key={index} variant="secondary" className="text-xs">
                      {tag}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {filteredSymbols.length === 0 && (
          <Card>
            <CardContent className="p-8 text-center">
              <Database className="w-12 h-12 text-slate-300 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-slate-600 mb-2">No symbols found</h3>
              <p className="text-slate-500">Try adjusting your search terms or category filter</p>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}
