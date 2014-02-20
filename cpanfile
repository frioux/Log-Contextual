requires 'Data::Dumper::Concise' => 0;
requires 'Exporter::Declare' => 0.111;
requires 'Carp' => 0;
requires 'Scalar::Util' => 0;
requires 'Moo' => 1.003000;
requires 'Sub::Identify' => 0.04;

on test => sub {
   requires 'Test::Fatal';
}
