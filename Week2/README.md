# Week 2: Agents: Constructing a Goal-Based Agent using an LLM

| | |
|---|---|
| **Question** | [lab-question/agents_lab.pdf](lab-question/agents_lab.pdf) |
| **Solution** | [solution/Warehouse_Agent_Lab.ipynb](solution/Warehouse_Agent_Lab.ipynb) |
| **Answers** | [answers-to-questions/answers.md](answers-to-questions/answers.md) (Task 1 Q1–5, Think About It, Task 2 design and block diagram, Task 3 Q1–4) |
| **Outputs** | [solution/outputs/](solution/outputs/) |

## Objective

An autonomous warehouse vehicle must find a collision-free route from the loading bay `S` to the dispatch area `G` on a grid with shelving, moving Up/Down/Left/Right one square at a time. The lab is less about Python and more about AI engineering:
- **Specify** the problem: environment, goal, actions, state.
- **Design** a goal-based agent.
- **Build** it with an LLM as a software-engineering assistant, improving the program through iterative prompting.
- **Test and validate** the generated code.
- **Evaluate** the strengths and limits of LLM-assisted development.

## What was built

The code uses the Python standard library only.

- **`Warehouse` (environment):**
  - validates and parses the map;
  - provides the transition model (`successors`);
  - executes moves with collision detection (`step`);
  - renders a path onto the map.
- **`GoalBasedAgent`:** keeps its current state and goal, plans with a pluggable search algorithm, executes the plan one action at a time, and replans when a move is blocked.
- **Planners:** BFS (the LLM's choice), plus A* (Manhattan heuristic), greedy best-first and DFS for comparison.
- **The LLM's first attempt:** kept verbatim, tested, and shown to be wrong. That led to an improved prompt and the final implementation.
- **Tests:**
  - replaying the plan against the lab's action definitions;
  - optimality against an independent BFS distance from `G`;
  - the no-path case;
  - malformed maps;
  - a trivial one-step map.
- **Experiments:**
  - strategy comparison on the given map;
  - a 2 × 2 tiled ("twice as large") warehouse;
  - random warehouses up to 112 × 336;
  - a replanning demo in which a pallet blocks the aisle mid-route.

## Key results

- **Shortest route:** 20 moves (`Right ×3, Down, Right ×3, Up, Right ×12`). There are exactly 2 shortest routes.
- **The LLM's first program ran, but gave wrong directions.** It stored moves as (x, y) but applied them to (row, col), so every action was mislabelled. The path *length* was right, but a vehicle following it would crash on move 6. Only a replay test caught this.
- **Search strategies:**

  | | BFS | A* | Greedy | DFS |
  |---|---|---|---|---|
  | Given map: nodes expanded | 59 | 23 | 21 | 34 |
  | Given map: path length | 20 | 20 | 20 | 22 |
  | 112 × 336: nodes expanded | 20,719 | 5,139 | 698 | 7,050 |
  | 112 × 336: path length | 453 | 453 | 510 | 2,140 |

- **Scaling:** BFS stays correct at any size, and still takes only milliseconds at twice the size. A* finds the same optimal paths with 4× less work at scale. Greedy and DFS give up optimality.

## What I learned

- **Goal-based agents plan with a model.** Explicitly representing the state, the goal and the transition model lets the agent look ahead and search, which a reflex agent cannot do. The same design adapts to a new goal or a changed map just by replanning.
- **Specifying the problem comes before the code.** Deciding the environment properties (fully observable, deterministic, static, discrete) is what justifies uninformed search in the first place. It also tells you when the choice would stop being valid.
- **"It runs" is not "it works".** The LLM's program ran and printed a plausible path of the right length, but every direction was wrong. Tests derived from the specification, such as replaying the plan with the defined action semantics, catch errors that eyeballing output misses.
- **Better prompts state the conventions and the tests.** Most LLM errors came from what the first prompt left implicit (coordinate conventions, input validation, output format). Iterating works best when you feed back the specific failing test.
- **Algorithm choice depends on scale and requirements.** BFS is optimal and simple for small uniform-cost grids. A* is the better choice as maps grow. Real warehouses add non-uniform costs, other vehicles and replanning. The LLM chose the typical textbook answer; judging when it stops being adequate is still the engineer's job.

## Running

```bash
jupyter notebook solution/Warehouse_Agent_Lab.ipynb
```

This week uses the Python standard library only. The random warehouses are seeded, so the results are reproducible; only the millisecond timings vary between machines.
