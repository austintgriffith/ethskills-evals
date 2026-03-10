# ethskills-evals

## What this is

An eval suite for [ethskills.com](https://ethskills.com) — the bot-readable Ethereum knowledge base that corrects stale AI training data.

Ethskills are **capability uplift skills**: they fix what models get wrong about Ethereum (gas prices, L2 landscape, deprecated chains, contract addresses, token decimals). This eval suite measures whether the skills actually work, and whether models still need them.

Inspired by [Anthropic's skill-creator eval framework](https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills).

## Goals

1. **Verify correctness** — Does an AI agent give the right answer after reading an ethskill?
2. **Detect regressions** — After a model update, do the skills still produce correct outputs?
3. **Measure uplift** — A/B test: skill loaded vs. bare model. How much does the skill actually help?
4. **Know when to deprecate** — If the base model passes without the skill, the skill's knowledge has been absorbed. Time to retire or update it.

## Architecture

```
ethskills-evals/
├── PLAN.md              # This file
├── README.md            # Usage instructions
├── evals/               # One YAML file per ethskill
│   ├── gas.yaml
│   ├── l2s.yaml
│   ├── standards.yaml
│   ├── security.yaml
│   ├── wallets.yaml
│   ├── building-blocks.yaml
│   ├── addresses.yaml
│   ├── tools.yaml
│   ├── concepts.yaml
│   ├── why.yaml
│   ├── indexing.yaml
│   ├── frontend-ux.yaml
│   └── frontend-playbook.yaml
├── runner/              # Eval runner scripts
│   ├── run.sh           # Main entry point
│   ├── judge.md         # System prompt for the judge LLM
│   └── report.sh        # Generate summary report
├── results/             # Benchmark results (gitignored except examples)
│   └── .gitkeep
└── .gitignore
```

## Eval format

Each eval YAML file contains test cases for one ethskill:

```yaml
skill: gas
skill_url: https://ethskills.com/gas/SKILL.md
description: "Ethereum gas costs and pricing in 2026"

evals:
  - id: gas-eth-transfer-cost
    prompt: "What does a simple ETH transfer cost on Ethereum mainnet today?"
    expected_facts:
      - "~$0.002 or under $0.01"
      - "Gas is 0.05-0.1 gwei, not 10-30 gwei"
    fail_if:
      - "Claims transfer costs more than $1"
      - "Uses gas prices from 2021-2023 (10+ gwei)"

  - id: gas-l2-swap-cost
    prompt: "How much does a token swap cost on Base?"
    expected_facts:
      - "$0.002-0.003"
    fail_if:
      - "Claims L2 swaps cost more than $0.10"
```

## How it runs

### Step 1: Fetch the skill
For each eval file, fetch the corresponding SKILL.md from ethskills.com.

### Step 2: Ask the model
Send each prompt to the target model twice:
- **With skill**: Include the SKILL.md content as context
- **Without skill**: Bare model, no skill loaded (for A/B comparison)

### Step 3: Judge the response
A separate judge LLM evaluates each response against `expected_facts` and `fail_if` criteria. Returns:
- **PASS** — All expected facts present, no fail conditions triggered
- **PARTIAL** — Some expected facts present, no fail conditions
- **FAIL** — Missing critical facts or fail condition triggered

### Step 4: Report
Generate a summary:
- Per-skill pass rate (with skill vs. without)
- Uplift score (how much better with skill)
- Regressions from previous run
- Candidates for deprecation (base model passes without skill)

## Models to test against

Priority targets (these are what builders actually use):
- Claude Opus 4.6 (via Venice)
- Claude Sonnet 4.5
- GPT-5.2 / GPT-5.4
- Qwen3 Coder 480B (via Venice)
- DeepSeek V3.2
- Llama 3.3 70B (local via Ollama)

## Implementation phases

### Phase 1: Eval definitions (NOW)
Write eval YAML files for every ethskill. Focus on facts that models commonly get wrong:
- Gas prices (almost all models think gas is 10-30 gwei)
- L2 landscape (Polygon zkEVM shutdown, Celo migration, dominant DEXes)
- Token decimals (USDC = 6, not 18)
- Contract addresses (hallucination is rampant)
- Current standards (ERC-8004, EIP-7702, x402)

### Phase 2: Runner script
Shell script that:
1. Fetches each SKILL.md
2. Sends prompts to target model via API
3. Sends responses + criteria to judge model
4. Outputs structured results (JSON)

Keep it simple — bash + curl + jq. No frameworks. Any agent can run it.

### Phase 3: A/B comparison
Run each eval with and without the skill. Calculate uplift percentage per skill.

### Phase 4: CI integration
GitHub Action that runs the full suite on:
- Push to ethskills.com (did we break something?)
- Monthly schedule (have models caught up?)
- Manual trigger (testing new skill versions)

## Design principles

- **No dependencies** — bash, curl, jq. Runs anywhere.
- **Model-agnostic** — Works with any API that accepts chat completions (OpenAI format).
- **Human-readable** — YAML evals, markdown reports. A subject matter expert can write evals without code.
- **Fast** — Parallel eval execution where possible.
- **Honest** — If the base model knows the answer without the skill, that's a win for Ethereum education, not a failure.
