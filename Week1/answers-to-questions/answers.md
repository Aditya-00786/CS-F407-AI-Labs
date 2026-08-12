# Week 1: Answers to the Lab Questions

**Lab:** Neural Models: Learning, Depth, Activations, and Output Layers ([question PDF](../lab-question/neur_models_lab_ex.pdf))
**Code and full outputs:** [solution/Neural_Models_Lab.ipynb](../solution/Neural_Models_Lab.ipynb)

This page collects every question in the lab sheet: the task checkpoints, the five "Think About It" boxes, and Reflection Questions 1–7. All numbers come from the notebook, which uses PyTorch, full-batch SGD with lr = 1.0 for 5000 steps, and seed 0 unless stated otherwise.

---

## Task 1: Understand the problem before coding

**1. Input space, output space, examples.**
- Input space $\mathcal{X} = \{0,1\}^2$: the two sensor readings.
- Output space $\mathcal{Y} = \{0,1\}$: whether to raise the disagreement warning.
- The target is $y = x_1 \oplus x_2$, and the four examples are the entire input space:

| $x_1$ | $x_2$ | $y$ |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

**2. Sketch.** The positives $(0,1), (1,0)$ lie on one diagonal of the unit square and the negatives $(0,0), (1,1)$ on the other ([plot](../solution/outputs/xor_points.png)).

**3. Why one straight line cannot separate them.** Any line that puts both positives on one side also puts at least one negative there. Algebraically, a linear rule $w_1x_1 + w_2x_2 + b > 0$ would need:
- $b \le 0$ (for $(0,0)$),
- $w_1 + b > 0$ and $w_2 + b > 0$ (for the two positives),
- $w_1 + w_2 + b \le 0$ (for $(1,1)$).

Adding the two middle conditions gives $w_1 + w_2 + b > -b \ge 0$, which contradicts the last one.

**4. Prediction for one affine map + sigmoid.** It cannot classify all four points correctly. More specifically, BCE training should converge to $w = 0, b = 0$, predicting $p = 0.5$ for every input with loss $\ln 2 \approx 0.693$:
- at $w = b = 0$, the gradient $\sum_i (p_i - y_i)x_i = 0.5[(0,0) - (0,1) - (1,0) + (1,1)] = 0$ and $\sum_i (p_i - y_i) = 0$;
- the loss is convex, so this stationary point is the global minimum.

**Observed:** the final loss was 0.693147, the weights were about $10^{-7}$, and all four probabilities were 0.5. A four-layer *deep linear* network (609 parameters) ended in exactly the same place.

### Think About It: what claim about representation does XOR test with four points?

That **the kind of representation, not the number of parameters, determines what a model can express**. XOR is the smallest problem that is not linearly separable in input space, so it cleanly tests the claim that a network needs a *nonlinear hidden representation*, in which the classes become separable. The 609-parameter deep linear network fails exactly like 3-parameter logistic regression, because both are affine maps. With four noise-free points and no generalisation question, the result is unambiguous: either the representation can express the function or it cannot.

---

## Task 2: Design the intelligent agent

**Model:** $2 \to 2 \to 1$, with $h = f(W^{(1)}x + b^{(1)})$ and $z = W^{(2)}h + b^{(2)}$, giving $P(y=1 \mid x) = \sigma(z)$ and label $= [z > 0]$.
- 9 parameters in total;
- tanh hidden activation as the baseline (sigmoid and ReLU compared in Task 4D);
- mean BCE loss via `BCEWithLogitsLoss` on the logit;
- full-batch SGD, PyTorch default random initialisation, fixed seed.

**1. Why is the hidden nonlinearity scientifically necessary?** Without it the network collapses to $W^{(2)}W^{(1)}x + \text{const}$, a single affine map, so the boundary is a line and XOR is impossible. The nonlinearity lets the hidden layer re-map the inputs into a space where they *are* linearly separable. The output layer then draws a line in that space.

**2. Why is sigmoid + BCE a sensible pairing?** The target is a single yes/no answer, i.e. a Bernoulli variable.
- The sigmoid turns a logit into a valid probability.
- BCE is exactly the Bernoulli negative log-likelihood, so training is maximum-likelihood estimation.
- The gradient at the logit is simply $\sigma(z) - y$. It is large when the model is confidently wrong, and it does not vanish when the sigmoid saturates (unlike MSE on a sigmoid).
- `BCEWithLogitsLoss` computes this stably from the logit.

