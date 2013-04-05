class solr::params { 
  case $operatingsystem {
    'RedHat', 'CentOS': {
      $tomcat_user  = 'tomcat'
      $tomcat_group = 'tomcat'
      
    }
    /^(Debian|Ubuntu)$/: {
      $tomcat_user  = 'tomcat6'
      $tomcat_group = 'tomcat6'
    }
  }

  #Generic parameters
  $solr_version = '4.2.1'
}
