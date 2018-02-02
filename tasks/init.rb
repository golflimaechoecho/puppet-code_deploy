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
require 'open3'

Puppet.initialize_settings

unless Puppet[:server] == Puppet[:certname]
  puts 'This task can only be run against the Master (of Masters)'
  exit 1
end

def puppet_code_deploy(environment)
  stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet-code', 'deploy', '--wait', environment)
  {
    stdout: stdout.strip,
    stderr: stderr.strip,
    exit_code: status.exitstatus,
  }
end

results = {}

params = JSON.parse(STDIN.read)
environments = params['environments'].split(',')

environments.each do |environment|

 results[environment] = {}

  output = puppet_code_deploy(environment) 
  outputsplit = output[:stdout].split('.') 
  puts outputsplit
  outputjson = JSON.parse(outputsplit[1]) 
  json_status = outputjson[0]['status'] 

  results[environment][:result] = if json_status == 'complete'
                              "Successfully deployed the #{environment}.upcase environment"
                            else
                              output
                            end
end
puts results.to_json
