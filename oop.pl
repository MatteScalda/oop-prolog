%% def_class
%% definisce una classe senza parents
def_class(CLASS_NAME, []):-
    atom(CLASS_NAME),
    assertz(class(CLASS_NAME)).

%% definisce una classe con parents
def_class(CLASS_NAME, PARENTS):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    assertz(class(CLASS_NAME, PARENTS)).

%% definisce una classe con parents e attributi
def_class(CLASS_NAME, PARENTS, PARTS):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    assertz(class(CLASS_NAME, PARENTS, PARTS)).


%%make
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    atom(INSTANCE_NAME),
    !,
    atom(CLASS_NAME),
    
    make(INSTANCE_NAME, CLASS_NAME, PARENTS, PARTS, FIELDS).



%% utilities

%% dice se è una lista di atomi
is_list_atoms([]).
is_list_atoms([A|ATOMS]):-
    atom(A),
    is_list_atoms(ATOMS).