file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    # using DockerHub ruby
    unless content.include?("- ruby:3.0")
      content.gsub!(<<YAML, <<YAML)
          - ruby:2.7
YAML
          - ruby:2.7
          - ruby:3.0
YAML
    end

    # using ruby/setup-ruby
    unless content.include?("- 3.0")
      content.gsub!(<<YAML, <<YAML)
          - 2.7
YAML
          - 2.7
          - 3.0
YAML
    end
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
