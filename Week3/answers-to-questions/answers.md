# Week 3: Answers to the Lab Questions

**Lab:** Search and A\*: Using an LLM as an Engineering Assistant ([question PDF](../lab-question/search_lab_ex.pdf))
**Code and full outputs:** [solution/Search_AStar_Lab.ipynb](../solution/Search_AStar_Lab.ipynb) · **Prompts:** [solution/prompts.md](../solution/prompts.md)

```
#################
#S....#.........#
#.###.#.#######.#
#...#.#.......#.#
###.#.#######.#.#
#...#.........#.#
#.###########.#.#
#.............#G#
#################
```

---

## Task 0: Understand the Search Problem

| Component | Specification |
|---|---|
| State $S$ | the robot's position $(r, c)$ on a free cell: $\{(r,c) : \text{map}[r][c] \ne \#\}$, which is 64 states |
| Actions $A$ | Up $(-1,0)$, Down $(+1,0)$, Left $(0,-1)$, Right $(0,+1)$; $A(s)$ = those whose target cell is in the grid and free |
| Transition $T$ | $T((r,c),a) = (r + \Delta r_a,\ c + \Delta c_a)$ for $a \in A(s)$; deterministic |
| Initial state $s_0$ | $(1, 1)$, the position of `S` |
| Goal $G$ | $\{(7, 15)\}$, the position of `G`; goal test $s = (7,15)$ |
| Cost $c$ | $c(s,a,s') = 1$ per move; path cost = number of moves |

**(a) What information is necessary to specify a state?**
Only the position $(r, c)$. The map, goal and costs are fixed parts of the problem, and nothing else (battery, orientation, load) is modelled. Two routes that arrive at the same cell therefore reach the same state, which is why duplicate detection is valid.

**(b) What makes an action invalid?**
Its target cell is an obstacle `#`, or lies outside the grid.

**(c) Is this a deterministic search problem?**
Yes. Each applicable action has exactly one successor. The problem is also fully observable, static and discrete, so the complete plan can be computed in advance.

**(d) What would constitute a solution?**
A sequence of applicable actions leading from $(1,1)$ to $(7,15)$, i.e. a chain of adjacent free cells. An **optimal** solution minimises the number of moves. If `G` is unreachable, the correct output is a report that no solution exists.

---

## Task 1: Plan the Agent

1. **State representation:** a `(row, col)` tuple, which is immutable and hashable, so it can serve as a dictionary key or set member.
2. **Warehouse representation:** a list of strings `grid[row][col]`, validated to be rectangular, with exactly one `S` and one `G` and only `#.SG`. `S` and `G` are located while parsing.
3. **Valid actions:** an `ACTIONS` table of displacements. `successors(state)` yields `(action, next_state, cost)` for in-bounds, non-`#` targets.
4. **Goal recognition:** `state == goal`, tested when a state is **popped for expansion**. This is required for A\* to be optimal.
5. **Frontier contents:** a heap of entries `(f, tie_break_counter, state)`. `g` is stored in a `g_cost` dictionary, and expanded states in a `closed` set. A cheaper path pushes a new entry, and stale entries are skipped when popped.
6. **Path reconstruction:** a `parent` dictionary maps each state to `(previous_state, action)`. When the goal is expanded, follow the parents back to `S` and reverse.

**Reported on termination:** whether a solution was found, the path (cells and actions), the path length **in moves**, and the number of states **expanded**.

---

## Task 2: Ask an LLM to Generate A\*

The lab's example prompt was used, extended with the Task 1 design constraints (prompt 1 in [prompts.md](../solution/prompts.md)). The generated program ran first time and reported "found, length 41, expanded 64". It was then tested before being accepted.

---

## Task 3: Test the Generated Program

The oracles:
- an independently written BFS, for the true shortest length;
- a rules check that the path starts at `S`, ends at `G`, and moves only to adjacent free cells;
- hand-known answers for Tests 2 and 3.

| Test | LLM first attempt | Corrected A\* |
|---|---|---|
| 1. Original warehouse (true shortest: 40) | **FAIL**: reports length 41 | PASS: found, 40 moves, 64 states expanded |
| 2. Trivial `#SG##` (1 move) | **FAIL**: reports length 2 | PASS: found, 1 move (`Right`), 2 expanded |
| 3. No solution | PASS: reports failure, no infinite loop | PASS: reports failure after expanding all 9 reachable cells |
| 4a. Two routes, 4 vs 8 moves | **FAIL**: reports 5 | PASS: 4 moves, the shorter route, 5 expanded |
| 4b. Open room (84 equal shortest paths) | **FAIL**: reports 10 | PASS: 9 moves = Manhattan distance, 28 expanded |

**Test 1, full result:** a path was found. It is 40 moves long, with 64 states expanded:
`Right ×4, Down ×4, Right ×8, Up ×2, Left ×6, Up ×2, Right ×8, Down ×6`.

```
#################
#S****#*********#
#.###*#*#######*#
#...#*#*******#*#
###.#*#######*#*#
#...#*********#*#
#.###########.#*#
#.............#G#
#################
```

**What testing found:**
- **Off-by-one path length.** The first attempt reported `len(path)`, the number of *cells* including `S`, so every length was one too high. Only Test 2, whose answer is obvious, made this visible: "41" on the real map looks plausible. The paths themselves were valid and optimal.
- **Stale heap entries were re-expanded** (found by inspection in Task 4e). A state pushed twice was popped and counted twice. With $h = 2\times$ Manhattan, the counter said 65 "expanded" for 64 distinct states.

**Think About It: working output ≠ validated algorithm.** The first attempt's output was plausible and partly wrong. Test cases with known expected behaviour, and comparisons against independent quantities, are what showed the difference.

**Side lesson from Test 4b.** In an empty room every cell ties at $f = 9$. First-in-first-out tie-breaking expands all 28 cells, while breaking ties towards larger $g$ expands only 10. Tie-breaking changes the effort but not the path length.

---

## Task 4: Inspect the A\* Algorithm

| Concept | Where it appears in the code |
|---|---|
| State | a `(row, col)` tuple: `Warehouse.initial`, and `state` / `nxt` in `astar` |
| Action | the `ACTIONS` dictionary (name → displacement); `action` in `successors` |
| Transition | `Warehouse.successors`: computes `(r + dr, c + dc)` and keeps in-bounds, non-`#` cells |
| Goal test | `Warehouse.is_goal`, called in `astar` right after a state is popped |
| $g(n)$ | the `g_cost` dictionary; `new_g = g_cost[state] + cost` |
| $h(n)$ | the heuristic parameter `h` (default `h_manhattan`), called as `h(nxt, goal)` |
| $f(n)$ | `f_nxt = new_g + h(nxt, goal)`, stored first in each heap entry |
| Frontier | `frontier`: a list used as a min-heap via `heapq.heappush` / `heappop` |
| Visited states | the `closed` set; stale heap entries for closed states are skipped |
| Path reconstruction | the `parent` dictionary and `reconstruct()` |

**(a) What data structure is used for the A\* frontier?**
A binary min-heap (priority queue) from Python's `heapq`, holding `(f, counter, state)` tuples.

**(b) How does the program select the next state to expand?**
`heappop` removes the entry with the smallest $f$, with ties going to the earliest-inserted entry. If that state is already closed, the entry is stale and is skipped.

**(c) Where is the heuristic calculated?**
When a successor is generated and pushed (`h(nxt, goal)`), and once for the start state.

**(d) Does the program explicitly calculate $f(n) = g(n) + h(n)$?**
Yes: `f_nxt = new_g + h(nxt, goal)`. The LLM's first attempt computed it inline inside `heappush`, without naming it.

**(e) How does the program prevent unnecessary repeated exploration?**
- the `closed` set: an expanded state is never expanded again, and closed successors are not pushed;
- the `g_cost` check: a successor is pushed only if its new path is strictly cheaper;
- skipping stale entries when they are popped.

The first attempt lacked the third mechanism, so it could re-expand a state and double-count it.

---

## Task 5: Compare A\* with Blind Search

| Measure | BFS | A\* (Manhattan) |
|---|---|---|
| Solution found | yes | yes |
| Path length | 40 | 40 |
| States expanded | 64 | 64 |

**(a) Did both algorithms find a solution?** Yes.

**(b) Did they find paths of the same length?** Yes, 40 moves, and in fact the same path (it is the only optimal path).

**(c) Which algorithm expanded fewer states?** **Neither.** Both expanded all 64 free cells.

**(d) Why might A\* expand fewer states?**
In general, A\* uses the heuristic to postpone states that look far from the goal. It must expand only the states with $g^*(n) + h(n) < C^*$ (plus ties), while BFS expands everything closer to `S` than the goal is.

On *this* map the heuristic is badly misleading:
- The warehouse is a maze with a single route, and the true cost (40) is **twice** the Manhattan estimate from `S` (20).
- As a result, 49 of the 64 states have $g^* + h < 40$, so A\* is *forced* to expand them. The other 15 tie at $f = 40$ and are expanded before the goal.
- BFS also expands everything, because `G` is the farthest cell from `S`.

On the random warehouses in Task 6, which have open floor and alternative routes, A\* expands about 45% fewer states than BFS (226 vs 405).

**Think About It: what information does each algorithm use to decide where to search next?**
- **BFS** uses only the discovery order, i.e. depth $g$. It uses no knowledge of where the goal is.
- **A\*** adds $h(n)$, an estimate of the remaining cost.

A\* is only "more intelligent" to the extent that $h$ is informative on the actual map. On this maze it is not.

---

## Task 6: Investigate the Heuristic

**Why Manhattan distance is appropriate** (the LLM's explanation, verified experimentally):
- **Exact without obstacles.** Each move changes one coordinate by 1, so at least $|dr| + |dc|$ moves are needed. Confirmed by Test 4b, where the path length equals the Manhattan distance.
- **Admissible.** Walls only add moves, so $h \le h^*$. Checked for every state.
- **Consistent.** One move changes $h$ by at most 1 and costs 1. Checked for every edge.
- **Dominates Euclidean.** $|dx| + |dy| \ge \sqrt{dx^2 + dy^2}$, so Manhattan is at least as informative.

**Lab warehouse:**

| Heuristic | Found | Length | States expanded | $h > h^*$ at | Inconsistent edges |
|---|---|---|---|---|---|
| $h = 0$ | yes | 40 | 64 | 0 / 64 | 0 |
| Manhattan | yes | 40 | 64 | 0 / 64 | 0 |
| Euclidean | yes | 40 | 64 | 0 / 64 | 0 |
| 2 × Manhattan | yes | 40 | 64 | **18 / 64** | **64** |

The maze has only one sensible route, so no heuristic can change anything here, not even an inadmissible one. To actually answer the questions, the experiment was repeated on 50 random 21 × 41 warehouses with aisles and clutter:

| Heuristic | Found | Mean states expanded | Suboptimal paths | Mean extra moves |
|---|---|---|---|---|
| BFS (reference) | 50/50 | 404.8 | 0/50 | 0.00 |
| $h = 0$ | 50/50 | 404.8 | 0/50 | 0.00 |
| Manhattan | 50/50 | 225.6 | 0/50 | 0.00 |
| Euclidean | 50/50 | 284.7 | 0/50 | 0.00 |
| 2 × Manhattan | 50/50 | 100.9 | **17/50** | 1.76 |

**1. What happens with $h(n) = 0$?**
A\* becomes uniform-cost search, which with unit costs is BFS. It is always optimal, but it expands the most states (405), because it has no information about the goal.

**2. What happens with Euclidean distance?**
Still admissible, so always optimal. But it is smaller than Manhattan whenever both $dx$ and $dy$ are non-zero, so it is less informative and expands more states (285 vs 226).

**3. What happens if the heuristic is multiplied by 2?**
It becomes inadmissible. It expands the fewest states (101), because it drives the search towards `G` like greedy search. But it returned a **longer-than-optimal path on 17 of 50 maps**, up to 6 extra moves in the example shown in the notebook. This is weighted A\*: the path found is guaranteed to be at most 2× optimal.

**Think About It: what happens when the heuristic is too optimistic or too aggressive?**
- **Too optimistic** (underestimating, like $h = 0$ or Euclidean): A\* stays **correct** but gets **slower**, degrading towards blind uniform-cost search.
- **Too aggressive** (overestimating, like 2 × Manhattan): A\* becomes **faster but loses optimality**, because it stops exploring detours whose cost it has overestimated.

Admissibility ($h \le h^*$) is exactly the boundary between the two. The best heuristic is the largest one that never overestimates.

---

## Task 7: Evaluate the LLM-Generated Agent

**1. What parts of the generated code were correct immediately?**
The whole algorithmic core, and every path it returned was valid and optimal:
- the `heapq` frontier ordered by $f = g + h$;
- the Manhattan heuristic;
- `g_score` with the strictly-cheaper update rule;
- the `closed` set for successors;
- the goal test at expansion time;
- `came_from` path reconstruction;
- clean termination when there is no path.

**2. Did you find any bugs or design problems?**
- **Bug 1:** the path length was reported as the number of cells rather than moves (off by one).
- **Bug 2:** stale heap entries were not skipped when popped, so states could be re-expanded and double-counted.
- **Design problems:**
  - the heuristic was hard-wired;
  - there was no input validation (a map without `S` raises `UnboundLocalError`);
  - variables named `(x, y)` actually held `(row, col)`.

**3. How did you discover those problems?**
- Bug 1 came from **Test 2**, the trivial map, which reported length 2 for a one-move solution.
- Bug 2 came from **reading the code for Task 4(e)**. It was confirmed by comparing the expansion counter with the number of *distinct* states expanded (65 vs 64 under 2 × Manhattan).
- The design problems came up when setting up the Task 6 experiments and when testing malformed maps.

**4. Did the LLM use terminology or data structures that you did not understand?**
Two things needed working through:
- `heapq` is a min-heap on *tuples*, so the tuple order silently sets both priority and tie-breaking.
- "Lazy deletion": `heapq` has no decrease-key, so a cheaper path is handled by pushing a new entry and leaving the old one in the heap. That leftover entry is exactly what Bug 2 failed to skip.

"Open set" and "closed set" correspond to the lecture's frontier and explored set.

**5. Did you modify the LLM-generated code?**
Yes. The changes:
- the length is reported in moves, and the actions are returned;
- stale entries are skipped;
- the heuristic is a parameter, with $f$ named explicitly;
- ties are broken by a counter;
- a validated `Warehouse` class mirrors $(S, A, T, s_0, G, c)$;
- a shared `SearchResult` record gives BFS and A\* identical measures.

The algorithmic core was kept.

**6. Which tests were most useful?**
- **Test 2 (trivial map)** was the only one to expose the off-by-one error.
- **The independent BFS oracle and the rules check** turned "plausible" into "verified".
- **Test 4** checked optimality.
- **Test 3** checked termination.
- **The random-map experiments** were essential for Task 6, because the lab map alone gives the same numbers for every heuristic.

**7. Could you have trusted the program without testing it?**
No. It ran first time and looked right, yet its headline length was wrong, and its expansion counter was unreliable in exactly the experiments whose conclusions depend on it. On the lab map, even a *correct* program gives the surprising result "A\* = BFS". Without analysis and extra maps, that result could be wrongly blamed on the code, or used to wrongly conclude that heuristics do not help.

**8. What did you understand about A\* that you did not understand before implementing it?**
- A\* is not automatically faster than BFS; its advantage depends entirely on how informative $h$ is on the map.
- Admissibility has a precise consequence: every state with $g + h < C^*$ must be expanded. This explains both why a weak heuristic is slow and why an inflated one can skip the optimal route.
- The goal test must happen at expansion, not at generation.
- Tie-breaking can change the effort a lot (28 vs 10 expansions in the open room) without changing the answer.
- Implementation details, such as skipping stale entries, determine what the "states expanded" metric actually measures.

### What I designed, what the LLM suggested, and what I accepted, changed and tested

| | |
|---|---|
| **Designed myself** | the problem formulation (Task 0); the representations, goal-test placement, reconstruction and reporting requirements (Task 1); the test plan and oracles; the random-map experiments; the admissibility and consistency checks |
| **Suggested by the LLM** | the first A\* implementation (`heapq` frontier of `(f, g, state)`, `g_score`, `came_from`, `closed`, Manhattan function); the BFS variant; the explanation of why Manhattan suits 4-connected moves |
| **Accepted** | the algorithmic core of A\* and BFS; the Manhattan explanation, after checking each claim |
| **Changed** | length in moves; skipping stale entries; parameterised heuristic with explicit $f$; counter tie-breaking; validated `Warehouse` class; `SearchResult` record |
| **Tested** | Tests 1–4 against the oracles; malformed maps; counted vs distinct expansions; admissibility and consistency over all states; BFS vs A\* and four heuristics on the lab map and on 50 random maps |

---

## Final Reflection

**1. Why is it important to formulate the search problem before writing the search algorithm?**
The formulation fixes what the algorithm may assume and what "correct" means:
- the state being `(row, col)` makes duplicate detection valid;
- unit costs make BFS optimal and Manhattan distance admissible;
- the goal definition says where the goal test belongs.

It is also what generated code gets checked against. Both bugs here were only recognisable as bugs because the specification said "length = number of moves" and "expanded = states popped and processed". An LLM will fill gaps in an underspecified problem with its own guesses.

**2. In what sense is A\* an "informed" search algorithm?**
It uses problem-specific knowledge beyond the problem definition: the heuristic $h(n)$, an estimate of the remaining cost that uses the goal's position. Blind searches order states only by how they were generated (depth or cost so far). A\* orders them by $f = g + h$, the estimated cost of the best solution *through* each state. With an admissible $h$, it focuses effort towards the goal without giving up optimality.

**3. Why does the choice of heuristic matter?**
It controls both efficiency and correctness:
- **Efficiency:** a more accurate admissible heuristic means fewer expansions (Manhattan 226, Euclidean 285, zero 405).
- **Correctness:** an overestimating heuristic can return suboptimal paths (2 × Manhattan did on 17 of 50 maps).
- **Fit to the problem:** the heuristic must match the movement model. Manhattan suits 4-connected moves; with diagonal moves it would overestimate.

The heuristic is where domain knowledge enters the search. On a map like the lab's maze, even a good heuristic buys nothing, so the choice has to be judged against the actual problem.

**4. What did the LLM contribute to the engineering process?**
- a fast, idiomatic, largely correct first implementation of a standard algorithm;
- quick variants (BFS) on request;
- a clear explanation of the heuristic.

That saved most of the typing and let the effort go into specification, testing and experiments. It did not contribute correctness: it shipped an off-by-one error in the headline metric and a subtle counting bug. It also could not have known the map-specific "A\* = BFS" result. Its code and explanations were useful as hypotheses to test, not as conclusions.

**5. What could go wrong if an engineer simply accepted LLM-generated code without testing it?**
Here:
- every reported path length would have been wrong;
- the expansion counts behind the BFS-vs-A\* and heuristic comparisons would have been inflated;
- the conclusions drawn from those comparisons could have been wrong.

In general:
- code that runs and prints plausible output can still violate its specification;
- edge cases (no path, malformed input) can crash or hang;
- subtle issues, such as an inadmissible heuristic or a goal test at generation time, silently return suboptimal answers.

For a real robot that means wrong routes, wrong performance claims, and failures on the first unusual layout, and an engineer who cannot explain the system's behaviour. The engineer, not the LLM, is responsible for validating the system.
