requires 'Data::Dumper::Concise' => 0;
requires 'Carp' => 0;
requires 'Scalar::Util' => 0;
requires 'Moo' => 1.003000;

on test => sub {
   requires 'Test::Fatal';
}
