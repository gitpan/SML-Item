### //////////////////////////////////////////////////////////////////////////
#
#	TOP
#

=head1 NAME

SML::Item - parsed SML item object

=cut

#------------------------------------------------------
# (C) Daniel Peder & Infoset s.r.o., all rights reserved
# http://www.infoset.com, Daniel.Peder@infoset.com
#------------------------------------------------------

###													###
###	size of <TAB> in this document is 4 characters	###
###													###

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: package
#

	package SML::Item;


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: version
#

	use vars qw( $VERSION $VERSION_LABEL $REVISION $REVISION_DATETIME $REVISION_LABEL $PROG_LABEL );

	$VERSION           = '0.10';
	
	$REVISION          = (qw$Revision: 1.3 $)[1];
	$REVISION_DATETIME = join(' ',(qw$Date: 2004/05/23 21:38:47 $)[1,2]);
	$REVISION_LABEL    = '$Id: Item.pm_rev 1.3 2004/05/23 21:38:47 root Exp root $';
	$VERSION_LABEL     = "$VERSION (rev. $REVISION $REVISION_DATETIME)";
	$PROG_LABEL        = __PACKAGE__." - ver. $VERSION_LABEL";

=pod

 $Revision: 1.3 $
 $Date: 2004/05/23 21:38:47 $

=cut


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: debug
#

	use vars qw( $DEBUG ); $DEBUG=0;
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: constants
#

	# use constant	name		=> 'value';
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: modules use
#

	require 5.005_62;

	use strict                  ;
	use warnings                ;
	
	use	SML::Parser				;
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: methods
#

=head1 METHODS

=over 4

=cut



### ##########################################################################

=item	new ( [ \@item ] )

=cut

### --------------------------------------------------------------------------
sub		new
### --------------------------------------------------------------------------
{
	my( $proto, $self ) = @_;
	
	$self	||= [];
	bless( $self, (ref( $proto ) || $proto ));
	
	$self
}


### ##########################################################################

=item	get_type ( ) : string

Get type of item, 'E'lement, 'C'omment, 'T'ext.

=cut

### --------------------------------------------------------------------------
sub		get_type
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	$self->[0]
}



### ##########################################################################

=item	is_element ( ) : bool

Return true if item is element.

=cut

### --------------------------------------------------------------------------
sub		is_element
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	$self->[0] eq 'E'

}


### ##########################################################################

=item	is_comment ( ) : bool

Return true if item is comment.

=cut

### --------------------------------------------------------------------------
sub		is_comment
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	$self->[0] eq 'C'

}


### ##########################################################################

=item	is_text ( ) : bool

Return true if item is text.

=cut

### --------------------------------------------------------------------------
sub		is_text
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	$self->[0] eq 'T'

}


### ##########################################################################

=item	is_pi ( ) : bool

Return true if item is pi (processing instruction), eg it has one of
'!', '?', '/' modifiers in tag name, see example:

 <!section>
 <?my-pi>
 </my-tag>
 
Yes, the closing tag is also considered processing instruction, however,
it could be tested by B< is_closing_tag() > method.


=cut

### --------------------------------------------------------------------------
sub		is_pi
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	length( $self->get_pi()||'' )

}


### ##########################################################################

=item	is_opening ( ) : bool

Return true if item is opening tag eg. element !pi.

=cut

### --------------------------------------------------------------------------
sub		is_opening
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	$self->is_element and not($self->is_pi)

}


### ##########################################################################

=item	is_closing ( ) : bool

Return true if item is closing tag eg. get_pi() eq '/'.

=cut

### --------------------------------------------------------------------------
sub		is_closing
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	
	( $self->get_pi()||'' ) eq '/'

}


### ##########################################################################

=item	get_pi ( ) : string

Get pi (processing instruction) mark. Valid only for element type of item, 
otherwise B< false > (by empty string '').

=cut

### --------------------------------------------------------------------------
sub		get_pi
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	$self->is_element ? $self->[1] : '';
}


### ##########################################################################

=item	get_name ( ) : string

Get name of element tag. Valid only for element type of item, 
otherwise B< false > (by empty string '').

=cut

### --------------------------------------------------------------------------
sub		get_name
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	$self->is_element ? $self->[2] : '';
}


### ##########################################################################

=item	get_text ( ) : string

Get text value of text or comment item type. For element type 
return allway B< false > (by empty string '').

=cut

### --------------------------------------------------------------------------
sub		get_text
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	$self->is_element ? '' : $self->[1];
}


