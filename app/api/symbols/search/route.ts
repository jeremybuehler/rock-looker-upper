import { type NextRequest, NextResponse } from "next/server"
import { createGroq } from "@ai-sdk/groq"
import { generateObject } from "ai"
import { z } from "zod"

const groq = createGroq({
  apiKey: process.env.GROQ_API_KEY!,
})

const SymbolSearchSchema = z.object({
  matches: z.array(
    z.object({
      name: z.string(),
      category: z.enum(["geological", "cultural", "marine_life", "modern"]),
      description: z.string(),
      significance: z.string(),
      commonLocations: z.array(z.string()),
      identificationTips: z.array(z.string()),
      tags: z.array(z.string()),
      confidence: z.number().min(0).max(100),
      additionalContext: z.string().optional(),
    }),
  ),
})

export async function POST(request: NextRequest) {
  try {
    const { query, provider, model } = await request.json()

    if (!query || provider === "default") {
      return NextResponse.json({ matches: [] })
    }

    const { object } = await generateObject({
      model: groq(model || "llama-3.2-90b-text-preview"),
      messages: [
        {
          role: "user",
          content: `You are an expert marine archaeologist and geologist. Search for symbols, patterns, markings, or specimens related to: "${query}"

Focus on items commonly found in marine environments including:
- Geological specimens (fossils, minerals, rock formations, sedimentary structures)
- Cultural artifacts (pottery, tools, anchors, coins, inscriptions, petroglyphs)
- Marine life indicators (coral patterns, shell markings, growth rings)
- Modern maritime items (ballast stones, ship components, navigation tools)

For each relevant match, provide:
- Specific name and category
- Detailed description and significance
- Common locations where found
- Key identification tips
- Relevant tags for searching
- Confidence score (0-100) for the match relevance
- Additional context if helpful

Return 3-5 most relevant matches ranked by confidence.`,
        },
      ],
      schema: SymbolSearchSchema,
      temperature: 0.3,
    })

    return NextResponse.json(object)
  } catch (error) {
    console.error("Symbol search error:", error)
    return NextResponse.json({ matches: [] }, { status: 500 })
  }
}
