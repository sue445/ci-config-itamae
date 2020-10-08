%w(test build go-mod-tidy-pr).each do |name|
  file "#{node[:repo]}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(%r{uses: homoluctus/slatify@.+}, "uses: lazy-actions/slatify@master")
    end

    only_if "ls #{node[:repo]}/.github/workflows/#{name}.yml"
  end
end
