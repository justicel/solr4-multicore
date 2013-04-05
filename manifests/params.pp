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
  $solr_version = '4.2.1'
}
