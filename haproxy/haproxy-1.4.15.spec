################################
# App info
################################
Summary: High Performance TCP/HTTP Load Balancer
Name: haproxy
Version: 1.4.15
Release: 1%{?dist}

################################
# Package info
################################
License: GPL
Group: System Environment/Daemons
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Source: %{name}-%{version}.tar.gz

################################
# Pre steps
################################
%pre
getent group haproxy >/dev/null || groupadd -r haproxy
getent passwd haproxy >/dev/null || \
useradd -r -g haproxy -d /etc/haproxy -s /sbin/nologin \
-c "haproxy daemon account" haproxy
exit 0

################################
# Prep steps
################################
%prep
rm -rf $RPM_BUILD_ROOT
%setup -q

################################
# Build steps
################################
%build
%{__make} TARGET=linux26

################################
# Install steps
################################
%install
rm -rf %{buildroot}
%{__make} DESTDIR=%{buildroot} install 

mkdir -p %{buildroot}%{_sbindir}
mkdir -p %{buildroot}%{_initrddir}
mkdir -p %{buildroot}%{_sysconfdir}/%{name}

cp %{name} %{buildroot}%{_sbindir}/
cp examples/%{name}.cfg %{buildroot}%{_sysconfdir}/%{name}/
cp examples/%{name}.init %{buildroot}%{_initrddir}/%{name}

################################
# Cleanup steps
################################
%clean
rm -rf ${RPM_BUILD_ROOT}

################################
# Main package files
################################
%description
HA-Proxy is a TCP/HTTP reverse proxy which is particularly suited for high
availability environments. Indeed, it can:
- route HTTP requests depending on statically assigned cookies
- spread the load among several servers while assuring server persistence
  through the use of HTTP cookies
- switch to backup servers in the event a main one fails
- accept connections to special ports dedicated to service monitoring
- stop accepting connections without breaking existing ones
- add/modify/delete HTTP headers both ways
- block requests matching a particular pattern

It needs very little resource. Its event-driven architecture allows it to easily
handle thousands of simultaneous connections on hundreds of instances without
risking the system's stability.

%files
%defattr(-,root,root,-)
%doc CHANGELOG TODO
%doc examples/*
%doc doc/*
%dir %{_sysconfdir}/haproxy/
%attr(0644,root,root) %config(noreplace) %{_sysconfdir}/haproxy/haproxy.cfg
%attr(0755,root,root) %{_initrddir}/haproxy
/usr/local/sbin/*
/usr/sbin/*
/usr/local/doc/haproxy/*
/usr/local/share/man/*/*

################################
# Callbacks
################################
%post
	/sbin/chkconfig --add %{name}

%preun
	/sbin/service %{name} stop 
	/sbin/chkconfig --del %{name} 

%postun
	/sbin/service %{name} condrestart 

################################
# Changelog
################################
%changelog
* Sat Apr 09 2011 Damian Zaremba <damian@damianzaremba.co.uk> - 1.4.15
- Packaged 1.4.15 up as an RPM with no patches.
