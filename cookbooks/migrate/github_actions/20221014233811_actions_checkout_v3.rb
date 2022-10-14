file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
