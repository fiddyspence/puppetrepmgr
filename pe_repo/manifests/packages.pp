# == Class: pe_repo
#
# Class container to manage the required packages for the pe_repo module
#
class pe_repo::packages {

  package { 'createrepo':
    ensure => present,
  }
  package { 'dpkg-devel':
    ensure => present,
  }

}
