import { describe, test, expect } from "vitest";
import { Stagehand } from "@browserbasehq/stagehand";
import { z } from "zod";

describe("Privacy Page Requirements", () => {
  test("should contain privacy policy content", async () => {
    const stagehand = new Stagehand({
      env: "LOCAL",
    });
    await stagehand.init();
    const page = stagehand.page;

    await page.goto("http://localhost:3000/privacy");

    const analysis = await page.extract({
      instruction: "Extract the main heading and verify if it mentions 'Privacy Policy'.",
      schema: z.object({
        heading: z.string(),
        isPrivacyPolicy: z.boolean(),
      }),
    });

    expect(analysis.isPrivacyPolicy).toBe(true);
    await stagehand.close();
  });
});
