# manage a sds
class scaleio::sds {
  include ::scaleio

  # only do a new installation of the package
  package{'EMC-ScaleIO-sds':
    ensure  => 'present',
    require => Package['numactl'],
  }
}
