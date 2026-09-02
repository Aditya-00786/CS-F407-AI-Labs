# Week 4: Answers to the Lab Questions

**Lab:** Logical Reasoning for Planning: Using an LLM to Construct and Test a Simple Planning Agent ([question PDF](../lab-question/logic_lab_ex.pdf))
**Code and full outputs:** [solution/Logic_Planning_Lab.ipynb](../solution/Logic_Planning_Lab.ipynb) · **Prolog:** [solution/planner.pl](../solution/planner.pl) · **Prompts:** [solution/prompts.md](../solution/prompts.md)

Locations $A$, $B$ and $C$, with the connections $A \leftrightarrow B$ and $B \leftrightarrow C$ only. The robot and the package both start at $A$. The goal is to get the package to $C$.

---

## Task 0: Understand the Planning Problem

**(a) Initial state:** $I = \{\text{At}(Robot,A),\ \text{At}(Package,A)\}$. Any proposition not listed is false (closed world).

**(b) Goal:** $G = \{\text{At}(Package,C)\}$, satisfied by any state $S$ with $G \subseteq S$. Where the robot ends up does not matter.

**(c) Actions:**
- $\text{Move}(A,B)$, $\text{Move}(B,A)$, $\text{Move}(B,C)$, $\text{Move}(C,B)$. There is no $\text{Move}(A,C)$ or $\text{Move}(C,A)$.
- $\text{PickUp}(Package,L)$ and $\text{Drop}(Package,L)$ for $L \in \{A,B,C\}$.

That makes 10 ground actions in total.

**(d) Preconditions and effects:**

| Action | Preconditions | Add effects | Delete effects |
|---|---|---|---|
| $\text{Move}(X,Y)$, for connected $X,Y$ | $\text{At}(Robot,X)$ | $\text{At}(Robot,Y)$ | $\text{At}(Robot,X)$ |
| $\text{PickUp}(Package,L)$ | $\text{At}(Robot,L)$, $\text{At}(Package,L)$ | $\text{Holding}(Package)$ | $\text{At}(Package,L)$ |
| $\text{Drop}(Package,L)$ | $\text{At}(Robot,L)$, $\text{Holding}(Package)$ | $\text{At}(Package,L)$ | $\text{Holding}(Package)$ |

No negative preconditions are needed, but the representation supports them.

**Question: in $I$, is $\text{PickUp}(Package,A)$ applicable? What about $\text{Drop}(Package,C)$?**
- **$\text{PickUp}(Package,A)$: yes.** Both of its preconditions, $\text{At}(Robot,A)$ and $\text{At}(Package,A)$, are in $I$, so $I \models \text{Pre}(\text{PickUp}(Package,A))$.
- **$\text{Drop}(Package,C)$: no.** It needs $\text{At}(Robot,C)$ and $\text{Holding}(Package)$, and neither is in $I$: the robot is at $A$ and holds nothing.

Only $\text{PickUp}(Package,A)$ and $\text{Move}(A,B)$ are applicable in $I$.

**Think About It: are all of its preconditions satisfied in the current state?**
Appearing in the action list only means that an action exists. Whether it can be executed depends on the current state, and that is decided by the entailment test $S \models \text{Pre}(a)$. In $I$, this test rules out 8 of the 10 actions. This check is where logical reasoning enters planning.

---

## Task 1: Construct a Plan by Hand

The lab's suggested sequence, $\text{Move}(A,B), \text{PickUp}(Package,B), \dots$, is **invalid as written**: after $\text{Move}(A,B)$ the package is still at $A$, so $\text{PickUp}(Package,B)$ fails. The robot must pick the package up before leaving $A$:

| State | Facts | Next action |
|---|---|---|
| $S_0$ | At(Robot,A), At(Package,A) | PickUp(Package,A) |
| $S_1$ | At(Robot,A), Holding(Package) | Move(A,B) |
| $S_2$ | At(Robot,B), Holding(Package) | Move(B,C) |
| $S_3$ | At(Robot,C), Holding(Package) | Drop(Package,C) |
| $S_4$ | At(Robot,C), At(Package,C) | — ($S_4 \models G$) |

---

## Task 2: Ask an LLM to Implement the Planner

The lab's suggested prompt was used verbatim, with the scenario appended; see [prompts.md](../solution/prompts.md).

