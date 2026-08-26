# Week 3: Search and A\*: Using an LLM as an Engineering Assistant

| | |
|---|---|
| **Question** | [lab-question/search_lab_ex.pdf](lab-question/search_lab_ex.pdf) |
| **Solution** | [solution/Search_AStar_Lab.ipynb](solution/Search_AStar_Lab.ipynb) |
| **Prompts** | [solution/prompts.md](solution/prompts.md) (the four prompts used with the LLM, as the submission asks) |
| **Answers** | [answers-to-questions/answers.md](answers-to-questions/answers.md) (Tasks 0–7, all Think About It boxes, Final Reflection 1–5) |
| **Outputs** | [solution/outputs/](solution/outputs/) |

## Objective

The goal was to formulate warehouse robot navigation as a search problem $\mathcal{P} = (S, A, T, s_0, G, c)$ and design a search agent before touching an LLM. The LLM was then used to generate A\*, and its output was treated as a *hypothesis* to be tested, inspected and validated. After that:

- compare A\* with blind search (BFS);
- investigate experimentally how the heuristic affects A\*: $h = 0$, Euclidean, and $2\times$ Manhattan;
- reflect on what the LLM contributed and what still had to be done by hand.

## What was built

The code uses the Python standard library only.

- **`Warehouse`:** the search problem. It validates the map and provides the initial state, the goal test, and `successors` (the actions, transitions and unit costs).
- **`astar(problem, h)`:** A\* graph search with a `heapq` frontier ordered by $f = g + h$. It has a `g_cost` dictionary, a `closed` set that also skips stale heap entries, parent-pointer path reconstruction, and a pluggable heuristic.
- **`bfs(problem)`:** a blind-search baseline that uses the same problem object and counts expansions the same way.
- **The LLM's first A\* attempt:** kept verbatim and run through the tests, which exposed two bugs.
- **Test oracles:** an independent BFS for the true shortest distance, a path-rules check, and exact $h^*$ via backwards BFS, used for the admissibility and consistency checks.
- **Test maps:** the lab map, the trivial map, the no-solution map, two alternative-path maps, and 50 random 21 × 41 warehouses.

## Key results

- **Original warehouse:** a 40-move shortest path; the maze has only one optimal route.
- **The LLM's A\* ran first time but had two bugs:**
  - **Off-by-one length:** it reported the number of *cells* rather than moves, 41 instead of 40. This was only caught by the trivial one-move test.
  - **Stale-entry re-expansion:** it inflated the "states expanded" metric. This was caught by code inspection, then confirmed with a distinct-state count.
- **A\* vs BFS on the lab map: identical.** Both expand all 64 cells. The maze's true cost (40) is twice the Manhattan estimate (20), so 49 states *must* be expanded and the remaining 15 tie. A\*'s advantage depends on how informative the heuristic is *on the specific map*.
- **Heuristic investigation on 50 random warehouses:**

  | | $h = 0$ | Euclidean | Manhattan | 2 × Manhattan |
  |---|---|---|---|---|
  | Mean states expanded | 405 | 285 | 226 | 101 |
  | Suboptimal paths | 0 | 0 | 0 | **17 / 50** |

## What I learned

- **Formulate first, then implement.** The state definition, unit costs and goal test decide which algorithms are valid and what "correct" means. They are also what the LLM's code gets checked against.
- **A\* is only as smart as its heuristic.** On a maze where the estimate is half the true cost, A\* = BFS. On open floor, Manhattan cuts expansions by about 45% while staying optimal.
- **Admissibility is the line between "slow but right" and "fast but wrong".** Underestimating heuristics degrade towards blind search. Overestimating ones find paths faster but not always the shortest. Among admissible heuristics, larger is better (Manhattan > Euclidean > 0).
- **Details change the metrics.** Goal test at expansion, skipping stale heap entries, and tie-breaking (28 vs 10 expansions in an open room) change the measurements without changing the answer. They have to be pinned down before comparing algorithms.
- **Working output ≠ validated algorithm.** Tests with known answers (the trivial map) and independent oracles caught bugs that plausible-looking output hid. The LLM was an excellent first-draft generator and explainer, but responsibility for correctness stayed with me.

## Running

```bash
jupyter notebook solution/Search_AStar_Lab.ipynb
```

Uses the Python standard library only. The random warehouses are seeded, so all results are reproducible.
