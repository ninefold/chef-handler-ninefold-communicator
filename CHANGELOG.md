
## 0.9.2 (Jun 18, 2014)

* Stop reporting successful runs - Chef already does that!

## 0.8.9 (Jun 10, 2014)

* Add tags to record overall state of the node
  - Running : chef-client is running (actually handled externally)
  - Error   : last run failed
  - Success : last run succeeded

## 0.7.0 (Apr 2, 2014)

* Remove timestamps from log snippet so that logstash doesn't
  split our lines up in the deployment log

## 0.6.0 (Apr 1, 2014)

* Improve formatting, add debugging and highlight optional

## 0.5.0 (Mar 25, 2014)

* Emit formatted\_exception for marker

## 0.4.0 (Mar 25, 2014)

* Add a 'marker' for exceptions to report via nagios scripts

## 0.3.0 (Mar 24, 2014)

* Emit checkpointed tags with formatting for better customer
  communication through portal deployments

## 0.2.0 (Mar 19, 2014)

* Alter to use new tag approach to log results
* Stub for testing approach - no meaningful data logged yet

## 0.1.0 (Dec 6, 2013)

* Initial creation of gem framework

