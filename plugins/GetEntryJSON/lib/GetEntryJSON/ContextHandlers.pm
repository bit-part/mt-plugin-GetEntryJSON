package GetEntryJSON::ContextHandlers;

use strict;
use warnings;
use CustomFields::Field;
use CustomFields::Util qw(get_meta);

sub hdlr_get_entry_json {
    my ($ctx, $args) = @_;
    my $blog_id = $ctx->stash('blog_id');
    my $entry = $ctx->stash('entry');
    my $response = $entry->column_values();

    my $entry_categories = $entry->categories;
    if ($entry_categories) {
        $response->{categories} = [];
        foreach (@$entry_categories) {
            push @{ $response->{categories} }, $_->column_values();
        }
    }
    my $primary_category = $entry->category;
    if ($primary_category) {
        $response->{primary_category} = $primary_category->column_values();
    }

    my $terms = {
        obj_type => 'entry',
        blog_id  => $blog_id,
    };
    my @fields = CustomFields::Field->load($terms);
    if (@fields) {

        my $meta = get_meta($entry);
        my %custom_fields;
        foreach my $field (@fields) {
            my $basename = $field->basename;
            my $type = $field->type;
            my $value = $meta->{$basename};
            if ($type eq 'datetime') {
                if ($value =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/) {
                    $custom_fields{$basename} = {
                        type  => $type,
                        value => $value,
                        Y     => $1,
                        m     => $2,
                        d     => $3,
                        H     => $4,
                        M     => $5,
                        S     => $6,
                    };
                }
            }
            elsif (grep {$_ eq $type} ('file', 'image', 'video', 'audio')) {
                if ($value =~ /mt:asset-id="(\d+)"/) {
                    $custom_fields{$basename} = {
                        type  => $type,
                        value => $value,
                        id    => $1,
                    };
                }
                else {
                    $custom_fields{$basename} = {
                        type  => $type,
                        value => $value,
                        id    => '',
                    };
                }
            }
            else {
                $custom_fields{$basename} = {
                    type  => $type,
                    value => $value,
                };
            }
        }
        $response->{customFields} = \%custom_fields;
    }
    return MT::Util::to_json($response);
}
1;
