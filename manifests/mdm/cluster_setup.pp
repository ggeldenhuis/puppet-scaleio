# setup a MDM cluster
class scaleio::mdm::cluster_setup {

  $primary_mdm_ips = join(any2array($::scaleio::mdms[$::scaleio::bootstrap_mdm_name]['ips']), ',')
  $primary_mdm_mgmt_ips = join(any2array($::scaleio::mdms[$::scaleio::bootstrap_mdm_name]['mgmt_ips']), ',')

  exec{ 'scaleio::mdm::cluster_setup::create_cluster':
    command => "/usr/bin/scli --create_mdm_cluster --master_mdm_ip ${primary_mdm_ips} --master_mdm_name ${::scaleio::bootstrap_mdm_name} --use_nonsecure_communication --accept_license; sleep 5",
    onlyif  => '/usr/bin/scli --query_cluster --approve_certificate 2>&1 |grep -qE "Error: MDM failed command.  Status: The MDM cluster state is incorrect"',
    require => Exec['scaleio::mdm::installation::restart_mdm'],
  }->
  exec{ 'scaleio::mdm::cluster_setup::login_default':
    command => "/usr/bin/scli --login --username admin --password ${::scaleio::old_password}",
    unless  => "/usr/bin/scli --login --username admin --password ${::scaleio::password} && scli --logout",
  } ~>
  exec{ 'scaleio::mdm::cluster_setup::primary_change_pwd':
    command     => "/usr/bin/scli --set_password --old_password ${::scaleio::old_password} --new_password ${scaleio::password}",
    refreshonly => true,
  }

  # create the MDMs as standby MDMs
  create_resources('scaleio_mdm', $scaleio::mdms, {
    ensure        => present,
    is_tiebreaker => false,
    require       => Exec['scaleio::mdm::cluster_setup::primary_change_pwd']
  })

  create_resources('scaleio_mdm', $scaleio::tiebreakers, {
    ensure        => present,
    is_tiebreaker => true,
    require       => Exec['scaleio::mdm::cluster_setup::primary_change_pwd']
  })

  Scaleio_mdm<||> -> Scaleio_mdm_cluster<||>

  scaleio_mdm_cluster{ 'mdm_cluster':
    mdm_names => keys($::scaleio::mdms),
    tb_names  => keys($::scaleio::tiebreakers),
  }
}
