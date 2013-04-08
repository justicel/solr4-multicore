define solr::core(
  $fields,
  $copyfields,
  $spellfields
)  {
  include solr::params

  $solr_home = "/etc/solr"

  file { "${solr_home}/${name}":
    ensure  => directory,
    owner   => "${solr::params::tomcat_user}",
    group   => "${solr::params::tomcat_group}",
    mode    => '0755',
    notify  => Service['tomcat6'],
  }

  exec { "cp-conf-data-${name}":
    command => "cp -R solr-${solr::params::solr_version}/example/multicore/core0/* ${solr_home}/${name}/",
    cwd     => "/home/vagrant/",
    path    => ["/usr/bin", "/usr/sbin/", "/bin"],
    require => File["${solr_home}/${name}"],
    notify  => Service['tomcat6'], 
  }

  file {
    "${name}-solrconfig.xml":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/solrconfig.xml",
      content => template('solr/solrconfig.xml.erb'),
      require => Exec["cp-conf-data-${name}"],
      notify  => Service['tomcat6'];

    "${name}-schema.xml":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/schema.xml",
      content => template('solr/schema.xml.erb'),
      require => Exec["cp-conf-data-${name}"],
      notify  => Service['tomcat6'];

    "${name}-stopwords.txt":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/stopwords.txt",
      content => template('solr/stopwords.txt.erb'),
      require => Exec["cp-conf-data-${name}"],
      notify  => Service['tomcat6'];

    "${name}-synonyms.txt":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/synonyms.txt",
      content => template('solr/synonyms.txt.erb'),
      require => Exec["cp-conf-data-${name}"],
      notify  => Service['tomcat6'];

    "${name}-protwords.txt":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/protwords.txt",
      content => template('solr/protwords.txt.erb'),
      require => Exec["cp-conf-data-${name}"],
      notify  => Service['tomcat6'];
  }

}
