package MB2EML::Metabase;
use Moose;
use strict;
use warnings;
use Config::Simple;

use lib './lib';
#use namespace::autoclean;

has 'schema' => ( is => 'rw' );
has 'databaseName' => ( is => 'ro', isa => 'Str', required => 1);
has 'datasetid' => ( is => 'ro', isa => 'Num' );

# Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing
sub BUILD {
    my $self = shift;

    # Load config file
    my $cfg = new Config::Simple('config/mb2eml.ini');
    # get PostgreSQL account and pass
    my $account = $cfg->param('account');
    my $pass = $cfg->param('pass');
    my $host = $cfg->param('host');

    # Open a conection to the mcr_metabase database. The 'quote_names' option causes table
    # names and columns to be quoted in any SQL that DBIC creates. This is necessary if the
    # Postgresql table names or field names are mixed case, because if Postgresql is sent a
    # query with mixed case names, it will 'case_fold' them to lower case, so the names in the
    # SQL won't match the Postgresql names and the query will fail.
    # Note: export DBIC_TRACE=1 to have DBIC print out the SQL that it generates
    if ($self->databaseName eq "mcr_metabase") {
        use mcr_metabase::Schema;
        $self->schema(mcr_metabase::Schema->connect('dbi:Pg:dbname="mcr_metabase";host=' . $host, $account, $pass,
           { on_connect_do => ['SET search_path TO mb2eml, public']}), { quote_names => 1 });
    }
    else {
        use sbc_metabase::Schema;
        $self->schema(sbc_metabase::Schema->connect('dbi:Pg:dbname="sbc_metabase";host='. $host, $account, $pass,
          { on_connect_do => ['SET search_path TO mb2eml, public']}, { quote_names => 1 }));
    }
}

sub DEMOLISH {
    my $self = shift;

    # Close any open database connection
    # Note: DEMOLISH is called automatically when this Moose object goes out of scope, which 
    # is the case at the end of the program
    $self->schema->storage->disconnect();
}

sub getAbstract {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlAbstract')->search({ datasetid => $datasetId})->single;

}

sub getAccess {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my @accesses = ();

    # resultset returns an iterator
    return $self->schema->resultset('VwEmlAccess')->search({ datasetid => $datasetId, entity_sort_order => $entityId })->single;
    
    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
    #return @accesses;
}

sub getAlternateIdentifier {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;

    # Return a single row, which is a hash of DBIC access methods named for the column that they access 
    return $self->schema->resultset('VwEmlAlternateidentifier')->search({ datasetid => $datasetId, entity_sort_order => $entityId })->single;

}

sub getAssociatedParties {
    my $self = shift;
    my $datasetId = shift;
    my @associatedParties = ();

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlAssociatedparty')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $associatedParty = $rs->next) {
        push(@associatedParties, $associatedParty);
        #print "party: " . $associatedParty->nameid . "\n";
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@associatedParties;
}

