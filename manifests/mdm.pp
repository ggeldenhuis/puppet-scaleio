# manage a mdm
class scaleio::mdm {
  $script_dir              = '/opt/emc/scaleio/scripts'
  $scli_wrap               = "${script_dir}/scli_wrap.sh"
  $add_scaleio_user        = "${script_dir}/add_scaleio_user.sh"
  $change_scaleio_password = "${script_dir}/change_scaleio_password.sh"

  if $scaleio::callhome{
    include scaleio::mdm::callhome
  }

  if $scaleio::use_consul {
    include ::consul
  }

  # only do a new installation of the package
  package::verifiable{ 'EMC-ScaleIO-mdm':
    version        => $scaleio::version,
    manage_package => !$::package_emc_scaleio_mdm_version,
    tag            => 'scaleio-install',
  }

  file{
    $script_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      require => Package::Verifiable['EMC-ScaleIO-mdm'];
    $scli_wrap:
      content => template('scaleio/scli_wrap.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      require => File[$script_dir];
    $add_scaleio_user:
      content => template('scaleio/add_scaleio_user.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      require => File[$script_dir];
    $change_scaleio_password:
      content => template('scaleio/change_scaleio_password.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      require => File[$script_dir];
    '/etc/bash_completion.d/si':
      content => 'complete -o bashdefault -o default -o nospace -F _scli si',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File[$script_dir];
    '/usr/bin/si':
      ensure => 'link',
      target => $scli_wrap;
  }

  # Include primary mdm class, if this server shall be the primary (first setup)
  # or if we are running on the actual SIO primary mdm

  if (has_ip_address($::scaleio::mdm_ips[0]) and str2bool($::scaleio_mdm_clustersetup_needed)) or str2bool($::scaleio_is_primary_mdm) {
    include scaleio::mdm::primary
  } else{
    include scaleio::mdm::secondary
  }

}