The generated planner's search and state-update logic were correct. However, its stated assumption, *"the robot can move directly between any two locations"*, created the actions $\text{Move}(A,C)$ and $\text{Move}(C,A)$, and it returned the plan `PickUp(Package,A), Move(A,C), Drop(Package,C)`.

**Think About It: where do the parts of the specification appear in the program?**

| Specification | In the program | Question answered |
|---|---|---|
| Preconditions | `is_applicable`: `pos_pre ⊆ state` and `neg_pre ∩ state = ∅`, checked before each action is used in BFS | When is an action applicable? |
| Effects | `apply`: `state − neg_eff`, then `∪ pos_eff` | How does the state change? |
| Goal | `goal.issubset(state)` when a state is dequeued | When does planning terminate? |
| BFS | FIFO `deque`, a `visited` set of `frozenset` states, and a plan stored with each state | How are alternative plans explored? |

---

## Task 3: Test the Generated Planner

"Valid" means the plan was executed step by step against the **specified** action set, not the planner's own.

| Test | Initial state | Goal | LLM first attempt | Corrected planner |
|---|---|---|---|---|
| A. Solvable | At(Robot,A), At(Package,A) | At(Package,C) | plan `PickUp(A), Move(A,C), Drop(C)`: **invalid** (no A–C link) ✗ | plan `PickUp(Package,A), Move(A,B), Move(B,C), Drop(Package,C)`: valid ✓ |
| B. Impossible (PickUp removed) | same | At(Package,C) | **No plan found** ✓ | **No plan found** ✓ |
| C. Irrelevant actions (Beep, Patrol); package cannot move; robot can reach C | same | At(Package,C) | **No plan found** ✓ | **No plan found** ✓ |
| C2. Irrelevant actions added to the solvable problem | same | At(Package,C) | uses `Move(A,C)`: invalid ✗ | same 4-step plan as A; irrelevant actions unused ✓ |
| D. Goal already true | At(Robot,A), At(Package,C) | At(Package,C) | — | empty plan `[]` ✓ |
| E. Reverse delivery | At(Robot,C), At(Package,C) | At(Package,A) | — | `PickUp(Package,C), Move(C,B), Move(B,A), Drop(Package,A)` ✓ |

- **Test C** confirms that the planner does not treat the robot reaching $C$ as the package reaching $C$.
- **Test C can actually fail.** A mutated planner whose goal test is `At(Robot,C) in state` returns `[Move(A,C)]` on Test C, and the test rejects it.
- **The fix went into the specification, not the search.** The prompt now states the connectivity explicitly, forbids adding actions, and asks for a separate validator. BFS itself was unchanged.

---

## Task 4: Logic and Search

Completed flow:

**Current state → Check action preconditions → *Select the applicable actions*, i.e. keep only those with $S \models \text{Pre}(a)$ → Generate successor state $S' = (S \setminus \text{Del}(a)) \cup \text{Add}(a)$ → Search over alternatives → Goal? ($G \subseteq S$)**

If the goal holds, planning stops and returns the plan; if not, the loop continues.

**How logic and search work together.**
- **Logic answers exact local questions:** can this action be executed in this state, what is true after it, and is this state a goal?
- **Search answers the global question:** which sequence of legal steps to try, and in what order (FIFO for BFS), while remembering visited states so it never loops.
- Together they turn the planning problem into a graph whose nodes are states and whose edges are applicable actions; BFS then finds a shortest path through it.
- **Neither works alone.** Logic without search can take only one step. Search without logic explores moves that break the rules, like the LLM's non-existent $\text{Move}(A,C)$ edge.

**Think About It: logic determines what is possible; search determines what to try.**
- The mapping to the previous module is direct: sets of propositions are the search states, applicable actions are the successor function, and $G \subseteq S$ is the goal test.
- BFS is the same algorithm as before, with the same guarantees.
- The new element is that the successor function is *derived* from logical action descriptions instead of being hand-coded.

---

## Task 5: Can the LLM Verify Its Own Plan?

- **The LLM's justification of its first plan was internally consistent.** It said: "Move(A,C) requires At(Robot,A), which holds after step 1."
- **It was wrong about the warehouse.** $\text{Move}(A,C)$ does not exist. The independent executor, working from the specification, stops at step 2: `Move(A,C) is NOT an action of this problem`.
- **For the corrected plan, the explanation and the execution agree.**

