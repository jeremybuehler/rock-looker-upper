import { type NextRequest, NextResponse } from "next/server"
import { createGroq } from "@ai-sdk/groq"
import { generateObject } from "ai"
import { z } from "zod"

const groq = createGroq({
  apiKey: process.env.GROQ_API_KEY!,
})

const AnalysisResultSchema = z.object({
  analyses: z.array(
    z.object({
      type: z.enum(["geological", "cultural"]),
      name: z.string(),
      confidence: z.number().min(0).max(100),
      description: z.string(),
      characteristics: z.array(z.string()),
      formation: z.string().optional(),
      age: z.string().optional(),
      cultural_significance: z.string().optional(),
      location_context: z.string().optional(),
    }),
  ),
})

export async function POST(request: NextRequest) {
  try {
    const { image, models } = await request.json()

    if (!image) {
      return NextResponse.json({ error: "No image provided" }, { status: 400 })
    }

    // Convert base64 image to proper format for AI analysis
    const base64Data = image.replace(/^data:image\/[a-z]+;base64,/, "")

    const { object } = await generateObject({
      model: groq("llama-3.2-90b-vision-preview"),
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: `You are an expert marine geologist and archaeologist. Analyze this specimen image and provide detailed identification results. Consider both geological specimens (rocks, minerals, fossils) and cultural artifacts that might be found in marine environments.

For each potential identification, provide:
- Type (geological or cultural)
- Specific name/classification
- Confidence score (0-100)
- Detailed description
- Key identifying characteristics
- Additional context (formation, age, cultural significance, location context as appropriate)

Focus on specimens commonly found in marine environments including:
- Sedimentary rocks (limestone, sandstone, shale)
- Igneous rocks (basalt, obsidian, pumice)
- Metamorphic rocks (slate, marble, quartzite)
- Minerals and crystals
- Marine fossils
- Cultural artifacts (pottery, tools, coins, anchors)
- Modern debris that might be mistaken for artifacts

Provide 1-3 most likely identifications ranked by confidence.`,
            },
            {
              type: "image",
              image: `data:image/jpeg;base64,${base64Data}`,
            },
          ],
        },
      ],
      schema: AnalysisResultSchema,
      temperature: 0.3,
    })

    return NextResponse.json(object)
  } catch (error) {
    console.error("Analysis error:", error)
    return NextResponse.json({ error: "Analysis failed" }, { status: 500 })
  }
}
