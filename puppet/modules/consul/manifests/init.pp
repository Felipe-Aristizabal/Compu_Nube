class consul {

  package { ['wget','gpg','lsb-release']:
    ensure => installed,
  }

  exec { 'add_hashicorp_gpg':
    command => 'wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg',
    path    => ['/bin','/usr/bin','/usr/local/bin'],
    creates => '/usr/share/keyrings/hashicorp-archive-keyring.gpg',
    require => Package['wget'],
  }

  exec { 'add_hashicorp_repo':
    command => 'echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list',
    path    => ['/bin','/usr/bin'],
    creates => '/etc/apt/sources.list.d/hashicorp.list',
    require => Exec['add_hashicorp_gpg'],
  }

  exec { 'apt_update':
    command     => '/usr/bin/apt-get update -y',
    refreshonly => true,
    subscribe   => Exec['add_hashicorp_repo'],
  }

  package { 'consul':
    ensure  => installed,
    require => Exec['apt_update'],
  }

  file { ['/etc/consul.d','/var/lib/consul']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Selección del HCL por hostname (ya creados en files/)
  $hcl_source = $facts['hostname'] ? {
    'haproxyServer' => 'puppet:///modules/consul/server-haproxy.hcl',
    'web1Server'    => 'puppet:///modules/consul/client-web1.hcl',
    'web2Server'    => 'puppet:///modules/consul/client-web2.hcl',
    default         => 'puppet:///modules/consul/client-default.hcl',
  }

  file { '/etc/consul.d/consul.hcl':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $hcl_source,
    require => Package['consul'],
    notify  => Service['consul'],
  }

  exec { 'check_consul_version':
    command => 'consul -v',
    path    => ['/bin','/usr/bin'],
    require => Package['consul'],
  }

  file { '/etc/systemd/system/consul.service':
    ensure  => file,
    content => "[Unit]
Description=Consul Agent
After=network.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
",
    require => Package['consul'],
    notify  => Exec['reload_systemd'],
  }

  exec { 'reload_systemd':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    path        => ['/bin','/usr/bin'],
  }

  service { 'consul':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/consul.d/consul.hcl'],
      File['/etc/systemd/system/consul.service']
    ],
  }
}