**3. Validation criteria.**
1. Final loss $< 0.05$, well below the linear plateau $\ln 2$.
2. All four labels correct, with probabilities clearly on the right side of 0.5.
3. The first-layer gradient is non-zero at initialisation, matches both a hand-derived chain rule and finite differences, and shrinks at convergence.
4. The learned hidden representation is linearly separable.
5. The success rate is reported over repeated seeds.

### Think About It: the hidden units have no targets, so what determines what they compute?

**Backpropagation does, starting from the output loss.** The output error $\delta^{(2)} = \sigma(z) - y$ is sent back through the output weights, $\partial L/\partial h = W^{(2)\top}\delta^{(2)}$, and scaled by $f'(a^{(1)})$. Each hidden unit is therefore pushed in whatever direction most reduces the *final* loss, given what the other unit and the output layer are doing at the time. What it ends up computing depends jointly on the loss (the task), the architecture, and the random initialisation, which is what breaks the symmetry between units. In the seed-0 run the two hidden units learned **OR** and **NAND**, and XOR = OR ∧ NAND.

---

## Task 3: Use an LLM to generate a first implementation

**Prompt (summary; the exact text is in the notebook):** minimal PyTorch code with:
- the four XOR examples as float tensors;
- `Linear(2,2)` → tanh → `Linear(2,1)`, with `forward` returning the **logit**;
- `BCEWithLogitsLoss`;
- default random initialisation after `torch.manual_seed(0)`;
- full-batch SGD, lr 1.0, 5000 steps;
- reporting of the final loss, the four probabilities, the thresholded labels, and the first-layer weight gradient, with a one-sentence explanation of each test.

**Inspection.**
- The forward pass is `model(X)`.
- The scalar loss is `loss_fn(model(X), y)`.
- Reverse-mode AD is `loss.backward()`.
- The optimiser changes the parameters in `opt.step()`, after `opt.zero_grad()`.

**Two changes made before execution.**

1. **Double sigmoid.** The generated `forward` returned `torch.sigmoid(self.out(h))` and then fed it to `BCEWithLogitsLoss`, which applies a second sigmoid. The effective probability $\sigma(\sigma(z))$ is confined to $(0.5, 0.731)$, and the loss cannot go below 0.503. The generated code was also confused about its variables: the one named `logits` held probabilities, and its "probabilities" were always above 0.5.

   Running the uncorrected version confirmed the problem. The loss stalled at 0.598, the specified `probs > 0.5` rule labelled every input 1, and the code's own `logits > 0.5` line got only 3 of 4 right.

   **Fix:** `forward` returns the raw logit; probabilities are `sigmoid(logit)`; labels are `prob > 0.5`.
2. **Stale reporting.** The loss and gradient printed after the loop came from *before* the final `opt.step()`. **Fix:** recompute the final loss with a fresh forward pass, and record the gradients explicitly.

### Think About It: what can be verified from the code, and what needs execution?

**From the code alone:**
- the data matches the truth table, with the right dtypes and shapes;
- the architecture is 2–2–1 with the chosen activation;
- the output and loss agree (logit + `BCEWithLogitsLoss`, no extra sigmoid);
- the thresholding rule is right;
- the order zero_grad → forward → loss → backward → step is correct;
- a seed is set and the requested quantities are printed.

This is how the double sigmoid was found.

**Only by running and measuring:**
- whether the loss actually decreases, and how far;
- whether all four labels come out right;
- whether a given seed gets stuck in a local minimum;
- the size of the gradients;
- whether autograd matches the chain rule;
- whether symmetric weights stay identical;
- how the activations compare;
- whether softmax overflows.

The code says *which experiment* is being run; only execution says *what happened*.

---

## Task 4: Execute, test, and diagnose

### Part A: Basic learning check

| $x_1$ | $x_2$ | $y$ | $P(y=1 \mid x)$ | label |
|---|---|---|---|---|
| 0 | 0 | 0 | 0.0008 | 0 |
| 0 | 1 | 1 | 0.9996 | 1 |
| 1 | 0 | 1 | 0.9996 | 1 |
| 1 | 1 | 0 | 0.0009 | 0 |

- **Loss:** 0.7152 initially, 0.00064 after training.
- **Labels:** all four correct.
- **Hidden representation:**
  - $h_1 \approx -1$ only for $(0,0)$, so it computes OR;
  - $h_2 \approx -1$ only for $(1,1)$, so it computes NAND;
  - in $(h_1, h_2)$ space, one line separates the classes.
