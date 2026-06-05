import { describe, test, expect } from "vitest";
import { Stagehand } from "@browserbasehq/stagehand";

describe("Privacy Page Use Case", () => {
  test("user can navigate to privacy page", async () => {
    const stagehand = new Stagehand({
      env: "LOCAL",
    });
    await stagehand.init();
    const page = stagehand.page;

    // Assuming there might be a link in the footer or user navigates directly
    await page.goto("http://localhost:3000/privacy");

    const title = await page.title();
    expect(title).toBeDefined();

    await stagehand.close();
  });
});
