# # encoding: utf-8

# Inspec test for recipe my_nrpe::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

expected_packages = %w(nrpe nagios-plugins-disk nagios-plugins-load nagios-plugins-procs nagios-plugins-users nagios-plugins-dummy)

expected_packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe group('nagios') do
  it { should exist }
end

describe user('nagios') do
  it { should exist }
  its('group') { should eq 'nagios' }
  its('shell') { should eq '/sbin/nologin' }
end

describe directory('/etc/nagios/nrpe.d') do
  it { should exist }
  its('owner') { should eq 'nagios' }
  its('group') { should eq 'nagios' }
  its('mode') { should cmp '0755' }
end

describe file('/etc/sudoers.d/nagios') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0440' }
  its('content') { should match(/^^Defaults:nagios !requiretty/) }
  its('content') { should match(/^nagios ALL=\(ALL\) NOPASSWD*/) }
end

describe file('/etc/nagios/nrpe.cfg') do
  its('owner') { should eq 'nagios' }
  its('group') { should eq 'nagios' }
  its('mode') { should cmp '0644' }
  its('content') { should match(%r{^pid_file=/var/run/nrpe.pid$}) }
  its('content') { should match(/^server_port=5666$/) }
  its('content') { should match(/^nrpe_user=nagios$/) }
  its('content') { should match(/^nrpe_group=nagios$/) }
  its('content') { should match(/^dont_blame_nrpe=0$/) }
  its('content') { should match(/^command_timeout=120$/) }
  its('content') { should match(%r{^include_dir=/etc/nagios/nrpe.d$}) }
  its('content') { should match(/^\#allowed_hosts=.*$/) }
  its('content') { should match(/^command\[CheckOK\]=.*$/) }
  its('content') { should match(/^command\[CheckCPU\]=.*$/) }
  its('content') { should match(/^command\[CheckDriveSize\]=.*$/) }
  its('content') { should match(/^command\[CheckMEM\]=.*$/) }
end

describe file('/etc/nagios/nrpe.d/hw.cfg') do
  its('owner') { should eq 'nagios' }
  its('group') { should eq 'nagios' }
  its('mode') { should cmp '0644' }
  its('content') { should match(/^command\[check_hw_storcli\]=.*$/) }
  its('content') { should match(/^command\[check_hw_mdraid\]=.*$/) }
  its('content') { should match(/^command\[check_hw_mdstat_mdraid\]=.*$/) }
  its('content') { should match(/^command\[check_disk_smartctl\]=.*$/) }
  its('content') { should match(/^command\[check_hw_megacli\]=.*$/) }
  its('content') { should match(/^command\[check_hw_megacli_args\]=.*$/) }
  its('content') { should match(/^command\[check_hw_medium_errors\]=.*$/) }
end

describe service('nrpe') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(5666) do
  it { should be_listening }
  its('processes') { should include 'nrpe' }
  its('protocols') { should include 'tcp' }
end
