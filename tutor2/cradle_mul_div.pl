use v5.21;
use experimental 'signatures';

# constant declaration
my $TAB = '\t';

# variable declaration

my $look;    # look ahead character

# read new char from input stream
sub GetChar { $look = getc; }

# report an error
sub Error($s) { say "Error : $s "; }

# report an error and halt
sub Abort($s) { Error($s); exit; }

# report what is expected
sub Expected ( $s) { Abort("$s Expected"); }

# match a specific input character, and then move forward a char
sub Match($c) {
    if ( $look eq $c ) {
        GetChar;
    }
    else {
        Expected( ' " ' . $c . ' " ' );
    }
}

# recognize an alpha character
sub IsAlpha($c) { $c =~ /[A..Z]/ }

# recognize a decimal digit
sub IsDigit($d) { $d =~ /[0-9]/ }

# get an identifier

sub GetName {
    if ( IsAlpha($look) ) {
        my $name = uc $look;
        GetChar;
        return $name;
    }
    else {
        Expected('Name');
    }
}

# get a number
sub GetNum {
    if ( IsDigit($look) ) {
        my $num = $look;
        GetChar;    # discard current look and read next
        return $num;
    }
    else {
        Expected('Integer');
    }
}

# out put a string with tab
sub Emit($s) { print $s . $TAB }

# out put a string with crlf
sub EmitLn($s) { say $s }




#==
# expression
#==
sub Factor {
    if ( $look eq '(' ) {
        Match('(');
        Expression();
        Match(')');
    }
    elsif ( IsAlpha($look) ) {
        EmitLn( 'Move ' . GetName . '(PC),D0' );
    }
    else {
        EmitLn( 'Move ' . GetNum . ',D0' );
    }

}

#===
sub Add {
    Match('+');
    Term();
    EmitLn('ADD (SP)+,D0');
}

sub Subtract {
    Match('-');
    Term();
    EmitLn('SUB (SP)+,D0');
    EmitLn('NEG D0');

}

sub Multiply {
    Match('*');
    Factor;
    EmitLn('MULS (SP)+, D0')
}

sub Divide {
    Match('/');
    Factor;
    EmitLn('MOVE (SP)+, D0');
    EmitLn('DIV D1, D0')
}

sub Term {
    Factor;
}

#TODO: write a Set in Perl?
my %Mulop = (
    '*' => 1,
    '/' => 1, 
);

sub Term {
    Factor;
    while ( $Mulop{$look} ) {
        EmitLn('MOVE D0, -(SP)');
        if ( $look eq '*' ) {
            Multiply;
        }
        elsif ( $look eq '-' ) {
            Divide;
        }
        else {
            Expected('Mulop');
        }
    }
}

my %Addop = (
    '+' => 1,
    '-' => 1, 
);

sub Expression {
    Term();
    while ( $Addop{$look} ) {
        EmitLn('MOVE D0, -(SP)');
        if ( $look eq '+' ) {
            Add;
        }
        elsif ( $look eq '-' ) {
            Subtract;
        }
        else {
            Expected('Addop');
        }
    }
}

#===
# main
#===

#init
sub Init { GetChar }

Init;
Expression;

