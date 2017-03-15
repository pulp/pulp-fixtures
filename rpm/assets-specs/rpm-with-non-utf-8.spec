Name:      rpm-with-non-utf-8
Version:   1
Release:   1%{?dist}
Summary:   An RPM file with non-utf-8 characters in its metadata.
License:   Public Domain
URL:       https://github.com/PulpQE/pulp-fixtures
BuildArch: noarch

%description
This file contains mostly unicode characters and should be encoded as UTF-8.
However, the following bytes don't represent valid utf-8 characters:

* 0x80 (0b10000000): €
* 0xE0 (0b11100000): à

Note that byte 0x80 does *not* correspond to the unicode code point U+0080. When
encoded with UTF-8, unicode code point U+0080 is represented by byte sequence
0xc280. Similar logic holds for 0xE0.

(Most?) Text editors won't let you insert invalid byte sequences into a
document. The byte sequences in this document were inserted with a hex editor.

See: http://www.unicode.org/charts/
%prep

%build

%install

%files

%changelog

