# install the MDM package either for an MDM or a TB
# and set the corresponding role
class scaleio::mdm::installation(
  $is_tiebreaker = true,
  $mdm_tb_ip = $is_tiebreaker ?{
    true  => $::scaleio::current_tb_ip,
    false => $::scaleio::current_mdm_ip,
    default => false,
  }
) inherits scaleio{

  ensure_packages(['python'])

  # only do a new installation of the package
  package { 'EMC-ScaleIO-mdm':
    ensure         => 'present',
    require        => [Package['python'], Package['numactl']],
  }

  $actor_role_is_manager = $is_tiebreaker ? {
    true  => '0',
    false => '1',
  }


  # set the actor role to manager
  file_line { 'scaleio::mdm::installation::actor':
    path    => '/opt/emc/scaleio/mdm/cfg/conf.txt',
    line    => "actor_role_is_manager=${actor_role_is_manager}",
    match   => '^actor_role_is_manager=',
    require => Package['EMC-ScaleIO-mdm'],
  } ~>
  exec{ 'scaleio::mdm::installation::restart_mdm':
    # give the mdm time to switch its role
    command     => '/usr/bin/systemctl restart mdm.service; sleep 15',
    refreshonly => true,
  }

}