- **Repeated runs:** the same 2–2–1 design solved XOR on only **11 of 20 seeds**. Every failed run stalled at loss $\approx 0.347 = \tfrac12 \ln 2$, with two inputs fit and two left at $p = 0.5$: the minimal network has local minima.

The task and architecture were not changed to hide this; the variability is reported instead.

### Part B: Backpropagation check

`parameter.grad` after `backward()` holds $\partial L / \partial\theta$ at the current parameters. So `net[0].weight.grad[j, k]` $= \partial L / \partial W^{(1)}_{jk}$: the rate at which the mean loss changes with the weight from input $k$ to hidden unit $j$. It has the same $2 \times 2$ shape as $W^{(1)}$.

At initialisation, the autograd gradient was

$$\frac{\partial L}{\partial W^{(1)}} = \begin{pmatrix} 0.0005 & 0.0006 \\ -0.0426 & -0.0448 \end{pmatrix}.$$

It agreed to about $10^{-7}$ with:
1. the hand-derived chain rule, $\delta^{(1)} = (W^{(2)\top}\delta^{(2)}) \odot (1 - h^2)$ and $\partial L/\partial W^{(1)} = \delta^{(1)\top} X$;
2. central finite differences in float64;
3. the mean of the four per-example gradients.

The norm fell from 0.062 to $9 \times 10^{-5}$ over training.

**Why is the gradient the average of the example-wise gradients?** `BCEWithLogitsLoss` averages: $L = \frac1N \sum_i \ell_i$. Differentiation is linear, so $\nabla L = \frac1N \sum_i \nabla \ell_i$. The per-example gradients also show that $(0,0)$ contributes exactly zero to $\partial L/\partial W^{(1)}$, because the weight gradient is $\delta x^\top$ and $x = 0$.

### Part C: Symmetry experiment

| Initialisation | Rows of $W^{(1)}$ identical? | What happened | Final loss | 4/4? |
|---|---|---|---|---|
| all zeros, tanh | yes, at every step | every gradient is exactly 0; nothing moves | 0.6931 | no |
| all zeros, sigmoid | yes, at every step | every gradient is exactly 0; nothing moves | 0.6931 | no |
| all 0.5, tanh | yes, at every step | rows move 0.5 → 4.9 in lock-step | 0.4778 | no |

**Explanation.** Identical hidden units compute the same output, $h_1 = h_2$, so they receive the same backpropagated error, the same gradient and the same update. By induction they remain identical forever. The network then behaves like a single hidden unit, whose decision boundary is a line, so XOR is unsolvable.

All-zero initialisation is the extreme case: with $z = 0$, $p = 0.5$ everywhere and the classes are balanced, so $\sum_i (p_i - y_i) = 0$. Together with $W^{(2)} = 0$, this makes every gradient vanish, and the parameters sit at a stationary point. The 0.5 run shows that the real problem is **symmetry**, not zero.

### Part D: Activation experiment

Same seed, same initial weights and same optimiser for all three; only the hidden activation differs.

| Hidden activation | Final loss | 4/4 correct? | Early $\lVert\nabla_{W^{(1)}}L\rVert_2$ (step 0) | Solved, 20 seeds |
|---|---|---|---|---|
| Sigmoid | 0.0061 | yes | 0.0009 | 15/20 |
| Tanh | 0.0006 | yes | 0.0618 | 11/20 |
| ReLU | 0.4774 | no | 0.0017 | 4/20 |

**Interpretation.**
- **Tanh** has the largest early gradient, because $\tanh'(0) = 1$ and its outputs are zero-centred. It learns fastest: its loss is below 0.1 by step 183.
- **Sigmoid** has a gradient about 70× smaller, because $\sigma' \le 1/4$ and its outputs sit near 0.5. On seed 0 it stays on the $\ln 2$ plateau for about 2000 steps before escaping, but it is the most reliable across seeds.
- **ReLU** fails on seed 0 because a hidden unit dies: its pre-activation becomes $\le 0$ on all four inputs, so $f' = 0$ and it never recovers. That leaves one effective unit. ReLU actually has the largest average gradient over the first 100 steps, so a large early gradient does not guarantee success.

None of this shows that one activation is universally best. The ranking depends on the metric (speed vs reliability), the width, the optimiser and the initialisation.

### Think About It: saturated sigmoid vs dead ReLU

