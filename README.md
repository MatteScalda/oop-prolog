# oop-prolog
Linguaggi di Programmazione
AA 2023-24
Progetto E1P 2024
OOΛ e OOΠ
Marco Antoniotti e Fabio Sartori
DISCo, Universit`a degli Studi di Milano-Bicocca
Dicembre 2023
1 Scadenza
La consegna di questo elaborato `e fissata per sabato 13 gennaio 2024 alle ore 23:59 GMT+1.
2 Introduzione
Ai tempi di Simula e del primo Smalltalk, molto molto tempo prima di Python, Ruby, Perl e SLDJ, i
programmatori Lisp gi`a producevano una pletora di linguaggi object oriented. Il vostro progetto consiste
nella costruzione di un’estensione “object oriented” di Common Lisp, chiamata OOΛ, e di un’estensione
“object oriented” di Prolog, chiamata OOΠ.
OOΛ `e un linguaggio object-oriented con eredit`a multipla. Il suo scopo `e didattico e mira soprattutto
ad evidenziare aspetti dell’implementazione di linguaggi object-oriented: (1) il problema di dove e come
recuperare i valori ereditati, (2) come rappresentare i metodi e le loro chiamate e (3) come manipolare il
codice nei metodi stessi.
3 OOΛ in Common Lisp
Le primitive di OOΛ sono essenzialmente quattro: def-class, make, field e fields.
Attenzione: nel seguito le parentesi quadre sono solo parte della grammatica.
1. def-class definisce la struttura di una classe e la memorizza in una locazione centralizzata (una
variabile globale).
La sua sintassi `e:
’(’ def-class <class-name> <parents> <part>* ’)’
dove <class-name> `e un simbolo, <parents> `e una lista (possibilmente vuota) di simboli, mentre
<part> ´e un insieme di field (o campo) o `e un insieme di definizioni di metodo:
part ::= ’(’ fields <field>* ’)
| ’(’ methods <method>* ’)’
field ::= <field-name>
| ’(’ field <field-name> <value> [<field-type>] ’)’
1
method ::= ’(’ <method-name> <arglist> <form>* ’)’
field-type ::= T | <type>
dove <field-name> e <method-name> sono simboli, <value> `e un’espressione costante autovalutante
qualunque, <arglist> `e una lista di parametri standard Common Lisp e <form> `e una qualunque
espressione Common Lisp. Ci sono due modi di definire un campo: nel caso semplice, field ´e sono
un simbolo il cui valore iniziale ´e NIL e il cui tipo ´e T; nel secondo caso, si possono specificare un
valore iniziale ed un tipo (opzionale) per il campo. Se <field-type> non ´e presente, in suo default
´e T; altrimenti deve essere il nome di una classe definita con def-class o un tipo numerico Common
Lisp1
.
Se <parent> `e NIL, allora la classe non ha genitori2
.
Notate che def-class `e una funzione normale e quindi gli argomenti che appaiono nelle sue chiamate
sono valutati regolarmente. Ne consegue che negli esempi sotto <field-name> e <method-name> sono
spesso delle espressioni costituite da un simbolo quotato (o da una keyword).
Il valore ritornato da def-class `e <class-name>.
2. make: crea una nuova istanza di una classe. La sintassi `e:
’(’ make <class-name> [<field-name> <value>]* ’)’
dove <class-name> e <field-name> sono simboli, mentre <value> `e un qualunque valore Common
Lisp.
Il valore ritornato da make `e la nuova istanza di <class-name>. Naturalmente make deve controllare
che i ‘fields’ siano stati definiti per la classe.
3. is-class: restituisce T se l’atomo passatogli `e il nome di una classe. La sintassi `e:
’(’ is-class <class-name> ’)’
dove <class-name> `e un simbolo.
4. is-instance: restituisce T se l’oggetto passatogli `e l’istanza di una classe. La sintassi `e:
’(’ is-instance <value> [<class-name>]’)’
dove <class-name> `e un simbolo o T (passato per default come parametro &optional) e <value>
`e un valore qualunque. Se <class-name> `e T allora basta che <value> sia un’istanza qualunque,
altrimenti deve essere un’istanza di una classe che ha <class-name> come superclasse.
5. field: estrae il valore di un campo da una classe. La sintassi `e:
’(’ field <instance> <field-name> ’)’
dove <instance> `e una istanza di una classe e <field-name> `e un simbolo. Il valore ritornato `e il
valore associato a <field-name> nell’istanza (tale valore potrebbe anche essere ereditato dalla classe
o da uno dei suoi antenati). Se <field-name> non esiste nella classe dell’istanza (ovvero se non `e
ereditato) allora viene segnalato un errore.
1Notate che qui potete finire molto velocemente in una serie di problemi non banali; i nostri test controllano solo casi
semplici e molto intuitivi.
2Come in C++ e Common Lisp non esiste una classe particolare che fa da “radice” come java.lang.Object in Java.
2
6. field*: estrae il valore da una classe percorrendo una catena di attributi. La sintassi `e:
’(’ field* <instance> <field-name>+ ’)’
dove <instance> `e un’istanza di una classe (nel caso pi`u semplice un simbolo) e <field-name>+ `e
una lista non vuota di simboli, che rappresentano attributi nei vari oggetti recuperati. Il risultato `e il
valore associato all’ultimo elemento di <field-name>+ nell’ultima istanza (tale valore potrebbe anche
essere ereditato dalla classe o da uno dei suoi antenati). Se uno degli elementi di <field-name>+
non esiste nella classe dell’istanza, la funzione segnala un errore.
NB. Vale l’equivalenza:
CL prompt> (eq (field (field (field I ’s1) ’s2) ’s3)
(field* I ’s1 ’s2 ’s3))
T
3.1 Esempi
Creiamo una classe person
CL prompt> (def-class ’person nil ’(fields (name "Eve") (age 21 integer)))
PERSON
Ora creiamo una sottoclasse student
CL prompt> (def-class ’student ’(person)
’(fields
(name "Eva Lu Ator")
(university "Berkeley" string))
’(methods
(talk (&optional (out *standard-output*))
(format out "My name is ~A~%My age is ~D~%"
(field this ’name)
(field this ’age)))))
STUDENT
Ora possiamo creare delle istanze delle classi person e student.
CL prompt> (defparameter eve (make ’person))
EVE
CL prompt> (defparameter adam (make ’person ’name "Adam"))
ADAM
CL prompt> (defparameter s1 (make ’student ’name "Eduardo De Filippo" ’age 108))
S1
CL prompt> (defparameter s2 (make ’student))
S2
CL prompt> (defparameter s3 (make ’student :age "42"))
Error: value "42" for field X is not of type INTEGER.
. . . e possiamo anche ispezionarne i contenuti.
3
CL prompt> (field eve ’age)
21
CL prompt> (field s1 ’age)
108
CL prompt> (field s2 ’name)
"Eva Lu Ator"
CL prompt> (field eve ’address)
Error: unknown field.
Un esempio pi`u “complesso”:
CL prompt> (def-class ’p-complex nil
’(fields
(:phi 0.0 real)
(:rho 1.0 real))
’(methods
(sum (pcn)
(let ((r1 (field this :rho))
(phi1 (field this :phi))
(r2 (field pcn :rho))
(phi2 (field pcn :phi))
)
;; Do the math!
(make ’p-complex #| fix :rho and :phi |#)))
(mult (pcn) #|...|#)
(div (pcn) #|...|#)
(as-complex ()
(complex #| fix realpart and imagpart |#))
))
P-COMPLEX ;; Complex numbers in polar format.
CL prompt> (defparameter pc1 (make ’p-complex :phi (/ pi 2) :rho 42.0))
PC1
CL prompt> (mult pc1 (make ’p-complex :rho 1.0 :phi pi))
;; the printed representation of the multiplication of PC1 with the new complex number.
Come potete vedere, le keywords del CL funzionano perfettamente come “field names”; ma non usate le
keywords come nomi di metodi.
Nell’esempio precedente PC1 = ρ(cos ϕ + isin ϕ) e la moltiplicazione di due numeri complessi in forma
polare ha la rappresentazione rettangolare:
ρpc1ρnew(cos(ϕpc1 + ϕnew) + isin(ϕpc1 + ϕnew)).
4
3.2 “Metodi”
Un linguaggio ad oggetti fornisce la nozione di metodo, ovvero di una funzione in grado di eseguire codice
associato3 alla “classe”. Ad esempio, considerate la classe student definita sopra.
Domanda: come invochiamo il metodo talk?
In Java, C++, Python e Ruby, una volta definita la variabile s1, in il metodo verrebbe invocato come
s1.talk()4
. In Common Lisp ci`o sarebbe. . . inelegante. In altre parole vogliamo mantenere la notazione
funzionale e rendere possibili chiamate come la seguente:
CL prompt> (talk s1)
My name is Eduardo De Filippo
My age is 108
108
Naturalmente, se non c’e un metodo appropriato associato alla classe dell’istanza, l’invocazione deve
generare un errore.
CL prompt> (talk eve)
Error: no method or field named TALK found.
Infine, il metodo deve essere invocato correttamente su istanze di sotto-classi. Ad esempio:
CL prompt> (def-class ’studente-bicocca ’(student)
’(methods
(talk ()
(format t "Mi chiamo ~A, e studio alla Bicocca~%"
(field this ’name))))
’(fields (university "UNIMIB")))
STUDENTE-BICOCCA
CL prompt> (defparameter ernesto (make ’studente-bicocca
’name "Ernesto"))
ERNESTO
CL prompt> (talk ernesto)
Mi chiamo Ernesto
e studio alla Bicocca
NIL
Il problema `e quindi come definire automaticamente la funzione talk in modo che sia in grado di riconoscere le diverse istanze.
3.3 Suggerimenti ed Algoritmi
Per realizzare il progetto vi si consiglia di implementare ogni classe ed istanza come delle list con alcuni
elementi di base e con una association list che contiene le associazioni tra campi e valori.
Si suggerisce di realizzare prima il meccanismo di manipolazione dei campi (o “field”) in modo che
i meccanismi di ereditariet`a funzionino correttamente. Solo dopo questo passo, `e possibile attaccare il
problema della definizione corretta dei metodi.
Il codice riportato di seguito vi sar`a utile per implementare def-class e la manipolazione dei metodi.
3Tralasciamo, per questo progetto le questioni di incapsulamento e visibilit`a, nonch`e le questioni legate al polimorfismo,
viste in Julia.
4
In C++ come s1.talk(), s1->talk() o (*s1).talk() a seconda del tipo associato alla variabile s1.
5
(defparameter *classes-specs* (make-hash-table))
(defun add-class-spec (name class-spec)
(setf (gethash name *classes-specs*) class-spec))
(defun class-spec (name)
(gethash name *classes-specs*))
make-hash-table e gethash manipolano le hash tables in Common Lisp. La forma di class-spec `e un
dettaglio implementativo.
Si consiglia di rappresentare le istanze come liste5 dalla forma
’(’ oolinst <class> <field-value>* ’)’
3.3.1 Come si recupera il valore di uno field in un’istanza
Per recuperare il contenuto di uno field in un’istanza, metodo o semplice valore6
che sia, prima si guarda
dentro all’istanza, se si trova un valore allora lo si ritorna, altrimenti si cerca tra le superclassi (se ce
ne sono). Dato che potenzialmente ci sono N superclassi, con un’intero grafo di superclassi sopra, allora
bisogna decidere come attraversare il grafo. Si veda la Domanda 4 qui sotto al proposito.
Naturalmente se non si trova alcun valore per lo field cercato (ovvero, non c’`e lo field), si dovr`a
richiamare la funzione error.
Domanda 1. Posso associare dei metodi ad un’istanza?
Domanda 2. Ho bisogno di un Object?
Domanda 3. Cosa succede in questo caso?
cl-prompt> (field s1 ’talk) ; S1 `e l’istanza "Eduardo"
Domanda 4. Supponiamo di avere queste classi:
(def-class person () ’(fields (:age 42) (:name "Lilith")))
(def-class superhero ’(person) ’(fields (:age 4092)))
(def-class doctor ’(person))
(def-class fictional-character ’(person) ’(fields (:age 60)))
(def-class time-lord ’(doctor superhero fictional-character))
Definiamo ora un’istanza
(defparameter the-doctor (make ’time-lord :name "Dr. Who"))
Quale dovr`a essere il risultato di
(field the-doctor :age)
5Vi sono alternative.
6Fa differenza?
6
?
NB. Ci sono almeno tre modi di rispondere a questa domanda. L’algoritmo che dovrete implementare
dovr`a recuperare il valore dello field :age attraversando il grafo delle superclassi in profondit`a partendo
dalla prima super classe7
. Nel caso qui sopra, la risposta dovr`a quindi essere 42.
Tipo associato ad un ‘field’. Ogni volta che si associa un valore ad un campo (e.g., via make) bisogna
controllare che il tipo del campo sia corretto, ovvero che l’oggetto sia di un tipo compatibile con il tipo
dichiarato del campo. Il tipo del campo ´e esso stesso ereditato.
Una complicazione la si ha quando si definiscono delle sottoclassi. Il tipo di uno slot non pu´o essere
pi´u “ampio” in una sottoclasse8
, quindi, al momento della creazione di una classe bisogna controllare che
ci´o non accada.
CL-prompt> (def-class using-integers ()
’(fields (x 42 integer)))
USING-INTEGERS
CL-prompt> (def-class using-reals (using-integers)
’(fields (x 42.0 real)))
Error: type of slot ’X’ is a supertype of inherited type.
CL-prompt> (make ’using-integers ’x "42")
Error: value "42" for field X is not of type INTEGER.
La funzione Common Lisp subtypep vi torner`a utile in questo caso.
3.3.2 Come si “installano” i metodi
Per la manipolazione dei metodi dovete usare la funzione qui sotto per generare il codice necessario (n.b.:
richiamata all’interno della def-class o della make).
(defun process-method (method-name method-spec)
#| ... and here a miracle happens ... |#
(eval (rewrite-method-code method-name method-spec)))
Notate che rewrite-method-code prende in input il nome del metodo ed una S-expression siffatta
’(’ <arglist> <form>* ’)’ (si veda la definizione di def-class) e la riscrive in maniera tale da ricevere
in input anche un parametro this.
Ovviamente, rewrite-method-code fa met`a del lavoro. L’altra met`a la fa il codice che deve andare
al posto di #| ... and here a miracle happens... |#. Questo codice deve fare due cose
1. creare una funzione lambda anonima che si preoccupi di recuperare il codice vero e proprio del
metodo nell’istanza, e di chiamarlo con tutti gli argomenti del caso;
2. associare la suddetta lambda al nome del metodo.
Il punto (1) `e relativamente semplice ed `e una semplice riscrittura di codice; la funzione anonima creata `e
a volte chiamata funzione-trampolino (trampoline) per motivi che si chiariranno da s`e durante la stesura
del codice. Il punto (2) richiede una spiegazione. Il sistema Common Lisp deve avere da qualche parte delle
primitive per associare del codice ad un nome. In altre parole, dobbiamo andare a vedere cosa succede
sotto il cofano di defun.
Senza entrare troppo nei dettagli, si pu`o dire che la primitiva che serve a recuperare la funzione
associata ad un nome `e fdefinition.
7Ne consegue che l’ordine delle superclassi `e importante.
8Note on “variance”.
7
CL prompt> (fdefinition ’first)
#<Function FIRST>
Questa primitiva pi`o essere usata con l’operatore di assegnamento setf per associare (ovvero, assegnare)
una funzione ad un nome.
CL prompt> (setf (fdefinition ’plus42) (lambda (x) (+ x 42)))
#<Anonymous function>
CL prompt> (plus42 3)
45
Con questo meccanismo il “miracolo” in process-method diventa molto semplice da realizzare.
Si noti che non dovrebbe importare quante volte si “definisce” un metodo. Il codice di base di un metodo
dovrebbe sempre essere lo stesso (pi`u o meno una decina di righe ben formattate).
Domanda: perch`e bisogna usare fdefinition invece di richiamare direttamente defun?
Attenzione: il linguaggio OOΛ `e senz’altro divertente ma ha molti problemi semantici. Sono tutti noti!
Nei test NON si analizzer`a il comportamento del codice in casi patologici, che distolgono l’attenzione dal
principale obiettivo didattico del progetto.
4 OOΠ in Prolog
Anche le primitive di OOΠ sono essenzialmente quattro: def class, make, field e fields.
1. il predicato def class definisce la struttura di una classe e la memorizza nella “base di conoscenza”
di Prolog.
La sua sintassi `e:
def_class ’(’ <class-name> ’,’ <parents> ’)’
def_class ’(’ <class-name> ’,’ <parents> ’,’ <parts> ’)’
dove <class-name> ´e un atomo (simbolo) e <parents> `e una lista (possibilmente vuota) di atomi
(simboli), e <parts> `e una lista di termini siffatti:
part ::= <field> | <method>
field ::= field ’(’ <field-name>, <value> ’)’
| field ’(’ <field-name>, <value>, <type> ’)’
method ::= method ’(’ <method-name>, <arglist> ’,’ <form> ’)’
dove <field-name> e <method-name> sono simboli, <value> `e un oggetto qualunque, <arglist> `e
una lista di parametri standard Prolog e <form> `e una qualunque congiunzione di predicati Prolog.
Il simbolo this all’interno di <form> si riferisce all’istanza stessa.
Si noti che le regole di unificazione Prolog si applicano a <value> ed al corpo del metodo.
def_class modifica la base dati del sistema Prolog mediante assert*.
2. make: crea una nuova istanza di una classe. La sintassi `e:
8
make ’(’ <instance-name> ’,’
<class-name> ’,’
’[’ [ <field-name> ’=’ <value>
[ ’,’ <field-name> ’=’ <value> ]* ]*
’]’
’)’
dove <class-name> e <field-name> sono simboli, mentre <value> `e un qualunque termine Prolog.
Il comportamento di make cambia a seconda di che cosa `e il primo argomento <instance-name>.
• Se <instance-name> `e un simbolo allora lo si associa, nella base dati, al termine che rappresenta
la nuova istanza.
• Se <instance-name> `e una variabile allora questa viene unificata con il termine che rappresenta
la nuova istanza.
• Altrimenti <instance-name> deve essere un termine che unifica con la nuova istanza appena
creata.
make modifica la base dati del sistema Prolog mediante assert* (ma solo nel primo e nel secondo
caso appena descritti).
Create sia il predicato make/2 and il predicato make/3.
make(foo, fooclass) ≡ make(foo, fooclass, [])
Il comportamento relativamente complesso di make `e necessario per facilitare la programmazione di
oggetti composti, ad esempio, strutture ad albero o grafo.
3. is_class: ha successo se l’atomo passatogli `e il nome di una classe. La sintassi `e:
is_class ’(’ <class-name> ’)’
dove <class-name> `e un simbolo.
4. is_instance: ha successo se l’oggetto passatogli `e l’istanza di una classe. La sintassi `e:
is_instance ’(’ <value> ’)’
is_instance ’(’ <value> ’,’ <class-name> ’)’
dove <class-name> `e un simbolo e <value> `e un valore qualunque. is_instance/1 ha successo se
<value> `e un’istanza qualunque; is_instance/2 ha successo se <value> `e un’istanza di una classe
che ha <class-name> come superclasse.
5. inst: recupera un’istanza dato il nome con cui `e stata creata da make9
.
inst ’(’ <instance-name> ’,’ <instance> ’)’
9Questo predicato `e necessario in Prolog dato che, al contrario di Common Lisp non abbiamo “variabili”.
9
dove <instance-name> `e un simbolo e <instance> `e un termine che rappresenta un’istanza (o,
ovviamente, una variabile logica).
6. field: estrae il valore di un campo da una classe. La sintassi `e:
field ’(’ <instance> ’,’ <field-name> ’,’ <result> ’)’
dove <instance> `e un’istanza di una classe (nel caso pi`u semplice un simbolo) e <field-name> `e un
simbolo. Il valore recuperato viene unificato con <result> ed `e il valore associato a <field-name>
nell’istanza (tale valore potrebbe anche essere ereditato dalla classe o da uno dei suoi antenati). Se
<field-name> non esiste nella classe dell’istanza il predicato fallisce.
7. fieldx: estrae il valore da una classe percorrendo una catena di attributi. La sintassi `e:
fieldx ’(’ <instance> ’,’ <field-names> ’,’ <result> ’)’
dove <instance> `e un’istanza di una classe (nel caso pi`u semplice un simbolo) e <field-namea> `e
una lista non vuota di simboli, che rappresentano attributi nei vari oggetti recuperati. Il valore recuperato viene unificato con <result> ed `e il valore associato all’ultimo elemento di <field-names>
nell’ultima istanza (tale valore potrebbe anche essere ereditato dalla classe o da uno dei suoi antenati). Se uno degli elementi di <field-names> non esiste nella classe dell’istanza il predicato fallisce.
NB. Vale l’equivalenza (e simili):
?- field(I1, s1, V1),
| field(V1, s2, V2),
| field(V2, s3, R),
| fieldx(I1, [s1, s2, s3], R).
Per semplificare, dovrete anche implementare make/2 che non prevede di modificare i valori degli field.
4.1 Esempi
Creiamo una classe person
?- def_class(person, [], [field(name, ’Eve’), field(age, 21, integer)]).
Ora creiamo una sottoclasse student
?- def_class(student, [person],
[field(name, ’Eva Lu Ator’),
field(university, ’Berkeley’),
method(talk, [],
(write(My name is ’),
field(this, name, N),
writeln(N),
write(’My age is ’)
field(this, age, A),
writeln(A)))]).
Ora possiamo creare delle istanze delle classi person e student.
10
?- make(eve, person).
result...
?- make(adam, person, [name = ’Adam’]).
result...
?- make(s1, student, [name = ’Eduardo De Filippo’, age = 108]).
result...
?- make(s2, student).
result...
?- make(s3, student, [name = ’Harry Potter’, age = "12"]).
fail % Si puo‘ stampare un messaggio di errore.
. . . e possiamo anche ispezionarne i contenuti.
?- field(eve, age, A).
A = 21
?- field(s1, age, A).
A = 108
?- field(s2, name, N).
N = ’Eva Lu Ator’
?- field(eve, address, Address).
false
4.2 “Metodi”
I “metodi” in OOΠ sono normali predicati Prolog che mettono in relazione un’istanza ed una serie di altri
argomenti. Anche in questo caso non ci preoccupiamo di incapsulamento e visibilit`a. Anche per OOΠ
valgono le stesse domande poste per OOΛ. Considerate la classe student definita sopra.
Domanda: come invochiamo il metodo talk?
In OOΠ vogliamo poter valutare il predicato talk come nell’esempio qui sotto:
?- talk(s1).
My name is Eduardo De Filippo
My age is 108
result...
Naturalmente, se non c’e un metodo appropriato associato alla classe dell’istanza, l’invocazione deve fallire.
?- talk(eve).
false
Come per OOΛ, in OOΠ il metodo deve essere verificabile correttamente su istanze di sotto-classi. Ad
esempio:
11
?- def_class(studente_bicocca, [studente],
[method(talk, [],
(write(’Mi chiamo ’),
field(this, name, N),
writeln(N),
writeln(’e studio alla Bicocca.’))),
method(to_string, [ResultingString],
(with_output_to(string(ResultingString),
(field(this, name, N),
field(this, university, U),
format(’#<~w Student ~w>’,
[U, N])))))
field(university, ’UNIMIB’)]).
result...
?- make(ernesto, studente_bicocca, [name = ’Ernesto’]).
true
?- talk(ernesto).
Mi chiamo Ernesto
e studio alla Bicocca
true
?- to_string(ernesto, S).
S = "#<UNIMIB Student Ernesto>"
Anche in questo caso, il problema `e come definire automaticamente i predicato talk e to string in
modo che siano in grado di riconoscere le diverse istanze. Notate come il predicato to string abbia due
argomenti ed il secondo sia usato come output (la semantica, dopotutto, `e quella Prolog).
4.3 Suggerimenti ed Algoritmi
Il suggerimento pi`u importante `e di ragionare in termini di base di dati. Ogni classe ed ogni istanza pu`o essere mappata su una serie di predicati interni. Ad esempio, un predicato potrebbe essere field value in class/3.
Altri predicati utili potrebbero essere instance of/2, superclass/2
4.3.1 Come si recupera il valore di uno field in un’istanza
In Prolog potrebbe essere pi`u semplice assicurarsi che ogni field sia direttamente associato all’istanza
creata da make. Ci`o significa che al momento di verificare un’istanziazione di make bisogner`a preoccuparsi
di ereditare tutti i valori ed i metodi. A questo proposito, si consiglia di studiare i predicati findall/3
e/o bagof/3.
Tipi dei ‘fields’. Anche in questo caso dovete controllare il tipo associato ai ‘fields’ nello stesso modo
descritto per il Common Lisp. Dovrete per´o implementare l’equivalente di subtypep almeno per i tipi
numerici.
12
4.3.2 Come si “installano” i metodi
Per manipolare i metodi in Prolog bisogna seguire una serie di passi alternativi.
Innanzitutto, nel “corpo” di un metodo, ovvero nella congiunzione di letterali, l’atomo this non pu`o
essere lasciato immutato. Ad esso va sostituita una variabile logica. Quindi `e necessario avere un predicato
che possa sostituire un atomo con un altro termine (inclusa una variabile logica); questo predicato `e
concettualmente semplice, ma richiede attenzione nella sua implementazione.
Una volta processato il corpo del predicato/metodo, baster`a fare una assert* appropriata per installare il predicato.
Attenzione: per trattare correttamente l’“invocazione” dinamica dei predicati/metodi sar`a necessario
asserire dei tests che precedono ogni chiamata vera e propria: il loro compito `e di implementare correttamente l’algoritmo di selezione del predicato/metodo da eseguire. Inoltre, bisogner`a accertarsi che solo
il predicato/metodo corretto venga eseguito. A questo proposito, si suggerisce di studiare il predicato di
sistema clause/2 in congiunzione con il predicato call.
Attenzione: anche il linguaggio OOΠ `e senz’altro divertente ma ha molti problemi semantici – pi`u di
OOΛ. Anche in questo caso sono tutti noti e nei tests NON si analizzer`a il comportamento del codice in
casi patologici, che non rappresentano l’obiettivo del progetto.
13
5 Da consegnare. . .
LEGGERE ATTENTAMENTE LE ISTRUZIONI QUI SOTTO.
PRIMA DI CONSEGNARE, CONTROLLATE ACCURATAMENTE
CHE TUTTO SIA NEL FORMATO E CON LA STRUTTURA DI CARTELLE
RICHIESTI.
Stesura del Codice
Valgono tutte le regole descritte sul sito Moodle e spiegate a lezione e a laboratorio.
Copia e Incolla. NON fate copia-incolla pedestre, specialmente da testo PDF. Questo causa normalmente l’inclusione di caratteri spurii nel testo con conseguente impossibilit´a a caricare il testo (vedasi sotto
per le conseguenze).
Consegna
Dovete consegnare:
Uno .zip file dal nome <Cognome> <Nome> <matricola> ool LP 202401.zip che conterr`a una
cartella dal nome <Cognome> <Nome> <matricola> ool LP 202401.
Inoltre. . .
• Nella cartella dovete avere due sottocartella di nome Lisp e Prolog.
• Nella directory Lisp dovete avere:
– un file dal nome ool.lisp che contiene il codice di def-class, make, etc. Inoltre dovete avere
il codice che realizza la definizione dei metodi.
∗ Le prime linee del file devono essere dei commenti con il seguente formato, ovvero
devono fornire le necessarie informazioni secondo le regole sulla collaborazione pubblicate
su Moodle.
;;;; <Cognome> <Nome> <Matricola>
;;;; <eventuali collaborazioni>
Il contenuto del file deve essere ben commentato.
– Un file README in cui si spiega come si possono usare i predicati definiti nel programma.
Nel file README vanno anche indicati i nomi e le matricole dei componenti del gruppo.
• Nella directory Prolog dovete avere:
– un file dal nome oop.pl che contiene il codice di def class, make, etc. Inoltre dovete avere il
codice che realizza la definizione dei metodi.
∗ Le prime linee del file devono essere dei commenti con il seguente formato, ovvero
devono fornire le necessarie informazioni secondo le regole sulla collaborazione pubblicate
su Moodle.
14
%%%% <Cognome> <Nome> <Matricola>
%%%% <eventuali collaborazioni>
Il contenuto del file deve essere ben commentato.
– Un file README in cui si spiega come si possono usare i predicati definiti nel programma.
Nel file README vanno anche indicati i nomi e le matricole dei componenti del gruppo.
ATTENZIONE!
Consegnate solo dei files e directories con nomi fatti come spiegato. Niente spazi extra e soprattutto
niente .rar or .7z o .tgz – solo .zip!
Repetita juvant! NON CONSEGNARE FILES .rar!!!!
Esempio:
File .zip:
Antoniotti_Marco_424242_ool_LP_202401.zip
Che contiene:
prompt$ unzip -l Antoniotti_Marco_424242_ool_LP_202401.zip
Archive: Antoniotti_Marco_424242_ool_LP_202401.zip
Length Date Time Name
-------- ---- ---- ----
0 12-09-23 09:59 Antoniotti_Marco_424242_ool_LP_202401/
0 12-09-23 09:55 Antoniotti_Marco_424242_ool_LP_202401/Lisp/
4623 12-09-23 09:51 Antoniotti_Marco_424242_ool_LP_202401/Lisp/ool.lisp
10598 12-09-23 09:53 Antoniotti_Marco_424242_ool_LP_202401/Lisp/README.txt
0 12-09-23 09:55 Antoniotti_Marco_424242_ool_LP_202401/Prolog/
4623 12-09-23 09:51 Antoniotti_Marco_424242_ool_LP_202401/Prolog/oop.pl
10598 12-09-23 09:53 Antoniotti_Marco_424242_ool_LP_202401/Prolog/README.txt
-------- -------
15221 4 files
ATTENZIONE ai nomi dei singoli files!
Valutazione
Il programma sar`a valutato sulla base di una serie di test standard. In particolare si valuter`a la copertura
e correttezza di def-class, make, field, fields, def class, field, fields e dei metodi.
I tests saranno condotti su SWI-Prolog versione almeno 9.1.11 e su Lispworks vesione almeno 8.1.
Ragioni di esclusione
Se il vostro progetto non si pu´o caricare – per qualunque ragione – in Lispworks e/o in SWI-Prolog, il
vostro progetto risulter´a insufficiente. Inoltre, il vostro progetto risulter´a insufficiente se non rispetter´a le
specifiche. Non saranno ammesse deroghe.
15
