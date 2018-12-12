#!/opt/puppetlabs/puppet/bin/ruby
#
# Puppet Task to run puppet code deploy
# https://puppet.com/docs/pe/2017.3/code_management/puppet_code.html
# This can only be run against the Puppet Master.
#
# Parameters:
#   * environment - A the desired environment code to be deployed.
#
require 'puppet'
require 'puppetclassify'
require 'open3'

Puppet.initialize_settings

unless Puppet[:server] == Puppet[:certname]
  puts 'This task can only be run against the Master (of Masters)'
  exit 1
end

def install_puppetclassify_gem
  stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet', 'resource', 'package', 'puppetclassify','ensure=present', 'provider=puppet_gem')
  {
    stdout: stdout.strip,
    stderr: stderr.strip,
    exit_code: status.exitstatus
  }
end

def puppet_code_deploy(environment)
  stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet-code', 'deploy', '--wait', environment)
  {
    stdout: stdout.strip,
    stderr: stderr.strip,
    exit_code: status.exitstatus
  }
end

def refresh_environment(environment)
  auth_info = {
    "ca_certificate_path" => `/opt/puppetlabs/bin/puppet config print localcacert`.strip,
    "certificate_path"    => `/opt/puppetlabs/bin/puppet config print hostcert`.strip,
    "private_key_path"    => `/opt/puppetlabs/bin/puppet config print hostprivkey`.strip,
    "read_timeout"        => 90
  }
  classifier_url = "https://#{Puppet[:server]}:4433/classifier-api"
  puppetclassify = PuppetClassify.new(classifier_url, auth_info)
  puppetclassify.update_classes.update  
end

def token_exists?
  stderr = Open3.capture3('/opt/puppetlabs/bin/puppet-code', 'deploy', 'status')
  if stderr.include? 'Error: Code Manager requires a token'
    false
  else
    true
  end
end

install_puppetclassify_gem
results = {}

params = JSON.parse(STDIN.read)

if params['environments'] == 'all' || params['environments'] == '--all'
  puts 'This task does not allow you to deploy ALL environments at one time.'
  puts 'Please use a comma separated list.'
  exit 1
end

unless token_exists?
  puts 'Error: Code Manager requires a token, please use'
  puts '`puppet access login` to generate a token'
  exit 1
end

environments = params['environments'].split(',')

environments.each do |environment|
  results[environment] = {}

  output = puppet_code_deploy(environment)
  output_index = output[:stdout].index('[')
  output_eol = output[:stdout][output_index..-1]
  output_json = JSON.parse(output_eol)
  json_status = output_json[0]['status']

  refresh_environment(environment)
  results[environment][:result] = if json_status == 'complete'
                                    "Successfully deployed the #{environment} environment. Puppet Classes refreshed."
                                  else
                                    "#{output_json[0]['error']['msg']} "
                                  end
end
puts results.to_json
