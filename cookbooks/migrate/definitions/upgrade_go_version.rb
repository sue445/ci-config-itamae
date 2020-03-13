define :upgrade_go_version do
  version = params[:name]

  %w(test build release).each do |name|
    file "#{node[:repo]}/.github/workflows/#{name}.yml" do
      action :edit

      block do |content|
        puts "name=#{name}, version=#{version}"
        content.gsub!(/go-version:\s+[\d.]+\s*$/, "go-version: #{version}")
      end

      only_if "ls #{node[:repo]}/.github/workflows/#{name}.yml"
    end
  end

  file "#{node[:repo]}/go.mod" do
    action :edit

    block do |content|
      content.gsub!(/^go [\d.]+$/, "go #{version}")
    end

    only_if "ls #{node[:repo]}/go.mod"
  end

  file "#{node[:repo]}/.circleci/config.yml" do
    action :edit

    block do |content|
      content.gsub!(%r{- image: circleci/golang:[\d.]+}, "- image: circleci/golang:#{version}")
    end

    only_if "ls #{node[:repo]}/.circleci/config.yml"
  end
end

