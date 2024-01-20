# OOΠ in Prolog

## Descrizione

Ai tempi di Simula e del primo Smalltalk, molto molto tempo prima di Python,
Ruby, Perl e SLDJ, i programmatori Lisp già producevano una pletora di
linguaggi object oriented. Il progetto consiste nella costruzione di
un’estensione “object oriented” di Common Lisp, chiamata OOΛ, e di
un’estensione “object oriented” di Prolog, chiamata OOΠ.

## Funzionalità Principali

-   `def_class`: definisce una classe con PARENTS e PARTS (Fields o Methods)
-   `make`: crea un'istanza di una classe (anche con Field passati)
-   `is_instance`: controlla se INSTANCE_NAME è istanza (di CLASS_NAME)
-   `inst`: ritorna l'istanza così come create da `make`
-   `field`: ritorna il valore di un FIELD in un'istanza
-   `fieldx`: ritorna il valore di un FIELD percorrendo una catena di attributi

## Installazione

Per utilizzare questo progetto, devi avere un interprete Prolog installato sul
tuo sistema.
Puoi scaricare SWI-Prolog da [qui](http://www.swi-prolog.org/Download.html).

Dopo aver installato Prolog, puoi aprire il file `oop.pl` in Prolog.

## Utilizzo

Per creare una nuova classe utilizza il predicato `def_class` come segue:

```
def_class(person, [human],
            [field(name, "Matteo", string),
            field(age, 50),
            method(talk, [], (write("Ciao")))]).
```

Per creare un'istanza di una classe utilizza il predicato `make` come segue:

```
make(p1, person, [age = 21]).
```

Poi utilizza `inst`, `field` e `fieldx` per accedere alle istanze
ed i loro campi, per esempio:

```
inst(p1, P), field(P, name, Result).
```

Puoi utilizzare i metodi che hai passato ad una classe
seguendo la sintassi di SWI-Prolog:

```
talk(p1)
```

oppure

```
inst(p1, Persona), talk(Persona).
```

## Alcuni Test Effettuati

```
def_class(person, [],
            [field(name, "matteo"),
            method(talk_p, [], (write("sono la persona")))]),
def_class(group, [],
            [field(prs, "", person),
            method(talk_g, [], (write("sono il gruppo")))]),
def_class(big, [],
            [field(grp, "", group),
            method(talk, [], (write("sono il gruppone")))]).
make(p1, person, [name = "prova"]),
make(g1, group, [prs = p1]),
make(b1, big, [grp = g1]).

field(p1, name, R).
fieldx(b1, [grp, prs, name], R).

inst(p1, P), field(P, name, R).
inst(b1, B), fieldx(B, [grp, prs, name], R).
```

## Autori e Informazioni

Questo progetto è stato fatto per l'esame di
Linguaggi di Programmazione dell'Università degli Studi di Milano-Bicocca.

Fatto da Mecenero Matteo [] e Scaldaferri Matteo [912001].
