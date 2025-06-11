# SkillFlow Platform

**The Future of Freelancing on Stacks Blockchain**

AI-powered skill marketplace with 80%+ success prediction, dynamic competency-based pricing, SKILL token spam prevention, and native STX payments.

## What is SkillFlow?

SkillFlow is a revolutionary freelancing platform built on the Stacks blockchain that uses artificial intelligence to predict project success rates and match clients with the most suitable service providers. Our platform ensures 80%+ success rates by only suggesting pre-verified, high-performing providers while giving opportunities to newcomers through our innovative 30% quota system.

### Key Features

- **AI Success Prediction**: Only providers with 80%+ predicted success rates get matched
- **STX Native Payments**: Direct Stacks token integration - no wrapping required
- **SKILL Token Spam Prevention**: 0.1 STX application fee via SKILL tokens (much cheaper than 15-20% competitor fees)
- **Smart Escrow**: Automatic payment protection and release
- **Dynamic Competency Pricing**: Real-time price adjustments based on demonstrated skills
- **New Provider Opportunities**: 30% quota system ensuring newcomer inclusion
- **Real-time Skill Verification**: Optional AI assessment with skill score boosts
- **Built-in Dispute Resolution**: Fair mediation system
- **Transparent Fees**: 2.5% platform fee with full transparency

## Revolutionary Features

### SKILL Token Application System
- **Application Fee**: 0.1 STX per application (via SKILL tokens)
- **Spam Prevention**: Eliminates low-quality applications
- **Cost Advantage**: Massive savings vs 15-20% fees on other platforms
- **Simple Purchase**: 0.1 STX = 1 SKILL token for applications

### Success Prediction Algorithm
- **Experienced Providers**: 80% minimum success prediction required
- **New Providers**: 70% threshold with trial period support
- **AI Filtering**: Only high-probability success matches suggested
- **Risk Assessment**: Detailed risk factors and recommended adjustments

### Quota-Based Fair Matching
- **30% New Provider Quota**: Ensures opportunities for emerging talent
- **70% Experienced Provider Quota**: Maintains quality standards
- **Minimum Guarantees**: At least 1 new provider suggestion per service
- **Maximum Suggestions**: Up to 5 total suggestions per service request

### Dynamic Competency-Based Pricing
- **Performance Bonuses**: Up to 20% bonus for skill overperformance
- **Competency Penalties**: Up to 30% reduction for underperformance
- **Real-time Adjustments**: Pricing updates based on demonstrated abilities
- **Fair Compensation**: Pay reflects actual skill demonstration

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client App    │    │  AI Oracle      │    │ Provider Tools  │
│                 │    │                 │    │                 │
│ • Service Req.  │    │ • Success Pred. │    │ • SKILL Token   │
│ • Provider Sel. │    │ • Skill Verify  │    │ • Applications  │
│ • STX Payments  │    │ • Price Oracle  │    │ • Portfolio     │
│ • Rating System │    │ • Competency    │    │ • Verification  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ SkillFlow Core  │
                    │                 │
                    │ • Smart Escrow  │
                    │ • Quota System  │
                    │ • SKILL Tokens  │
                    │ • Success Filter│
                    │ • Dynamic Pricing│
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │ Stacks Network  │
                    │                 │
                    │ • STX Payments  │
                    │ • Clarity VM    │
                    │ • Bitcoin Security│
                    └─────────────────┘
