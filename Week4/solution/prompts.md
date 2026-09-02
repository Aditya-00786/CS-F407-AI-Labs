# Week 4: Prompts used with the LLM

The submission asks for the prompt used, and for the LLM-generated or LLM-modified parts to be clearly identified. The three prompts are listed below, in order. The code each one produced, and what was accepted or changed, is marked in [Logic_Planning_Lab.ipynb](Logic_Planning_Lab.ipynb).

## Prompt 1: implement the planner (Task 2)

The lab's suggested prompt, verbatim, followed by the scenario:

> I want to implement a simple planning agent in Python. Represent a state as a set of logical propositions. Each action should contain: a name; positive preconditions; negative preconditions; positive effects; negative effects.
> An action is applicable if all of its preconditions are satisfied by the current state. When an action is applied: 1. remove its negative effects from the state; 2. add its positive effects to the state.
> Use breadth-first search to find a sequence of actions that achieves a specified goal. The program should also: detect when no plan exists; print the resulting sequence of actions; print the states reached after each action.
> Explain the implementation and identify any assumptions you make.
>
> Problem: a warehouse robot and a package, with locations A, B and C. Initially At(Robot,A) and At(Package,A); the goal is At(Package,C). Actions: Move(X,Y) (precondition At(Robot,X); effects ¬At(Robot,X), At(Robot,Y)); PickUp(Package,L) (preconditions At(Robot,L), At(Package,L); effects ¬At(Package,L), Holding(Package)); Drop(Package,L) (preconditions At(Robot,L), Holding(Package); effects ¬Holding(Package), At(Package,L)).

**Response:** `LLMAction`, `build_warehouse_actions`, `bfs_plan` and `run_llm_planner` in the notebook. Among the assumptions it stated: *"the robot can move directly between any two locations."*

**Result:** the search and state-update logic were correct, but the plan `PickUp(Package,A), Move(A,C), Drop(Package,C)` is invalid, because A and C are not connected.

## Prompt 2: fix the action set (after Task 3)

> The warehouse has exactly these connections: A–B and B–C, in both directions. There is no direct connection between A and C. Generate Move actions **only** for these pairs. Do not add any action that is not listed in the problem. Also add a separate `validate_plan(plan)` function that re-executes a plan from the initial state, checks each action's preconditions against the state it is executed in, and reports the first failing step.

**Response:** grounding from an explicit `CONNECTIONS` list, plus a `validate_plan` function. In the notebook these are `ACTIONS` / `CONNECTIONS` (Task 0) and `validate_plan` (Task 1). `bfs_plan` was kept unchanged.

## Prompt 3: self-verification (Task 5)

> For every action in the plan, identify its preconditions and show that those preconditions are satisfied in the state in which the action is executed.

This was asked for both the first plan and the corrected plan. For the first plan, the LLM declared `Move(A,C)` valid, because At(Robot,A) holds; that reasoning is consistent with its own assumed action set. For the corrected plan, its justification was correct. Both were compared with the independently executed transitions (Task 5) and with Prolog's `valid_plan/3` (Task 7).
