Name:           lssm
Version:        0.01
Release:        1%{?dist}
Summary:        Web-based self-service application for LDAP accounts

Group:          Applications/Internet
License:        GPLv2+
URL:            http://github.com/stahnma/LDAPService
Source0:        lssm-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  
Requires:       

%description


%prep
%setup -q


%build
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc README TODO AUTHORS



%changelog
