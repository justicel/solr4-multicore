class solr::params { 
  case $operatingsystem {
    'RedHat', 'CentOS': {
      $tomcat_user  = 'tomcat'
      $tomcat_group = 'tomcat'
      $openjdk_package = 'java-1.6.0-openjdk-devel'
    }
    /^(Debian|Ubuntu)$/: {
      $tomcat_user  = 'tomcat6'
      $tomcat_group = 'tomcat6'
      $openjdk_package = 'openjdk-6-jdk'
    }
  }

  #Generic parameters
  $solr_home       = '/etc/solr'
  $install_source  = 'http://mirrors.gigenet.com/apache/lucene/solr/4.3.1/solr-4.3.1.tgz',
  $version         = 'solr-4.3.1',

}
