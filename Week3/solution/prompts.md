# Week 3: Prompts used with the LLM

The lab asks for the important prompts in an appendix or a separate file. These are the four prompts used, in order. How each response was tested and what was changed is described in [Search_AStar_Lab.ipynb](Search_AStar_Lab.ipynb) (Tasks 2–6).

## Prompt 1: generate A* (Task 2)

> I am implementing a simple goal-based search agent in Python.
> The environment is a grid represented by an ASCII map. The agent starts at S and must reach G. The symbols # represent obstacles and . represents free cells. The agent can move up, down, left, or right, and every movement has cost 1.
> Implement A* search. Use Manhattan distance as the heuristic: h(n) = |x − x_G| + |y − y_G|.
> The program should:
> - represent grid positions as states;
> - maintain an appropriate frontier;
> - calculate g(n), h(n) and f(n);
> - avoid repeatedly expanding the same state;
> - reconstruct the path when the goal is reached;
> - report the path and its length;
> - report the number of states expanded.
>
> Keep the implementation simple and explain the main components of the code.
>
> Design constraints: states are (row, col) tuples; the map is a list of strings indexed grid[row][col]; the frontier is a priority queue ordered by f = g + h; the goal test happens when a state is removed from the frontier; the path is reconstructed from parent pointers.
>
> Here is the map:
> ```
> #################
> #S....#.........#
> #.###.#.#######.#
> #...#.#.......#.#
> ###.#.#######.#.#
> #...#.........#.#
> #.###########.#.#
> #.............#G#
> #################
> ```

**Response:** `astar_first_attempt` in the notebook. It was accepted for testing, not for use.

## Prompt 2: fix the bugs found by testing (Task 3/4)

> Two problems with your A* code:
> 1. On the map `#####` / `#SG##` / `#####` it reports length 2, but the solution is one move. Report the path length as the number of moves (`len(path) - 1`), and also return the list of actions.
> 2. When a state is pushed onto the heap more than once, the old entry is popped later and expanded again and counted again in `expanded`. When a popped state is already in the closed set, skip it before incrementing `expanded`.
>
> Also: make the heuristic a parameter `h(state, goal)` so I can try other heuristics; store f explicitly in each heap entry; break ties with an insertion counter instead of comparing states; validate the map (rectangular, exactly one S and one G, only `#.SG`); and return a result object with `found`, `path`, `actions`, `length` and `expanded`. Do not change anything else about the algorithm.

**Response:** it became the `astar` / `Warehouse` / `SearchResult` code in the notebook. It passed all the Task 3 tests.

## Prompt 3: BFS version (Task 5)

> Using the same `Warehouse` problem class and `SearchResult` record, write breadth-first search for the same agent. Use a FIFO queue, a reached set with parent pointers, and do the goal test when a state is removed from the queue, so that "states expanded" is counted the same way as in A*. Do not change the warehouse.

**Response:** `bfs` in the notebook, accepted after it matched the oracle on all the test maps.

## Prompt 4: explain the heuristic (Task 6)

> Explain why Manhattan distance is an appropriate heuristic for this warehouse when the robot can move only horizontally and vertically. Is it admissible? Is it consistent? How does it compare with Euclidean distance?

**Response (summary):**
- Manhattan distance equals the exact cost when there are no obstacles, since each move changes one coordinate by 1.
- It is admissible, because obstacles only add moves.
- It is consistent, because one move changes h by at most 1 and costs 1.
- It dominates Euclidean distance.

Each claim was then checked experimentally in Task 6: an admissibility and consistency check over every state, the open-room test, and the heuristic comparison on the lab map and on 50 random warehouses.
