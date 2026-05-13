import { describe, test, expect } from "vitest";
import { Stagehand } from "@browserbasehq/stagehand";

describe("Terms Page Use Case", () => {
  test("user can navigate to terms page", async () => {
    const stagehand = new Stagehand({
      env: "LOCAL",
    });
    await stagehand.init();
    const page = stagehand.page;

    await page.goto("http://localhost:3000/terms");

    const title = await page.title();
    expect(title).toBeDefined();

    await stagehand.close();
  });
});
