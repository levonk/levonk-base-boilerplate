import http from "node:http";

import yakbak from "yakbak";

const tapeDir = "__test__/api/yakbak";

const upstream = process.env.YAKBAK_UPSTREAM ?? "https://ipinfo.io";
const port = Number(process.env.YAKBAK_PORT ?? "3030");

const handler = yakbak(upstream, {
  dirname: tapeDir,
  noRecord: process.env.YAKBAK_NO_RECORD === "1",
});

http.createServer(handler).listen(port, () => {
  console.log(`Yakbak proxy listening on http://localhost:${port}`);
  console.log(`Upstream: ${upstream}`);
  console.log(`Tape directory: ${tapeDir}`);
  console.log("Example:");
  console.log(`  curl http://localhost:${port}/json`);
});
