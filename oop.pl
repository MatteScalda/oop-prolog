:- dynamic class/1.

%% def_class
%% def_class/2 definisce una classe con parents
def_class(CLASS_NAME, PARENTS):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    are_classes(PARENTS),
    get_classes_parts(PARENTS, PARENTS_PARTS),
    assert(class(CLASS_NAME, PARENTS, PARENTS_PARTS)).

%% def_class/3 definisce una classe con parents e attributi
def_class(CLASS_NAME, PARENTS, PARTS):-
    atom(CLASS_NAME),
    is_list_atoms(PARENTS),
    are_classes(PARENTS),
    get_classes_parts(PARENTS, PARENTS_PARTS),
    append(PARENTS_PARTS, PARTS, ALL_PARTS),
    assert(class(CLASS_NAME, PARENTS, ALL_PARTS)),
    get_methods(PARTS, METHODS),
    load_methods(METHODS, CLASS_NAME).

%%make
%% make/2 crea un'istanza di una classe
make(INSTANCE_NAME, CLASS_NAME):-
    make(INSTANCE_NAME, CLASS_NAME, []),
    !.

%% make/3 crea un'istanza di una classe (instance-name è atomo) 
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    atom(INSTANCE_NAME),
    !,
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    get_class_parts(CLASS_NAME, PARTS),
    get_fields(PARTS, CLASS_FIELDS),
    extract_fields(CLASS_FIELDS, FIELDS_EXTRACTED),
    overwrite_fields(FIELDS_EXTRACTED, FIELDS, FIELDS_OVERWRITTEN),
    assert(instance(INSTANCE_NAME, CLASS_NAME, FIELDS_OVERWRITTEN)).

%% //TODO capire che cazzo fanno
%% make/3 crea un'istanza di una classe (instance-name è variabile)
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    var(INSTANCE_NAME),
    !,
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    INSTANCE = instance(INSTANCE_NAME, CLASS_NAME, FIELDS).

%% make/3 crea un'istanza di una classe (instance-name è termine)
make(INSTANCE_NAME, CLASS_NAME, _):-
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    INSTANCE_NAME =.. Instance,
    second(Instance, X),
    is_instance(X), 
    !.


%% utilities

%% is_list_atoms/1 dice se è una lista di atomi
is_list_atoms([]).
is_list_atoms([A|ATOMS]):-
    atom(A),
    is_list_atoms(ATOMS).


%% is_class/1 dice se è una classe
is_class(CLASS_NAME):-
    atom(CLASS_NAME),
    current_predicate(class/1), !,
    class(CLASS_NAME, _, _).

%% are_classes/1 dice se una lista è formata da 
%% classi precedentemente dichiarate
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
    instance(INSTANCE_NAME, CLASS_NAME, _);
    is_a_child(INSTANCE_NAME, CLASS_NAME).

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
get_methods([], _).

%% get_methods/2 prende i metodi e li mette in METHODS
get_methods([P | PARTS], [P | METHODS]) :-
    is_method(P),
    !,
    get_methods(PARTS, METHODS).

get_methods([_ | PARTS], METHODS) :-
    get_methods(PARTS, METHODS).

%% get_fields/2 caso base
get_fields([], _).

%% get_fields/2 prende i metodi e li mette in METHODS
get_fields([P | PARTS], [P | FIELDS]) :-
    is_field(P),
    !,
    get_fields(PARTS, FIELDS).

get_fields([_ | PARTS], FIELDS) :-
    get_fields(PARTS, FIELDS).

%% is_methods/1 dice se è un metodo
is_method(PART):-
    term_to_atom(PART, ATOM_PART),
    sub_atom(ATOM_PART, 0, 6, _, PART_TYPE),
    PART_TYPE = method.
    
is_field(PART):-
    term_to_atom(PART, ATOM_PART),
    sub_atom(ATOM_PART, 0, 5, _, PART_TYPE),
    PART_TYPE = field.

%% load_methods/2 carica i metodi
load_methods([M | METHODS], CLASS_NAME):-
    %%Ridondante ma senza non va (non so perchè)
    is_method(M),
    load_method(M, CLASS_NAME),
    load_methods(METHODS, CLASS_NAME).
%% caso base
load_methods([], _).

