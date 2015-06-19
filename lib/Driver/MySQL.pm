=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

# Forces the schema type to MySQL and forces engines into MyISAM format if requested
# and can dump constraints as generated by SQL::Translator

package Driver::MySQL;

use Moose;
use namespace::autoclean;
use base 'Driver';

has '+schema_type'  => (default => 'MySQL');
has 'default_table' => (isa => 'Str', is => 'ro', default => 'MyISAM');

override 'build_schema_translator' => sub {
  my ($self) = @_;
  my $translator = super();
  $translator->filters(sub {
    my ($schema) = @_;
    foreach my $t ($schema->get_tables) {
      if($self->default_table() eq 'MyISAM') {
        $t->options({ENGINE => 'MyISAM'});
        foreach my $c ($t->get_constraints) {
          if(uc($c->type) eq 'FOREIGN KEY') {
            $t->drop_constraint($c->name());
          }
        }
      }
    }
  });
  return $translator;
};

1;