**Which should you trust more: (a) the LLM's explanation, or (b) the independently executed state transitions? (b)**
- The explanation is generated from the same assumptions as the plan, so it repeats the same error in fluent prose.
- The executor takes its actions from the specification, computes every state mechanically, and fails at the exact step, naming the exact missing fact.
- An explanation helps a person understand a plan; only execution against the true model verifies it.

*A generated explanation is not the same as an independent verification.*

---

## Optional Extension: Prolog (Tasks 6–8)

Run in SWI-Prolog 10.0.2 with [planner.pl](../solution/planner.pl).

### Task 6

| Query | Result |
|---|---|
| `?- can_move(a,b).` | `true` |
| `?- can_move(a,c).` | `false` |

**(a) Why does Prolog return `true` for `can_move(a,b)`?**
The rule `can_move(X,Y) :- connected(X,Y)` unifies with `X=a, Y=b`. That reduces the goal to `connected(a,b)`, which is a fact, so the proof succeeds.

**(b) Why does it not establish `can_move(a,c)`?**
The only rule needs `connected(a,c)`, and there is no such fact and no rule that derives it, so the proof fails. Here `false` means *not provable from this knowledge base*: this is negation as failure under the closed-world assumption. It is not a proof that $a$ and $c$ are disconnected. The rule also expresses only direct moves: `reachable(a,c)` (an extension with a visited list) is `true`, because $c$ can be reached through $b$.

**(c) What is the relationship between the rule `can_move(X,Y)` and $\text{Connected}(X,Y) \to \text{CanMove}(X,Y)$?**
The rule is a Horn clause and reads as $\forall X\,\forall Y\ (\text{Connected}(X,Y) \to \text{CanMove}(X,Y))$, where `:-` means "if". A query asks whether its conclusion is entailed by the knowledge base, and Prolog answers by backward chaining through the implication. Under the closed-world reading the rule is treated as the *only* way to derive `can_move`.

### Task 7

| Query | Result | Reason |
|---|---|---|
| `valid_move(a,b)` | `true` | the fact `connected(a,b)` |
| `valid_move(b,c)` | `true` | the fact `connected(b,c)` |
| `valid_move(a,c)` | `false` | no fact `connected(a,c)` |

**Challenge: the planner proposes $\text{Move}(a,c)$.** `valid_move(a,c)` is `false`, so the action is **not supported** by the warehouse knowledge. It is exactly the action the LLM's first planner invented.

The `valid_plan/3` extension checks whole plans:
- the LLM's first plan is `false`, with the first failing step being step 2, `move(a,c)`;
- the lab's literal example is `false`, failing at step 2, `pickup(package,b)`;
- the corrected plan is `true`.

Searching on its own, Prolog finds exactly one plan of length ≤ 4, the same one BFS found.

**Think About It: generate → independent verification.** Python (with help from the LLM) generated the plan, and Prolog, using its own encoding of the specification, checked it. Because the two share no code, the generator's bug was not reproduced in the checker.

### Task 8: why `?- reduce_speed.` succeeds

`reduce_speed` needs `slippery` (from the rule); `slippery` needs `wet_road` (from the rule); `wet_road` is a fact. The chain of implications is:

$$\text{WetRoad (fact)} \Rightarrow \text{Slippery (rule: WetRoad} \to \text{Slippery)} \Rightarrow \text{ReduceSpeed (rule: Slippery} \to \text{ReduceSpeed)} \Rightarrow \text{conclusion: ReduceSpeed}$$

That is two applications of modus ponens.

**Think About It: Prolog is not identical to classical logic.**
- Its depth-first backtracking makes clause order matter. For example, a naive recursive `reachable` over the symmetric `connected` facts loops forever.
- Negation as failure and `false` mean "not provable", not "false".
- There is no occurs-check.

For facts, Horn rules and ground queries like the ones here, its answers match classical entailment.

### Prolog reflection

**1. What is the difference between a Prolog fact and a Prolog rule?**
A **fact** is an unconditional truth: a head with no body, such as `connected(a,b).` A **rule** is a conditional: the head holds *if* the body does, i.e. the implication body → head, as in `can_move(X,Y) :- connected(X,Y).` Facts are the data; rules are the general knowledge from which new facts are derived.

