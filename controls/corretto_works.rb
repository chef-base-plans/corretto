title 'Tests to confirm corretto8 works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'corretto8')

control 'core-plans-corretto8-works' do
  impact 1.0
  title 'Ensure corretto8 works as expected'
  desc '
  Verify corretto8 by ensuring that
  (1) its installation directory exists 
  (2) all binaries, with exception of jconsole, orbd, and
      java-rmi.cgi, return expected output. The exceptions are ignored here 
      since they are not easily tested: for example jconsole needs a jvm to connect to; orbd
      starts a daemon, etc
  '
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end
  
  plan_pkg_version = plan_installation_directory.stdout.split("/")[5]
  fullsuite = {
    "jaotc" => {
      command_suffix: "",
    },
    "jar" => {
      command_suffix: "",
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jarsigner" => {},
    "java" => {
      io: "stderr",
    },
    "javac" => {
    },
    "javadoc" => {},
    "javap" => {},
    "jcmd" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    # ignore because we need a JVM to connect to...
    # "jconsole" => {},
    "jdb" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jdeprscan" => {},
    "jdeps" => {},
    "jfr" => {},
    "jhsdb" => {},
    "jimage" => {},
    "jinfo" => {
      io: "stderr",
      command_output_pattern: /jinfo \[option\] <pid>/,
    },
    "jjs" => {
      io: "stderr",
      command_output_pattern: /jjs \[<options>\] <files> \[-- <arguments>\]/,
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jlink" => {},
    "jmap" => {
      io: "stderr",
      command_output_pattern: /jmap \[option\] <pid>/,
    },
    "jmod" => {},
    "jps" => {
      io: "stderr",
    },
    "jrunscript" => {
      io: "stderr",
    },
    "jshell" => {},
    "jstack" => {
      io: "stderr",
      command_output_pattern: /jstack \[-l\] <pid>/,
    },
    "jstat" => {},
    "jstatd" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "keytool" => {
      io: "stderr",
      command_output_pattern: /Key and Certificate Management Tool/,
    },
    "pack200" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmic" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmid" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmiregistry" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "serialver" => {
      io: "stderr",
      command_suffix: "",
      exit_pattern: /^[^0]{1}\d*$/,
      command_output_pattern: /use: serialver \[-classpath classpath\]/,
    },
    "unpack200" => {
      exit_pattern: /^[^0]{1}\d*$/,
      io: "stderr",
    },
  } 
  
  # Use the following to pull out a subset of the above and test progressiveluy
  subset = fullsuite.select { |key, value| key.to_s.match(/^[j]a.*$/) }

  # over-ride the defaults below with (command_suffix:, io:, etc)
  subset.each do |binary_name, value|
    # set default values if each binary doesn't define an over-ride
    command_prefix = value[:command_prefix] || ""
    command_suffix = value[:command_suffix] || "-help"
    command_output_pattern = value[:command_output_pattern] || /usage:(\s+|.*)#{binary_name}/i 
    exit_pattern = value[:exit_pattern] || /^[0]$/ # use /^[^0]{1}\d*$/ for non-zero exit status
    io = value[:io] || "stdout"
  
    # verify output
    command_full_path = File.join(plan_installation_directory.stdout.strip, "bin", binary_name)
    describe bash("#{command_prefix} #{command_full_path} #{command_suffix}") do
      its('exit_status') { should cmp exit_pattern }
      its(io) { should match command_output_pattern }
    end
  end
end