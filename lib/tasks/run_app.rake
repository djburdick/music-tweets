require 'open-uri'
require 'aws-sdk-core'
require 'aws-sdk-kinesis'

APP_DIR = File.expand_path('../../app', __dir__)

JAR_DIR = File.join(APP_DIR, 'jars')
directory JAR_DIR

BIN_DIR = File.expand_path('../../bin', __dir__)

def get_maven_jar_info(group_id, artifact_id, version)
  jar_name = "#{artifact_id}-#{version}.jar"
  jar_url = "http://repo1.maven.org/maven2/#{group_id.gsub(/\./, '/')}/#{artifact_id}/#{version}/#{jar_name}"
  local_jar_file = File.join(JAR_DIR, jar_name)
  [jar_name, jar_url, local_jar_file]
end

def download_maven_jar(group_id, artifact_id, version)
  jar_name, jar_url, local_jar_file = get_maven_jar_info(group_id, artifact_id, version)
  open(jar_url) do |remote_jar|
    open(local_jar_file, 'w') do |local_jar|
      IO.copy_stream(remote_jar, local_jar)
    end
  end
end

MAVEN_PACKAGES = [
  # (group id, artifact id, version),
    ['com.amazonaws', 'amazon-kinesis-client', '1.7.6'],
    ['com.amazonaws', 'aws-java-sdk-dynamodb', '1.11.151'],
    ['com.amazonaws', 'aws-java-sdk-s3', '1.11.151'],
    ['com.amazonaws', 'aws-java-sdk-kms', '1.11.151'],
    ['com.amazonaws', 'aws-java-sdk-core', '1.11.151'],
    ['commons-logging', 'commons-logging', '1.1.3'],
    ['org.apache.httpcomponents', 'httpclient', '4.5.2'],
    ['org.apache.httpcomponents', 'httpcore', '4.4.4'],
    ['commons-codec', 'commons-codec', '1.9'],
    ['com.fasterxml.jackson.core', 'jackson-databind', '2.6.6'],
    ['com.fasterxml.jackson.core', 'jackson-annotations', '2.6.0'],
    ['com.fasterxml.jackson.core', 'jackson-core', '2.6.6'],
    ['com.fasterxml.jackson.dataformat', 'jackson-dataformat-cbor', '2.6.6'],
    ['joda-time', 'joda-time', '2.8.1'],
    ['com.amazonaws', 'aws-java-sdk-kinesis', '1.11.151'],
    ['com.amazonaws', 'aws-java-sdk-cloudwatch', '1.11.151'],
    ['com.google.guava', 'guava', '18.0'],
    ['com.google.protobuf', 'protobuf-java', '2.6.1'],
    ['commons-lang', 'commons-lang', '2.6']
]

task :download_jars => [JAR_DIR]

MAVEN_PACKAGES.each do |jar|
  _, _, local_jar_file = get_maven_jar_info(*jar)
  file local_jar_file do
    puts "Downloading '#{local_jar_file}' from maven..."
    download_maven_jar(*jar)
  end
  task :download_jars => local_jar_file
end

desc "Run KCL music producer to generate sample tweet data"
task :run_producer do |t|
  puts "Running the Kinesis muisc tweets producer..."
  commands = %W(
    #{APP_DIR}/music_tweets_producer.rb
  )
  sh *commands
end

desc "Run KCL sample processor"
task :run => :download_jars do |t|
  fail "JAVA_HOME environment variable not set."  unless ENV['JAVA_HOME']
  puts "Running the Kinesis sample processing application..."
  classpath = FileList["#{JAR_DIR}/*.jar"].join(':')
  classpath += ":#{APP_DIR}"

  ENV['PATH'] = "#{ENV['PATH']}:#{APP_DIR}:#{BIN_DIR}"
  commands = %W(
    #{ENV['JAVA_HOME']}/bin/java
    -classpath #{classpath}
    com.amazonaws.services.kinesis.multilang.MultiLangDaemon kinesis.properties
  )
  sh *commands
end
