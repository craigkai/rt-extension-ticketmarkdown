use strict;
use warnings;
package RT::Extension::TicketMarkdown;

our $VERSION = '0.01';

use Text::Markdown 'markdown';

=head2

TicketToMarkdown takes a ticket ID as input and returns the tickets history
converted from Markdown to HTML.

=cut

sub TicketToMarkdown {
    my $ticket_id = shift;

    my $ticket = RT::Ticket->new(RT->SystemUser);
    my ($ret, $msg) = $ticket->Load($ticket_id);
    return ($ret, $msg) unless $ret;

    my $transactions = $ticket->Transactions;
    my $content;
    while (my $transaction = $transactions->Next) {
        if ($transaction->Type ne 'EmailRecord') {
            my $attachments = $transaction->Attachments;
            while (my $attachment = $attachments->Next) {
                next unless $attachment->ContentType =~ m!^(text/html|text/plain|message|text$)!i;
                $content .= defined $attachment->OriginalContent ? $attachment->OriginalContent : "";
            }
        }
    }
    my $html = markdown($content);

    return $html;
}

=head2

Need to store content for Tickets outside of Queue that were set to convert to HTML

=cut

=head1 NAME

RT-Extension-TicketMarkdown - Take ticket history and generate HTML page, converts Markdown text to html

=head1 DESCRIPTION

Create quick blog posts or READMEs using Tickets content.

=head1 RT VERSION

Works with RT 4.4

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

If you are using RT 4.2 or greater, add this line:

    Plugin('RT::Extension::TicketMarkdown');

Add the config option

    Set($TicketMarkdownQueue, 'General');

to select a Queue in which all the Tickets will generate a link to their content at Blog/

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 AUTHOR

Best Practical Solutions, LLC E<lt>modules@bestpractical.comE<gt>

=head1 BUGS

All bugs should be reported via email to

    L<bug-RT-Extension-TicketMarkdown@rt.cpan.org|mailto:bug-RT-Extension-TicketMarkdown@rt.cpan.org>

or via the web at

    L<rt.cpan.org|http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-TicketMarkdown>.

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2018 by Craig

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
