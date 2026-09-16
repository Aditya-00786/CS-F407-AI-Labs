# Week 6: Building and Learning a Bayesian Network with an LLM Coding Assistant

| | |
|---|---|
| **Question** | [lab-question/llm_bn.ipynb](lab-question/llm_bn.ipynb) (the lab notebook, unchanged) |
| **Solution** | [solution/LLM_BN_Solution.ipynb](solution/LLM_BN_Solution.ipynb) |
| **Answers** | [answers-to-questions/answers.md](answers-to-questions/answers.md) (validation results, the HW query exercise, the CPT-explanation and dataset exercises, observed failure modes) |
| **LLM responses** | [solution/outputs/llm_responses.json](solution/outputs/llm_responses.json) (every prompt and response, labelled by model) and [solution/outputs/local_responses.json](solution/outputs/local_responses.json) (the same prompts on the lab's model run locally) |

## Objective

The lab separates **AI science** from **AI engineering**:
- **AI science:** define the Sprinkler Bayesian network, $C \to R,\ C \to S,\ R,S \to W$, and perform correct inference and parameter estimation.
- **AI engineering:** use a coding LLM (Qwen2.5-Coder) to translate natural-language specifications into `pgmpy` code, then **inspect, execute, validate and test** that code.

The LLM writes programs. It is never the inference engine.

## What was built

- **Trusted references:**
  - a hand-built model;
  - brute-force enumeration of all 16 joint probabilities;
  - a joint-distribution validator (the strongest semantic test: it catches CPTs whose numbers are valid but whose meaning is wrong);
  - trusted MLE and BDeu fits, compared entry by entry via `get_value`.
- **Code-safety tooling:** the lab's AST check, plus a stricter one that also catches attribute calls such as `pd.read_csv`, overwritten inputs, and APIs missing from the installed pgmpy.
- **The three LLM tasks** (inference, MLE and BDeu estimation), each run as round 1 (the lab's prompt), then feedback rounds, then a minimal human fix where needed. Every program was executed and validated.
- **A model-size comparison:** the lab's prompts sent to Qwen2.5-Coder-1.5B, Qwen2.5-Coder-32B and Qwen3-Coder-30B.
- **All three exercises**, completed.

## Key results

- **Qwen2.5-Coder-1.5B never produced a correct inference program**, even after three rounds of prompting. A five-line human fix to its best attempt then passed every test ($P(R{=}1\mid W{=}1) = 0.70477$). For estimation, one round of concrete feedback produced code that exactly matched the trusted MLE and BDeu fits.
- **The larger models failed quietly.** Their inference code used the right API, ran, and passed `check_model()`, but encoded wrong CPTs, giving posteriors of 0.40 (32B) and 0.56 (Qwen3-30B) instead of 0.70. Only the semantic tests caught this.
- **Every model used obsolete pgmpy APIs** at some point, and one response read a file despite being told not to. The lab's AST check misses that pattern.
- **Hosted greedy decoding did not reproduce** the lab's recorded responses.
- **A local run of the 1.5B model**, set up exactly as in the lab, reproduced two of the lab's recorded responses word for word. It made every error category seen through the API and passed only **1 of 10** code tasks (hosted: 3 of 8). It got all three HW queries wrong by overwriting the provided model, and ignored the feedback about `pd.read_csv`. **The errors belong to the model, not to the API.**
- **The exercises:**
  - **Queries:** $P(S{=}1\mid W{=}1) = 0.428$, $P(C{=}1\mid W{=}1) = 0.575$, $P(R{=}1\mid W{=}1,S{=}0) = 0.992$. All three qualitative predictions held. The query code from 32B was correct; from the 1.5B model it was correct once when hosted and never when run locally.
  - **CPT explanation:** 1.5B's explanation was wrong; 32B's was right.
  - **Datasets:** the variation is sampling variability; the estimate's spread shrinks as $1/\sqrt{N}$, matching the binomial prediction.

## What I learned

- **Successful execution is not evidence of correctness.** `check_model()` confirms only that each column sums to 1. A model can pass it and still encode the wrong distribution. A trusted reference and semantic tests (known posteriors, the full joint distribution) are what establish correctness.
- **CPT conventions are semantics, not formatting.** Row order, column order and declared parents decide which distribution the numbers mean. That is exactly where every LLM failed, at every model size.
- **Bigger models change *how* they fail.** Small models fail loudly, with exceptions. Large models fail quietly, with plausible code that is wrong, which makes validation more important, not less.
- **Feedback prompts work best when they report concrete test failures.** They fixed the estimation code in one round. When prompting stops converging, a minimal, auditable human fix is the right engineering move.
- **Generated code is an artifact.** The same prompt with greedy decoding gave different programs, so generated code must be saved, reviewed and pinned together with the library version.
- **The LLM's explanations need checking just like its code.** A model can explain a convention correctly and still apply it wrongly, and vice versa.
- **Sampling variability is quantifiable:** the MLE is unbiased, with standard error $\sqrt{p(1-p)/N_{\text{parent}}}$.

## Running

```bash
pip install -r ../requirements.txt
jupyter notebook solution/LLM_BN_Solution.ipynb
```

The notebook works from the saved responses in `solution/outputs/llm_responses.json`.
