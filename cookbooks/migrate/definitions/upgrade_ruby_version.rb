require "open-uri"

define :upgrade_ruby_version do
  version = params[:name]

  # Fetch RUBY_PATCHLEVEL from https://github.com/ruby/ruby/blob/master/version.h
  git_tag = "v" + version.gsub(".", "_")
  version_h = URI.open("https://raw.githubusercontent.com/ruby/ruby/#{git_tag}/version.h").read
  ruby_patchlevel = /^#define\s+RUBY_PATCHLEVEL\s+(\d+)/.match(version_h).to_a[1]
  version_with_patch_level = "#{version}p#{ruby_patchlevel}"

  v = version.split(".")
  version_with_minor_version = "#{v[0]}.#{v[1]}"

  file "#{node[:repo]}/.circleci/config.yml" do
    action :edit

    block do |content|
      content.gsub!(%r{- image: circleci/ruby:[\d.]+}, "- image: circleci/ruby:#{version}")
    end

    only_if "ls #{node[:repo]}/.circleci/config.yml"
  end

  file "#{node[:repo]}/wercker.yml" do
    action :edit

    block do |content|
      content.gsub!(%r{^box: ruby:([\d.]+)}, "box: ruby:#{version}")
    end

    only_if "ls #{node[:repo]}/wercker.yml"
  end

  file "#{node[:repo]}/.ruby-version" do
    action :edit

    block do |content|
      content.gsub!(/[\d.]+/, version)
    end

    only_if "ls #{node[:repo]}/.ruby-version"
  end

  file "#{node[:repo]}/Gemfile" do
    action :edit

    block do |content|
      content.gsub!(/^ruby "([\d.]+)"$/, %Q{ruby "#{version}"})
    end

    only_if "ls #{node[:repo]}/Gemfile"
  end

  file "#{node[:repo]}/Gemfile.lock" do
    action :edit

    block do |content|
      content.gsub!(/^RUBY VERSION\n   ruby ([\d.p]+)\n/m) do
        <<~GEMFILE_LOCK
        RUBY VERSION
           ruby #{version_with_patch_level}
        GEMFILE_LOCK
      end
    end

    only_if "ls #{node[:repo]}/Gemfile.lock"
  end

  file "#{node[:repo]}/.rubocop.yml" do
    action :edit

    block do |content|
      content.gsub!(/TargetRubyVersion: ([\d.]+)/, "TargetRubyVersion: #{version_with_minor_version}")
    end

    only_if "ls #{node[:repo]}/.rubocop.yml"
  end
end

