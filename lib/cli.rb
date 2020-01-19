require "tmpdir"
require "yaml"

class Cli
  include FileUtils

  # @param recipe [String]
  # @param repo [String]
  # @param commit_message [String]
  # @param dry_run [Boolean]
  def initialize(recipe:, repo:, commit_message: , dry_run:)
    @recipe = recipe
    @repo = repo
    @commit_message = commit_message
    @dry_run = dry_run
  end

  def run
    run_with_single_repo(@repo)
  end

  private

  # @param repo [String]
  def run_with_single_repo(repo)
    run_itamae(repo)
  end

  # @param repo [String]
  def run_itamae(repo)
    Dir.mktmpdir("ci-config-itamae") do |tmp_dir|
      node = { "repo" => repo_fullpath(repo) }
      node_yaml = File.join(tmp_dir, "node.yml")

      File.open(node_yaml, "wb") do |f|
        f.write(node.to_yaml)
      end

      args = [
        @recipe,
        "--node-yaml=#{node_yaml}",
      ]
      args << "--dry-run" if @dry_run

      system("itamae local #{args.join(" ")}", exception: true)
    end
  end

  # @param repo [String]
  # @return [String]
  def repo_fullpath(repo)
    fullpath = `ghq list --full-path --exact #{repo}`.strip
    raise "NotFound: '#{repo}'" if fullpath.empty?
    fullpath
  end
end