```

## Smart Contract Components

### Core Contracts

| Contract | Purpose | Key Functions |
|----------|---------|---------------|
| `skillflow-main.clar` | Main platform logic | Service creation, provider selection, payments, quota system |
| `skills-token-simple.clar` | SKILL token management | Token purchases, application fees, spam prevention |
| `oracle.clar` | AI predictions & pricing | Success prediction, skill verification, STX price feeds |
| `constants.clar` | Platform configuration | Error codes, fee rates, success thresholds, quotas |
| `utils.clar` | Validation & utilities | Input validation, STX calculations, formatting |

### Contract Addresses (Mainnet)
```
Main Contract:     SP1234...MAIN
SKILL Token:       SP1234...SKILL
Oracle Contract:   SP1234...ORACLE
Constants:         SP1234...CONST
Utils:             SP1234...UTILS
```

## Prerequisites

- **Stacks Wallet**: [Hiro Wallet](https://wallet.hiro.so/) or [Xverse](https://www.xverse.app/)
- **STX Tokens**: Minimum 1 STX for service requests + 0.1 STX per application
- **SKILL Tokens**: Purchase with STX for application fees (0.1 STX = 1 SKILL)
- **Clarinet**: For local development and testing
- **Node.js**: Version 16+ for frontend integration

## Quick Start

### For Clients (Service Requesters)

1. **Connect Your Wallet**
   ```javascript
   // Using @stacks/connect
   import { showConnect } from '@stacks/connect';
   
   const connectWallet = () => {
     showConnect({
       appDetails: {
         name: 'SkillFlow',
         icon: window.location.origin + '/logo.svg',
       },
       redirectTo: '/dashboard',
       onFinish: () => window.location.reload(),
     });
   };
   ```

2. **Create a Service Request**
   ```clarity
   ;; Example: Request a logo design with AI suggestions
   (contract-call? .skillflow-main create-service-request
     "Logo Design"
     "Need a modern logo for my tech startup with brand guidelines"
     u5000000  ;; 5 STX
     false     ;; not rush delivery
     u240      ;; 4 hours estimated
     true      ;; request AI suggestions (80%+ providers only)
   )
   ```

3. **Review AI-Suggested Providers**
   - View providers with 80%+ success prediction
   - See new provider opportunities (30% quota)
   - Check competency scores and pricing adjustments
   - Select your preferred provider

4. **Automatic STX Escrow**
   - Funds automatically locked until completion
   - Provider receives payment based on competency performance
   - Platform takes 2.5% fee

### For Providers (Service Deliverers)

1. **Buy SKILL Tokens for Applications**
   ```clarity
   ;; Buy 10 SKILL tokens for applications (1 STX total)
   (contract-call? .skills-token-simple buy-skill-tokens u10000000)
   ```

2. **Create Provider Profile**
   ```clarity
   (contract-call? .skillflow-main create-provider-profile
     (list "Web Development" "React" "Node.js" "Smart Contracts" "UI/UX")
   )
   ```

3. **Start New Provider Onboarding (Optional)**
   ```clarity
   ;; For new providers - get trial project access
   (contract-call? .skillflow-main start-new-provider-onboarding
     (list "React" "TypeScript" "Node.js")
     (list "github.com/portfolio" "live-demo.com")
     (list "LinkedIn Profile" "Previous Work Examples")
   )
   ```

4. **Apply to Services (Uses SKILL Tokens)**
   ```clarity
   ;; Each application costs 1 SKILL token (0.1 STX equivalent)
   (contract-call? .skillflow-main apply-to-service
     u1  ;; service-id
     "Perfect match! I have 5+ years React experience..."
     u180  ;; 3 hours timeline
     (list "github.com/mywork" "portfolio.com" "testimonials.com")
     (some u4500000)  ;; propose 4.5 STX
     (some "What's your preferred color scheme and brand personality?")
   )
   ```

5. **Benefit from Dynamic Pricing**
   - Demonstrate high competency → earn up to 20% bonus
   - Build reputation for 80%+ success rate matching
   - Access more high-value projects

### For New Providers

1. **Trial Period Benefits**
   - First 3 projects with 70% success threshold (vs 80%)
   - Included in 30% new provider quota
   - Optional skill verification for score boosts

2. **Skill Verification Boost (Optional)**
   ```clarity
   ;; AI can award 5-25 point skill boosts
   ;; Called by oracle after skill demonstration
   (contract-call? .skillflow-main give-skill-verification-boost
     'SP1234...PROVIDER
     "React Development"
     u15  ;; 15-point boost
   )
   ```

## Development Setup

### 1. Clone Repository
```bash
git clone Repository
cd Repository
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Setup Clarinet
```bash
# Install Clarinet
brew install clarinet

# Initialize project
clarinet new Stacks-Skills
cd Stacks-Skills
```

### 4. Deploy Contracts Locally
```bash
# Test all contracts including SKILL token
clarinet test

# Deploy to local testnet
clarinet integrate
```

### 5. Environment Variables
```bash
# .env.local
NEXT_PUBLIC_NETWORK=testnet
NEXT_PUBLIC_MAIN_CONTRACT=ST1234...MAIN
NEXT_PUBLIC_SKILL_TOKEN_CONTRACT=ST1234...SKILL
NEXT_PUBLIC_ORACLE_CONTRACT=ST1234...ORACLE
```

## Testing

### Run Contract Tests
```bash
# Test all contracts
clarinet test

# Test SKILL token integration
clarinet test tests/skills-token.test.ts

# Test quota system
clarinet test tests/quota-system.test.ts

# Test success prediction
clarinet test tests/success-prediction.test.ts

# Coverage report
clarinet test --coverage
```

