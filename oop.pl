%%%% Scaldaferri Matteo 912001
%%%% Collaboratore: Mecenero Matteo 894512

:- dynamic class/1.

%% ---------
%%   MAIN  |
%% ---------

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
    set_default_type(ALL_PARTS, PARTS_WITH_DEFAULT_TYPE),
    assert(class(CLASS_NAME, PARENTS, PARTS_WITH_DEFAULT_TYPE)),
    get_methods(PARTS, METHODS),
    load_methods(METHODS, CLASS_NAME).

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
    control_type(FIELDS, CLASS_NAME),
    extract_fields(CLASS_FIELDS, FIELDS_EXTRACTED),
    overwrite_fields(FIELDS_EXTRACTED, FIELDS, FIELDS_OVERWRITTEN),
    assert(instance(INSTANCE_NAME, CLASS_NAME, FIELDS_OVERWRITTEN)).

%% make/3 crea un'istanza di una classe (instance-name è variabile)
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    var(INSTANCE_NAME),
    !,
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    get_class_parts(CLASS_NAME, PARTS),
    get_fields(PARTS, CLASS_FIELDS),
    control_type(FIELDS, CLASS_NAME),
    extract_fields(CLASS_FIELDS, FIELDS_EXTRACTED),
    overwrite_fields(FIELDS_EXTRACTED, FIELDS, FIELDS_OVERWRITTEN),
    INSTANCE_NAME = instance(_, CLASS_NAME, FIELDS_OVERWRITTEN).

%% make/3 crea un'istanza di una classe (instance-name è termine)
make(INSTANCE_NAME, CLASS_NAME, FIELDS):-
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    get_class_parts(CLASS_NAME, PARTS),
    get_fields(PARTS, CLASS_FIELDS),
    control_type(FIELDS, CLASS_NAME),
    extract_fields(CLASS_FIELDS, FIELDS_EXTRACTED),
    overwrite_fields(FIELDS_EXTRACTED, FIELDS, FIELDS_OVERWRITTEN),
    INSTANCE_NAME = instance(_, CLASS_NAME, FIELDS_OVERWRITTEN).

%% is_instance/1 dice se è un'istanza
is_instance(INSTANCE_NAME):-
    atom(INSTANCE_NAME),
    instance(INSTANCE_NAME, _, _).

is_instance(instance(_,_,_)).
    
is_instance(INSTANCE_NAME, CLASS_NAME):-
    is_a_child(INSTANCE_NAME, CLASS_NAME).

%% is_instance/2 dice se è un'istanza di quella classe
is_instance(INSTANCE_NAME, CLASS_NAME):-
    atom(INSTANCE_NAME),
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    !,
    instance(INSTANCE_NAME, CLASS_NAME, _).
    
is_instance(instance(_, CLASS_NAME, _), CLASS_NAME):-
    atom(CLASS_NAME),
    is_class(CLASS_NAME),
    !.

%% is_instance/2 dice se è un'istanza di quella classe o se è di quel tipo
is_instance(VALUE, TYPE):-
    is_of_type(TYPE, VALUE).

%% inst/2 recupera l'istanza
inst(INSTANCE_NAME, INSTANCE):-
    atom(INSTANCE_NAME),
    instance(INSTANCE_NAME, CLASS_NAME, FIELDS),
    is_instance(INSTANCE_NAME, CLASS_NAME),
    INSTANCE = instance(INSTANCE_NAME, CLASS_NAME, FIELDS).

field(INSTANCE_NAME, FIELD_NAME, RESULT):-
    atom(INSTANCE_NAME),
    !,
    is_instance(INSTANCE_NAME),
    var(RESULT),
    instance(INSTANCE_NAME, _, FIELDS),
    member(FIELD_NAME = RESULT, FIELDS).

field(instance(INSTANCE_NAME, _, _), FIELD_NAME, RESULT):-
    field(INSTANCE_NAME, FIELD_NAME, RESULT).

%% fieldx/3 recupera il valore di un campo
fieldx(INSTANCE_NAME, [LAST_FIELD], RESULT):-
    is_instance(INSTANCE_NAME),
    field(INSTANCE_NAME, LAST_FIELD, RESULT).

fieldx(INSTANCE_NAME, [FIELD | FIELD_NAMES], RESULT):-
    is_instance(INSTANCE_NAME),
    field(INSTANCE_NAME, FIELD, VAL),
    is_instance(VAL),
    fieldx(VAL, FIELD_NAMES, RESULT).

fieldx(instance(INSTANCE_NAME, _, _), FIELDS, RESULT):-
    fieldx(INSTANCE_NAME, FIELDS, RESULT).

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

    %aggiunge al body il controllo per vedere se il metodo esiste
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

%% ---------
%% UTILITIES |
%% ---------

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
get_fields([], _):- !.

%% get_fields/2 prende i fields e li mette in FIELDS
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
    
%% replace_words/4 sostituisce tutte le occorrenze di una 
%% parola in una stringa con un'altra parola
replace_words(STRING, SUBSTRING, REPLACEMENT, RESULT) :-
    atom(STRING),
    atom(SUBSTRING),
    atom(REPLACEMENT),
    var(RESULT),
    sub_atom(STRING, BEFORE, _, AFTER, SUBSTRING),
    sub_atom(STRING, 0, BEFORE, _, START),
    sub_atom(STRING, _, AFTER, 0, END),
    atomic_list_concat([START, REPLACEMENT, END], TEMP_RESULT),
    replace_words(TEMP_RESULT, SUBSTRING, REPLACEMENT, RESULT).

replace_words(STRING, _, _, STRING).

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
%% extract_field/3 estrae il nome, il valore e il tipo di un campo
extract_field(FIELD, NAME, VALUE, TYPE) :- 
    FIELD =.. [_, NAME, VALUE, TYPE].

%% extract_fields/2 estrae il nome, il valore e i tipi di più campi
%% caso base
extract_fields([], []).
%% caso ricorsivo
extract_fields([FIELD | FIELDS], [NAME = VALUE : TYPE| RESULT]) :-
    extract_field(FIELD, NAME, VALUE, TYPE),
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

%%set_default_type/2 setta il tipo di default
%%caso base
set_default_type([], _).
%%caso type non inserito
set_default_type([field(N, V) | FIELDS], [field(N, V, any) | RESULT]):-
    set_default_type(FIELDS, RESULT),
    !.
%% caso type già inserito oppure P = method
set_default_type([P | PARTS], [P | RESULT]):-
    set_default_type(PARTS, RESULT).
    
%% control_type/2 controlla che i campi siano del tipo giusto
%% caso base
control_type([], _).

%% caso ricorsivo
control_type([NAME = VALUE | FIELDS], CLASS_NAME):-
    class(CLASS_NAME, _, PARTS),
    get_fields(PARTS, CLASS_FIELDS),
    extract_fields(CLASS_FIELDS, EX_CLASS_FIELDS),
    get_type(NAME, EX_CLASS_FIELDS, TYPE),
    is_instance(VALUE, TYPE),
    !,
    control_type(FIELDS, CLASS_NAME).
    
%% get_type/3 recupera il tipo di un campo
get_type(_, [], _):-
    false.
get_type(FIELD_NAME, [FIELD_NAME = FIELD_VALUE : TYPE| _], TYPE) :- 
    nonvar(FIELD_NAME), 
    nonvar(FIELD_VALUE),
    !.
get_type(FIELD_NAME, [_ | CLASS_FIELDS], TYPE):-
    get_type(FIELD_NAME, CLASS_FIELDS, TYPE).
