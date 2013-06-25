class solr::install($solr_home,$version,$install_source) inherits solr::params {

  exec { "solr-download":
    command => "wget ${install_source}",
    cwd => "/var/tmp",
    creates => "/var/tmp/${version}.tgz",
    path => ["/usr/bin", "/usr/sbin/"],
    require => Service['tomcat6'],
  }

  exec { "solr-inflate":
    command => "tar xzf ${version}.tgz",
    cwd => "/var/tmp",
    creates => "/var/tmp/${version}/",
    path => "/bin/",
    require => Exec["solr-download"]
  }

  file { "${solr_home}":
    ensure  => "directory",
    owner   => "${solr::params::tomcat_user}",
    group   => "${solr::params::tomcat_group}",
    mode    => '0755',
  }
  file { "${solr_home}/classes":
    ensure   => directory,
    owner    => "${solr::params::tomcat_user}",
    group    => "${solr::params::tomcat_group}",
    mode     => '0755',
    require  => File["${solr_home}"],
  }

  exec { "solr-install":
    command => "cp -R ${version}/example/solr/bin ${solr_home}/bin | cp ${version}/example/multicore/zoo.cfg ${solr_home}/ | cp -R ${version}/example/webapps/solr.war ${solr_home}/",
    cwd => "/var/tmp/",
    path => ["/usr/bin", "/usr/sbin/", "/bin"],
    require => Exec["solr-inflate"]
  }

  #Copy required log4j libraries to tomcat
  exec { "solrlibs-install":
    command => "cp -R ${version}/example/lib/ext /usr/share/tomcat6/lib",
    cwd     => "/var/tmp/",
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    require => Exec['solr-inflate'],
  }

  #Add log4j properties file
  exec { "log4j-properties":
    command => "cp ${version}/example/cloud-scripts/log4j.properties ${solr_home}/classes"
    cwd     => '/var/tmp',
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    require => File["${solr_home}/classes"],
  }

}
