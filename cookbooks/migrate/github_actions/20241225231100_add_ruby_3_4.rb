workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      # using DockerHub ruby
      unless content.include?("- ruby:3.4")
        content.gsub!(<<YAML, <<YAML)
          - ruby:3.3
YAML
          - ruby:3.3
          - ruby:3.4
YAML
      end

      # using ruby/setup-ruby
      unless content.include?('- "3.4"')
        content.gsub!(<<YAML, <<YAML)
          - "3.23
YAML
          - "3.3"
          - "3.4"
YAML
      end
    end

    only_if "ls #{workflow_file}"
  end
end
