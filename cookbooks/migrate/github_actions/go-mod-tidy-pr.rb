template "#{node[:repo]}/.github/workflows/go-mod-tidy-pr.yml" do
  source "templates/go-mod-tidy-pr.yml.erb"

  only_if "ls #{node[:repo]}/.github/workflows/go-mod-tidy-pr.yml"
end