sub getAttributeList {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my @attributeList = ();
    my $dataType;

    # resultset returns an iterator
    # Retrieve attributes for a particular dataset and entity, ordered by entity sort order
    my $rs = $self->schema->resultset('VwEmlAttributelist')->search({ datasetid => $datasetId, entity_sort_order => $entityId }, { order_by => { -asc => 'column_sort_order' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $attribute = $rs->next) {
        push(@attributeList, $attribute);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@attributeList;
}

sub getContacts {
    my $self = shift;
    my $datasetId = shift;
    my @contacts = ();

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlContact')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $contact = $rs->next) {
        push(@contacts, $contact);
    }

    return \@contacts;
}

sub getCreators {
    my $self = shift;
    my $datasetId = shift;
    my @creators = ();

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlCreator')->search({ datasetid => $datasetId }, { order_by => { -asc => 'authorshiporder' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $creator = $rs->next) {
        push(@creators, $creator);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@creators;
}

sub getDistribution {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlDistribution')->search({ datasetid => $datasetId})->single;
}

sub getEntities{
    my $self = shift;
    my $datasetId = shift;
    my @entities;

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlEntity')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $entity = $rs->next) {
        push(@entities, $entity);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@entities;
}

sub getGeographicCoverage {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my @geographicCoverage = ();

    my $rs = $self->schema->resultset('VwEmlGeographiccoverage')->search({ datasetid => $datasetId, entity_sort_order => $entityId }, { order_by => { -asc => 'column_sort_order' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $coverage = $rs->next) {
        #print "coverage: " . $coverage->begindate . "\n";
        push(@geographicCoverage, $coverage);
    }

    return \@geographicCoverage;
}

sub getIntellectualRights {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlIntellectualrights')->search({ datasetid => $datasetId})->single;
}

sub getKeywords {
    my $self = shift;
    my $datasetId = shift;
    my @keywords = ();

    my $rs = $self->schema->resultset('VwEmlKeyword')->search({ datasetid => $datasetId }, { order_by => { -asc => 'keywordthesaurus'}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $keyword = $rs->next) {
        push(@keywords, $keyword);
    }

    return \@keywords;
}

sub getLanguage {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlLanguage')->search({ datasetid => $datasetId})->single;
}

sub getMethods {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my $columnId = shift;
    my @methods;

    my $rs = $self->schema->resultset('VwEmlMethods')->search({ datasetid => $datasetId, entity_sort_order => $entityId, column_sort_order => $columnId }, { order_by => { -asc => 'column_sort_order' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $method = $rs->next) {
        #print "metabase methodstep: " . $method->methodstep. "\n";
        push(@methods, $method);
    }

    return \@methods;
}

sub getPhysical {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;

    # resultset returns resultSet object
    # Retrieve physical format description for a particular dataset and entity
    return $self->schema->resultset('VwEmlPhysical')->search({ datasetid => $datasetId, sort_order => $entityId })->single;
}

sub getProject {
    my $self = shift;
    my $datasetId = shift;

    # Retrieve project description for a particular dataset and entity
    return $self->schema->resultset('VwEmlProject')->search({ datasetid => $datasetId })->single;
}

sub getPublisher {
    my $self = shift;
    my $datasetId = shift;

    return $self->schema->resultset('VwEmlPublisher')->search({ datasetid => $datasetId })->single;
}

sub getTemporalCoverage {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my $columnId = shift;
    my @temporalCoverage = ();

    #print "$entityId , $datasetId \n";
    my $rs = $self->schema->resultset('VwEmlTemporalcoverage')->search({ datasetid => $datasetId, entity_sort_order => $entityId, column_sort_order => $columnId }, { order_by => { -asc => 'column_sort_order' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $coverage = $rs->next) {
        #print "coverage: " . $coverage->begindate . "\n";
        push(@temporalCoverage, $coverage);
    }

    return \@temporalCoverage;
}

sub getTaxonomicCoverage {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my $columnId = shift;
    my @taxonomicCoverage = ();

    #print "$entityId , $datasetId \n";
    my $rs = $self->schema->resultset('VwEmlTaxonomiccoverage')->search({ datasetid => $datasetId, entity_sort_order => $entityId, column_sort_order => $columnId }, { order_by => { -asc => 'column_sort_order' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $coverage = $rs->next) {
        #print "coverage: " . $coverage->begindate . "\n";
        push(@taxonomicCoverage, $coverage);
    }

    return \@taxonomicCoverage;
}

sub getTitle{
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlTitle')->search({ datasetid => $datasetId})->single;
}

sub getUnitList {
    my $self = shift;
    my $datasetId = shift;
    my @unitList = ();

    my $rs = $self->schema->resultset('VwStmmlUnitlist')->search({ datasetid => $datasetId }, { order_by => { -asc => 'unit'}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $unit = $rs->next) {
        push(@unitList, $unit);
    }

    return \@unitList;
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

