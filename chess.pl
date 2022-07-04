% This file serves as the driver file. The user will consult this file and perform inputs here

:- [inputs].
:- [rules].

start :- 
    instructions(_),
    read_line_to_codes(user_input,Cs),
    atom_codes(Atom, Cs),
    write(Cs),
    validate_input(Cs).
