
## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'puppet1.spence.org.uk.local',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {

  file { '/opt/puppet/pe_version':
    content => '3.0.0',
    replace => false,
  }

  include root
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  $moo = decrypt('/etc/puppetlabs/puppet/ssl/private_keys/puppet1.spence.org.uk.local.pem',$::encfact)
#  if $moo {
#    notify { $moo: }
#  }
  Yumrepo <<| |>>

  file { '/usr/local/bin/gem':
    ensure => link,
    target => '/opt/gem/bin/gem',
  }
  file { '/usr/local/bin/puppet':
    ensure => link,
    target => '/opt/puppet/bin/puppet',
  }
  file { '/usr/local/bin/mco':
    ensure => link,
    target => '/opt/puppet/bin/mco',
  }
  file { '/usr/local/bin/facter':
    ensure => link,
    target => '/opt/puppet/bin/facter',
  }
  file { '/usr/local/bin/irb':
    ensure => link,
    target => '/opt/puppet/bin/irb',
  }
  file { '/usr/local/bin/ruby':
    ensure => link,
    target => '/opt/puppet/bin/ruby',
  }
}

node /postgres/ inherits 'default' {

  include compiler

  class { 'pe_postgresql':
    config_hash => {
      'ip_mask_deny_postgres_user' => '0.0.0.0/32',
      'ip_mask_allow_all_users'    => '0.0.0.0/0',
      'listen_addresses'           => '*',
      'postgres_password'          => 'TPSReport!',
    },
  }
  class { 'repmgr': }

}
node 'puppet1.spence.org.uk.local' inherits 'default' {

  include pe_repo
  pe_repo::yumrepo { 'el_6_x86_64_3.0.0':
    pever => '3.0.0',
    arch  => 'x86_64',
    dist  => 'el',
    rel   => '6',
  }

}
