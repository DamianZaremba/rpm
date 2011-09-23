################################
# App info
################################
Summary: A RRDtool frontend for Mail statistics
Name: mailgraph
Version: 1.14
Release: 9%{?dist}

################################
# Package info
################################
License: GPL+
Group: System Environment/Daemons
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Source0:        http://mailgraph.schweikert.ch/pub/%{name}-%{version}.tar.gz
Source1:        mailgraph-%{version}.init
Source2:        mailgraph-%{version}.sysconfig
Patch0:         paths-%{version}.patch

Requires:       perl(File::Tail), rrdtool, httpd
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       initscripts

BuildArch:      noarch

################################
# Pre steps
################################
%prep
%setup -q
%patch0 -p1 -b .paths

################################
# Build steps
################################
%build

################################
# Install steps
################################
%install
rm -rf $RPM_BUILD_ROOT
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{_sbindir}
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{_initrddir}
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{_datadir}/mailgraph
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{_localstatedir}/lib/mailgraph
%{__install} -d -m 0775 $RPM_BUILD_ROOT/%{_localstatedir}/cache/mailgraph

%{__install} -p -m 0755 mailgraph.cgi $RPM_BUILD_ROOT/%{_datadir}/mailgraph
%{__install} -p -m 0644 mailgraph.css $RPM_BUILD_ROOT/%{_datadir}/mailgraph
%{__install} -p -m 0755 mailgraph.pl $RPM_BUILD_ROOT/%{_sbindir}/mailgraph
%{__install} -p -m 0755 %SOURCE1 $RPM_BUILD_ROOT/%{_initrddir}/mailgraph
%{__install} -p -m 0644 %SOURCE2 $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/mailgraph

################################
# Cleanup steps
################################
%clean
rm -rf $RPM_BUILD_ROOT

################################
# Callbacks
################################
%post
	/sbin/chkconfig --add %{name} 2>&1 > /dev/null || :

	if [ "$1" -ge "1" ]; then
		/sbin/service %{name} condrestart 2>&1 > /dev/null || :
	fi

%preun
	if [ $1 = 0 ]; then
		/sbin/service %{name} stop 2>&1 > /dev/null || :
		/sbin/chkconfig --del %{name} 2>&1 > /dev/null || :
	fi
	exit 0

%postun
	if [ "$1" -ge "1" ]; then
		/sbin/service %{name} condrestart 2>&1 > /dev/null || :
	fi

################################
# Main package files
################################
%description
Mailgraph is a very simple mail statistics RRDtool frontend for Postfix and
Sendmail that produces daily, weekly, monthly and yearly graphs of
received/sent and bounced/rejected mail.

%files
%defattr(-,root,root,-)
%doc CHANGES COPYING README
%dir %{_localstatedir}/lib/mailgraph
%{_sbindir}/*
%{_datadir}/mailgraph
%{_initrddir}/mailgraph
%config(noreplace) %{_sysconfdir}/sysconfig/mailgraph

################################
# Changelog
################################
%changelog
* Fri Apr 22 2011 Damian Zaremba <damian@damianzaremba.co.uk> - 1.14
- Packaged up 1.14 without a requirement on apache.
