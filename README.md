# music-tweets

## Description
Looks at a stream of tweets and counts artist/band popularity in real-time

## Setup
1. Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables from your AWS account
2. Set AWS_REGION environment variable # likely it's "us-east-1"
3. bundle install
4. Install JDK (java --version to see if you have it)
5. Set JAVA_HOME env var (mine is like /Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home) 
6. Install Cassandra
  - `pip install cql`
  - `pip install cassandra-driver --ignore-installed six` # I had an issue with six and OS X Sierra
  - `brew install cassandra`
  - I had to downgrade from Java 9 to Java 8 because of a compatability issue with Cassandra

## Datasets
- Artist data: https://labrosa.ee.columbia.edu/millionsong/pages/getting-dataset
