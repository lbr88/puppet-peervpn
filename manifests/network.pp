define peervpn::network (
  String $networkname     = $name,
  String $psk             = undef,
  Array $initpeers       = [],
  $enabletunneling = 'yes',
  $interface       = undef,
  $ifconfig4       = undef,
  $ifconfig6       = undef,
  $upcmd           = undef,
  $local           = undef,
  $port            = 7000,
  $sockmark        = 0,
  $enableipv4      = 'yes',
  $enableipv6      = 'yes',
  $enablenat64clat = 'no',
  $enablendpcache  = 'no',
  $enablerelay     = 'no',
  $engine          = undef,
  $enableprivdrop  = 'no',
  $user            = 'nobody',
  $group           = 'nogroup',
  $chroot          = '/var/run/peervpn/chroot',
  $cfgdir          = '/etc/peervpn',
) {
  include ::peervpn
  $servicename = downcase($networkname)
  file { "${chroot}":
    ensure => directory,
    owner => $user,
    group => $group,
    mode => "0750",
    notify => Service["peervpn@${servicename}"],
  }
  if str2bool(getvar('::systemd')) {
    $service_provider = 'systemd'
  } else {
    $service_provider = undef
  }
  service { "peervpn@${servicename}":
    ensure     => running,
    enable     => true,
    provider   => $service_provider,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['peervpn'],
  }
  /*
  // manage configs in dir
  file { "$cfgdir": 
    ensure => directory,
    purge => true,
    recursive => true,
  }
  */
  file { "/etc/peervpn/${servicename}.conf":
    ensure => file,
    content => template("peervpn/peervpn.conf.erb"),
    notify => Service["peervpn@${servicename}"],
    require => Package['peervpn'],
  }
}
