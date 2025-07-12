// Setup file to mock the clarinet environment
import { beforeAll } from "vitest"

// Mock the simnet object that would normally be provided by clarinet environment
const mockAccounts = new Map([
  ["deployer", { address: "ST1HTBVD3JG9C05J7HBJTH6BNR6V7X4PT9X526F0" }],
  ["wallet_1", { address: "ST2HTBVD3JG9C05J7HBJTH6BNR6V7X4PT9X54444" }],
  ["wallet_2", { address: "ST3HTBVD3JG9C05J7HBJTH6BNR6V7X4PT9X55555" }],
])

// Create a mock result object that matches Clarinet's API
const createMockResult = (value: any) => {
  const mockResult = {
    expectUint: (expected?: number) => {
      if (expected !== undefined) {
        console.log(`Expected uint: ${expected}`)
      }
      return value
    },
    expectOk: () => ({
      expectTuple: () => {
        // Return mock tuple data for version info
        if (typeof value === "object") {
          return {
            version: { expectAscii: () => "1.0.0" },
            major: { expectUint: () => 1 },
            minor: { expectUint: () => 0 },
            patch: { expectUint: () => 0 },
            "deployment-block": { expectUint: () => 1 },
          }
        }
        return value
      },
    }),
    expectErr: () => ({
      expectUint: (expected?: number) => {
        if (expected !== undefined) {
          console.log(`Expected error uint: ${expected}`)
        }
        return value
      },
    }),
    expectTuple: () => {
      // Mock platform info structure
      return {
        "primary-token": { expectAscii: () => "STX" },
        "application-token": { expectAscii: () => "SKILL" },
        "platform-fee-rate": { expectUint: () => 250 },
        "min-service-amount": { expectUint: () => 1000000 },
        "application-cost": { expectUint: () => 100000 },
        "application-cost-display": { expectAscii: () => "0.1 STX per application" },
        "native-currency": { expectBool: () => true },
        blockchain: { expectAscii: () => "Stacks" },
        "payment-model": { expectAscii: () => "stx-escrow-with-skill-token-applications" },
        version: { expectAscii: () => "1.0.0" },
        "ai-features": "mock-ai-features",
        "success-thresholds": "mock-success-thresholds",
        "quota-system": "mock-quota-system",
        "pricing-system": "mock-pricing-system",
        "application-system": "mock-application-system",
        "rate-limits": "mock-rate-limits",
        "max-service-duration": { expectUint: () => 8640 },
        "min-provider-rating": { expectUint: () => 20 },
        "max-applications-per-block": { expectUint: () => 3 },
        "max-services-per-block": { expectUint: () => 5 },
        "max-applications-per-service": { expectUint: () => 15 },
        "emergency-timeout": { expectUint: () => 2160 },
        "skill-boost-cooldown": { expectUint: () => 144 },
        "min-portfolio-links": { expectUint: () => 1 },
        "max-portfolio-links": { expectUint: () => 5 },
        "max-external-verifications": { expectUint: () => 5 },
      }
    },
  }
  return mockResult
}

// Mock function return values based on function name
const getMockValue = (functionName: string) => {
  const mockValues: Record<string, any> = {
    "get-platform-fee-rate": 250,
    "get-basis-points": 10000,
    "get-skill-token-price": 100000,
    "get-application-cost-skill": 1000000,
    "get-application-cost-stx": 100000,
    "get-contract-version": { version: "1.0.0", major: 1, minor: 0, patch: 0 },
    "err-unauthorized": 100,
    "err-not-found": 101,
    "err-invalid-state": 102,
    "err-insufficient-funds": 103,
    "err-duplicate": 104,
    "err-verification-required": 105,
    "err-expired": 106,
    "err-invalid-rating": 107,
    "err-admin-only": 108,
    "err-funds-locked": 109,
    "err-invalid-amount": 110,
    "err-oracle-stale": 115,
    "err-paused": 116,
    "err-invalid-input": 117,
    "err-owner-only": 118,
    "err-insufficient-balance": 120,
    "err-transfer-failed": 121,
    "err-invalid-recipient": 124,
    "err-invalid-duration": 125,
    "err-contract-paused": 126,
    "err-rate-limited": 127,
    "err-invalid-status": 128,
    "err-invalid-confidence": 129,
    "err-stale-price": 130,
    "err-invalid-price": 131,
    "err-success-threshold-not-met": 132,
    "err-experienced-provider-quota-full": 133,
    "err-not-new-provider": 134,
    "err-new-provider-quota-full": 135,
    "err-insufficient-skill-tokens": 136,
    "err-skill-token-contract-not-set": 137,
    "err-application-fee-required": 138,
    "get-service-status-open": 0,
    "get-service-status-matched": 1,
    "get-service-status-in-progress": 2,
    "get-service-status-completed": 3,
    "get-service-status-disputed": 4,
    "get-service-status-cancelled": 5,
    "get-min-rating": 10,
    "get-max-rating": 50,
    "get-min-provider-rating-threshold": 20,
    "get-blocks-per-day": 144,
    "get-blocks-per-year": 52560,
    "get-rush-delivery-blocks": 60,
    "get-price-staleness-threshold": 144,
    "get-max-service-duration": 8640,
    "get-emergency-timeout": 2160,
    "get-stale-service-timeout": 4320,
    "get-max-dispute-resolution-time": 1440,
    "get-stx-decimals": 6,
    "get-min-stx-amount": 1000000,
    "get-max-stx-amount": 100000000000,
    "get-min-success-probability": 80,
    "get-new-provider-success-threshold": 70,
    "get-new-provider-quota-percentage": 30,
    "get-max-total-suggestions": 5,
    "get-new-provider-trial-projects": 3,
    "get-max-skill-verification-boost": 25,
    "get-max-competency-bonus": 20,
    "get-max-competency-penalty": 30,
    "get-min-price-adjustment-factor": 5000,
    "get-max-price-adjustment-factor": 15000,
    "get-max-applications-per-block": 3,
    "get-max-services-per-block": 5,
    "get-max-applications-per-service": 15,
    "get-application-window-blocks": 144,
    "get-platform-limits-extended": {},
    "get-platform-info": {},
  }

  return mockValues[functionName] ?? 0
}

const mockSimnet = {
  getAccounts: () => mockAccounts,
  callReadOnlyFn: (contract: string, method: string, args: any[], sender: any) => {
    console.log(`Mock call: ${contract}.${method}`)
    const value = getMockValue(method)
    return {
      result: createMockResult(value),
    }
  },
}

beforeAll(() => {
  // Make simnet available globally
  ;(globalThis as any).simnet = mockSimnet
})