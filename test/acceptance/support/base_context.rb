require File.expand_path("../isolated_environment", __FILE__)
require File.expand_path("../output", __FILE__)
require File.expand_path("../virtualbox", __FILE__)

shared_context "acceptance" do
  # Setup variables for the loggers of this test. These can be used to
  # create more verbose logs for tests which can be useful in the case
  # that a test fails.
  let(:logger_name) { "logger" }
  let(:logger) { Log4r::Logger.new("acceptance::#{logger_name}") }

  # This is the global configuration given by the acceptance test
  # configurations.
  let(:config) { $acceptance_options }

  # Setup the environment so that we have an isolated area
  # to run Vagrant. We do some configuration here as well in order
  # to replace "vagrant" with the proper path to Vagrant as well
  # as tell the isolated environment about custom environmental
  # variables to pass in.
  let!(:environment) do
    apps = { "vagrant" => config.vagrant_path }
    Acceptance::IsolatedEnvironment.new(apps, config.env)
  end

  before(:each) do
    # Wait for VBoxSVC to disappear, since each test requires its
    # own isolated VirtualBox process.
    Acceptance::VirtualBox.wait_for_vboxsvc
  end

  after(:each) do
    environment.close
  end

  # Executes the given command in the context of the isolated environment.
  #
  # @return [Object]
  def execute(*args, &block)
    environment.execute(*args, &block)
  end

  # Returns an output matcher for the given text.
  #
  # @return [Acceptance::Output]
  def output(text)
    Acceptance::Output.new(text)
  end

  # This method is an assertion helper for asserting that a process
  # succeeds. It is a wrapper around `execute` that asserts that the
  # exit status was successful.
  def assert_execute(*args, &block)
    result = execute(*args, &block)
    assert(result.success?, "expected '#{args.join(" ")}' to succeed")
    result
  end
end
