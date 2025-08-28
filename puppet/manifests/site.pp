node 'haproxyServer' {
  include roles::haproxy
}

node 'web1Server' {
  include roles::web
}

node 'web2Server' {
  include roles::web
}
