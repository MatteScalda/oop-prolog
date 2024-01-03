:- dynamic class/1.

%% def_class
%% def_class/2 definisce una classe con parents
def_class(CLASS_NAME, PARENTS):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    are_classes(PARENTS),
    assert(class(CLASS_NAME, PARENTS, [])).

%% def_class/3 definisce una classe con parents e attributi
def_class(CLASS_NAME, PARENTS, PARTS):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    are_classes(PARENTS),
    assert(class(CLASS_NAME, PARENTS, PARTS)),
    get_methods(PARTS, METHODS),
    load_methods(METHODS, CLASS_NAME).
/*
def_class(CLASS_NAME, PARENTS, PART):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    are_classes(PARENTS),
    assert(class(CLASS_NAME, PARENTS, PART))
    get_methods(PARTS, METHODS),
    load_methods(METHODS, CLASS_NAME).
*/

%%make
%% make/2 crea un'istanza di una classe
make(INSTANCE_NAME, CLASS_NAME):-
    make(INSTANCE_NAME, CLASS_NAME, []).

%% make/3 crea un'istanza di una classe (instance-name è atomo)
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    atom(INSTANCE_NAME),
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    assert(instance(INSTANCE_NAME, CLASS_NAME, FIELDS)),
    !.

%% make/3 crea un'istanza di una classe (instance-name è variabile)
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    var(INSTANCE_NAME),
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    INSTANCE = instance(INSTANCE_NAME, CLASS_NAME, FIELDS),
    !.

%% make/3 crea un'istanza di una classe (instance-name è termine)
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    INSTANCE_NAME =.. Instance,
    second(Instance, X),
    is_instance(X), !.


%% utilities

%% is_list_atoms/1 dice se è una lista di atomi --> NON PRESENTE NEL TESTO
is_list_atoms([]).
is_list_atoms([A|ATOMS]):-
    atom(A),
    is_list_atoms(ATOMS).


%% is_class/1 dice se è una classe
is_class(CLASS_NAME):-
    atom(CLASS_NAME),
    current_predicate(class/1), !,
    class(CLASS_NAME, _, _).

%% are_classes/1 dice se una lista è formata da classi precedentemente dichiarate
are_classes([]).
are_classes([CLASS | CLASS_NAMES]):-
    is_class(CLASS),
    are_classes(CLASS_NAMES).

%% is_instance/1 dice se è un'istanza
is_instance(INSTANCE_NAME):-
    atom(INSTANCE_NAME),
    instance(INSTANCE_NAME, _, _).

%% is_instance/2 dice se è un'istanza di quella classe
is_instance(INSTANCE_NAME, CLASS_NAME):-
    atom(INSTANCE_NAME),
    atom(CLASS_NAME),
    instance(INSTANCE_NAME, CLASS_NAME, _).

%% inst/2 recupera l'istanza
inst(INSTANCE_NAME, INSTANCE):-
    atom(INSTANCE_NAME),
    is_instance(INSTANCE_NAME),
    instance(INSTANCE_NAME, _, INSTANCE).

%% field/3 recupera il valore di un campo
field(INSTANCE_NAME, FIELD_NAME, RESULT):-
    atom(INSTANCE_NAME),
    is_instance(INSTANCE_NAME),
    var(RESULT),
    instance(INSTANCE_NAME, _, FIELDS),
    member(FIELD_NAME = RESULT, FIELDS).

%% fieldx/3 recupera il valore di più campi
fieldx(_, [], []).
fieldx(INSTANCE, [FIELD | FIELD_NAMES], RESULT):-
    atom(INSTANCE),
    var(RESULT),
    is_instance(INSTANCE),
    is_list_atoms(FIELD_NAMES),
    field(INSTANCE, FIELD, VAL),
    fieldx(INSTANCE, FIELD_NAMES, RESULT_TAIL),
    RESULT = [FIELD = VAL | RESULT_TAIL],
    !.

%% get_methods/2 caso base
get_methods([], []).

%% get_methods/2 prende i metodi e li mette in METHODS
get_methods([P | PARTS], [H|METHODS]) :-
    is_method(P),
    !,
    get_methods(PARTS, METHODS).

get_methods([P | PARTS], METHODS) :-
    get_methods(PARTS, METHODS).

%% is_methods/1 dice se è un metodo
is_method(PART):-
    sub_atom(PART, 0, 6, _, PART_TYPE),
    PART_TYPE = method.

%% load_methods/2 carica i metodi
load_methods([M | METHODS], CLASS_NAME):-
    load_method(M, CLASS_NAME),
    load_methods(METHODS, CLASS_NAME).
%% caso base
load_methods([], _).

%% load_method/2 carica un metodo nella base di conoscenza
load_method(method(METHOD_NAME, ARGS, BODY), CLASS_NAME):-
    append([this], ARGS, ARGS_THIS),
    append([METHOD_NAME], ARGS_THIS, METHOD_HEAD),
    TERM =.. METHOD_HEAD.
    %% MANCANO TUTTI I CONTROLLI PER IL BODY
    %% CONTROLLARE CHE IL METODO SIA CHIAMABILE DA UNA CERTA ISTANZA
    replace_words(BODY, this, This, REPLACED_BODY),
    term_to_atom(METHOD, REPLACED_BODY),
    assert(METHOD).
    

%% replace_words/4 sostituisce tutte le occorrenze di una parola in una stringa con un'altra parola
replace_words(STRING, WORD, REPLACEMENT, RESULT):-
    atomic_list_concat(LIST, ' ', STRING),  % divide la stringa in una lista di parole
    maplist(replace_word(WORD, REPLACEMENT), LIST, REPLACED_LIST),  % sostituisce tutte le occorrenze della parola
    atomic_list_concat(REPLACED_LIST, ' ', RESULT).  % ricongiunge la lista di parole in una stringa

%% replace_word/4 se la parola è la parola da sostituire, fallisce
replace_word(WORD, REPLACEMENT, WORD, REPLACEMENT):-
    !.
%% altrimenti, sostituisce la parola con la parola di sostituzione
replace_word(_, _, OTHER, OTHER).