**2. How does a Prolog query correspond to asking whether something follows from a knowledge base?**
`?- Q.` asks whether $KB \models Q$. Prolog searches for a proof by backward chaining with unification. `true` means a proof was found (with variable bindings, if any). `false` means no proof exists from this knowledge base.

**3. Why might it be useful to use a Prolog program to verify a plan generated by a Python program?**
- It is independent: a different language and different code, with knowledge written directly from the specification.
- It is declarative, so a person can audit it line by line.
- A failure comes with a concrete reason (for example, no `connected(a,c)`, or the first failing step).
- Checking a given plan needs no search, so the verifier is much simpler than the planner and easier to trust.

**4. What advantage does an independent verifier provide when the plan was generated with the help of an LLM?**
LLM-generated code can embed unstated assumptions ("all locations are connected") that make its output self-consistent but wrong. Any self-check built on the same assumptions, including the LLM's own explanation, inherits them. An independent verifier encodes the specification separately and catches exactly these errors: it rejected $\text{Move}(a,c)$ immediately. Trust then rests on a checkable proof from stated facts, not on the generator's word.

---

## Reflection Questions

**1. Why is it useful to specify action preconditions and effects before asking an LLM to write the planner?**
They *are* the problem; the search code is generic. Writing them down first gives the LLM a precise description, gives you something to check its code against, and provides the ground truth for an independent validator. It also exposes gaps. The suggested prompt never said which locations were connected, so the LLM assumed that all of them were and produced an invalid plan. Having specified Move only for A–B and B–C is what made that error detectable.

**2. Give an example of an error that could occur if the planner failed to check an action's preconditions.**
In the initial state, $\text{Drop}(Package,C)$ could be applied: a package the robot is not holding would be "dropped" at a location the robot is not at. That adds $\text{At}(Package,C)$, and the planner would return the physically impossible one-step "plan" `[Drop(Package,C)]`. Likewise, $\text{PickUp}(Package,B)$ could be applied while the package is at $A$ (the lab's own example), or $\text{Move}(B,C)$ applied while the robot is still at $A$.

**3. Why is a plan that "looks reasonable" not necessarily a valid plan?**
A plan is valid only if each action's preconditions hold *in the exact state produced by the previous actions*, and the final state satisfies the goal. "Looks reasonable" judges whether the steps make sense in general.
- `Move(A,B), PickUp(Package,B), …` reads naturally but fails at step 2.
- The LLM's `PickUp(Package,A), Move(A,C), Drop(Package,C)` reads even better, but it uses a move that doesn't exist.

Only step-by-step execution against the action definitions tells these apart.

**4. What did the LLM contribute to the implementation?**
- the whole planner skeleton: an action class with the four precondition/effect sets, the applicability test, effect application in the specified order, and BFS over `frozenset` states with a visited set;
- output of the plan and the states, and detection of the no-plan case;
- a list of its assumptions;
- a correct justification of the corrected plan.

The search and state-update logic were accepted unchanged.

**5. What did you have to verify independently?**
- that the action set matched the warehouse (no invented $\text{Move}(A,C)$);
- that every plan executes correctly against the specification, using `validate_plan` in Python and `valid_plan/3` in Prolog;
- that "No plan found" is reported when no plan exists (Test B);
- that the goal test is about the package, not the robot (Test C, plus the mutation check);
- the edge cases (Tests D and E);
- the LLM's own explanation of its plan (Task 5).

**6. In this laboratory, where is logical reasoning being used?**
- deciding applicability, $S \models \text{Pre}(a)$;
- computing effects, $(S \setminus \text{Del}) \cup \text{Add}$, under the closed-world representation;
- the goal test, $S \models G$;
- validating plans, as a chain of entailment checks;
- in Prolog: deriving `can_move`, `valid_move`, `reachable`, `valid_plan` and `reduce_speed` by backward chaining, i.e. modus ponens.

**7. How is planning related to the search algorithms studied in the previous module?**
Planning is search in a state space defined by logic: the states are sets of propositions, the successors are the applicable actions, the goal test is $G \subseteq S$, and every action costs 1. BFS is the same algorithm as in the grid labs and keeps the same guarantees: it is complete and finds a shortest plan. Here it explores 12 reachable states. A\*, with a heuristic such as the number of unsatisfied goal propositions, would plug in unchanged. The difference is that the successor function is *derived* from action schemas rather than hand-coded, which is what lets one planner handle many problems.