Both give small gradients, but they can be told apart by inspecting the pre-activations $a$ and the local derivative $f'(a)$ on each input:
- **Saturation:** $|a|$ is large (the trained sigmoid net has $a \approx \pm 10$ on some inputs), $f(a)$ is near 0 or 1, and $f'(a)$ is small but non-zero. It is usually limited to some inputs, so the unit still learns from the others.
- **Dead ReLU:** $a \le 0$ on **all** inputs (as for unit 1 of the trained ReLU net), $f'(a) = 0$ exactly, and that unit's gradient row is exactly zero.

---

## Task 5: Three-class extension

**Predictions before accepting the change.**
1. The final weight matrix has shape $3 \times 2$, plus a bias of size 3.
2. There are 3 logits per example, so the output has shape (4, 3).
3. Softmax outputs sum to one because $p_k = e^{z_k}/\sum_j e^{z_j}$: all terms are positive, and the numerators summed over $k$ equal the shared denominator.
4. The logit gradient is $p - y$ because, for true class $c$, $\ell = -z_c + \log\sum_j e^{z_j}$, so $\partial\ell/\partial z_k = p_k - [k = c]$. For a mean loss this is divided by $N$.

**Results.**

| $x$ | class | $P(0)$ | $P(1)$ | $P(2)$ |
|---|---|---|---|---|
| (0,0) | 0 | 0.9997 | 0.0003 | 0.0000 |
| (0,1) | 1 | 0.0001 | 0.9998 | 0.0001 |
| (1,0) | 1 | 0.0001 | 0.9998 | 0.0001 |
| (1,1) | 2 | 0.0000 | 0.0003 | 0.9997 |

- **Loss:** 1.0591 initially, 0.00026 after training.
- **Classification:** all four inputs correct.
- **Softmax sums:** for $x = (0,1)$ the probability vector is $(7.4\times10^{-5},\ 0.99979,\ 1.4\times10^{-4})$, which sums to 1.0.
- **Gradient check:** autograd's logit gradient matched $(p - y)/N$ exactly, and each row sums to 0.
- **Side observation:** this task is linearly separable, since the class is $x_1 + x_2$, the number of active sensors. A softmax with no hidden layer also classifies all four inputs correctly.

**Optional diagnostic.** Adding 100 to all logits leaves PyTorch's softmax unchanged to within $4 \times 10^{-10}$, because $e^{z+c}/\sum e^{z_j+c} = e^z/\sum e^{z_j}$. A naive `exp(z)/sum(exp(z))`, however, already returns `nan` at +100, because $e^{105.6}$ overflows float32 (whose limit is about $e^{88.7}$). Stable implementations subtract $\max_j z_j$ first. That uses the same invariance to make the largest exponent $e^0 = 1$, so nothing overflows and the denominator is at least 1.

**Explanation of $p - y$.** The gradient moves each logit by how much the predicted probability exceeds the target:
- the true class's logit is pushed up by $1 - p_c$;
- every wrong class's logit is pushed down by $p_k$.

Once the prediction matches the one-hot target, the gradient vanishes.

### Think About It: what stays the same with a vocabulary of tens of thousands?

**Unchanged:**
- the softmax formula and the normalisation of its outputs;
- cross-entropy as the negative log-likelihood;
- the $p - y$ logit gradient;
- shift invariance and max-subtraction;
- averaging over the batch;
- backpropagation below the output.

Next-token prediction is this three-class computation with $K = |V|$.

**Changes dramatically:**
- the output layer becomes $d \times |V|$ (hundreds of millions of parameters, with expensive logits);
- the hidden representation becomes deep transformer stacks with embeddings and attention;
- the input is a variable-length context rather than two bits;
- mixed precision is used (which makes the stability tricks essential), along with weight tying and large-batch engineering;
- decoding strategy (sampling, temperature, top-$p$) becomes a design choice;
- the input space can no longer be tested exhaustively.

---

## Reflection Questions

**1. What did the XOR experiment demonstrate about depth vs nonlinearity?**
Depth without nonlinearity adds no expressive power. The 609-parameter four-layer linear network collapsed to logistic regression's answer ($p = 0.5$ everywhere, loss $\ln 2$), because a composition of affine maps is affine. One hidden layer of just two *nonlinear* units solved XOR, by learning OR and NAND features in which the classes are separable. Nonlinearity is what makes depth useful.

**2. What evidence showed that backpropagation supplied a useful learning signal, not merely a nonzero gradient?**
- The loss fell from 0.715 to 0.0006, far below the $\ln 2$ plateau that every linear model is stuck at.
- All four labels were correct, with probabilities within 0.001 of their targets.
- The hidden layer learned interpretable, separable features (OR and NAND).
- The gradient norm shrank by nearly three orders of magnitude as the model converged.
- Autograd's gradient matched the chain rule and finite differences, so the signal was the correct derivative.

