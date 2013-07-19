# == Class: pe_repo
#
# Class to setup repositories for PE on Yum/Apt based systems
#
# === Examples
#
# include pe_repo
#
# === Authors
#
# Fiddyspence <chris.spence@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Puppet Labs
#
class pe_repo (
  $vardir = hiera('pe_repo::vardir','/opt/pe_repo'),
  $url = 'https://s3.amazonaws.com/pe-builds/released/PEVER/',
  $defaultfile = 'puppet-enterprise-PEVER-DIST-REL-ARCH.tar.gz'
){
  class { 'pe_repo::packages': } ->
  class { 'pe_repo::files': } ->
  Pe_repo::Yumrepo <| |> ->
  Pe_repo::Dpkg <| |> ->
  Class['pe_repo']
}
