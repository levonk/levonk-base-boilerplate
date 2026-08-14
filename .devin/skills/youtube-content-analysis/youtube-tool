#!/usr/bin/env -S devbox run -- npx tsx

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { YoutubeTranscript } from "youtube-transcript";
import { z } from "zod";

/**
 * YouTube Content Analysis Skill
 * Ported from jkawamoto/mcp-youtube-transcript
 */

const server = new Server(
  {
    name: "youtube-content-analysis",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// --- Schemas ---

const GetTranscriptSchema = z.object({
  url: z.string().describe("The URL of the YouTube video"),
  lang: z.string().optional().describe("The preferred language for the transcript (default: en)"),
  next_cursor: z.string().optional().describe("Cursor to retrieve the next page of the transcript"),
});

const GetTimedTranscriptSchema = z.object({
  url: z.string().describe("The URL of the YouTube video"),
  lang: z.string().optional().describe("The preferred language for the transcript (default: en)"),
  next_cursor: z.string().optional().describe("Cursor to retrieve the next page of the transcript"),
});

const GetVideoInfoSchema = z.object({
  url: z.string().describe("The URL of the YouTube video"),
});

// --- Utilities ---

function parseVideoId(url: string): string {
  try {
    const urlObj = new URL(url);
    if (urlObj.hostname === "youtu.be") {
      return urlObj.pathname.slice(1);
    }
    const v = urlObj.searchParams.get("v");
    if (!v) {
      // Try to handle mobile URLs or other formats
      const match = url.match(/(?:v=|\/embed\/|\/1.1\/|\/v\/|(?:\?|&)v=|youtu\.be\/|(?:\?|&)vi=)([^&?#\/\s]+)/);
      if (match && match[1]) return match[1];
      throw new Error(`Could not find video ID in URL: ${url}`);
    }
    return v;
  } catch (e) {
    // Last ditch effort for raw IDs
    if (/^[a-zA-Z0-9_-]{11}$/.test(url)) return url;
    throw new Error(`Invalid URL or Video ID: ${url}`);
  }
}

// Simple pagination logic mimicking the Python implementation's response_limit behavior
// although Windsurf/Claude Desktop don't usually pass response_limit, we add it for completeness.
const DEFAULT_RESPONSE_LIMIT = 5000; // characters

// --- Handlers ---

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "get_transcript",
        description: "Retrieves the full text transcript of a YouTube video.",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string", description: "The URL of the YouTube video" },
            lang: { type: "string", description: "The preferred language (e.g., 'en', 'es')" },
            next_cursor: { type: "string", description: "Cursor for pagination" },
          },
          required: ["url"],
        },
      },
      {
        name: "get_timed_transcript",
        description: "Retrieves the transcript of a YouTube video with timestamps.",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string", description: "The URL of the YouTube video" },
            lang: { type: "string", description: "The preferred language" },
            next_cursor: { type: "string", description: "Cursor for pagination" },
          },
          required: ["url"],
        },
      },
      {
        name: "get_video_info",
        description: "Retrieves video metadata (Title, ID, URL).",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string", description: "The URL of the YouTube video" },
          },
          required: ["url"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "get_transcript": {
        const { url, lang, next_cursor } = GetTranscriptSchema.parse(args);
        const videoId = parseVideoId(url);
        const transcript = await YoutubeTranscript.fetchTranscript(videoId, { lang });

        let resultText = "";
        let cursor: string | undefined = undefined;
        const startIndex = next_cursor ? parseInt(next_cursor, 10) : 0;

        for (let i = startIndex; i < transcript.length; i++) {
          const line = transcript[i].text;
          if (resultText.length + line.length + 1 > DEFAULT_RESPONSE_LIMIT) {
            cursor = i.toString();
            break;
          }
          resultText += (resultText ? " " : "") + line;
        }

        return {
          content: [
            {
              type: "text",
              text: `Transcript (Video: ${videoId}):\n\n${resultText}${cursor ? `\n\n[More available, use cursor: ${cursor}]` : ""}`
            }
          ],
        };
      }

      case "get_timed_transcript": {
        const { url, lang, next_cursor } = GetTimedTranscriptSchema.parse(args);
        const videoId = parseVideoId(url);
        const transcript = await YoutubeTranscript.fetchTranscript(videoId, { lang });

        const startIndex = next_cursor ? parseInt(next_cursor, 10) : 0;
        const sliced = transcript.slice(startIndex);

        // We return a reasonable chunk to stay within context limits
        const maxSnippets = 50;
        const chunk = sliced.slice(0, maxSnippets);
        const cursor = (startIndex + chunk.length < transcript.length)
          ? (startIndex + chunk.length).toString()
          : undefined;

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                videoId,
                snippets: chunk,
                next_cursor: cursor
              }, null, 2),
            },
          ],
        };
      }

      case "get_video_info": {
        const { url } = GetVideoInfoSchema.parse(args);
        const videoId = parseVideoId(url);
        // Note: For full metadata (uploader, date, duration), yt-dlp is required.
        // This TS implementation provides basic info available from the URL and ID.
        return {
          content: [
            {
              type: "text",
              text: `Video ID: ${videoId}\nURL: ${url}\n\nNote: Detailed metadata (uploader, upload date, etc.) requires an external tool like yt-dlp.`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error: any) {
    return {
      content: [{ type: "text", text: `Error: ${error.message}` }],
      isError: true,
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});
