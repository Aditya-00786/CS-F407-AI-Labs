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
| 2 | [Agents: Constructing a Goal-Based Agent using an LLM](Week2/) | [Question](Week2/lab-question/agents_lab.pdf)<br>[Solution](Week2/solution/Warehouse_Agent_Lab.ipynb)<br>[Answers](Week2/answers-to-questions/answers.md) | Specifies the warehouse-navigation problem and designs a goal-based agent (state, goal, transition model, planner), then builds it with an LLM through iterative prompting. The LLM's first BFS program ran but mislabelled every move; replay tests caught this and led to an improved prompt. Validates the final agent (optimality, no-path, malformed maps), compares BFS, A*, greedy and DFS on warehouses up to 112 × 336, and demonstrates replanning when an aisle is blocked. |

## Running the notebooks

```bash
pip install -r requirements.txt
jupyter notebook
```

Week 2 needs only the Python standard library. Week 1 uses PyTorch, NumPy and matplotlib (CPU only).
