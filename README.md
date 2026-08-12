# CS F407 Artificial Intelligence: Lab Solutions

Weekly lab solutions for CS F407 (Artificial Intelligence) at BITS Pilani, K K Birla Goa Campus. Click a week's topic to open its folder, which contains:

- **`lab-question/`**: the question PDF;
- **`solution/`**: a Jupyter notebook with the code, outputs and inline answers;
- **`answers-to-questions/`**: the answers to the lab's questions as a standalone Markdown file;
- **`README.md`**: the lab's objective, key results and what was learned.

## Labs

| Week | Topic&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Links | Description&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|:---:|---|---|---|
| 1 | [Neural Models: Learning, Depth, Activations, and Output Layers](Week1/) | [Question](Week1/lab-question/neur_models_lab_ex.pdf)<br>[Solution](Week1/solution/Neural_Models_Lab.ipynb)<br>[Answers](Week1/answers-to-questions/answers.md) | Trains a 2–2–1 PyTorch network on the XOR sensor-disagreement problem, after showing that linear and deep-linear models are stuck at p = 0.5. Checks backprop against the chain rule and finite differences, demonstrates the symmetry problem of identical initialisation, and compares sigmoid, tanh and ReLU. Extends the task to a three-class softmax (p − y gradient, numerical stability) and reflects on verifying LLM-generated code. |

## Running the notebooks

```bash
pip install -r requirements.txt
jupyter notebook
```

Week 1 uses PyTorch, NumPy and matplotlib (CPU only).
