file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    # Update jobs.test.runs-on
    content.gsub!(<<-YAML, <<-YAML)
jobs:
  test:
    runs-on: ${{ matrix.runner }}

    strategy:
YAML
jobs:
  test:
    runs-on: ubuntu-latest

    container: ${{ matrix.ruby }}

    strategy:
YAML

    # Update jobs.test.strategy.matrix.ruby
    content.gsub!(/- (\d+)\.(\d+)\.(\d+)$/) { "- ruby:#{$1}.#{$2}" }
    content.gsub!("2.8.0-dev", "rubylang/ruby:master-nightly-bionic")

    # Update jobs.test.strategy.matrix.include
    content.gsub!(/^        include:\n.+?\n\n/m, <<-YAML)
        include:
          - ruby: rubylang/ruby:master-nightly-bionic
            allow_failures: "true"
    YAML

    # Remove setup-rbenv
    content.gsub!(<<-YAML, "")
      - name: Set up rbenv
        uses: masa-iwasaki/setup-rbenv@1.1.0

      - name: Cache RBENV_ROOT
        uses: actions/cache@v1
        id: cache_rbenv
        with:
          path: ~/.rbenv/versions
          key: v1-rbenv-${{ runner.os }}-${{ matrix.ruby }}
        if: "!endsWith(matrix.ruby, '-dev')"

      - name: Reinstall libssl-dev
        run: |
          set -xe
          sudo apt-get remove -y libssl-dev
          sudo apt-get install -y libssl-dev=1.0.2g-1ubuntu4.15
        if: matrix.runner == 'ubuntu-16.04'

      - name: Install Ruby
        run: |
          set -xe
          eval "$(rbenv init -)"
          rbenv install -s $RBENV_VERSION
          gem install bundler --no-document -v 1.17.3 || true
        env:
          RBENV_VERSION: ${{ matrix.ruby }}
        continue-on-error: ${{ endsWith(matrix.ruby, '-dev') }}

    YAML

    content.gsub!(<<-YAML, <<-YAML)
          set -xe
          eval "$(rbenv init -)"
    YAML
          set -xe
    YAML

    # Update continue-on-error:
    content.gsub!("continue-on-error: ${{ endsWith(matrix.ruby, '-dev') }}", "continue-on-error: ${{ matrix.allow_failures == 'true' }}")

    # Update Code Climate Test Reporter
    content.gsub!(<<-YAML, <<-YAML)
      - name: Setup Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: before-build
    YAML
      - name: Setup Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: before-build
        if: matrix.ruby >= 'ruby:2.4'
    YAML

    content.gsub!(<<-YAML, <<-YAML)
      - name: Teardown Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: after-build
        if: always()
    YAML
      - name: Teardown Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: after-build
        if: matrix.ruby >= 'ruby:2.4' && always()
    YAML
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
