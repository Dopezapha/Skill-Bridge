// tests/setup.ts
import { beforeAll } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";

// Initialize clarinet environment
beforeAll(async () => {
  console.log("Initializing Clarinet test environment...");
  try {
    globalThis.simnet = await initSimnet();
    console.log("Clarinet environment ready!");
  } catch (error) {
    console.error("Failed to initialize Clarinet:", error);
    throw error;
  }
});

export {};