#! /usr/bin/perl
#
#   This file is part of the WebKit project
#
#   Copyright (C) 2010 Andras Becsi (abecsi@inf.u-szeged.hu), University of Szeged
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Library General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Library General Public License for more details.
#
#   You should have received a copy of the GNU Library General Public License
#   along with this library; see the file COPYING.LIB.  If not, write to
#   the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.

use strict;
use Switch;
use File::Basename;

my $outdir = $ARGV[0];
shift;
my $option = basename($ARGV[0],".gperf");

my $hashToolsHeader = "$outdir/HashTools.h";

sub createHashToolsHeader() {

open HEADER, ">$hashToolsHeader" || die "Could not open $hashToolsHeader for writing";
print HEADER << "EOF";
/* This file is automatically generated by make-hash-tools.pl, do not edit */

#ifndef HashTools_h
#define HashTools_h

#include "wtf/Platform.h"

namespace WebCore {

struct PubIDInfo {
    enum eMode {
        eQuirks,
        eQuirks3,
        eAlmostStandards
    };

    const char* name;
    eMode mode_if_no_sysid;
    eMode mode_if_sysid;
};

struct NamedColor {
    const char* name;
    unsigned ARGBValue;
};

struct Property {
    const char* name;
    int id;
};

struct Value {
    const char* name;
    int id;
};

const PubIDInfo* findDoctypeEntry(register const char* str, register unsigned int len);
const NamedColor* findColor(register const char* str, register unsigned int len);
const Property* findProperty(register const char* str, register unsigned int len);
const Value* findValue(register const char* str, register unsigned int len);
}

#endif // HashTools_h

EOF
close HEADER;

}

switch ($option) {

case "DocTypeStrings" {

    createHashToolsHeader();

    my $docTypeStringsImpl         = "$outdir/DocTypeStrings.cpp";
    my $docTypeStringsGenerated    = "$outdir/DocTypeStringsHash.h";
    my $docTypeStringsGperf        = $ARGV[0];
    shift;

    open DOCTYPESTRINGS, ">$docTypeStringsImpl" || die "Could not open $docTypeStringsImpl for writing";
    print DOCTYPESTRINGS << "EOF";
/* This file is automatically generated by make-hash-tools.pl, do not edit */

#include <string.h>
#include "HashTools.h"

namespace WebCore {
#include "DocTypeStringsHash.h"

const PubIDInfo* findDoctypeEntry (register const char* str, register unsigned int len)
{
    return DocTypeStringsHash::findDoctypeEntryImpl(str, len);
}

}

EOF
    close DOCTYPESTRINGS;

    system("gperf --key-positions=\"*\" -s 2 $docTypeStringsGperf > $docTypeStringsGenerated") == 0 || die "calling gperf failed: $?";

} # case "DocTypeStrings"

case "ColorData" {

    my $colorDataImpl              = "$outdir/ColorData.cpp";
    my $colorDataGenerated         = "$outdir/ColorDataHash.h";
    my $colorDataGperf             = $ARGV[0];
    shift;

    open COLORDATA, ">$colorDataImpl" || die "Could not open $colorDataImpl for writing";
    print COLORDATA << "EOF";
/* This file is automatically generated by make-hash-tools.pl, do not edit */

#include <string.h>
#include "HashTools.h"

namespace WebCore {
#include "ColorDataHash.h"

const struct NamedColor* findColor (register const char* str, register unsigned int len)
{
    return ColorDataHash::findColorImpl(str, len);
}

}

EOF
    close COLORDATA;

    system("gperf --key-positions=\"*\" -D -s 2 $colorDataGperf > $colorDataGenerated") == 0 || die "calling gperf failed: $?";

} # case "ColorData"

} # switch ($option)
