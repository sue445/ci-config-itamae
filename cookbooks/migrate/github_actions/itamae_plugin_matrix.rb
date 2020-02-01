file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    content.gsub!(/^        image:\n.+?\n\n/m) do
<<-YAML
        image:
          - centos:7
          - centos:8
          - debian:jessie
          - debian:stretch
          - debian:buster
          - amazonlinux:2

YAML
    end
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
