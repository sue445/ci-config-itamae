file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    # using DockerHub ruby
    unless content.include?("- ruby:3.1")
      content.gsub!(<<YAML, <<YAML)
          - ruby:3.0
YAML
          - ruby:3.0
          - ruby:3.1
YAML
    end

    # using ruby/setup-ruby
    unless content.include?('- "3.1"')
      content.gsub!(<<YAML, <<YAML)
          - "3.0"
YAML
          - "3.0"
          - "3.1"
YAML
    end
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
