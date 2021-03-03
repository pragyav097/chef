# encoding: utf-8
require 'chef-api'
include ChefAPI::Resource

YOUR_CHEF_SERVER = 'URL_RIGHT_HERE'


task :generate_jobs_file do
  # You can find documentation for the chef-api client here https://github.com/sethvargo/chef-api/blob/master/README.md
  ChefAPI.configure do |config|
    config.endpoint = YOUR_CHEF_SERVER

    # This is to simplify configuration. It assumes your PEM file is named the same as your username
    pem_file = Dir.glob("#{File.expand_path('~/')}/.chef/*.pem").reject { |file| file.include?('chef-validator.pem') }.first
    pem_name = File.basename pem_file, '.pem'

    config.client = pem_name
    config.key    = pem_file

    # Should this be false? Probably not
    config.ssl_verify = false
  end


  nodes = []
  return_nodes = []
  page_count = 1000
  current_start = 1
  while ((return_nodes.length == 0) || (return_nodes.length == page_count)) do
    results = PartialSearch.query(:node, { data: ['name'] }, '*:*', start: current_start, rows: page_count)
    return_nodes = results.rows.map { |node| node['data'] }
    nodes.push(*return_nodes)
    current_start += page_count
  end


  file = File.open("#{Dir.pwd}/base_jobs.groovy", 'rb')
  jobs_template = file.read
  file.close

  jobs = ''
  nodes.each do | node |
    jobs += "BaseBuildFramework.complianceJob(this, '#{node}')\n"
  end

  jobs_template
  phab_file = File.new("#{Dir.pwd}/import_jobs.groovy", 'a+')
  phab_file.puts(jobs_template.gsub! 'REPLACE_ME', jobs)
  phab_file.close
end
