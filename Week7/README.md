# Week 7: Transformers — Encoders, Decoders, and Running GPT-type Models Locally

| | |
|---|---|
| **Question** | [lab-question/Transformer.pdf](lab-question/Transformer.pdf) (notes and tasks), [AI_lab_transformers.ipynb](lab-question/AI_lab_transformers.ipynb), [Run_Ollama.ipynb](lab-question/Run_Ollama.ipynb) |
| **Solution, Part 1** | [solution/Transformers_Lab.ipynb](solution/Transformers_Lab.ipynb): architecture, the six concepts from scratch, attention in real models, translation, sentiment, semantic search, GPT-2 generation |
| **Solution, Part 2** | [solution/Ollama_LLM_Comparison.ipynb](solution/Ollama_LLM_Comparison.ipynb): Mistral-7B run locally with Ollama, compared with GPT, Claude and four open models on 12 graded prompts |
| **Answers** | [answers-to-questions/answers.md](answers-to-questions/answers.md) |
| **Raw model outputs** | [solution/data/](solution/data/): all model responses and measurements the notebooks analyse, plus the 12 comparison prompts |

## Objective

The lab covers the Transformer and its three architectural families:
- **Encoder-decoder**, built originally for machine translation;
- **Encoder-only** (BERT): understanding text, as in search, retrieval, clustering and classification;
- **Decoder-only** (GPT): generating text.

It also covers the six mechanisms behind them: attention, self-attention, cross-attention, multi-head attention, positional encoding and masked attention.

**Hands-on:**
- translation, sentiment analysis and GPT-style generation with Hugging Face `transformers`;
- running a GPT-type model locally with **Ollama** and comparing its answers with GPT and Claude.

## What was built

- **The six concepts from scratch in NumPy,** each checked against PyTorch:
  - scaled dot-product attention, with the effect of $\sqrt{d_k}$ scaling measured;
  - self-attention and cross-attention;
  - multi-head attention;
  - sinusoidal positional encodings (permutation-equivariance shown without them, relative-offset structure shown with them);
  - the causal mask (a future token cannot change earlier outputs).
- **Attention in real models:**
  - BERT's pronoun-resolving heads ("it" → "animal");
  - GPT-2's exact causal mask;
  - attention sinks;
  - T5's cross-attention between German and English.
- **The lab's demos, re-run and analysed:**
  - bert2bert, T5 and Hinglish translation;
  - 14 sentiment probes;
  - semantic search vs keyword matching;
  - BERT fill-mask;
  - GPT-2 decoding strategies and next-token distributions;
  - a comparison of all seven models' architectures.
- **An LLM comparison:**
  - 12 prompts with reference answers, given to Mistral-7B (local, Ollama), GPT 5.6 Sol, Claude Sonnet 5.5, LFM-2.5-2.6B, Qwen3.8-27B, Gemma-4-31B and Nemotron-3-Super-120B;
  - graded automatically where the answer is objective, and manually with stated reasons elsewhere;
  - every model's code executed against 200 test cases in an isolated process.

## Key results

- **Encoder vs decoder attention, measured.** GPT-2 has exactly 0 weight above the diagonal; BERT reaches 1.0. In 93 of 144 BERT heads, "it" attends more to "animal" than to "street".
- **The lab's own cells had hidden issues:**
  - the GPT-2 call ignored `max_length=30` and generated 261 tokens;
  - the bert2bert input was a half-sentence, which the model quietly completed or invented;
  - T5 answered "translate to Spanish" in German;
  - the Ollama notebook failed because Ollama was never installed.
- **Sentiment analysis:** DistilBERT got 7 of 11 definite probes right. It **failed on sarcasm**, which every chat model got right.
- **LLM comparison (score out of 12):**

  | Model | Score |
  |---|---|
  | GPT | 12 |
  | Claude | 12 |
  | Qwen3.8-27B | 12 |
  | Nemotron-3-Super-120B | 11.5 |
  | Gemma-4-31B | 11 |
  | **Mistral-7B (local)** | **8.5** |
  | LFM-2.5-2.6B | 8.5 |

  **The local Mistral** got an arithmetic question wrong, **invented a summary of a non-existent paper**, and followed only 4 of 8 format instructions. It ran at about 13.8 tokens per second on a laptop, for free and offline. **Gemma-4-31B also fabricated the paper**, so refusing to answer an unanswerable question is not guaranteed by model size.

## What I learned

- **One building block, three families.** Encoder-only, decoder-only and encoder-decoder Transformers share the same attention block. What distinguishes them is the **mask** (bidirectional vs causal) and **what the model is trained to predict**. That is why they suit understanding, generation or sequence-to-sequence tasks respectively.
- **Each concept has a precise, testable meaning:**
  - the $\sqrt{d_k}$ scaling keeps the softmax from saturating;
  - positional encodings exist because attention is order-blind;
  - the causal mask means the future cannot affect the past.

  All of these were verified numerically, not just described.
- **Attention maps are informative, but they aren't explanations.** Some heads clearly resolve pronouns or align words, but sink tokens and head-averaging hide or distort that.
- **Small task models and large chat models are different tools.** A 67M sentiment classifier is fast and deterministic but misses sarcasm. A 7B+ chat model reads irony but can invent facts.
- **Local LLMs are practical but need checking.** Quantised 7B models run on a laptop, yet they make confident arithmetic errors and hallucinate. Comparing against references and running generated code are the only reliable checks.
- **Reasoning models need token budgets.** With a 1024-token limit, one model spent everything on hidden thinking and returned nothing.

## Running

```bash
pip install -r ../requirements.txt
jupyter notebook solution/
```

The notebooks read the saved model outputs from `solution/data/`, so no model downloads are needed.
