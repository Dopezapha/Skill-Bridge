/// <reference types="vitest" />
import { defineConfig } from "vite"

export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"],
    exclude: ["node_modules/**"],
    testTimeout: 30000,
    globals: true,
    // Remove setupFiles for now to test the simpler approach
    // setupFiles: ["./tests/setup.ts"],
  },
})