### Test Scenarios
```clarity
;; Test SKILL token purchase and application
(define-test-case test-skill-token-application
  (let ((buy-result (contract-call? .skills-token-simple buy-skill-tokens u1000000))
        (apply-result (contract-call? .skillflow-main apply-to-service
                        u1 "Test application" u60 (list) none none)))
    (assert-ok buy-result)
    (assert-ok apply-result)
  )
)

;; Test quota system enforcement
(define-test-case test-quota-system
  (let ((quota-init (contract-call? .skillflow-main initialize-service-suggestion-quota u1)))
    (assert-ok quota-init)
    ;; Verify 30% new provider quota is enforced
  )
)

;; Test success prediction filtering
(define-test-case test-success-filtering
  ;; Test that only 80%+ providers get suggested for experienced category
  ;; Test that 70%+ new providers get trial opportunities
)
```

## Platform Economics

### Revolutionary Cost Structure
- **Application Fee**: 0.1 STX per application (via SKILL tokens)
- **Platform Fee**: 2.5% of service amount
- **Massive Savings**: Avoid 15-20% fees charged by competitors
- **Example**: 100 applications = 10 STX vs $1000+ in percentage fees elsewhere

### SKILL Token Economics
- **Price**: 0.1 STX = 1 SKILL token
- **Usage**: 1 SKILL token per application
- **Supply**: 10 million maximum SKILL tokens
- **Benefit**: Fixed cost vs percentage-based competitor fees

### Success Rate Requirements
- **Experienced Providers**: 80% minimum success prediction
- **New Providers**: 70% minimum with 3-project trial period
- **Competency Bonuses**: Up to 20% payment increase for overperformance
- **Performance Penalties**: Up to 30% reduction for underperformance

### Quota System Economics
- **30%** of suggestions reserved for new providers
- **70%** for experienced providers (80%+ success rate)
- **Minimum 1** new provider suggestion per service
- **Maximum 5** total suggestions per service

## Advanced Features

### Success Prediction Algorithm
```clarity
;; AI Oracle creates suggestions with success prediction
(create-ai-suggested-application-with-prediction
  service-id: uint
  suggested-provider: principal
  estimated-timeline: uint
  success-probability: uint  ;; Must be 80%+ for experienced
  risk-factors: (list 10 (string-ascii 50))
  recommended-adjustments: (string-ascii 300)
  initial-skill-score: uint
)
```

### Dynamic Competency Pricing
```clarity
;; Competency assessment affects final payment
(map competency-assessments
  { service-id: uint, provider: principal }
  {
    initial-skill-score: uint,
    demonstrated-competency: uint,
    competency-verified: bool,
    price-adjustment-factor: uint,  ;; 5000-15000 (50%-150%)
    assessment-timestamp: uint,
    verification-evidence: (optional (string-ascii 200))
  }
)
```

### New Provider Trial System
```clarity
;; Special trial period for new providers
(map new-provider-trials
  principal
  {
    trial-projects-completed: uint,
    trial-success-rate: uint,
    skill-verification-score: uint,
    portfolio-verification-score: uint,
    external-verification-score: uint,
    trial-period-active: bool,
    trial-start-block: uint
  }
)
```

## Security Features

### Smart Contract Security
- **SKILL Token Protection**: Secure token minting and burning
- **Escrow Protection**: Funds locked until completion or dispute resolution
- **Input Validation**: All parameters sanitized and validated
- **Access Control**: Role-based permissions for all operations
- **Emergency Controls**: Pause functionality for critical issues

### Anti-Spam Protection
- **SKILL Token Gate**: 0.1 STX cost prevents spam applications
- **Quality Filter**: Only verified providers can apply
- **Rate Limiting**: Maximum applications per provider per time period
- **Success Threshold**: Minimum prediction scores required

### Oracle Security
- **Price Feed Validation**: Multiple source verification for STX prices
- **Staleness Checks**: Price data freshness validation
- **Confidence Scoring**: AI prediction reliability metrics
- **Success Rate Tracking**: Continuous monitoring of prediction accuracy

## API Reference

### SKILL Token Functions

#### Buy SKILL Tokens
```clarity
(buy-skill-tokens 
  skill-amount: uint
) -> (response uint uint)
```

#### Check Application Eligibility
```clarity
(check-application-eligibility 
  provider: principal
  service-id: uint
) -> (response application-eligibility-info uint)
```

#### Get Token Info
```clarity
(get-user-token-info 
  user: principal
) -> (response token-info uint)
```

### Enhanced Client Functions

#### Create Service with AI Matching
```clarity
(create-service-request 
  skill-category: (string-ascii 50)
  service-description: (string-ascii 500)
  payment-amount: uint
  rush-delivery: bool
  duration-minutes: uint
  request-ai-suggestions: bool  ;; Get 80%+ success rate providers
) -> (response uint uint)
```

### Advanced Provider Functions

