class solr::install($solr_home,$version,$install_source) inherits solr::params {

  #Start tomcat6 if necessary
  service { 'tomcat6':
    ensure  => running,
    require => Package['tomcat6'],
  }

  exec { "solr-download":
    command => "wget ${install_source}",
    cwd => "/var/tmp",
    creates => "/var/tmp/${version}.tgz",
    path => ["/usr/bin", "/usr/sbin/"],
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

  exec { "solr-install":
    command => "cp -R ${version}/example/solr/bin ${solr_home}/bin | cp ${version}/example/multicore/zoo.cfg ${solr_home}/ | cp -R ${version}/example/webapps/solr.war ${solr_home}/",
    cwd     => "/var/tmp/",
    path    => ["/usr/bin", "/usr/sbin/", "/bin"],
    require => Exec["solr-inflate"],
    creates => "${solr_home}/solr.war",
    before  => Service['tomcat6'],
  }

  file { "${solr_home}/bin":
    ensure  => directory,
    owner   => "${solr::params::tomcat_user}",
    group   => "${solr::params::tomcat_group}",
    mode    => '0755',
    recurse => true,
    require => Exec['solr-install'],
  }
  file { "${solr_home}/zoo.cfg":
    ensure  => file,
    owner   => "${solr::params::tomcat_user}",
    group   => "${solr::params::tomcat_group}",
    mode    => '0644',
    require => Exec['solr-install'],
  }
  file { "${solr_home}/solr.war":
    ensure  => file,
    owner   => "${solr::params::tomcat_user}",
    group   => "${solr::params::tomcat_group}",
    mode    => '0644',
    require => Exec['solr-install'],
  }

  #Copy required log4j libraries to tomcat
  exec { "solrlibs-install":
    command => "cp -R ${version}/example/lib/ext/* /usr/share/tomcat6/lib",
    cwd     => "/var/tmp/",
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    require => Exec['solr-inflate'],
    creates => '/usr/share/tomcat6/lib/log4j-1.2.16.jar',
  }

  #Add log4j properties file
  exec { "log4j-properties":
    command => "cp ${version}/example/cloud-scripts/log4j.properties /usr/share/tomcat6/lib",
    cwd     => '/var/tmp',
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    require => Exec['solr-inflate'],
    creates => '/usr/share/tomcat6/lib/log4j.properties',
    before  => Service['tomcat6'],
  }

  #Extract war file
  exec { "war-extract":
    command => "jar xf solr.war",
    cwd     => "/var/tmp/${version}/example/webapps",
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    require => Exec['solr-inflate'],
    creates => "/var/tmp/${version}/example/webapps/admin.html",
  }

}
