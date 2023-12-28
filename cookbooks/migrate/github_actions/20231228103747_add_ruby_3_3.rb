workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      # using DockerHub ruby
      unless content.include?("- ruby:3.3")
        content.gsub!(<<YAML, <<YAML)
          - ruby:3.2
YAML
          - ruby:3.2
          - ruby:3.3
YAML
      end

      # using ruby/setup-ruby
      unless content.include?('- "3.3"')
        content.gsub!(<<YAML, <<YAML)
          - "3.2"
YAML
          - "3.2"
          - "3.3"
YAML
      end
    end

    only_if "ls #{workflow_file}"
  end
end
