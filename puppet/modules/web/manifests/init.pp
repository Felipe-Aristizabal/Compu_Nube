class web (
  String  $app_dir = '/opt/webapp',
  Integer $port    = 3000,
  String  $user    = 'webapp',
) {

  package { ['curl','gnupg','ca-certificates']:
    ensure => installed,
  }

  exec { 'nodesource_setup_20':
    command => 'curl -fsSL https://deb.nodesource.com/setup_20.x | bash -',
    path    => ['/bin','/usr/bin'],
    creates => '/etc/apt/sources.list.d/nodesource.list',
    require => Package['curl'],
  }

  package { 'nodejs':
    ensure  => installed,
    require => Exec['nodesource_setup_20'],
  }

  user { $user:
    ensure     => present,
    managehome => true,
    home       => "/home/${user}",
    shell      => '/bin/bash',
  }

  file { $app_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  # usa el package.json del módulo
  file { "${app_dir}/package.json":
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    source  => 'puppet:///modules/web/package.json',
    require => File[$app_dir],
    notify  => Exec['npm_install'],
  }

  file { "${app_dir}/server.js":
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    source  => 'puppet:///modules/web/server.js',
    require => File[$app_dir],
    notify  => Exec['npm_install'],
  }

  exec { 'npm_install':
    command     => '/usr/bin/npm install',
    cwd         => $app_dir,
    user        => $user,
    environment => ["HOME=/home/${user}"],
    path        => ['/bin','/usr/bin'],
    creates     => "${app_dir}/node_modules",
    require     => [Package['nodejs'], File["${app_dir}/package.json"]],
    notify      => Exec['systemd_reload'],
  }

  file { '/etc/systemd/system/webapp.service':
    ensure  => file,
    mode    => '0644',
    content => "[Unit]
Description=Node WebApp
After=network-online.target
Wants=network-online.target

[Service]
User=${user}
WorkingDirectory=${app_dir}
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=PORT=${port}
Environment=NODE_ENV=production
Environment=CONSUL_HTTP_ADDR=127.0.0.1:8500

[Install]
WantedBy=multi-user.target
",
    notify  => Exec['systemd_reload'],
    require => [Exec['npm_install'], User[$user]],
  }

  exec { 'systemd_reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'webapp':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/systemd/system/webapp.service'],
      File["${app_dir}/server.js"],
    ],
    require   => Exec['systemd_reload'],
  }
}
