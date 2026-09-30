# Week 8: Bayesian Networks and Autoregressive Language Models

| | |
|---|---|
| **Question** | [lab-question/BN_lab.pdf](lab-question/BN_lab.pdf) |
| **Solution** | [solution/BN_Lab.ipynb](solution/BN_Lab.ipynb) |
| **Answers (Q1–14)** | [answers-to-questions/answers.md](answers-to-questions/answers.md) |
| **Generated text** | [solution/outputs/](solution/outputs/) |

## Objective

The lab connects Bayesian networks to the models behind modern AI text generation. An autoregressive language model rests on the chain rule,

$$P(x_1,\dots,x_T) = \prod_{t} P(x_t \mid x_1,\dots,x_{t-1}),$$

and if each word is assumed to depend only on the previous one (or two), that model *is* a small Bayesian network. The goal was to:

- build such a model from scratch and estimate its conditional probability tables (CPTs) by counting;
- use it to predict and generate text;
- test that it really implements the intended probability model;
- use an LLM to write the code, without handing over the modelling decisions to it.

## What was built

All code uses plain Python: `collections`, `random` and `fractions`, with no ML libraries or pretrained models.

- **`FirstOrderLM`**: the Bayesian network $X_{t-1} \to X_t$. It counts word pairs, normalises them into P(next | previous), and supports displaying a distribution, argmax prediction, sampling, and generation in greedy or sampling mode.
- **`SecondOrderLM`**: the Bayesian network $X_{t-2} \to X_t \leftarrow X_{t-1}$, built from triple counts with two `<START>` tokens of padding. It subclasses the first-order model, so both are tested by the same code.
- **Tests**:
  - a normalisation check that every CPT row sums to 1, which fails loudly on a deliberately buggy variant;
  - assertions against the hand-computed counts;
  - chain-rule sentence probabilities.
- **Experiments**:
  - next-word distributions for 9 contexts;
  - 20 generated sentences per model;
  - 5 greedy vs 5 sampled sentences;
  - a side-by-side comparison of parameters, sparsity, diversity (over 1000 samples) and coherence.

## Key results

| | first-order | second-order |
|---|---|---|
| Free parameters (full CPT) | 110 | 1110 |
| Unseen contexts | 0 of 11 | 96 of 111 |
| Distinct sentences in 1000 samples | 154 | 6 |
| Novel sentences (not in training data) | 148 | 0 |
| Greedy output | loops forever: "the cat sat on the cat sat on …" | "the cat sat on the mat" |

- **The first-order model generalises, but badly.** It produces new sentences, but they are fragments ("the park" is its single most likely output, with P = 1/6), wrong combinations ("the dog sat on the park"), and recursive chains up to 42 words long.
- **The second-order model is always coherent, but only because it memorises.** With six training sentences, two words of context identify the whole sentence. It never generates anything new, and it gives a plausible unseen sentence ("the cat ran to the mat") probability 0.

## What I learned

- **The chain rule is exact; the model is the independence assumption.** Choosing a Bayesian network structure ($X_{t-1}\to X_t$) is what turns an intractable joint distribution into a small table that can be counted.
- **More context vs data sparsity.** Each extra word of context multiplies the CPT size by $|V|$, while the data stays the same. On small data this trades bias for variance: the first-order model is wrong but well estimated, and the second-order model is sharp but mostly empty. This sparsity problem is what smoothing, back-off and, ultimately, neural networks with shared parameters are designed to solve.
- **Greedy decoding is not "the model's best sentence".** Always taking the argmax can loop forever, and it misses the most probable complete sentence. Sampling is what actually draws from the distribution the Bayesian network defines.
- **Probabilistic code needs probabilistic tests.** A CPT row summing to 0.87 is a bug that sampling hides, because `random.choices` renormalises its weights. Testing invariants such as normalisation and hand-counted values catches bugs that looking at the outputs does not.
- **Specify first, then let the LLM implement.** Writing a behavioural spec (the variables, the dependencies, the estimator, the stopping rule) made the LLM's code checkable. Inspecting that code found cases the spec had missed: non-termination in greedy mode, silent tie-breaking, and crashes on unseen words. Those were fixed by updating the spec, not just patching the code.
- **Modern LLMs solve the same problem at scale.** A modern LLM estimates the same P(next token | previous tokens) and generates with the same sample-and-append loop. The difference is that the CPT is replaced by a neural network trained by gradient descent, over a much longer context.

## Running

```bash
jupyter notebook solution/BN_Lab.ipynb
```

Any Python 3 kernel works. Sampling uses a fixed seed (`SEED = 407`), so re-running reproduces the outputs shown, and writes the generated sentences to `solution/outputs/`.
