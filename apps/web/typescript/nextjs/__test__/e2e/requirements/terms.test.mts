import { describe, test, expect } from "vitest";
import { Stagehand } from "@browserbasehq/stagehand";
import { z } from "zod";

describe("Terms Page Requirements", () => {
  test("should contain terms of service content", async () => {
    const stagehand = new Stagehand({
      env: "LOCAL",
    });
    await stagehand.init();
    const page = stagehand.page;

    await page.goto("http://localhost:3000/terms");

    const analysis = await page.extract({
      instruction: "Extract the main heading and verify if it mentions 'Terms'.",
      schema: z.object({
        heading: z.string(),
        isTermsPage: z.boolean(),
      }),
    });

    expect(analysis.isTermsPage).toBe(true);
    await stagehand.close();
  });
});
