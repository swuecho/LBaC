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
        GetChar; # discard current look and read next
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

sub Term {
    EmitLn('MOVE #' . GetNum . ',D0');
}

sub Add {
    Match('+');
    Term();
    EmitLn('ADD D1,D0');
}


sub Subtract {
    Match('-');
    Term();
    EmitLn('SUB D1,D0');
    EmitLn('NEG D0');


}
my %Addop = ( '+' => sub { Add }  ,
              '-' => sub { Subtract } 
          );
sub Expression { 
    Term();
    my $addop_subref = $Addop{$look};
    while ($addop_subref) {
        EmitLn('MOVE D0, D1');
        $addop_subref->(); 
    }
}
#===
# main
#===

#init
sub Init { GetChar }

Init;
Expression;