The failures make the contrast: the ReLU run had the largest average early gradient but stalled with a dead unit, and the "all 0.5" run had large non-zero gradients throughout but learned only one feature.

**3. Why did identical/zero weight initialisation prevent the two hidden units from learning distinct features?**
Identical units compute identical activations, receive identical backpropagated errors, and so get identical gradients and updates. Symmetry is preserved at every step, and the rows of $W^{(1)}$ stayed bit-for-bit equal in all three runs. All-zero initialisation is worse still: $p = 0.5$ everywhere, balanced classes and $W^{(2)} = 0$ make *every* gradient exactly zero, so training never moves. Either way the network is effectively one hidden unit with a linear boundary, and random initialisation is what breaks the tie.

**4. How did changing the hidden activation affect the gradient? Distinguish the scientific explanation from the engineering observation.**
- **Engineering observation (seed 0):**
  - tanh had the largest early first-layer gradient (0.062) and converged fastest (below 0.1 by step 183);
  - sigmoid's early gradient was about 70× smaller (0.0009), and it sat on the $\ln 2$ plateau for about 2000 steps before solving XOR;
  - ReLU failed because a unit died.

  Over 20 seeds, sigmoid solved 15, tanh 11 and ReLU 4.
- **Scientific explanation:** the activation enters the backpropagated error as the factor $f'(a)$ in $\delta^{(1)} = (W^{(2)\top}\delta^{(2)}) \odot f'(a^{(1)})$.
  - $\tanh'(0) = 1$, and zero-centred outputs let the error through almost unscaled.
  - $\sigma' \le 1/4$ scales the error down at every sigmoid layer.
  - $\mathrm{ReLU}' \in \{0, 1\}$ passes the error unchanged for active units and blocks it completely for inactive ones. A unit that is inactive on every input is dead.

  The observation is *what the numbers were* for this network and seed. The explanation is *why*, and it predicts when the ranking would change: for example, dead units matter far less in wide networks.

**5. Why must the output layer and loss be selected together according to the task?**
The output activation defines the probability model, and the loss must be that model's negative log-likelihood:
- a yes/no answer is Bernoulli, so a sigmoid output with BCE;
- one-of-$K$ is categorical, so a softmax output with cross-entropy.

Matched pairs give the clean, non-vanishing logit gradient $p - y$ and can be computed stably from logits. Mismatched pairs break, as the LLM's double sigmoid (sigmoid + `BCEWithLogitsLoss`) showed: probabilities were stuck in $(0.5, 0.73)$ and the loss had a floor of 0.503. Similarly, MSE on a sigmoid has vanishing gradients, and softmax over a single output is always 1.

**6. One example where the LLM improved productivity, and one where human verification was essential.**
- **Productivity:** from a written specification, the LLM produced the complete training scaffold (tensors, module, loss, optimiser loop, reporting) and the three-class output/loss change in seconds. That left time for the specification, the tests and the interpretation.
- **Verification was essential:** the generated code put a sigmoid in `forward` *and* used `BCEWithLogitsLoss`, contradicting the prompt. It ran without error and its loss went down (0.70 → 0.60), so it *looked* fine. But the effective probabilities could never go below 0.5, the loss had a floor of 0.503, and the model got at most 3 of 4 inputs right. It was caught by reading the code against the specification before running it, and confirmed by running the uncorrected version. The repeated-seed test was also a human addition: it showed that "works on seed 0" was not the full story (11 of 20 seeds).

**7. Which tests would you keep if the model were scaled up, and which would become too expensive?**
- **Keep** (cheap, scale well):
  - loss curves against a trivial baseline;
  - held-out predictions and accuracy;
  - per-layer gradient-norm monitoring and NaN/inf checks;
  - activation statistics (the fraction of dead and saturated units, as in the Part D diagnostic);
  - softmax normalisation and max-subtraction stability;
  - shape checks and the output/loss pairing;
  - symmetry checks at initialisation;
  - a few repeated seeds.
- **Too expensive:**
  - exhaustive finite-difference gradient checks (two forward passes per parameter, i.e. billions);
  - evaluating the entire input space;
  - per-example gradient averaging on every batch;
  - dozens of full training runs for seed statistics.
- **Scaled-down replacements:** finite differences on a few random coordinates or on a tiny copy of the architecture, and gradient checks on a small batch.
