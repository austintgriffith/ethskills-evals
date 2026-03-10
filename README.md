# ethskills-evals

Eval suite for [ethskills.com](https://ethskills.com) — measuring whether AI agents actually learn from Ethereum skill docs.

## What it does

1. Asks an AI model Ethereum questions **with** and **without** skill docs loaded
2. A judge model evaluates factual accuracy against expected answers
3. Generates a pass/fail report showing **uplift** (how much the skill helped)

## Quick start

```bash
# Requirements
brew install yq jq curl

# Set API keys
export VENICE_API_KEY="..."
export OPENAI_API_KEY="..."

# Run all evals
./runner/run.sh

# Run one skill
./runner/run.sh --skill gas

# Test a specific model
./runner/run.sh --model openai/gpt-5.2

# Skip baseline (faster, no A/B comparison)
./runner/run.sh --no-baseline
```

## Eval format

Each YAML file in `evals/` tests one ethskill:

```yaml
skill: gas
skill_url: https://ethskills.com/gas/SKILL.md

evals:
  - id: gas-eth-transfer-cost
    prompt: "What does an ETH transfer cost on mainnet today?"
    expected_facts:
      - "Under $0.01 at typical gas prices"
    fail_if:
      - "Claims transfer costs more than $1"
```

## Current evals

| Skill | Evals | What it tests |
|-------|-------|---------------|
| gas | 10 | Gas prices, costs, fee settings, L1 vs L2 |
| l2s | 11 | L2 landscape, DEXes, Celo migration, Polygon zkEVM shutdown |
| security | 10 | Token decimals, reentrancy, oracles, SafeERC20, vaults |
| standards | 8 | ERC-8004, EIP-7702, x402, EIP-3009, ERC-4337 |
| why | 7 | Pectra/Fusaka, gas correction, agent infra, ETH price |
| concepts | 6 | Nothing is automatic, incentive design, CROPS |
| wallets | 6 | EIP-7702, Safe, key management, ERC-4337 |
| building-blocks | 6 | Uniswap V4, hooks, dominant DEXes, flash loans |

**Total: 64 evals** across 8 skills.

## How judging works

A separate judge model (default: GPT-5.2) evaluates each response:

- **PASS** — All expected facts present, no fail conditions triggered
- **PARTIAL** — ≥50% of expected facts, no fail conditions
- **FAIL** — Any fail condition triggered, or <50% of expected facts

The judge returns structured JSON with reasoning, so you can see exactly what the model got right and wrong.

## What the results tell you

- **High uplift** (model fails without skill, passes with) → skill is doing its job
- **Both pass** → model has learned this; skill may be ready for deprecation
- **Both fail** → skill isn't working; needs revision
- **Passes without, fails with** → skill is actively making things worse (investigate)

## Adding evals

1. Create `evals/your-skill.yaml`
2. Add test cases with `prompt`, `expected_facts`, and `fail_if`
3. Run `./runner/run.sh --skill your-skill`
