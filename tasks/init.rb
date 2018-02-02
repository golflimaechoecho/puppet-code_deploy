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

def token_exists?
  stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet-access', 'show')
  puts "Standard Out: #{stdout}"
  puts "Standard Error: #{stderr}"
  puts `whoami`
  if stderr.include? "No authentication token exists"
    puts "false"
    false
  else
    puts "true"
    true
  end
end

results = {}

params = JSON.parse(STDIN.read)

if params['environments'] == 'all' || params['environments'] == '--all'
  puts 'This task does not allow you to deploy ALL environments at one time. Please use a comma separated list.'
  exit 1
end

# do this unless the token exists

unless token_exists?
  #puts "Error: Code Manager requires a token, please use `puppet access login` to generate a token"
  puts "Code Manager requires a token, please use `puppet access login` to generate a token"
  exit 1
end

environments = params['environments'].split(',')

environments.each do |environment|

 results[environment] = {}

  output = puppet_code_deploy(environment) 
  outputindex = output[:stdout].index('[')
  outputeol = output[:stdout][outputindex..-1]
  outputjson = JSON.parse(outputeol) 
  json_status = outputjson[0]['status'] 

  results[environment][:result] = if json_status == 'complete'
                              "Successfully deployed the #{environment} environment"
                            else
                              "#{outputjson[0]['error']['msg']} "
                            end
end
puts results.to_json

# Puppet access token