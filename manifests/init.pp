class solr (
  $active_cores    = [],
  $install_source  = $solr::params::install_source,
  $version         = $solr::params::version,
  $solr_home       = $solr::params::solr_home,
  $zookeeper_hosts = false,
  $numshards       = false,
) inherits solr::params {

  case $::operatingsystem {
    /^(Debian|Ubuntu)$/: {
      exec { 'apt-get update':
        command => '/usr/bin/apt-get update'
      }
    }
  }

  package { "${solr::params::openjdk_package}":
    ensure => present,
  }

  package { 'tomcat6':
    ensure => present,
    require => $::operatingsystem ? {
      /(?i:Debian|Ubuntu)/ => [
        Exec['apt-get update'],
        Package["${solr::params::openjdk_package}"]
      ],
      default => [
        Package["${solr::params::openjdk_package}"]
      ],
    },
  }

  class { 'solr::install':
    solr_home       => $solr_home,
    install_source  => $install_source,
    version         => $version,
    require         => Package['tomcat6'],
  }

  class { 'solr::config':
    solr_home       => $solr_home,
    cores           => $active_cores,
    zookeeper_hosts => $zookeeper_hosts,
    numshards       => $numshards,
    require         => Package['tomcat6'],
  }

}
