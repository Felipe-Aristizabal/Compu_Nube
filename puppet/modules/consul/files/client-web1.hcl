datacenter = "dc1"
server     = false
bind_addr  = "192.168.100.30"
client_addr = "0.0.0.0"
data_dir   = "/var/lib/consul"
retry_join = ["192.168.100.20"]
ports { dns = 8600 }
ui_config { enabled = false }
