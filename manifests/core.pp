define solr::core(
  $fields,
  $dynamicfields,
  $copyfields,
  $spellfields,
  $solr_version = $solr::params::solr_version,
  $solr_home    = $solr::params::solr_home
)  {
  include solr::params


  file { 
    "${solr_home}/${name}":
      ensure  => directory,
      owner   => "${solr::params::tomcat_user}",
      group   => "${solr::params::tomcat_group}",
      mode    => '0755';

    "${solr_home}/${name}/conf":
      ensure  => directory,
      owner   => "${solr::params::tomcat_user}",
      group   => "${solr::params::tomcat_group}",
      mode    => '0755',
      require => File["${solr_home}/${name}"];
  } ->

  file {
    "${name}-solrconfig.xml":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/solrconfig.xml",
      content => template('solr/solrconfig.xml.erb'),
      notify  => [Exec["${name}-upconfig"], Exec["${name}-linkconfig"] ];

    "${name}-schema.xml":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/schema.xml",
      content => template('solr/schema.xml.erb'),
      notify  => [Exec["${name}-upconfig"], Exec["${name}-linkconfig"] ];

    "${name}-stopwords.txt":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/stopwords.txt",
      content => template('solr/stopwords.txt.erb'),
      notify  => [Exec["${name}-upconfig"], Exec["${name}-linkconfig"] ];

    "${name}-synonyms.txt":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/synonyms.txt",
      content => template('solr/synonyms.txt.erb'),
      notify  => [Exec["${name}-upconfig"], Exec["${name}-linkconfig"] ];

    "${name}-protwords.txt":
      ensure  => file,
      path    => "${solr_home}/${name}/conf/protwords.txt",
      content => template('solr/protwords.txt.erb'),
      notify  => [Exec["${name}-upconfig"], Exec["${name}-linkconfig"] ];
  }

  #Exec installation of solr configs to zookeeper if needed
  if $solr::zookeeper_hosts {
    exec {
      "${name}-upconfig":
        command     => "java -classpath /var/tmp/solr-${solr_version}/example/webapps/WEB-INF/lib/*:/usr/share/tomcat6/lib/ext/* \
                  org.apache.solr.cloud.ZkCLI -zkhost ${solr::zookeeper_hosts} \
                  -cmd upconfig -confdir ${solr_home}/${name}/conf \
                  -confname ${name}",
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
        require     => Exec['war-extract'],
        refreshonly => true,
        before      => Exec["${name}-linkconfig"],
        notify      => Service['tomcat6'];

      "${name}-linkconfig":
        command     => "java -classpath /var/tmp/solr-${solr_version}/example/webapps/WEB-INF/lib/*:/usr/share/tomcat6/lib/ext/* \
                  org.apache.solr.cloud.ZkCLI -zkhost ${solr::zookeeper_hosts} \
                  -cmd linkconfig -collection ${name} -confname ${name}",
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
        refreshonly => true,
        require     => Exec['war-extract'],
        notify      => Service['tomcat6'];
    }

  }

}
