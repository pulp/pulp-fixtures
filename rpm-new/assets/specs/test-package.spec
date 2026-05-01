Name:           test-package
Version:        1.0
Release:        1.fc41
License:        MIT
Summary:        A minimal test package for Pulp fixture use

BuildArch:      noarch

%description
A minimal package used as a test fixture for Pulp RPM.

%build
echo "test" > README

%install
mkdir -p %{buildroot}/usr/share/doc/%{name}/
cp README %{buildroot}/usr/share/doc/%{name}/

%files
%doc README

%changelog
* Fri May 01 2026 Pulp Fixtures <pulp-fixtures@example.com> - 1.0-1
- Initial test package
