/// <reference types="vitest" />
import { defineConfig } from "vite"

export default defineConfig({
  test: {
    environment: "node", // Use node environment instead of clarinet
    include: ["tests/**/*.test.ts"],
    exclude: ["node_modules/**"],
    testTimeout: 30000,
    globals: true,
    setupFiles: ["./tests/setup.ts"], // Add setup file
  },
})
