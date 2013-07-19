class repmgr {

  file { "${::puppet_vardir}/repmgr":
    ensure => directory,
  } ->
  exec { 'wget http://www.repmgr.org/download/repmgr-1.2.0.tar.gz':
    path => '/bin:/usr/bin:/usr/local/bin',
    cwd => "${::puppet_vardir}/repmgr",
    creates => "${::puppet_vardir}/repmgr/repmgr-1.2.0.tar.gz",
  } ->
  exec { 'tar -zxvf repmgr-1.2.0.tar.gz':
    path => '/bin:/usr/bin:/usr/local/bin',
    cwd => "${::puppet_vardir}/repmgr",
    creates => "${::puppet_vardir}/repmgr/repmgr-1.2.0",
  } ->
  exec { 'make USE_PGXS=1 install':
    path => '/bin:/usr/bin:/usr/local/bin:/opt/puppet/bin',
    cwd => "${::puppet_vardir}/repmgr/repmgr-1.2.0",
    creates => '/opt/puppet/bin/repmgr',
  }

  user { 'pe-postgres':
    ensure           => 'present',
    comment          => 'Puppet Enterprise PostgreSQL Server',
    gid              => '498',
    home             => '/opt/puppet/var/lib/pgsql',
    shell            => '/sbin/nologin',
    uid              => '497',
  }

  ssh_authorized_key { 'postgres':
    ensure => present,
    key =>  'AAAAB3NzaC1yc2EAAAABIwAAAQEAu4IlSAZrjF9VzVzDOxp0mGm9ju3pZetc1GSTeavSMlgrKqAcMAM6y+bANacQQ+gJQfnexc5g6vtwejc/z05aVEOLvEDem/qV1uLDPlj+hPesPMGOyrVDmj17ewb9PBy+vV7uOiEbxT2anypjemwOhLl3iqox7ggEOzJsIB/+ALmOxJHfmIIMyCIGjldMPZASnrOw86OAYFT+TZaipZkQafSi55OB31jcZIPaTDe/quWK3B92pgV7g0rEvqEiCMqe7q13ABTH/bLdhkG1evuGCiIFFt5WhH+doi545yyrAB2HXTCIo15MOPSFXbd3GqqnVjQzKIJz/M5m8+gIMsrJ/Q==',
    type => 'ssh-rsa',
    user => 'pe-postgres',
  }
  file { '/opt/puppet/var/lib/pgsql/.ssh':
    ensure => directory,
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
    mode   => '0600',
  }
  file { '/opt/puppet/var/lib/pgsql/.ssh/id_rsa':
    ensure => file,
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
    mode   => '0600',
    source => 'puppet:///modules/repmgr/id_rsa',
  }

  Ini_setting {
    section => '',
  }
  ini_setting { 'wal_level':
    ensure  => present,
    path    => '/opt/puppet/var/lib/pgsql/9.2/data/postgresql.conf',
    setting => 'wal_level',
    value   => 'hot_standby',
    notify  => Service['pe-postgresql'],
  }
  ini_setting { 'archive_command':
    ensure  => present,
    path    => '/opt/puppet/var/lib/pgsql/9.2/data/postgresql.conf',
    setting => 'archive_command',
    value   => '\'/bin/true\'',
    notify  => Service['pe-postgresql'],
  }
  ini_setting { 'archive_mode':
    ensure  => present,
    path    => '/opt/puppet/var/lib/pgsql/9.2/data/postgresql.conf',
    setting => 'archive_mode',
    value   => 'on',
    notify  => Service['pe-postgresql'],
  }
  ini_setting { 'max_wal_senders':
    ensure  => present,
    path    => '/opt/puppet/var/lib/pgsql/9.2/data/postgresql.conf',
    setting => 'max_wal_senders',
    value   => '10',
    notify  => Service['pe-postgresql'],
  }
  ini_setting { 'wal_keep_segments':
    ensure  => present,
    path    => '/opt/puppet/var/lib/pgsql/9.2/data/postgresql.conf',
    setting => 'wal_keep_segments',
    value   => '100',
    notify  => Service['pe-postgresql'],
  }
  ini_setting { 'hot_standby':
    ensure  => present,
    path    => '/opt/puppet/var/lib/pgsql/9.2/data/postgresql.conf',
    setting => 'hot_standby',
    value   => 'on',
    notify  => Service['pe-postgresql'],
  }

  @@postgresql::pg_hba_rule { "allow access from ${::fqdn} for repmgr":
    description => "allow access from ${::fqdn} for replication",
    type => 'host',
    database => 'repmgr',
    user => 'repmgr',
    address => "${::ipaddress}/32",
    auth_method => 'trust',
    tag   => 'repmgr_replication',
  }
  @@postgresql::pg_hba_rule { "allow access from ${::fqdn} for replication":
    description => "allow access from ${::fqdn} for replication",
    type => 'host',
    database => 'replication',
    user => 'all',
    address => "${::ipaddress}/32",
    auth_method => 'trust',
    tag   => 'repmgr_replication',
  }
  Postgresql::Pg_hba_rule <<| tag == 'repmgr_replication' |>>

}