#### Apply with SKILL Token Fee
```clarity
(apply-to-service
  service-id: uint
  application-message: (string-ascii 300)
  proposed-timeline: uint
  portfolio-links: (list 5 (string-ascii 200))
  proposed-price: (optional uint)
  provider-questions: (optional (string-ascii 200))
) -> (response bool uint)
;; Note: Automatically deducts 1 SKILL token
```

#### Start New Provider Onboarding
```clarity
(start-new-provider-onboarding
  skills-to-verify: (list 5 (string-ascii 50))
  portfolio-links: (list 5 (string-ascii 200))
  external-verifications: (list 3 (string-ascii 300))
) -> (response bool uint)
```

### AI Oracle Functions

#### Create Experienced Provider Suggestion
```clarity
(create-experienced-provider-suggestion
  service-id: uint
  suggested-provider: principal
  estimated-timeline: uint
  success-probability: uint  ;; Must be >= 80%
  risk-factors: (list 10 (string-ascii 50))
  recommended-adjustments: (string-ascii 300)
  initial-skill-score: uint
) -> (response bool uint)
```

#### Give Skill Verification Boost
```clarity
(give-skill-verification-boost
  provider: principal
  skill: (string-ascii 50)
  boost-amount: uint  ;; 5-25 points
) -> (response uint uint)
```

## Cost Comparison

### SkillFlow vs Competitors

| Platform | Application Fee | Project Fee | 100 Applications Cost |
|----------|----------------|-------------|----------------------|
| **SkillFlow** | **0.1 STX** | **2.5%** | **10 STX (~$20)** |
| Upwork | Free | 20% | $0 + 20% of all projects |
| Fiverr | Free | 20% | $0 + 20% of all projects |
| Freelancer | $3-15 per bid | 10% | $300-1500 + 10% |

### Real Cost Example
- **100 applications on SkillFlow**: 10 STX (~$20)
- **Same volume on percentage platforms**: 15-20% of ALL project values
- **Break-even**: After just $100 in project value, SkillFlow is cheaper
- **At $10,000 projects**: Save $1,500-2,000 vs competitors

## Roadmap

### Phase 1: Core Platform ✅
- [x] Smart contract development
- [x] SKILL token integration
- [x] AI success prediction (80%+ filtering)
- [x] Quota system (30% new providers)
- [x] Dynamic competency pricing
- [x] New provider trial system

### Phase 2: Enhanced Features
- [ ] Mobile application with SKILL token integration
- [ ] Advanced dispute resolution with competency consideration
- [ ] Multi-token support while maintaining SKILL for applications
- [ ] Reputation NFTs for top performers

### Phase 3: Ecosystem Growth
- [ ] API marketplace for third-party integrations
- [ ] White-label platform licensing
- [ ] DAO governance for platform parameters
- [ ] Cross-chain SKILL token bridges

### Phase 4: Enterprise & Scale
- [ ] Enterprise solutions with bulk SKILL token purchasing
- [ ] AI model marketplace for specialized predictions
- [ ] Advanced analytics and success prediction training
- [ ] Global expansion with localized skill verification

## Why SkillFlow Wins

### For Clients
- **Quality Guarantee**: 80%+ success rate with AI matching
- **Cost Effective**: 2.5% platform fee vs 15-20% elsewhere
- **Spam-Free**: SKILL token filter ensures quality applications
- **Bitcoin Security**: Stacks blockchain provides maximum security
- **Fair Pricing**: Competency-based adjustments ensure fair compensation

### For Providers
- **Equal Opportunities**: 30% quota guarantees new provider inclusion
- **Performance Rewards**: Up to 20% bonus for skill demonstration
- **Low Application Costs**: 0.1 STX per application vs percentage-based fees
- **Trial Period**: New providers get 70% threshold for first 3 projects
- **Skill Recognition**: Optional verification boosts for demonstrated abilities

### For New Providers
- **Guaranteed Inclusion**: 30% of all suggestions reserved for newcomers
- **Lower Barriers**: 70% success threshold during trial period
- **Skill Development**: Optional verification with AI assessment
- **Fair Competition**: Protected quota prevents experienced provider dominance

### For the Ecosystem
- **Revolutionary Economics**: Fixed application fees vs percentage exploitation
- **Open Source**: Fully auditable smart contracts
- **Decentralized**: No single point of failure
- **Sustainable**: Community-driven development with fair economics

---

## Get Started Today

1. **Set up Stacks wallet**
2. **Buy some STX tokens**
3. **Purchase SKILL tokens for applications (0.1 STX each)**
4. **Create your profile**
5. **Start earning with guaranteed fair opportunities**

**Join the freelancing revolution that puts fairness and quality first!**

---