%% load_method/2 carica un metodo nella base di conoscenza
load_method(method(METHOD_NAME, ARGS, BODY), CLASS_NAME):- 
    append(['this'], ARGS, ARGS_THIS),
    term_to_atom(METHOD_NAME, ATOM_METHOD_NAME),
    append([ATOM_METHOD_NAME], ARGS_THIS, HEAD),
    METHOD_HEAD =.. HEAD,

    term_to_atom(METHOD_NAME, ATOM_NAME),
    term_to_atom(METHOD_HEAD, ATOM_METHOD_HEAD),
    term_to_atom(BODY, ATOM_BODY),
    term_to_atom(CLASS_NAME, ATOM_CLASS),

    %%is_instance('this', CLASS_NAME), !,
    atom_concat('is_instance(this, ', ATOM_CLASS, CHECK_INSTANCE_1),
    atom_concat(CHECK_INSTANCE_1, '),!,', CHECK_INSTANCE),

    %aggiunge al body il controllo per vedere se il metodo esiste nell'istanza
    atom_concat(CHECK_INSTANCE, 'method_exists(', CHECK_CALL_1), 
    atom_concat(CHECK_CALL_1, ATOM_CLASS, CHECK_CALL_2),
    atom_concat(CHECK_CALL_2, ', ', CHECK_CALL_3), 
    atom_concat(CHECK_CALL_3, ATOM_NAME, CHECK_CALL), 
    atom_concat(CHECK_CALL, '),', TO_APPEND), 

    atom_concat(TO_APPEND, ATOM_BODY, BODY_CHECKED),
    atom_concat(ATOM_METHOD_HEAD, ' :- ', METHOD_WOUT_BODY),
    atom_concat(METHOD_WOUT_BODY, BODY_CHECKED, METHOD_WITHOUT_END),
    atom_concat(METHOD_WITHOUT_END, '.', METHOD_WOUT_THIS),
    replace_words(METHOD_WOUT_THIS, 'this', 'THIS', REPLACED_BODY),
    atom_to_term(REPLACED_BODY, METHOD, _),
    assert(METHOD).

    
%% replace_words/4 sostituisce tutte le occorrenze di una 
%% parola in una stringa con un'altra parola
replace_words(STRING, SUBSTRING, REPLACEMENT, RESULT) :-
    atom(STRING),
    atom(SUBSTRING),
    atom(REPLACEMENT),
    var(RESULT),
    (   
        sub_atom(STRING, BEFORE, _, AFTER, SUBSTRING)
    ->  sub_atom(STRING, 0, BEFORE, _, START),
        sub_atom(STRING, _, AFTER, 0, END),
        atomic_list_concat([START, REPLACEMENT, END], TEMP_RESULT),
        replace_words(TEMP_RESULT, SUBSTRING, REPLACEMENT, RESULT)
    ;   RESULT = STRING
    ).

%% method_exists/2 dice se il metodo esiste
method_exists(CLASS_NAME, METHOD_NAME):-
    atom(CLASS_NAME),
    atom(METHOD_NAME),
    is_class(CLASS_NAME),
    class(CLASS_NAME, _ , PARTS),
    get_methods(PARTS, METHODS),
    member(method(METHOD_NAME, _, _), METHODS).

%% get_classes_parts/2 prende le parti di più classi
%% caso base
get_classes_parts([], _).

%% caso ricorsivo
get_classes_parts([C | CLASSES], ALL_PARTS):-
    are_classes(CLASSES),
    get_class_parts(C, PARTS),
    get_classes_parts(CLASSES, REST_PARTS),
    append(PARTS, REST_PARTS, ALL_PARTS).

%% get_class_parts/2 prende le parti di una classe
get_class_parts(CLASS, PART):-
    atom(CLASS),
    is_class(CLASS),
    class(CLASS, _, PART).

%% extract_field/3 estrae il nome e il valore di un campo
extract_field(FIELD, NAME, VALUE) :- 
    FIELD =.. [_, NAME, VALUE].

%% extract_fields/2 estrae il nome e il valore di più campi
%% caso base
extract_fields([], []).
%% caso ricorsivo
extract_fields([FIELD | FIELDS], [NAME = VALUE | RESULT]) :-
    extract_field(FIELD, NAME, VALUE),
    extract_fields(FIELDS, RESULT),
    !.

%% overwrite_fields/3 sovrascrive i campi
%% caso base
%% Caso in cui ho inserito un campo non presente nella classe
overwrite_fields([], _, _):-  
    false,
    !.
overwrite_fields([], [], _):-
    !.
%% caso ricorsivo
overwrite_fields([FIELD = _ | FIELDS], 
        [FIELD = VALUE_2 | FIELDS_2], 
        [FIELD = VALUE_2 | RESULT]):-     
    atom(FIELD),
    var(RESULT),
    overwrite_fields(FIELDS, FIELDS_2, RESULT),
    !.
%% caso ricorsivo 2
overwrite_fields([FIELD = VALUE | FIELDS], 
        FIELDS_2, 
        [FIELD = VALUE | RESULT]):-
    atom(FIELD),
    var(RESULT),
    overwrite_fields(FIELDS, FIELDS_2, RESULT).


%% is_a_child/2 dice se è un'istanza di quella classe
is_a_child(INSTANCE_NAME, PARENT):-
    atom(INSTANCE_NAME),
    atom(PARENT),
    instance(INSTANCE_NAME, CLASS_NAME, _),
    get_all_parents([CLASS_NAME], PARENTS),
    member(PARENT, PARENTS).

%% get_all_parents/2 recupera i genitori e li mette in PARENTS
%% caso base
get_all_parents([], []).
%% caso ricorsivo
get_all_parents([CLASS_NAME | _], PARENTS):- 
    get_parents(CLASS_NAME, ALL_PARENTS),
    get_all_parents(ALL_PARENTS, PARENTS_REST),
    append(ALL_PARENTS, PARENTS_REST, PARENTS).

%% get_parents/2 recupera i genitori e li mette in PARENTS
get_parents(C, PARENTS):-
    atom(C),
    is_class(C),
    class(C, PARENTS, _).
