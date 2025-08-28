class haproxy {
  package { ['haproxy','curl']:
    ensure => installed,
  }

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/haproxy/haproxy.cfg',
    require => Package['haproxy'],
  }

  file { '/etc/sysctl.d/99-icmp.conf':
    ensure  => file,
    mode    => '0644',
    content => "net.ipv4.icmp_echo_ignore_all=0\n",
    notify  => Exec['sysctl_reload'],
  }

  exec { 'sysctl_reload':
    command     => '/sbin/sysctl --system',
    refreshonly => true,
  }


  exec { 'haproxy-validate':
    command     => 'haproxy -c -f /etc/haproxy/haproxy.cfg',
    path        => ['/usr/sbin','/usr/bin','/bin'],
    refreshonly => true,
    subscribe   => File['/etc/haproxy/haproxy.cfg'],
  }

  service { 'haproxy':
    ensure    => running,
    enable    => true,
    subscribe => Exec['haproxy-validate'],
  }
}
