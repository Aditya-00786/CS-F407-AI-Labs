% planner.pl: Week 4, Tasks 6-8 (optional Prolog extension)
% Run with SWI-Prolog:  swipl planner.pl

% ---------------------------------------------------------------
% Task 6: warehouse knowledge (facts) and a movement rule
% ---------------------------------------------------------------
connected(a, b).
connected(b, a).
connected(b, c).
connected(c, b).

can_move(X, Y) :-
    connected(X, Y).

% ---------------------------------------------------------------
% Task 7: checking proposed movements
% ---------------------------------------------------------------
valid_move(X, Y) :-
    connected(X, Y).

% Extension: multi-step reachability. The visited list stops the
% search from looping forever, because connected/2 is symmetric
% (a -> b -> a -> ...).
reachable(X, Y) :-
    reachable(X, Y, [X]).

reachable(X, X, _).
reachable(X, Z, Visited) :-
    connected(X, Y),
    \+ member(Y, Visited),
    reachable(Y, Z, [Y|Visited]).

% Extension: a verifier for a complete plan, using the same STRIPS
% semantics as the Python planner.
% action(Action, Preconditions, AddEffects, DeleteEffects)
location(a).
location(b).
location(c).

action(move(X, Y), [at(robot, X)], [at(robot, Y)], [at(robot, X)]) :-
    connected(X, Y).
action(pickup(package, L), [at(robot, L), at(package, L)], [holding(package)], [at(package, L)]) :-
    location(L).
action(drop(package, L), [at(robot, L), holding(package)], [at(package, L)], [holding(package)]) :-
    location(L).

holds_all([], _).
holds_all([F|Fs], State) :-
    member(F, State),
    holds_all(Fs, State).

apply_action(State, Add, Del, NewState) :-
    subtract(State, Del, Kept),
    union(Add, Kept, NewState).

% valid_plan(+State, +Plan, +Goal): Plan is executable from State and ends in a state satisfying Goal.
valid_plan(State, [], Goal) :-
    holds_all(Goal, State).
valid_plan(State, [A|As], Goal) :-
    action(A, Pre, Add, Del),
    holds_all(Pre, State),
    apply_action(State, Add, Del, Next),
    valid_plan(Next, As, Goal).

% first_failure(+State, +Plan, -Step, -Action): the first step whose preconditions fail.
first_failure(State, [A|_], 1, A) :-
    \+ ( action(A, Pre, _, _), holds_all(Pre, State) ), !.
first_failure(State, [A|As], N, Bad) :-
    action(A, Pre, Add, Del),
    holds_all(Pre, State),
    apply_action(State, Add, Del, Next),
    first_failure(Next, As, M, Bad),
    N is M + 1.

% ---------------------------------------------------------------
% Task 8: facts + rules -> inference
% ---------------------------------------------------------------
wet_road.

slippery :-
    wet_road.

reduce_speed :-
    slippery.