### ##########################################################################

=item	get_attributes_str ( ) : string

Get attributes part of tag body as plain uparsed, unmodified string value. 
Valid only for element type of item, otherwise  B< false (by empty string '')>.

=cut

### --------------------------------------------------------------------------
sub		get_attributes_str
### --------------------------------------------------------------------------
{
	my( $self )=@_;
	$self->is_element ? $self->[3] : '';
}


### ##########################################################################

=item	get_attribute_value ( $name [, $position ] ) : string

Get value of named attribute, optionally from specified position.

=cut

### --------------------------------------------------------------------------
sub		get_attribute_value
### --------------------------------------------------------------------------
{
	my( $self, $name, $position )=@_;
	
		$position	||= 0;
	my	$attr		= $self->get_attribute( $name );
		return undef unless $attr;
		
	$attr->[$position];
}


### ##########################################################################

=item	get_attribute ( $name )

Get attribute by B<$name> represented as arrayref of corresponding values.

=cut

### --------------------------------------------------------------------------
sub		get_attribute
### --------------------------------------------------------------------------
{
	my( $self, $name )=@_;
	
	my	$attrs	=	$self->get_attributes();
		return undef unless $attrs;

	$attrs->{$name};
}


### ##########################################################################

=item	set_attribute_value ( $name, $value [, $pos ] )

Set attribute B<$name> optionaly at specified position B<$pos>.

=cut

### --------------------------------------------------------------------------
sub		set_attribute_value
### --------------------------------------------------------------------------
{
	my( $self, $name, $value, $pos )=@_;
	
	my	$attrs	=	$self->get_attributes();
	unless( $attrs )
	{
		$attrs	= $self->[4] = {};
	}
		$pos	||= 0;
	unless( exists( $attrs->{$name}[$pos] ))
	{
		push @{$attrs->{'='}}, [ $name, $pos ];
	}
	$attrs->{$name}[$pos] = $value;
}


### ##########################################################################

=item	get_attributes ( )

Get parsed attributes.

=cut

### --------------------------------------------------------------------------
sub		get_attributes
### --------------------------------------------------------------------------
{
	my( $self )=@_;

	if( !$self->[4] && $self->is_element() && !$self->is_closing() ) # note: all elements can get attributes except closing tags
	{
		$self->[4] = SML::Parser->parse_attributes( $self->get_attributes_str );
	}
	$self->[4]
}


### ##########################################################################

=item	get_attributes_names ( )

Get list of all named attributes.

=cut

### --------------------------------------------------------------------------
sub		get_attributes_names
### --------------------------------------------------------------------------
{
	my( $self )=@_;

	my	$attrs	=	$self->get_attributes();
		return undef unless $attrs;

	my	@names	= keys %$attrs;
	wantarray ? @names : \@names ;
}



### ##########################################################################

=item	build_attributes_str ( [ $strict ] )

Build new attributes_str from parsed attributes info, replacing the old one attributes_str.

If B< $strict > >= 1 or any true value, drop invalid attribute body entries, eg. <myTag #$ myAttr=1> --> <myTag myAttr=1>.

If B< $strict > >= 2, build only attributes in the 
form of single token or token with equal sign 
and quoted values, eg. <myTag #$ myAttr=1> --> <myTag myAttr="1">


=cut

### --------------------------------------------------------------------------
sub		build_attributes_str
### --------------------------------------------------------------------------
{
	my( $self, $strict )=@_;
	
	my	$attrs	= $self->get_attributes(); # important, because this forces parsing unless already done.

		$strict	||=0;
	my	$str	= '';	
	my	@order	= @{ $attrs->{'='} };
	for my $item ( @order )
	{
		my(	$key, $pos )	= @$item;
		my	$val			= $attrs->{$key}[$pos];
		next unless defined $val;
		
		if( ($key eq '*'))
		{
			$str .= qq{ $val} unless $strict;
		}
		elsif(	$val eq "\0" )
		{
			$str .= qq{ $key};
		}
		elsif(	$val !~ /["']/ and ($strict < 2 ))
		{
			$str .= qq{ $key=$val};
		}
		elsif(	$val =~ /"/ )
		{
			$str .= qq{ $key='$val'};
		}
		else
		{
			$str .= qq{ $key="$val"};
		}
	}
	
	$self->[3] = $str;
}








=back

=cut


1;

__DATA__

__END__

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: TODO
#

=head1 TODO	


=cut
