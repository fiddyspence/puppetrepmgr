class compiler {

  package { ['gcc','make','pam-devel','libxslt-devel','pe-postgresql-devel','openssl-devel','readline-devel']:
    ensure => present,
  }

}
