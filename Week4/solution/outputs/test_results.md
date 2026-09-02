| Test | Initial state | Goal | Plan found | Plan | Valid |
|---|---|---|---|---|---|
| Test A: solvable (original problem) | {At(Package,A), At(Robot,A)} | {At(Package,C)} | True | PickUp(Package,A), Move(A,B), Move(B,C), Drop(Package,C) | True |
| Test B: impossible (PickUp removed) | {At(Package,A), At(Robot,A)} | {At(Package,C)} | False | No plan found | None |
| Test C: irrelevant actions; package cannot move, robot CAN reach C | {At(Package,A), At(Robot,A)} | {At(Package,C)} | False | No plan found | None |
| Test C2: irrelevant actions added to the solvable problem | {At(Package,A), At(Robot,A)} | {At(Package,C)} | True | PickUp(Package,A), Move(A,B), Move(B,C), Drop(Package,C) | True |
| Test D: goal already true (package starts at C) | {At(Package,C), At(Robot,A)} | {At(Package,C)} | True | [] (empty plan) | True |
| Test E: robot and package start at C, goal At(Package,A) | {At(Package,C), At(Robot,C)} | {At(Package,A)} | True | PickUp(Package,C), Move(C,B), Move(B,A), Drop(Package,A) | True |
