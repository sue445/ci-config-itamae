file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    content.gsub!(/^      - name: Setup Code Climate Test Reporter\n(.+?)continue-on-error: (.+?)\n/m) do
      [
        "      - name: Setup Code Climate Test Reporter\n",
        $1,
        "continue-on-error: true\n"
      ].join
    end

    content.gsub!(/^      - name: Teardown Code Climate Test Reporter\n(.+?)continue-on-error: (.+?)\n/m) do
      [
        "      - name: Teardown Code Climate Test Reporter\n",
        $1,
        "continue-on-error: true\n"
      ].join
    end
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
