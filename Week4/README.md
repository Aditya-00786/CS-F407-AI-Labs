# Week 4: Logical Reasoning for Planning

| | |
|---|---|
| **Question** | [lab-question/logic_lab_ex.pdf](lab-question/logic_lab_ex.pdf) |
| **Solution** | [solution/Logic_Planning_Lab.ipynb](solution/Logic_Planning_Lab.ipynb) |
| **Prolog** | [solution/planner.pl](solution/planner.pl) (optional Tasks 6–8, run with SWI-Prolog) |
| **Prompts** | [solution/prompts.md](solution/prompts.md) |
| **Answers** | [answers-to-questions/answers.md](answers-to-questions/answers.md) (Tasks 0–8, all Think About It boxes, Reflection Q1–7, Prolog reflection Q1–4) |
| **Outputs** | [solution/outputs/](solution/outputs/) |

## Objective

A warehouse robot must carry a package from $A$ to $C$ (connections $A \leftrightarrow B \leftrightarrow C$). The lab frames this as a planning problem $(I, A, G)$ and shows that **Logic + Search = Planning**:

- **Logic** decides whether an action is applicable ($S \models \text{Pre}(a)$) and what it changes.
- **Search** explores sequences of applicable actions.

An LLM generates the planner, and the lab's focus is on testing that output and verifying it *independently*: by executing plans against the specification, and optionally with Prolog as a separate logical checker.

## What was built

- **STRIPS-style model:** an `Action` with positive/negative preconditions and add/delete effects, plus `applicable` (the entailment test) and `apply` ($(S \setminus \text{Del}) \cup \text{Add}$). There are 10 ground actions, grounded from the explicit connection list.
- **`validate_plan`:** an independent executor that replays a plan against the *specified* action set and reports the first failing step and the missing fact.
- **The LLM's planner:** kept verbatim (action class, BFS over `frozenset` states, printing), tested, and then corrected through the specification.
- **Tests:** A (solvable), B (impossible), C (irrelevant actions, where the robot can reach C but the package can't), C2, D (goal already true) and E (reverse delivery). A mutation check shows that Test C would catch a wrong goal test.
- **Prolog (`planner.pl`):**
  - the Task 6–8 facts and rules;
  - a cycle-safe `reachable/2`;
  - a full STRIPS plan verifier `valid_plan/3` with `first_failure/4`;
  - all queries executed from the notebook in SWI-Prolog 10.0.2.

## Key results

- **Plan:** `PickUp(Package,A), Move(A,B), Move(B,C), Drop(Package,C)` (4 steps; BFS explores 12 reachable states).
- **The lab's own example sequence is invalid.** `Move(A,B), PickUp(Package,B), …` fails at step 2, because the package is still at A.
- **The LLM's planner was mechanically correct but assumed that every location is connected.** It returned `PickUp(Package,A), Move(A,C), Drop(Package,C)`, which looks fine but uses a corridor that doesn't exist. Tests A and C2 failed on it; B and C passed.
- **Asking the LLM to verify its own plan didn't help.** It "verified" the invalid plan, and its reasoning was consistent with its own wrong assumptions. The independent executor and Prolog (`valid_move(a,c)` → `false`, `valid_plan` fails at `move(a,c)`) both rejected it.
- **Prolog confirms the corrected plan.** It is the only valid plan of length ≤ 4, and Prolog finds that plan by searching on its own.

## What I learned

- **Planning = logic + search.** Logic answers exact local questions (applicable? next state? goal?), and search chooses which sequence to explore. This is the same BFS as in the search labs, but with the successor function derived from action schemas.
- **The specification is the problem.** The preconditions, effects and connectivity have to be written down before prompting. Any gap in them (connectivity, here) gets filled with an LLM's plausible assumption.
- **"Looks reasonable" ≠ valid.** Both the lab's example and the LLM's plan read naturally, and both are invalid. Only step-by-step execution against the action definitions shows this.
- **Tests must be able to fail.** Test C only proves something because a mutated goal test would fail it.
- **A generated explanation is not an independent verification.** A self-explanation inherits the generator's assumptions. An independent checker built from the specification (a Python executor or Prolog rules) does not.
- **Prolog is facts + rules → inference.** A query asks whether the conclusion is entailed by the knowledge base, and `false` means "not provable" (closed world). Its procedural features, such as depth-first search, mean care is needed with recursion over symmetric relations.

## Running

```bash
brew install swi-prolog      # only needed for the optional Prolog cells
jupyter notebook solution/Logic_Planning_Lab.ipynb
```

The Python parts use only the standard library. The Prolog cells call `swipl` on `planner.pl`, which can also be used interactively (`swipl solution/planner.pl`).
