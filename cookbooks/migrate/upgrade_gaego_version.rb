include_recipe "./definitions/upgrade_go_version"

upgrade_go_version "1.13"

file "#{node[:repo]}/app.yaml" do
  action :edit

  block do |content|
    # c.f. https://cloud.google.com/appengine/docs/standard/go/go-differences?hl=ja
    content.gsub!(/^runtime: go\d+$/, "runtime: go113")
  end

  only_if "ls #{node[:repo]}/go.mod"
end
