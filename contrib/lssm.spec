Name:           lssm
Version:        0.02
Release:        1%{?dist}
Summary:        Web-based self-service application for LDAP accounts

Group:          Applications/Internet
License:        GPLv2+
URL:            http://github.com/stahnma/LDAPService
Source0:        lssm-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

BuildRequires:  rubygem-rake, httpd
Requires:       ruby-ldap, mod_ssl

%description
A simple, configurable LDAP account management utility.  Users can
update their account information and recover/reset lost passwords 
as long as they have an account in LDAP.  See README.

%prep
%setup -q


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/srv/lssm/{src,style,views}
cp -pr src/* $RPM_BUILD_ROOT/srv/lssm/src
cp -pr views/* $RPM_BUILD_ROOT/srv/lssm/views
cp -pr style/* $RPM_BUILD_ROOT/srv/lssm/style
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/lssm
cp -pr configuration.yaml $RPM_BUILD_ROOT/%{_sysconfdir}/lssm
pushd $RPM_BUILD_ROOT/srv/lssm
ln -s ../../%{_sysconfdir}/lssm/configuration.yaml  .
popd
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/httpd/conf.d/
cp -pr contrib/lssm-apache.conf  $RPM_BUILD_ROOT/%{_sysconfdir}/httpd/conf.d/


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc README TODO AUTHORS Rakefile
%doc contrib
%doc tests
/srv/lssm
%config(noreplace) %{_sysconfdir}/lssm
%config(noreplace) %{_sysconfdir}/httpd/conf.d/lssm-apache.conf


%changelog
* Fri Oct 23 2009 Michael Stahnke <stahnma@websages.com> - 0.01-1
- Added https support and ldaps

* Mon Aug 17 2009 Michael Stahnke <stahnma@websages.com> - 0.01-1
- Initial packaging.
